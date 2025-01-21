#!/bin/bash

apt update
apt install -y net-tools curl

while [ ! -f "/share/token" ]; do
    sleep 1
done

export K3S_TOKEN_FILE=/share/token
export K3S_URL=https://$1:6443
export INSTALL_K3S_EXEC"--flannel-iface=eth1"

curl -sfL https://get.k3s.io |  sh -

[ $? -ne 0 ] && {
    echo "K3S failed to install."
    exit 1
}

echo 'export PATH="/sbin:$PATH"' >> $HOME/.bashrc
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-aliases.sh > /dev/null
