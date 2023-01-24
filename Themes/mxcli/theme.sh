#!/bin/bash

THEME_DIR=$(dirname $(readlink -f $0))
source $THEME_DIR/../theme-functions.sh
start_theme "$@"

copy_file grub                  /etc/default/
copy_file 55-tweak-override.conf /etc/polkit-1/localauthority.conf.d/
copy_file 10_linux              /etc/grub.d/
copy_file 30_os-prober			/etc/grub.d/
copy_file 30_uefi-firmware		/etc/grub.d/
copy_dir desktop-base/          /usr/share/desktop-base/    --create
copy_file rc.local              /etc/
copy_file libuser.conf          /etc/
copy_file modules               /etc/
copy_file timezone		        /etc/
copy_file pc-speaker.conf	    /etc/modprobe.d/
copy_file desktop.data          /usr/local/share/boot-menus/
copy_file desktop.menu          /usr/local/share/boot-menus/

exit
