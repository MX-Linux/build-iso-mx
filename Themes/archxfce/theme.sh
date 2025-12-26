#!/bin/bash

THEME_DIR=$(dirname $(readlink -f $0))
source $THEME_DIR/../theme-functions.sh
start_theme "$@"

#
# archxfce: Arch-friendly subset of the `mx` (Xfce) theme.
# This theme reuses `Themes/mx/misc` and `Themes/mx/extra` via symlinks and only
# copies files that make sense for Arch-based live systems.
#

# Fonts used by the desktop stack.
copy_dir extra/ /usr/share/fonts/extra --create

# Display manager defaults (only used if LightDM is installed).
copy_file lightdm.conf             /etc/lightdm/ --create
copy_file lightdm-gtk-greeter.conf /etc/lightdm/ --create

# Hardware niceties.
copy_file pc-speaker.conf  /etc/modprobe.d/            --create
copy_file 20-thinkpad.conf /usr/share/X11/xorg.conf.d/ --create

# Optional components: safe even if the corresponding packages aren't installed.
copy_file plymouthd.conf /etc/plymouth/ --create

# Default live-user autostarts and Xfce settings.
mkdir -p /etc/skel/.local/share/applications/ /etc/skel/.config/autostart/
copy_file conky.desktop             /etc/skel/.config/autostart/ --create
copy_file magnus-autostart.desktop  /etc/skel/.config/autostart/ --create
copy_file xfce4-desktop.xml /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/ --create

# Enable services
systemctl enable systemd-resolved

exit 0

