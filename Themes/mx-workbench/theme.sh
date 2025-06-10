#!/bin/bash

THEME_DIR=$(dirname $(readlink -f $0))
source $THEME_DIR/../theme-functions.sh
start_theme "$@"

copy_file grub                  /etc/default/
copy_file 55-tweak-override.conf /etc/polkit-1/localauthority.conf.d/
copy_dir extra/               	/usr/share/fonts/extra       	--create
copy_file rc.local              /etc/
copy_file libuser.conf          /etc/
copy_file modules               /etc/
copy_file timezone		/etc/
copy_file lightdm.conf		/etc/lightdm/
copy_file lightdm-gtk-greeter.conf /etc/lightdm/
copy_file pc-speaker.conf	/etc/modprobe.d/
copy_file desktop.data          /usr/share/boot-menus/
copy_file desktop.menu          /usr/share/boot-menus/
copy_file 20-thinkpad.conf      /usr/share/X11/xorg.conf.d/
copy_file ufw.conf       	/etc/ufw/ 	--create
copy_file zramswap.service 	/etc/systemd/system/

# setup zsh and powerlevel10k
copy_file .zshrc /etc/skel/
copy_file .p10k.zsh /etc/skel/
copy_file gitstatusd-linux-x86_64 /etc/skel/.cache/gitstatus/ --create
copy_file adduser.conf /etc/

# copy custom Workbench stuff
copy_file workbench-tools.desktop /usr/share/applications/ --create
copy_file workbench-tools.desktop /etc/skel/.config/autostart/
copy_dir desktop_files/ /usr/share/applications/workbench/ --create
copy_file workbench-tools.list /etc/custom-toolbox/
copy_file wood-architect-table-work.jpeg /usr/share/backgrounds/MXLinux/ --create
copy_file wood-architect-table-work-BW.jpeg /usr/share/backgrounds/MXLinux/lightdm/ --create
copy_file lightdm-gtk-greeter.conf /etc/lightdm/
copy_file workbench-sudoers /etc/sudoers.d/
copy_dir defaults/panel/ /etc/skel/.config/xfce4/panel/	--create
copy_dir defaults/xfconf/xfce-perchannel-xml/ /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/ --create
copy_dir defaults/terminal/ /etc/skel/.config/xfce4/terminal/ --create
copy_file mx-snapshot.conf /etc/
copy_file custom-toolbox.conf /etc/custom-toolbox/
copy_file default23.png /usr/share/backgrounds/
ln -sf /usr/games/blockout2 /usr/bin/blockout2 # add a link in $PATH

exit
