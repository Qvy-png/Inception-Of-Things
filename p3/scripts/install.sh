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

echo -e "${YELLOW}[INSTALL_SH]${NC} - Updating . . ."
apt-get -qq update > /dev/null

# tools
## curl net-tools docker
apt-get -qq install curl net-tools git docker.io -y > /dev/null

# systemctl
systemctl start docker
systemctl enable docker

## k3d
[ ! -f $K3D_PATH ] && {
    echo -e "${YELLOW}[INSTALL_SH]${NC} - installing k3d"
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash > /dev/null
    RET="$?"
    [ ! $RET -eq "0" ] && {
        echo -e "${RED}[INSTALL_SH]${NC} - error installing k3d"
    } || {
        echo -e "${GREEN}[INSTALL_SH]${NC} - k3d installation complete!"
    }
} || {
    echo -e "${GREEN}[INSTALL_SH]${NC} - k3d already installed"
}

## kubectl
[ ! -f $KUBECTL_PATH ] && {
    echo -e "${YELLOW}[INSTALL_SH]${NC} - installing kubectl"
    curl -LOs https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
    RET="$?"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    [ ! $RET -eq "0" ] && {
        echo -e "${RED}[INSTALL_SH]${NC} - error installing kubectl"
    } || {
        [ -f $KUBECTL_PATH ] && {
            echo -e "${GREEN}[INSTALL_SH]${NC} - kubectl installation complete!"
        }
    }
} || {
    echo -e "${GREEN}[INSTALL_SH]${NC} - kubectl already installed"
}

## argoCD
[ ! -f $ARGOCD_PATH ] && {
    echo -e "${YELLOW}[INSTALL_SH]${NC} - installing argocd"
    curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    RET="$?"
    chmod +x argocd
    sudo mv argocd /usr/local/bin/
    [ ! $RET -eq "0" ] && {
        echo -e "${RED}[INSTALL_SH]${NC} - error installing argoCD"
    } || {
        [ -f $ARGOCD_PATH ] && {
            echo -e "${GREEN}[INSTALL_SH]${NC} - argoCD installation complete!"
        }
    }
} || {
    echo -e "${GREEN}[INSTALL_SH]${NC} - argocd already installed"
}

## dev
kubectl apply -f ./confs/deploy.yml
# echo -e "${GREEN}[INSTALL_SH] - port forwarded : sudo kubectl port-forward -n dev 8888:8080${RESET}"

# alias
# kubectl alias -> k
echo 'export PATH="/sbin:$PATH"' >> $HOME/.bashrc
echo "alias k='kubectl'" | sudo tee /etc/profile.d/00-alias.sh > /dev/null
