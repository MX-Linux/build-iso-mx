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

# GRUB configuration for installed system
copy_file grub /etc/default

# Display manager defaults (only used if LightDM is installed).
copy_file lightdm.conf             /etc/lightdm/ --create
copy_file lightdm-gtk-greeter.conf /etc/lightdm/ --create

# System configuration files
copy_file rc.local /etc/

# Hardware niceties.
copy_file pc-speaker.conf  /etc/modprobe.d/            --create

# Optional components: safe even if the corresponding packages aren't installed.
copy_file plymouthd.conf /etc/plymouth/ --create
copy_file ufw.conf       /etc/ufw/      --create

# Default live-user autostarts and Xfce settings.
copy_file magnus-autostart.desktop  /etc/skel/.config/autostart/ --create
copy_file xfce4-desktop.xml /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/ --create

# System services
copy_file zramswap.service /etc/systemd/system/

# Enable services
systemctl enable systemd-resolved

exit 0
