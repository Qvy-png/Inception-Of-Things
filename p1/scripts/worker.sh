#!/bin/bash

while [ ! -f "/vagrant/token" ]; do
    sleep 1
done

export K3S_TOKEN_FILE=/vagrant/token
export K3S_URL=https://$1:6443
export INSTALL_K3S_EXEC"--flannel-iface=eth1"

curl -sfL https://get.k3s.io |  sh -

if [ $? -ne 0 ]; then
    echo "K3S failed to install."
    exit 1
fi

echo 'export PATH="/sbin:$PATH"' >> $HOME/.bashrc
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-aliases.sh > /dev/null