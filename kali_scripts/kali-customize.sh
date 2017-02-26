# update Kali
apt-get update
apt-get -y upgrade

# install necessary files
apt-get install -y apt-transport-https ca-certificates

# set timezone
timedatectl set-timezone Europe/Amsterdam

# install useful tools
apt-get install -y synaptic # package manager
apt-get install -y apt-file # file search in apt


# install developer tools
#apt-get install -y gitg # git GUI
apt-get install -y zim # desktop wiki
apt-get install -y vym # mindmap tool
apt-get install -y xfce4-whiskermenu-plugin #nicer menu

# install desired kali tools
# apt-get install -y kali-linux-all # Kali Linux - all packages
# apt-get install -y kali-linux-forensic # Kali Linux Forensic tools
# apt-get install -y kali-linux-gpu # Kali Linux GPU tools
# apt-get install -y kali-linux-pwtools # Kali Linux password cracking tools
# apt-get install -y kali-linux-rfid # Kali Linux RFID tools
# apt-get install -y kali-linux-sdr # Kali Linux SDR tools
# apt-get install -y kali-linux-top10 # Kali Linux Top 10 tools
# apt-get install -y kali-linux-voip # Kali Linux VoIP tools
apt-get install -y kali-linux-web # Kali Linux webapp assessment tools
# apt-get install -y kali-linux-wireless # Kali Linux wireless tools

# cleanup
apt-get remove -y maltegoce
apt-get remove -y orage
apt-get remove -y wapiti
apt-get remove -y webscarab
apt-get remove -y paros
apt-get remove -y vim

