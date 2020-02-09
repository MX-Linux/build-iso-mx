while ! pidof xfdesktop >>/dev/null;
do
sleep 1
done
if [ -e "/home/$USER/.cache/fontconfig" ]; then
continue
else
fc-cache -r /usr/share/fonts/extra
fi
sleep 20
killall conky
cd "/home/$USER/.conky/MX-CowonBlue"
conky -c "/home/$USER/.conky/MX-CowonBlue/MX-Cowon_blue_roboto" &
