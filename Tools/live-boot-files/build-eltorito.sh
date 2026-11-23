#!/bin/bash
#
# build-eltorito.sh - build GRUB's BIOS El Torito boot image (eltorito.img)
#                     for an MX live ISO, from the GRUB installed on THIS system.
#
# eltorito.img = cdboot.img + GRUB core (kernel + embedded modules + prefix).
# Everything not embedded (linux.mod, gfxterm, ...) is loaded at boot time
# from $prefix/i386-pc on the ISO, i.e. boot/grub/i386-pc/*.mod.
#
# The core and the modules it loads later must come from the SAME GRUB build.
# So by default:
#   - the core is built from the host's /usr/lib/grub/i386-pc (grub-pc-bin)
#   - with -t ISO_TREE, the ISO tree's boot/grub/i386-pc/ module set is
#     replaced by the host's as well, and eltorito.img is written there.
#
# Profiles (default: full):
#   minimal   small module set, as used by MX-25.3 (mid Nov 2026) in
#             mx-iso-template's eltorito.img
#   extended  minimal + partition tables, configfile and normal mode embedded
#   full      (default) a "fully working GRUB" in the core: filesystems, RAID/LVM/LUKS,
#             decompressors, loaders (linux, multiboot, chain, ntldr),
#             video/gfx, script helpers. Needed when the live menu switches
#             into a FOUND system's grub.cfg (rescue.cfg "GRUB menus"):
#             after "set prefix=(found)/boot/grub" every insmod is served
#             from the found system (other GRUB build, or no i386-pc dir at
#             all) - unless the module is already resident in the core.
#             Modules missing in the host GRUB are skipped with a note.
#
# Usage:
#   build-eltorito.sh [-p full|extended|minimal] [-m "extra mods"] [-c early.cfg]
#                     [-t ISO_TREE | -o eltorito.img] [-d GRUB_I386PC_DIR | -T]
#   build-eltorito.sh -l IMAGE        # list modules/prefix/config in an image
#   build-eltorito.sh -L [-p PROFILE] [-d DIR] [-m "extra"]
#                                     # only print the profile's module list
#                                     # (modules missing in DIR dropped);
#                                     # mk-boot-files uses it for its cores
#
#   -t ISO_TREE  sync host modules into ISO_TREE/boot/grub/i386-pc/ and write
#                ISO_TREE/boot/grub/i386-pc/eltorito.img
#   -o FILE      only write the image (default ./eltorito.img); the modules
#                on the ISO must then match the GRUB used here
#   -d DIR       GRUB i386-pc directory (default /usr/lib/grub/i386-pc)
#   -T           use the module set from mx-iso-template instead of the host
#
set -euo pipefail

PROFILE=full
GRUB_DIR=/usr/lib/grub/i386-pc
USE_TEMPLATE=
EXTRA_MODS=
EARLY_CFG=
OUT=
ISO_TREE=
LIST=
TEMPLATE_TAR=/usr/lib/iso-template/iso-template.tar.gz
PREFIX=/boot/grub

# minimal: what mx-iso-template's eltorito.img contained in MX-25.3 (mid Nov 2026) (dependencies fshelp, extcmd,
# disk are added by grub-mkimage via moddep.lst).
MODS_MINIMAL="biosdisk iso9660 search search_fs_uuid search_fs_file search_label test loadenv"

# minimal plus:
#   part_msdos part_gpt  read the MBR/GPT partition tables of a hybrid ISO on
#                        a USB stick, so "search" also finds (hdX,msdos1)/(hdX,gptN)
#   configfile           "source" / "configfile" usable from the core
#   normal               normal mode embedded, does not depend on loading
#                        normal.mod (and its deps) from the medium first
#   echo                 messages from an early config
MODS_EXTENDED="$MODS_MINIMAL part_msdos part_gpt configfile normal echo"

# extended plus everything a foreign grub.cfg typically insmods.
MODS_FULL="$MODS_EXTENDED
    part_apple
    ext2 fat exfat ntfs ntfscomp btrfs xfs f2fs jfs reiserfs hfsplus udf squash4
    lvm mdraid09 mdraid1x raid5rec raid6rec diskfilter
    cryptodisk luks luks2 gcry_rijndael gcry_sha256 gcry_sha512
    gzio xzio lzopio zstd
    regexp probe cat ls help sleep keystatus true halt reboot minicmd loopback
    linux linux16 multiboot multiboot2 chain ntldr
    all_video video_bochs video_cirrus vbe vga
    gfxterm gfxterm_background gfxmenu font png jpeg tga gettext"

usage() { sed -n '2,/^set -euo/p' "$0" | sed '$d; s/^# \{0,1\}//'; exit "${1:-0}"; }

PRINT_MODS=
while getopts "p:d:Tm:c:o:t:l:Lh" opt; do
    case $opt in
        p) PROFILE=$OPTARG ;;
        d) GRUB_DIR=$OPTARG ;;
        T) USE_TEMPLATE=1 ;;
        m) EXTRA_MODS=$OPTARG ;;
        c) EARLY_CFG=$OPTARG ;;
        o) OUT=$OPTARG ;;
        t) ISO_TREE=$OPTARG ;;
        l) LIST=$OPTARG ;;
        L) PRINT_MODS=1 ;;
        h) usage 0 ;;
        *) usage 1 ;;
    esac
done

# --- list contents of an existing eltorito.img ---------------------------
# Decompresses the LZMA core and walks GRUB's module-info table.
list_image() {
    python3 -I - "$1" <<'EOF'
import lzma, re, struct, sys
img = open(sys.argv[1], 'rb').read()
raw = None
for off in range(0, 16384):              # compressed core: after cdboot.img (eltorito) or diskboot.img (core.img)
    try:
        d = lzma.LZMADecompressor(format=lzma.FORMAT_RAW, filters=[
            {"id": lzma.FILTER_LZMA1, "lc": 3, "lp": 0, "pb": 2, "dict_size": 1 << 24}])
        out = d.decompress(img[off:], max_length=4 << 20)
    except lzma.LZMAError:
        continue
    if len(out) > 20000:
        raw = out
        break
if raw is None:
    sys.exit("could not find the compressed GRUB core")
magic = struct.pack('<I', 0x676d696d)    # "mimg" = grub_module_info32
hits = [m.start() for m in re.finditer(re.escape(magic), raw)
        if struct.unpack_from('<I', raw, m.start() + 4)[0] in (12, 16)]
if not hits:
    sys.exit("module info header not found")
p = hits[-1]
_, hdr, size = struct.unpack_from('<III', raw, p)
q, end = p + hdr, p + size
types = {1: 'memdisk', 2: 'config', 3: 'prefix', 4: 'pubkey'}
mods = []
while q < end:
    t, s = struct.unpack_from('<II', raw, q)
    body = raw[q + 8:q + s]
    if t == 0:                           # ELF module: read its .modname section
        shoff, = struct.unpack_from('<I', body, 0x20)
        shentsize, shnum, shstrndx = struct.unpack_from('<HHH', body, 0x2e)
        sh = lambda i: struct.unpack_from('<IIIIIIIIII', body, shoff + i * shentsize)
        stro = sh(shstrndx)[4]
        for i in range(shnum):
            h = sh(i)
            if body[stro + h[0]:].split(b'\0')[0] == b'.modname':
                mods.append(body[h[4]:h[4] + h[5]].split(b'\0')[0].decode())
    else:
        text = body.rstrip(b'\0').decode(errors='replace')
        print(f"{types.get(t, t)}:", text if t != 2 else "\n" + text)
    q += s
print("modules:", " ".join(mods))
EOF
}

if [[ -n $LIST ]]; then
    list_image "$LIST"
    exit 0
fi

case $PROFILE in
    minimal)  MODS=$MODS_MINIMAL ;;
    extended) MODS=$MODS_EXTENDED ;;
    full)     MODS=$MODS_FULL ;;
    *)        echo "unknown profile: $PROFILE" >&2; usage 1 ;;
esac
MODS="$MODS $EXTRA_MODS"

[[ -n $ISO_TREE && -n $OUT ]] && { echo "use either -t or -o, not both" >&2; exit 1; }

TMP=
cleanup() { if [[ -n $TMP ]]; then rm -rf -- "$TMP"; fi; }
trap cleanup EXIT

# --- GRUB module directory: host (default) or template (-T) ---------------
if [[ -n $USE_TEMPLATE ]]; then
    [[ -f $TEMPLATE_TAR ]] || { echo "$TEMPLATE_TAR not found" >&2; exit 1; }
    TMP=$(mktemp -d)
    tar xf "$TEMPLATE_TAR" -C "$TMP" --wildcards '*/boot/grub/i386-pc/*'
    GRUB_DIR=$(find "$TMP" -type d -path '*/boot/grub/i386-pc' | head -n1)
    echo "GRUB modules: template $TEMPLATE_TAR"
else
    echo "GRUB modules: $GRUB_DIR"
    if [[ $(realpath "$GRUB_DIR") == /usr/lib/grub/i386-pc ]]; then
        ver=$(dpkg-query -W -f '${Version}' grub-pc-bin 2>/dev/null || pacman -Q grub 2>/dev/null || true)
        echo "GRUB version: ${ver:-unknown}"
    fi
fi
for f in kernel.img cdboot.img lzma_decompress.img moddep.lst; do
    [[ -f $GRUB_DIR/$f ]] || {
        echo "missing $GRUB_DIR/$f" >&2
        echo "(host: install grub-pc-bin (Debian) / grub (Arch), or use -T for the template)" >&2
        exit 1
    }
done

# --- drop modules this GRUB build does not have (differs between versions) -
wanted=$MODS
MODS=
for m in $wanted; do
    if [[ -f $GRUB_DIR/$m.mod ]]; then
        MODS="$MODS $m"
    else
        echo "NOTE: module $m not in $GRUB_DIR - skipped"
    fi
done

if [[ -n $PRINT_MODS ]]; then
    echo $MODS
    exit 0
fi

# building an image needs grub-mkimage (-L above only prints the module list)
command -v grub-mkimage >/dev/null || { echo "grub-mkimage not found (package grub-common)" >&2; exit 1; }

# --- with -t: replace the ISO tree's module set by the one we build from ---
if [[ -n $ISO_TREE ]]; then
    dest=$ISO_TREE/boot/grub/i386-pc
    [[ -d $ISO_TREE/boot/grub ]] || { echo "$ISO_TREE/boot/grub not found" >&2; exit 1; }
    if [[ $(realpath -m "$dest") != $(realpath "$GRUB_DIR") ]]; then
        mkdir -p "$dest"
        # Drop the old set completely so no module of another GRUB build stays behind.
        find "$dest" -maxdepth 1 -type f \( -name '*.mod' -o -name '*.lst' \) -delete
        cp -- "$GRUB_DIR"/*.mod "$GRUB_DIR"/*.lst "$GRUB_DIR"/*.img "$dest"/
        echo "Synced $(find "$dest" -maxdepth 1 -name '*.mod' | wc -l) modules into $dest"
        # Files the host does not have (e.g. the template's core.img) are left
        # alone, but they belong to the other GRUB build.
        for f in "$dest"/*; do
            [[ -e $GRUB_DIR/${f##*/} || ${f##*/} == eltorito.img ]] || echo "NOTE: not from host GRUB: $f"
        done
    fi
    OUT=$dest/eltorito.img
fi
OUT=${OUT:-eltorito.img}

# --- build ----------------------------------------------------------------
# An early config (-c) is run by the core before normal mode. Keep it to
# simple commands (search, set, source/configfile, normal, echo); "if"
# blocks may not work there (that is normal mode's script engine).
CFG_ARGS=()
[[ -n $EARLY_CFG ]] && CFG_ARGS=(-c "$EARLY_CFG")

# shellcheck disable=SC2086  # MODS is a word list on purpose
grub-mkimage -d "$GRUB_DIR" -O i386-pc-eltorito -p "$PREFIX" "${CFG_ARGS[@]}" -o "$OUT" $MODS

echo "Built $OUT ($(stat -c %s "$OUT") bytes), profile=$PROFILE"
list_image "$OUT"
