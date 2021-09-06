#!/bin/bash

THEME_DIR=$(dirname $(readlink -f $0))
source $THEME_DIR/../theme-functions.sh
start_theme "$@"

rm -R /etc/skel/.conky
copy_file grub                  /etc/default/
copy_file 55-tweak-override.conf /etc/polkit-1/localauthority.conf.d/
copy_file 10_linux              /etc/grub.d/
#copy_file 20_memtest86+         /etc/grub.d/
#copy_dir conky/               /etc/skel/.conky/          --create
#copy_dir extra/               /usr/share/fonts/extra       --create
copy_file alsamixer.desktop /usr/share/applications/
#copy_file conky-toggle.desktop /usr/share/applications/
#copy_file conkytoggle.sh /usr/local/bin/
#copy_file conky.desktop  /etc/skel/.config/autostart/
copy_file rc.local              /etc/
copy_file libuser.conf          /etc/
copy_file modules               /etc/
copy_file timezone		/etc/
#copy_file 98vboxadd-xclient     /etc/X11/Xsession.d/
copy_file display-im6.desktop		/usr/share/applications/ 
copy_file display-im6.q16.desktop	/usr/share/applications/
#copy_file Window_Buttons.desktop	/usr/share/applications/
copy_file synaptic.desktop 		/usr/share/applications/
copy_file nano.desktop		/usr/share/applications/
copy_file lightdm.conf		/etc/lightdm/
#copy_file lightdm-gtk-greeter.conf /etc/lightdm/
copy_file pc-speaker.conf	/etc/modprobe.d/
copy_file desktop.data          /usr/local/share/boot-menus/
copy_file desktop.menu          /usr/local/share/boot-menus/
copy_file 20-thinkpad.conf      /usr/share/X11/xorg.conf.d/
copy_file pppoeconf.desktop     /usr/share/applications/
#copy_file daemon.conf 		/etc/pulse/
#copy_file i915-power-saving.conf 	/etc/modprobe.d/
#copy_file hang-on-shutdown.conf  	/etc/modprobe.d/
#copy_file 98qtconfig /etc/X11/Xsession.d/
#copy_file ndisgtk.desktop /usr/share/applications/
#copy_file ndisgtk.svg /usr/share/icons/hicolor/scalable/apps/
#copy_file ndisgtk.svg /usr/share/icons/hicolor/48x48/apps/
#copy_file plymouthd.conf /etc/plymouth/ --create
#copy_file luckybackup.desktop /usr/share/applications/
#copy_file luckybackup-su.desktop /usr/share/applications/
#copy_file luckybackup.svg /usr/share/icons/hicolor/scalable/apps/

#copy_dir Desktop/               /etc/skel/Desktop/           --create
#copy_dir cache		/etc/skel/.cache/ 	--create

# copy custom Workbench stuff
copy_file workbench-tools.desktop /usr/share/applications/
copy_file workbench-tools.desktop /etc/skel/.config/autostart/
copy_dir desktop_files/ /usr/share/applications/workbench/ --create
copy_file workbench-tools.list /etc/custom-toolbox/
copy_file wood-architect-table-work.jpeg /usr/share/backgrounds/MXLinux/ --create
copy_file wood-architect-table-work-BW.jpeg /usr/share/backgrounds/MXLinux/lightdm/ --create
copy_file lightdm-gtk-greeter.conf /etc/lightdm/
copy_file workbench-sudoers /etc/sudoers.d/
copy_dir defaults/panel/ /etc/skel/.config/xfce4/panel/	--create
copy_dir defaults/xfconf/xfce-perchannel-xml/ /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/	--create
copy_dir defaults/qt4-fsarchiver/ /etc/skel/.config/qt4-fsarchiver/ --create
copy_file mx-snapshot.conf /etc/
copy_file custom-toolbox.conf /etc/custom-toolbox/
ln -sf /usr/games/blockout2 /usr/bin/blockout2 # add a link in $PATH
exit
