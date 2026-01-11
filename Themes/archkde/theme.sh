#!/bin/bash

THEME_DIR=$(dirname $(readlink -f $0))
source $THEME_DIR/../theme-functions.sh
start_theme "$@"

#
# archkde: Arch-friendly subset of the mxkde theme
# (avoid Debian/MX-specific files like /etc/default/grub, /etc/modules, etc).
#
copy_dir desktop-base/		/usr/share/desktop-base/	--create
copy_dir extra/			/usr/share/fonts/extra		--create
copy_file grub			/etc/default
copy_file rc.local		/etc/
copy_file pc-speaker.conf	/etc/modprobe.d/
copy_file plymouthd.conf	/etc/plymouth/			--create
copy_file ufw.conf		/etc/ufw/			--create
copy_file zramswap.service	/etc/systemd/system/

# Enable services
systemctl enable sddm 2>&1 | tr '\r' '\n'
systemctl enable systemd-resolved 2>&1 | tr '\r' '\n'
systemctl --user enable mx-arch-updater-tray 2>&1 | tr '\r' '\n'

exit 0
