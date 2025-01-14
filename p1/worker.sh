#!/bin/bash

sudo apt update -y && sudo apt upgrade -y

sudo apt install kubectl -y

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='agent' K3S_URL=https://192.168.1.100:6443 K3S_TOKEN=aaaaa::server:3289azer sh -
