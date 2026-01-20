#!/bin/bash

THEME_DIR=$(dirname $(readlink -f $0))
source $THEME_DIR/../theme-functions.sh
start_theme "$@"

copy_file grub                  /etc/default/
copy_dir desktop-base/          /usr/share/desktop-base/    --create
copy_file rc.local              /etc/
copy_file libuser.conf          /etc/
copy_file modules               /etc/
copy_file timezone		/etc/
copy_file pc-speaker.conf	/etc/modprobe.d/
copy_file desktop.data          /usr/share/boot-menus/
copy_file desktop.menu          /usr/share/boot-menus/

# Disable services that require executables from mx-tweak (not installed in CLI)
# Remove symlinks and deb-systemd-helper state files to prevent re-enabling at boot
rm_file /usr/lib/systemd/system/live-broadcomstartup.service
rm_file /usr/lib/systemd/system/live-clock12or24.service

exit
