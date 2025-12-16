#!/bin/bash

THEME_DIR=$(dirname $(readlink -f $0))
source $THEME_DIR/../theme-functions.sh
start_theme "$@"

#
# archkde: Arch-friendly subset of the mxkde theme
# (avoid Debian/MX-specific files like /etc/default/grub, /etc/modules, etc).
#

# Fonts used by the KDE theme stack.
copy_dir extra/ /usr/share/fonts/extra --create

# Display manager defaults (only used if SDDM is installed).
copy_file sddm.conf /etc/ --create

# Hardware niceties.
copy_file pc-speaker.conf  /etc/modprobe.d/          --create
copy_file 20-thinkpad.conf /usr/share/X11/xorg.conf.d/ --create

# Optional components: safe even if the corresponding packages aren't installed.
copy_file plymouthd.conf /etc/plymouth/ --create

# Convenience desktop entries for the live user.
mkdir -p /etc/skel/.local/share/applications/ /etc/skel/.config/autostart/
copy_file yad-icon-browser.desktop /etc/skel/.local/share/applications/ --create
copy_file conky.desktop            /etc/skel/.config/autostart/         --create

exit 0
