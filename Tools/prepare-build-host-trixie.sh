#!/bin/bash
#
# prepare-build-host.sh - v4 (2026-09-15)
#
# Prepare a MINIMAL, HEADLESS Debian 13 "trixie" host (accessed over SSH) to
# run MX's build-iso, e.g. for the mxlxqt flavour:
#
#   sudo ./build-iso --user-default defaults-lxqt
#
# It installs only what build-iso actually calls on the host: the program list
# below is taken from the require_programs() calls inside build-iso itself,
# not guessed. No desktop, no X, no recommends.
#
# NEW IN v2: package caching.
#   * Pre-creates build-iso's own caches under Remaster/ and reports them:
#       Remaster/deb-cache/archives  -> bind-mounted on the chroot's
#                                       /var/cache/apt/archives, so every .deb
#                                       already downloaded is reused
#       Remaster/cache               -> debootstrap/chroot stage snapshots
#                                       (CACHE="debootstrap,chroot", 7 days)
#   * Optional apt-cacher-ng proxy (--proxy), which also caches the host-side
#     debootstrap and survives a wiped Remaster.
#
# NEW IN v3: gnupg. build-iso has SIGN_FILES="true" in Input/defaults-system
#   and signs the ISO with "gpg --detach-sign". A minimal Debian ships no gpg
#   at all, and build-iso runs as root, so the key has to be in ROOT's keyring
#   (/root/.gnupg): a key created by your normal user is invisible to it.
#   This script installs gnupg, checks for a root secret key, and offers both
#   ways out: --no-sign (disable signing) or --sign-key (create one).
#
# NEW IN v4: the helper tools used around the build - unzip and bsdtar to
#   unpack the tree preserving its 242 symlinks, git to track the flavour, tmux
#   to survive SSH. They are checked separately from build-iso's own
#   requirements: missing ones warn, they do not abort.
#
# USAGE:
#   sudo ./prepare-build-host.sh                  # install + verify + caches
#   sudo ./prepare-build-host.sh --check          # verify only, install nothing
#   sudo ./prepare-build-host.sh --remaster /srv/remaster
#   sudo ./prepare-build-host.sh --proxy          # local apt-cacher-ng
#   sudo ./prepare-build-host.sh --proxy=http://10.0.0.5:3142
#                                                 # existing proxy on the LAN
#   sudo ./prepare-build-host.sh --no-sign        # SIGN_FILES="false"
#   sudo ./prepare-build-host.sh --sign-key="MX builder <me@example.org>"
#                                                 # root signing key, no passphrase
#

set -Eeuo pipefail

CHECK_ONLY=false
REMASTER_TARGET=""
PROXY_MODE=false
PROXY_URL=""
NO_SIGN=false
SIGN_KEY=""
BUILD_DIR="$PWD"

for arg in "$@"; do
    case "$arg" in
        --check)      CHECK_ONLY=true ;;
        --remaster=*) REMASTER_TARGET="${arg#*=}" ;;
        --proxy)      PROXY_MODE=true ;;
        --proxy=*)    PROXY_MODE=true; PROXY_URL="${arg#*=}" ;;
        --no-sign)    NO_SIGN=true ;;
        --sign-key=*) SIGN_KEY="${arg#*=}" ;;
        --help|-h)    sed -n '2,30p' "$0"; exit 0 ;;
        /*)           REMASTER_TARGET="$arg" ;;
        *)            ;;
    esac
done

log()  { printf '\n== %s\n' "$*"; }
ok()   { printf '   [ok]   %s\n' "$*"; }
bad()  { printf '   [MISS] %s\n' "$*"; }
warn() { printf '   [warn] %s\n' "$*"; }
die()  { printf '\nERROR: %s\n' "$*" >&2; exit 1; }
human() { du -sh "$1" 2>/dev/null | cut -f1 || echo "0"; }

[ "$EUID" -eq 0 ] || die "Run as root (sudo)."

# ---------------------------------------------------------------------------
# 1. Host sanity
# ---------------------------------------------------------------------------
log "Host"
if [ -r /etc/os-release ]; then
    . /etc/os-release
    printf '   %s (kernel %s, %s)\n' "${PRETTY_NAME:-unknown}" "$(uname -r)" "$(dpkg --print-architecture)"
    [ "${VERSION_CODENAME:-}" = trixie ] || warn "Expected Debian 13 trixie, found '${VERSION_CODENAME:-?}'."
fi
[ "$(dpkg --print-architecture)" = amd64 ] || warn "The mxlxqt flavour targets amd64."

# build-iso chroots and bind-mounts /proc, /sys and /dev: that does not work
# in an unprivileged container.
if command -v systemd-detect-virt >/dev/null 2>&1; then
    virt=$(systemd-detect-virt --container 2>/dev/null || true)
    case "$virt" in
        none|"") ;;
        lxc|lxc-libvirt|docker|podman|systemd-nspawn)
            warn "Running inside a $virt container: chroot + bind mounts usually fail here."
            warn "Use a VM or bare metal, or a fully privileged container." ;;
    esac
fi

# ---------------------------------------------------------------------------
# 2. Packages
# ---------------------------------------------------------------------------
PACKAGES=(
    debootstrap          # builds the base chroot
    squashfs-tools       # mksquashfs
    xorriso              # MAKE_ISO_PROGS, and grub-mkrescue needs it
    syslinux-utils       # isohybrid
    grub2-common         # grub-mkrescue
    grub-pc-bin          # BIOS modules for grub-mkrescue
    grub-efi-amd64-bin   # UEFI modules for grub-mkrescue
    mtools               # mformat/mcopy, used to build the EFI image
    dosfstools           # mkfs.vfat, used by Tools/make-efi-img
    zsync                # zsync/zsyncmake
    expect               # unbuffer
    binutils             # strings
    procps               # pkill
    rsync                # file collection
    sudo
    ca-certificates      # https apt sources inside the chroot
    gnupg                # gpg --detach-sign of the finished ISO (SIGN_FILES)
    pigz                 # GZIP_PROGS (falls back to gzip)
    xz-utils lz4 zstd    # squashfs compression choices
    bc
    git                  # to clone/update the build tree
    unzip                # unpacks the delivered zip, symlinks included
    libarchive-tools     # bsdtar: same, with --strip-components
    tmux                 # see the SSH note at the end
)
# Only when a local caching proxy was requested.
[ "$PROXY_MODE" = true ] && [ -z "$PROXY_URL" ] && PACKAGES+=(apt-cacher-ng)

if $CHECK_ONLY; then
    log "Skipping installation (--check)"
else
    log "Installing host build dependencies"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends "${PACKAGES[@]}"
fi

# ---------------------------------------------------------------------------
# 3. Verify exactly what build-iso requires
# ---------------------------------------------------------------------------
# From build-iso: require_programs chroot isohybrid mksquashfs md5sum sudo tee
# zsync pkill expand strings iconv unbuffer / debootstrap apt-get dpkg /
# grub-mkrescue xorriso unshare mount umount find mktemp
REQUIRED_PROGS=(
    chroot isohybrid mksquashfs md5sum sudo tee zsync pkill expand strings
    iconv unbuffer debootstrap apt-get dpkg grub-mkrescue xorriso unshare
    mount umount find mktemp mkfs.vfat mcopy mformat gpg
)

log "Required programs"
missing=()
for p in "${REQUIRED_PROGS[@]}"; do
    if PATH="/usr/sbin:/sbin:$PATH" command -v "$p" >/dev/null 2>&1; then
        ok "$p"
    else
        bad "$p"
        missing+=("$p")
    fi
done

# ---------------------------------------------------------------------------
# 3b. Helper tools (not required by build-iso: missing ones only warn)
# ---------------------------------------------------------------------------
log "Helper tools"
for pair in "unzip:unzip" "bsdtar:libarchive-tools" "git:git" "tmux:tmux"; do
    prog=${pair%%:*} pkg=${pair##*:}
    if command -v "$prog" >/dev/null 2>&1; then
        ok "$prog"
    else
        warn "$prog missing - apt-get install $pkg"
    fi
done
# Both unpack the tree preserving symlinks; 7z does NOT - it turns them into
# regular files holding the target path, silently breaking the initrd.
printf '   unpack with: unzip <file>.zip\n'
printf '                bsdtar -xf <file>.zip --strip-components=1   # into an existing repo\n'

# ---------------------------------------------------------------------------
# 4. Work directory and build-iso's own caches
# ---------------------------------------------------------------------------
log "Work directory and package cache"
REMASTER=""
if [ -x "$BUILD_DIR/build-iso" ]; then
    if [ -n "$REMASTER_TARGET" ]; then
        mkdir -p "$REMASTER_TARGET"
        if [ -e "$BUILD_DIR/Remaster" ] && [ ! -L "$BUILD_DIR/Remaster" ]; then
            warn "$BUILD_DIR/Remaster already exists and is not a symlink; left untouched."
        else
            ln -sfn "$REMASTER_TARGET" "$BUILD_DIR/Remaster"
            ok "Remaster -> $REMASTER_TARGET"
        fi
    elif [ ! -e "$BUILD_DIR/Remaster" ]; then
        mkdir -p "$BUILD_DIR/Remaster"
        ok "created $BUILD_DIR/Remaster"
        warn "It will hold several GB. To move it: ln -s /big/disk/remaster Remaster"
    else
        ok "$BUILD_DIR/Remaster exists"
    fi
    REMASTER=$(readlink -f "$BUILD_DIR/Remaster")

    # build-iso bind-mounts deb-cache/archives onto the chroot's apt archive
    # directory, so .debs survive from one build to the next. Creating it here
    # means the very first build already writes into a persistent cache.
    mkdir -p "$REMASTER/deb-cache/archives" "$REMASTER/cache" "$REMASTER/iso-files"
    ok "deb cache  : $REMASTER/deb-cache/archives ($(human "$REMASTER/deb-cache/archives"), \
$(find "$REMASTER/deb-cache/archives" -maxdepth 1 -name '*.deb' 2>/dev/null | wc -l) debs)"
    ok "stage cache: $REMASTER/cache ($(human "$REMASTER/cache"))"
    printf '   note   : stage snapshots (debootstrap, chroot) expire after\n'
    printf '            CACHE_EXPIRE days - both set in Input/defaults-system\n'

    avail_kb=$(df -Pk "$REMASTER" | awk 'NR==2{print $4}')
    avail_gb=$(( avail_kb / 1024 / 1024 ))
    if [ "$avail_gb" -lt 30 ]; then
        warn "only ${avail_gb} GB free on $REMASTER - a full build wants 30-40 GB"
    else
        ok "${avail_gb} GB free on $REMASTER"
    fi
else
    warn "build-iso not found in $BUILD_DIR - run this script from the build tree,"
    warn "or pass the Remaster path with --remaster /path"
fi

# ---------------------------------------------------------------------------
# 5. Optional caching proxy
# ---------------------------------------------------------------------------
if $PROXY_MODE; then
    log "Caching proxy"
    if [ -z "$PROXY_URL" ]; then
        PROXY_URL="http://127.0.0.1:3142"
        if ! $CHECK_ONLY; then
            systemctl enable --now apt-cacher-ng >/dev/null 2>&1 || \
                warn "could not start apt-cacher-ng via systemd; start it manually"
        fi
        ok "local apt-cacher-ng on $PROXY_URL"
        ok "cache dir: /var/cache/apt-cacher-ng ($(human /var/cache/apt-cacher-ng))"
    else
        ok "using existing proxy $PROXY_URL"
    fi

    if ! $CHECK_ONLY; then
        # Host side: speeds up debootstrap, which runs outside the chroot.
        printf 'Acquire::http::Proxy "%s";\n' "$PROXY_URL" > /etc/apt/apt.conf.d/01proxy-build-iso
        ok "host apt -> /etc/apt/apt.conf.d/01proxy-build-iso"
        printf '   note   : delete that file if you remove the proxy, or apt will fail\n'
    fi

    # The chroot inherits the environment from build-iso, so exporting the
    # proxy on the command line covers apt inside the chroot as well.
    cat <<EOF

   Run the build with the proxy exported:
     sudo http_proxy=$PROXY_URL ./build-iso --user-default defaults-lxqt

   Do NOT put the proxy in Template/mxlxqt/squashfs/etc/apt/apt.conf: that
   file is copied into the squashfs and would ship your build-host proxy to
   everyone who installs the ISO.
EOF
fi

# ---------------------------------------------------------------------------
# 6. ISO signing
# ---------------------------------------------------------------------------
# build-iso runs as root, so "gpg --detach-sign" reads /root/.gnupg. A key in
# your own ~/.gnupg is NOT used, which is why "gpg --list-secret-keys" can look
# empty even right after installing gnupg.
log "ISO signing"
DEFAULTS_LOCAL="$BUILD_DIR/Input/defaults-local"

if $NO_SIGN; then
    if $CHECK_ONLY; then
        warn "--check: would set SIGN_FILES=\"false\" in Input/defaults-local"
    elif [ -d "$BUILD_DIR/Input" ]; then
        if grep -q '^SIGN_FILES=' "$DEFAULTS_LOCAL" 2>/dev/null; then
            sed -i 's|^SIGN_FILES=.*|SIGN_FILES="false"|' "$DEFAULTS_LOCAL"
        else
            printf 'SIGN_FILES="false"\n' >> "$DEFAULTS_LOCAL"
        fi
        ok "signing disabled in $DEFAULTS_LOCAL (read last, overrides --user-default)"
    else
        warn "Input/ not found here; add SIGN_FILES=\"false\" to Input/defaults-local yourself"
    fi
elif [ -n "$SIGN_KEY" ]; then
    if $CHECK_ONLY; then
        warn "--check: would create a root signing key for $SIGN_KEY"
    elif gpg --list-secret-keys --with-colons 2>/dev/null | grep -q '^sec'; then
        ok "root already has a secret key; leaving it alone"
    else
        # Unattended build host: no passphrase, otherwise every build stops to
        # ask for it. The key only signs public ISOs.
        gpg --batch --pinentry-mode loopback --passphrase '' \
            --quick-generate-key "$SIGN_KEY" default default never
        ok "created a root signing key for $SIGN_KEY"
        printf '   export it with: gpg --armor --export "%s" > builder.pub\n' "$SIGN_KEY"
    fi
else
    if gpg --list-secret-keys --with-colons 2>/dev/null | grep -q '^sec'; then
        ok "root has a secret key: the ISO will be signed"
    else
        warn "root has NO secret key, so build-iso's signing step will fail"
        warn "(the ISO itself is still produced; only the .sig is missing)"
        printf '   fix it either way:\n'
        printf '     sudo %s --no-sign\n' "$(basename "$0")"
        printf '     sudo %s --sign-key="Your Name <you@example.org>"\n' "$(basename "$0")"
    fi
fi

# ---------------------------------------------------------------------------
# 6. Result
# ---------------------------------------------------------------------------
echo
if [ "${#missing[@]}" -gt 0 ]; then
    die "Still missing: ${missing[*]}
Install them and run this script again with --check."
fi

cat <<'EOF'
============================================================================
Host ready.

Build (from the build tree, as root):
  sudo ./build-iso --user-default defaults-lxqt        # systemd
  sudo ./build-iso --user-default defaults-lxqt-sysv   # sysVinit

Over SSH, always run it inside tmux: a build takes hours and a dropped
connection would kill it mid-chroot, leaving bind mounts behind.
  tmux new -s iso        # start
  Ctrl+b d               # detach
  tmux attach -t iso     # come back

Signing: build-iso signs the ISO as root. If the .sig is missing, root has no
key - see the "ISO signing" section above. A missing signature never
invalidates the ISO itself.

Caching: leave Remaster/deb-cache and Remaster/cache alone between builds -
they are what makes the second build fast. Clearing Remaster/iso-files and
Output/ is safe; clearing deb-cache means downloading everything again.

If a build is interrupted, check for leftovers before retrying:
  mount | grep -E 'Remaster|chroot'
and unmount them in reverse order.
============================================================================
EOF
