#!/bin/bash

THEME_DIR=$(dirname $(readlink -f $0))
source $THEME_DIR/../theme-functions.sh
start_theme "$@"

copy_file grub                  /etc/default/
#copy_file 10_linux              /etc/grub.d/
copy_file 20_memtest86+         /etc/grub.d/
copy_dir desktop-base/               /usr/share/desktop-base/          --create
copy_dir conky/               /etc/skel/.conky/          --create
copy_dir extra/               /usr/share/fonts/extra       --create
copy_file alsamixer.desktop /usr/share/applications/
#copy_file conky-toggle.desktop /usr/share/applications/
#copy_file conkytoggle.sh /usr/local/bin/
copy_file conky.desktop  /etc/skel/.config/autostart/
copy_file rc.local              /etc/
copy_file libuser.conf          /etc/
copy_file modules               /etc/
copy_file timezone		/etc/
copy_file 98vboxadd-xclient     /etc/X11/Xsession.d/
copy_file 99-sandbox-mx.conf	/etc/sysctl.d/
#copy_file catfish.desktop	/usr/share/applications/ 
copy_file display-im6.desktop		/usr/share/applications/ 
copy_file display-im6.q16.desktop	/usr/share/applications/
#copy_file Window_Buttons.desktop	/usr/share/applications/
copy_file nano.desktop		/usr/share/applications/
#copy_file lightdm.conf		/etc/lightdm/
copy_file sddm.conf		/etc/
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
#copy_file compton.desktop /etc/skel/.local/share/applications/
#copy_file compton-conf.desktop /etc/skel/.local/share/applications/
copy_file yad-icon-browser.desktop /etc/skel/.local/share/applications/ --create
#copy_file ndisgtk.desktop /usr/share/applications/
#copy_file ndisgtk.svg /usr/share/icons/hicolor/scalable/apps/
#copy_file ndisgtk.svg /usr/share/icons/hicolor/48x48/apps/
copy_file uswsusp.conf /etc/
copy_file plymouthd.conf /etc/plymouth/
#copy_file luckybackup.desktop /usr/share/applications/
#copy_file luckybackup-su.desktop /usr/share/applications/
#copy_file luckybackup.svg /usr/share/icons/hicolor/scalable/apps/

copy_dir Desktop/               /etc/skel/Desktop/           --create
copy_dir cache		/etc/skel/.cache/ 	--create

##alpha

#copy_file 48381996347_8f9d2001e3_k.jpg /usr/share/backgrounds/
#copy_file xfce4-desktop.xml /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/

#copy KDE configs to skel
# copy_file kcminputrc /etc/skel/.config/ 
# copy_file kde-mimeapps.list /etc/xdg/ 
# copy_file kdeglobals /etc/skel/.config/ 
# copy_file kglobalshortcutsrc /etc/skel/.config/ 
# copy_file klaunchrc /etc/skel/.config/ 
# copy_file komparerc /etc/skel/.config/ 
# copy_file kscreenlockerrc /etc/skel/.config/ 
# copy_file ksmserverrc /etc/skel/.config/ 
# copy_file ksplashrc /etc/skel/.config/ 
# copy_file kwalletrc /etc/skel/.config/ 
# copy_file kwinrc /etc/skel/.config/ 
# copy_file mx_blue.jpg /usr/share/sddm/themes/breeze/
# copy_file org.kde.yakuake.desktop /etc/skel/.config/autostart/
# copy_file plasma-org.kde.plasma.desktop-appletsrc /etc/skel/.config/
# copy_file set_wallpaper.desktop /etc/skel/.config/autostart/
# copy_file theme.conf.user /usr/share/sddm/themes/breeze/
# copy_file yakuakerc /etc/skel/.config/ 

exit
