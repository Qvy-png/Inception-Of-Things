#!/bin/bash

apt update
apt install -y net-tools curl

export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="server --node-external-ip=$1 --bind-address=$1 --flannel-iface=eth1"

curl -sfL https://get.k3s.io |  sh -
[ $? -ne 0 ] && {
	echo "K3S install failed."
    journalctl -xeu k3s.service
	exit 1
}

while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
    if [ "$TIMEOUT" -eq 0 ]; then
        echo "Token file not generated."
        exit 1
    fi
done
cp /var/lib/rancher/k3s/server/node-token /share/token

echo 'export PATH="/sbin:$PATH"' >> $HOME/.bashrc
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-alias.sh > /dev/null
