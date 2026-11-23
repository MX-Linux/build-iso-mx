#!/bin/bash
#
# mk-efi-img.sh - build the El Torito EFI image (efi.img) for an MX live ISO.
# No root needed: the FAT image is made with mkfs.fat and filled with mtools.
#
# Layout (as in MX's efi.img):
#   EFI/boot/bootx64.efi    secureboot=yes: shim (shimx64.efi.signed)
#                           secureboot=no:  GRUB, grub-mkstandalone from --x64-dir
#   EFI/boot/grubx64.efi    secureboot=yes: Debian's signed GRUB for CDs
#                           (gcdx64.efi.signed, mostly monolithic)
#   EFI/boot/mmx64.efi      secureboot=yes: MOK manager (mmx64.efi.signed)
#   EFI/boot/bootia32.efi   --ia32-efi FILE: this file (e.g. Debian's unsigned
#                           gcdia32.efi), or GRUB grub-mkstandalone from
#                           --ia32-dir (always unsigned; only when given)
#   boot/grub/grub.cfg      search the ISO by /.disk/info (hint: the boot device
#                           from $fw_path, Debian signed GRUB, or $cmdpath, other
#                           builds), then "source" its /boot/grub/grub.cfg
#                           (--cfg FILE to replace).
#                           "source", not "configfile": Debian's signed GRUB
#                           takes its prefix from this FAT image and runs this
#                           file; with configfile the MX menu would be nested
#                           and Esc would leave it to the grub> prompt.
#
# Usage:
#   mk-efi-img.sh -o efi.img [--secureboot yes|no] [--x64-dir DIR]
#                 [--ia32-dir DIR | --ia32-efi FILE]
#                 [--efi-src ROOT] [--cfg FILE] [--extra-kib N] [--label LABEL]
#
#   --x64-dir DIR    GRUB x86_64-efi module dir (for secureboot=no; also used to
#                    warn when the signed GRUB is another build than the modules)
#   --ia32-dir DIR   GRUB i386-efi module dir -> bootia32.efi (mkstandalone)
#   --ia32-efi FILE  ready bootia32.efi to put in (instead of --ia32-dir)
#   --efi-src ROOT   where usr/lib/shim and usr/lib/grub/x86_64-efi-signed are
#                    (default /; e.g. a dir with unpacked shim-signed and
#                    grub-efi-amd64-signed .debs)
#   --extra-kib N    free space added to the FAT image (default 1024)
#
# Reproducible: with SOURCE_DATE_EPOCH set, the same input files give a
# byte-identical efi.img (fixed volume id/serial, all FAT times = that
# epoch, UTC). Not with --ia32-dir/--secureboot no (mkstandalone stamps).
#
set -euo pipefail

ME=${0##*/}
OUT='' SB=yes X64='' IA32='' IA32EFI='' SRC='' CFG='' EXTRA=1024 LABEL=EFIBOOT

die()  { printf '%s: ERROR: %s\n' "$ME" "$*" >&2; exit 1; }
warn() { printf '%s: WARNING: %s\n' "$ME" "$*" >&2; }
usage() { sed -n '2,/^set -euo/p' "$0" | sed '$d; s/^# \{0,1\}//'; exit "${1:-0}"; }

while (($#)); do
    case $1 in
        -o) OUT=${2:?}; shift ;;
        --secureboot) SB=${2:?}; shift ;;
        --x64-dir) X64=${2:?}; shift ;;
        --ia32-dir) IA32=${2:?}; shift ;;
        --ia32-efi) IA32EFI=${2:?}; shift ;;
        --efi-src) SRC=${2%/}; shift ;;
        --cfg) CFG=${2:?}; shift ;;
        --extra-kib) EXTRA=${2:?}; shift ;;
        --label) LABEL=${2:?}; shift ;;
        -h|--help) usage 0 ;;
        *) die "unknown argument: $1" ;;
    esac
    shift
done
[[ -n $OUT ]] || usage 1
case $SB in yes|no) ;; *) die "--secureboot yes|no" ;; esac
[[ -n $IA32 && -n $IA32EFI ]] && die "use --ia32-dir or --ia32-efi, not both"
for t in mkfs.fat mmd mcopy; do command -v "$t" >/dev/null || die "$t not found (dosfstools / mtools)"; done

TMP=$(mktemp -d)
cleanup() { rm -rf -- "$TMP"; }
trap cleanup EXIT
st=$TMP/stage
mkdir -p "$st/EFI/boot" "$st/boot/grub"

if [[ -n $CFG ]]; then
    cp -- "$CFG" "$st/boot/grub/grub.cfg"
else
    cat > "$st/boot/grub/grub.cfg" <<'EOF'
# efi.img boot/grub/grub.cfg: find the live ISO on the boot device, then source its menu.
# Debian's signed GRUB sets $fw_path ($cmdpath stays empty); other GRUB builds set $cmdpath.
set efi_bootpath="$fw_path"
if [ -z "$efi_bootpath" ]; then set efi_bootpath="$cmdpath"; fi
if regexp --set=1:efi_bootdev '^\(([^)]+)\)' "$efi_bootpath"; then
    regexp --set=1:efi_bootdisk '^([^,]+)' "$efi_bootdev"
    search --no-floppy --set=root --file /.disk/info --hint="$efi_bootdisk" --hint="$efi_bootdev"
else
    search --no-floppy --set=root --file /.disk/info
fi
set prefix=($root)/boot/grub
source ($root)/boot/grub/grub.cfg
EOF
fi

# grub-mkstandalone: all modules in a memdisk (no version mix inside the image);
# its embedded grub.cfg is the same small search config
standalone() {
    local target=$1 dir=$2 out=$3
    [[ -f $dir/kernel.img && -f $dir/moddep.lst ]] || die "not a GRUB $target module dir: $dir"
    command -v grub-mkstandalone >/dev/null || die "grub-mkstandalone not found (grub-common)"
    grub-mkstandalone -O "$target" -d "$dir" -o "$out" --compress=xz \
        --locales= --themes= --fonts= \
        --modules="part_gpt part_msdos fat iso9660 search search_fs_file normal configfile regexp test echo" \
        "boot/grub/grub.cfg=$st/boot/grub/grub.cfg"
    echo "  ${out##*/}: grub-mkstandalone -O $target -d $dir ($(stat -c %s "$out") bytes)"
}

echo "Building $OUT (secureboot=$SB)"
if [[ $SB == yes ]]; then
    shim=$SRC/usr/lib/shim/shimx64.efi.signed
    mm=$SRC/usr/lib/shim/mmx64.efi.signed
    gcd=$SRC/usr/lib/grub/x86_64-efi-signed/gcdx64.efi.signed
    for f in "$shim" "$mm" "$gcd"; do
        [[ -f $f ]] || die "missing $f (packages shim-signed, grub-efi-amd64-signed; or --efi-src)"
    done
    cp -- "$shim" "$st/EFI/boot/bootx64.efi"
    cp -- "$gcd"  "$st/EFI/boot/grubx64.efi"
    cp -- "$mm"   "$st/EFI/boot/mmx64.efi"
    sbat() { strings -n 6 "$1" | grep -m1 -oE '^(shim|grub),[0-9]+,[^,]+,[^,]+,[^,]+' || true; }
    echo "  bootx64.efi: $shim  [$(sbat "$shim")]"
    echo "  grubx64.efi: $gcd  [$(sbat "$gcd")]"
    echo "  mmx64.efi:   $mm"
    # Without Secure Boot the signed GRUB also loads .mod files from
    # /boot/grub/x86_64-efi; they should be from the same GRUB build.
    if [[ -n $X64 && -f $SRC/usr/lib/grub/x86_64-efi/normal.mod && -f $X64/normal.mod ]]; then
        cmp -s "$SRC/usr/lib/grub/x86_64-efi/normal.mod" "$X64/normal.mod" \
            || warn "the ISO's x86_64-efi modules ($X64) are not the build of $SRC/usr/lib/grub (signed GRUB)"
    fi
else
    [[ -n $X64 ]] || die "--secureboot no needs --x64-dir"
    standalone x86_64-efi "$X64" "$st/EFI/boot/bootx64.efi"
fi
if [[ -n $IA32 ]]; then
    standalone i386-efi "$IA32" "$st/EFI/boot/bootia32.efi"
elif [[ -n $IA32EFI ]]; then
    [[ -f $IA32EFI ]] || die "missing $IA32EFI"
    cp -- "$IA32EFI" "$st/EFI/boot/bootia32.efi"
    echo "  bootia32.efi: $IA32EFI"
fi

# size: content + FAT overhead + extra, rounded up to whole MiB
kib=$(du -sk --apparent-size "$st" | cut -f1)
kib=$(( (kib + kib / 16 + 256 + EXTRA + 1023) / 1024 * 1024 ))
rm -f -- "$OUT"
export MTOOLS_SKIP_CHECK=1
if [[ -n ${SOURCE_DATE_EPOCH:-} ]]; then
    # FAT keeps local time: TZ=UTC so every maintainer gets the same bytes
    export TZ=UTC
    find "$st" -exec touch -h -d "@$SOURCE_DATE_EPOCH" {} +
    mkfs.fat --invariant -C -n "$LABEL" "$OUT" "$kib" >/dev/null
else
    mkfs.fat -C -n "$LABEL" "$OUT" "$kib" >/dev/null
fi
mcopy -s -m -i "$OUT" "$st/EFI" "$st/boot" ::/
echo "Built $OUT ($((kib / 1024)) MiB)"
