cd /root/Downloads

# gitkraken
apt-get install -y gvfs-bin
wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
dpkg -i gitkraken-amd64.deb 
rm gitkraken-amd64.deb

#notepadqq
wget https://github.com/notepadqq/notepadqq/releases/download/v1.0.1/notepadqq-v1.0.1-linux-x64.tar.gz
tar -xvf notepadqq-v1.0.1-linux-x64.tar.gz

# needed for Damn Vulnerable Web Services
echo 127.0.0.1         dvws.local >> /etc/hosts
