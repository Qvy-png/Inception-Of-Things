#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

K3D_PATH="/usr/local/bin/k3d"
KUBECTL_PATH="/usr/local/bin/kubectl"
ARGOCD_PATH="/usr/local/bin/argocd"

if [ "$(id -u)" -ne 0 ] && [ -z "$SUDO_UID" ] && [ -z "$SUDO_USER" ]; then
	printf "${RED}[LINUX]${NC} - Permission denied. Please run the command with sudo privileges.\n"
	exit 87
fi

echo -e "${GREEN}[LAUNCH_SH]${NC} - Configuring . . ."

