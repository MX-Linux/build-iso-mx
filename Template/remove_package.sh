#!/bin/bash
set -e

if [[ $# != 1 || ! $1 =~ ^[[:alnum:]@][[:alnum:]@._+:-]*$ ]]; then
    echo "Usage: $0 <package_to_remove>" >&2
    exit 1
fi

# With this package alphabet only dots and plus signs are special in an ERE.
package=${1//./\\.}
package=${package//+/\\+}
entry="^[[:space:]]*${package}[[:space:]]*(#.*)?$"

shopt -s globstar nullglob
for file in **/*.list; do
    [[ -f $file && ! -L $file ]] || continue
    case ${file##*/} in
        package.list|*-package.list|aur-packages.list|add.list|remove.list|\
exclude-chroot.list|exclude-debootstrap.list|include-debootstrap.list|\
reconfigure.list|reinstall.list|save-selections.list) ;;
        *) continue ;;
    esac
    if grep -Eq -- "$entry" "$file"; then
        sed -i -E "/$entry/d" -- "$file"
    else
        [[ $? == 1 ]] || exit 1
    fi
done
