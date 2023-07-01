if [ "$XDG_CURRENT_DESKTOP" = "XFCE" ]; then
	while ! pidof xfdesktop >>/dev/null;
		do
			sleep 1
		done
fi
if [ ! -e "/home/$USER/.cache/fontconfig" ]; then
	fc-cache -r /usr/share/fonts/extra
fi
sleep 20
killall conky
cd "$HOME/.conky/MX-CowonMildBlue"
conky -c "$HOME/.conky/MX-CowonMildBlue/MX-Cowon_MildBlue" &
