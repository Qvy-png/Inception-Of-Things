#!/bin/bash

apt update
apt install -y net-tools curl

export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="server --node-external-ip=$1 --bind-address=$1 --flannel-iface=eth1"

curl -sfL https://get.k3s.io |  sh -
[ $? -ne 0 ] && {
	echo "K3S install failed."
	exit 1
}