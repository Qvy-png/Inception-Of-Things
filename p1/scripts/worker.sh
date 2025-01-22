#!/bin/bash

apt update
apt install -y net-tools curl

TIMEOUT=10
while [ ! -f "/share/token" ]; do
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
    if [ "$TIMEOUT" -eq 0 ]; then
        echo "Token file not found."
        exit 1
    fi
done

export K3S_TOKEN_FILE=/share/token
export K3S_URL=https://$1:6443
export INSTALL_K3S_EXEC="--flannel-iface=eth1"

curl -sfL https://get.k3s.io |  sh -

[ $? -ne 0 ] && {
    echo "K3S failed to install."
    exit 1
}

echo 'export PATH="/sbin:$PATH"' >> $HOME/.bashrc
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-aliases.sh > /dev/null
