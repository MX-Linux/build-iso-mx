#!/bin/bash

THEME_DIR=$(dirname $(readlink -f $0))
source $THEME_DIR/../theme-functions.sh
start_theme "$@"

mkdir -p /etc/skel/.local/share/applications/
copy_file conky.desktop  	/etc/skel/.config/autostart/
copy_file grub                  /etc/default/
copy_dir desktop-base/          /usr/share/desktop-base/    --create
copy_dir extra/                 /usr/share/fonts/extra      --create
copy_file conky.desktop         /etc/skel/.config/autostart/
copy_file rc.local              /etc/
copy_file libuser.conf          /etc/
copy_file modules               /etc/
copy_file timezone              /etc/
copy_file sddm.conf             /etc/
copy_file pc-speaker.conf       /etc/modprobe.d/
copy_file desktop.data          /usr/share/boot-menus/
copy_file desktop.menu          /usr/share/boot-menus/
copy_file 20-thinkpad.conf      /usr/share/X11/xorg.conf.d/
copy_file yad-icon-browser.desktop /etc/skel/.local/share/applications/ --create
copy_file plymouthd.conf        /etc/plymouth/  --create
copy_file ufw.conf              /etc/ufw/       --create
copy_file zramswap.service      /etc/systemd/system/

##alpha

#copy_file MXALPHAWALL.png /usr/share/backgrounds/

exit
