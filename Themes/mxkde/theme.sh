#!/bin/bash

THEME_DIR=$(dirname $(readlink -f $0))
source $THEME_DIR/../theme-functions.sh
start_theme "$@"
rm -R /etc/skel/.conky
copy_file grub                  /etc/default/
copy_file 55-tweak-override.conf /etc/polkit-1/localauthority.conf.d/
copy_dir desktop-base/               /usr/share/desktop-base/          --create
copy_dir conky/               /etc/skel/.conky/          --create
copy_dir extra/               /usr/share/fonts/extra       --create
#copy_file alsamixer.desktop /usr/share/applications/
#copy_file conky-toggle.desktop /usr/share/applications/
#copy_file conkytoggle.sh /usr/local/bin/
copy_file conky.desktop  /etc/skel/.config/autostart/
copy_file rc.local              /etc/
copy_file libuser.conf          /etc/
copy_file modules               /etc/
copy_file timezone		/etc/
#copy_file display-im6.desktop		/usr/share/applications/ 
#copy_file display-im6.q16.desktop	/usr/share/applications/
#copy_file nano.desktop		/usr/share/applications/
copy_file sddm.conf		/etc/
copy_file pc-speaker.conf	/etc/modprobe.d/
copy_file desktop.data          /usr/local/share/boot-menus/
copy_file desktop.menu          /usr/local/share/boot-menus/
copy_file 20-thinkpad.conf      /usr/share/X11/xorg.conf.d/
#copy_file pppoeconf.desktop     /usr/share/applications/
#copy_file daemon.conf 		/etc/pulse/
#copy_file 98qtconfig /etc/X11/Xsession.d/
copy_file yad-icon-browser.desktop /etc/skel/.local/share/applications/ --create
copy_file plymouthd.conf /etc/plymouth/ --create

##alpha

#copy_file MXALPHAWALL.png /usr/share/backgrounds/

exit
