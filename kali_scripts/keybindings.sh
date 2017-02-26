
# set keyboard shortcuts
xfconf-query -c xfce4-keyboard-shortcuts -p /xfwm4/custom/\<Super\>Left -s tile_left_key -n -t string
xfconf-query -c xfce4-keyboard-shortcuts -p /xfwm4/custom/\<Super\>Right -s tile_right_key -n -t string
xfconf-query -c xfce4-keyboard-shortcuts -p /xfwm4/custom/\<Super\>Up -s tile_up_key -n -t string
xfconf-query -c xfce4-keyboard-shortcuts -p /xfwm4/custom/\<Super\>Down -s tile_down_key -n -t string
xfconf-query -c xfce4-keyboard-shortcuts -p /commands/custom/\<Super\>r -s xfce4-appfinder -n -t string
xfconf-query -c xfce4-keyboard-shortcuts -p /commands/custom/\<Super\>t -s xfce4-terminal -n -t string
xfconf-query -c xfce4-keyboard-shortcuts -p /commands/custom/\<Super\>e -s exo\-open\ \-\-launch\ FileManager -n -t string

