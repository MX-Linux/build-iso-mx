	#! /bin/sh -e
	# Name of this script: 'grub_background.sh'
	
	   WALLPAPER="/usr/share/images/desktop-base/background"
	
	if [ "${GRUB_MENU_PICTURE}" ] ; then
	   echo "using custom appearance settings" >&2
	   WALLPAPER="${GRUB_MENU_PICTURE}"
	fi
