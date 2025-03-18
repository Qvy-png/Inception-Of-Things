#!/bin/bash

if [ "$(id -u)" -ne 0 ] && [ -z "$SUDO_UID" ] && [ -z "$SUDO_USER" ]; then
	printf "${RED}[LINUX]${NC} - Permission denied. Please run the command with sudo privileges.\n"
	exit 87
fi

echo "[INSTALL_SH]Updating . . .\n"
apt update > /dev/null

# tools
## curl net-tools docker
apt install curl net-tools docker.io -y

# systemctl
systemctl start docker
systemctl enable docker

## k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

## kubectl #TODO check if kubectl already exists
# [ ]
curl -LO https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/

# alias
# kubectl alias -> k
echo 'export PATH="/sbin:$PATH"' >> $HOME/.bashrc
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-alias.sh > /dev/null
