#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

sudo apt install curl -y


export K3S_TOKEN_FILE=/vagrant/token
export K3S_URL=https://$1:6443
export INSTALL_K3S_EXEC"--flannel-iface=eth1"

curl -sfL https://get.k3s.io |  sh -
