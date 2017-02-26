# add Docker repository
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

cat > /etc/apt/sources.list.d/docker.list <<'EOF'
deb https://apt.dockerproject.org/repo debian-stretch main
EOF

# update and install
apt-get update
apt-get install -y apt-transport-https ca-certificates
apt-get install -y docker-engine

# set Docker to auto-launch on startup
systemctl enable docker

