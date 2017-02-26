echo '+--------------------------------------+'
echo '|                                      |'
echo '| XEBIA TRAINING ENVIRONMENT INSTALLER |'
echo '|                                      |'
echo '+--------------------------------------+'


# ---- CONFIGURATION SETTINGS -----------
INSTALL_DOCKER 
INSTALL_KALI_WEBUTILS
INSTALL_KALI_RE_MOBILE
INSTALL_XEBIA_BRANDING
INSTALL_KEYBINDINGS




# ---- CONFIGURATION SETTINGS -----------

cd kali_scripts

# update kali and install extra kali packages
#source kali_customize.sh

#install docker
#source install_docker.sh

#install additional tools
#source additional_tools.sh

#install xebia branding
#source xebia_branding.sh

#install windows like keybindings
#source keybindings.sh

