#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

K3D_PATH="/usr/local/bin/k3d"
KUBECTL_PATH="/usr/local/bin/kubectl"
ARGOCD_PATH="/usr/local/bin/argocd"

USERNAME=rpol

## K3D PART

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
	if ! sudo k3d cluster create $USERNAME; then
        echo -e "${RED}[LAUNCH_SH]${NC} - Cluster creation failed! Do you have k3d installed and is the Docker service running?${NC}"
        exit 1
    fi
fi

export KUBECONFIG="$(sudo k3d kubeconfig write "$USERNAME")"

## ARGOCD PART

sudo kubectl create namespace argocd && sudo kubectl create namespace dev
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

HOST_ENTRY="127.0.0.1 argocd.mydomain.com"
HOSTS_FILE="/etc/hosts"

if grep -q "$HOST_ENTRY" "$HOSTS_FILE"; then
    echo "exist $HOSTS_FILE"
else
    echo "adding $HOSTS_FILE"
    echo "$HOST_ENTRY" | sudo tee -a "$HOSTS_FILE"
fi

sudo kubectl wait --for=condition=ready --timeout=600s pod --all -n argocd

echo -ne "${GREEN}ARGOCD PASSWORD : "
  sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode
echo "${RESET}"

sudo kubectl port-forward svc/argocd-server -n argocd 8085:443 > /dev/null 2>&1 &

## DEV PART