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
rm -fv $PREFIX/etc/systemd/system/multi-user.target.wants/live-broadcomstartup.service
rm -fv $PREFIX/etc/systemd/system/multi-user.target.wants/live-clock12or24.service
rm -fv $PREFIX/var/lib/systemd/deb-systemd-helper-enabled/multi-user.target.wants/live-broadcomstartup.service
rm -fv $PREFIX/var/lib/systemd/deb-systemd-helper-enabled/multi-user.target.wants/live-clock12or24.service
rm -fv $PREFIX/var/lib/systemd/deb-systemd-helper-enabled/live-broadcomstartup.service.dsh-also
rm -fv $PREFIX/var/lib/systemd/deb-systemd-helper-enabled/live-clock12or24.service.dsh-also

exit
