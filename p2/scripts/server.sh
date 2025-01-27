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

# kubectl alias -> k
echo 'export PATH="/sbin:$PATH"' >> $HOME/.bashrc
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-alias.sh > /dev/null

# web apps

kubectl create configmap app-one --from-file /share/app1/index.html
kubectl apply -f /share/app1/deployment.yml
kubectl apply -f /share/app1/service.yml

kubectl apply -f /share/ingress.yml