#!/bin/bash


sudo apt update && sudo apt upgrade -y

sudo apt install kubectl curl -y

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s
