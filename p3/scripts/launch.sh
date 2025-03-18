#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

K3D_PATH="/usr/local/bin/k3d"
KUBECTL_PATH="/usr/local/bin/kubectl"
ARGOCD_PATH="/usr/local/bin/argocd"

USERNAME=$(whoami)

if [ "$(id -u)" -ne 0 ] && [ -z "$SUDO_UID" ] && [ -z "$SUDO_USER" ]; then
	printf "${RED}[LINUX]${NC} - Permission denied. Please run the command with sudo privileges.\n"
	exit 87
fi

echo -e "${GREEN}[LAUNCH_SH]${NC} - Configuring . . ."

echo -e "${YELLOW}[LAUNCH_SH]${NC} - starting with k3d"

if sudo k3d cluster list | grep -q "$USERNAME"; then
	printf "${RED}[LAUNCH_SH]${NC} - A cluster named $USERNAME already exists.\n"
	exit 1
else
	if ! sudo k3d cluster create $USERNAME --port 80:80 --servers 1 --agents 3; then
        echo -e "${RED}[LAUNCH_SH]${NC} - Cluster creation failed! Do you have k3d installed and is the Docker service running?${NC}"
        exit 1
    fi
fi
