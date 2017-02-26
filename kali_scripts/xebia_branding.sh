# set xebia styling
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s ../images/wallpaper.png -n -t string
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s ../images//wallpaper.png -n -t string
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/color1 -s 0 -s 0 -s 0 -s 0
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/color2 -s 19456 -s 10845 -s 24022 -s 65535
xfconf-query -c xfce4-panel -p /plugins/plugin-1/button-icon -s ../images/button.png -n -t string 

