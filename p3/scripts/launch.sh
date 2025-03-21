#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

K3D_PATH="/usr/local/bin/k3d"
KUBECTL_PATH="/usr/local/bin/kubectl"
ARGOCD_PATH="/usr/local/bin/argocd"

USERNAME="rpol"
ARGOCD_NAMESPACE="argocd"
DEV_NAMESPACE="dev"

if [ "$(id -u)" -ne 0 ] && [ -z "$SUDO_UID" ] && [ -z "$SUDO_USER" ]; then
    printf "${RED}[LINUX]${NC} - Permission denied. Please run the command with sudo privileges.\n"
    exit 87
fi

echo -e "${GREEN}[LAUNCH_SH]${NC} - Configuring . . ."

echo -e "${YELLOW}[LAUNCH_SH]${NC} - Starting K3D cluster"

if sudo k3d cluster list | grep -q "$USERNAME"; then
    printf "${RED}[LAUNCH_SH]${NC} - A cluster named $USERNAME already exists.\n"
    exit 1
else
    if ! sudo k3d cluster create $USERNAME -p "8888:8888@loadbalancer"; then
        echo -e "${RED}[LAUNCH_SH]${NC} - Cluster creation failed! Do you have k3d installed and is the Docker service running?${NC}"
        exit 1
    fi
fi

export KUBECONFIG="$(sudo k3d kubeconfig write "$USERNAME")"

# Create Namespaces
sudo kubectl create namespace $ARGOCD_NAMESPACE --dry-run=client -o yaml | sudo kubectl apply -f -
sudo kubectl create namespace $DEV_NAMESPACE --dry-run=client -o yaml | sudo kubectl apply -f -

# Install ArgoCD
sudo kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD Pods to Be Ready
echo -e "${YELLOW}[LAUNCH_SH]${NC} - Waiting for ArgoCD pods to be ready..."
while [[ $(sudo kubectl get pods -n $ARGOCD_NAMESPACE -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[*].status.phase}') != "Running" ]]; do
    echo -e "${YELLOW}[LAUNCH_SH]${NC} - Waiting for ArgoCD server to start..."
    sleep 10
done
echo -e "${GREEN}[LAUNCH_SH]${NC} - ArgoCD is ready!"

# Grant admin permissions to ArgoCD
echo -e "${YELLOW}[LAUNCH_SH]${NC} - Granting ArgoCD admin permissions..."
sudo kubectl create clusterrolebinding argocd-admin-binding \
    --clusterrole=cluster-admin \
    --serviceaccount=argocd:argocd-server || true

# Get ArgoCD admin password
ARGOCD_PWD=$(sudo kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)
echo -e "${GREEN}ARGOCD PASSWORD: $ARGOCD_PWD${NC}"

# Port-forward ArgoCD to port 8080
echo -e "${YELLOW}[LAUNCH_SH]${NC} - Starting port-forwarding for ArgoCD on port 8080..."
sudo kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443 > /dev/null 2>&1 &

# Wait for port-forward to establish
sleep 5  

# Login to ArgoCD
echo -e "${YELLOW}[LAUNCH_SH]${NC} - Logging into ArgoCD..."
argocd login localhost:8080 --username admin --password "$ARGOCD_PWD" --insecure || {
    echo -e "${RED}[LAUNCH_SH]${NC} - Failed to log in to ArgoCD!"
    exit 1
}

# Apply the ArgoCD application
echo -e "${YELLOW}[LAUNCH_SH]${NC} - Deploying application..."

sudo kubectl apply -f ./confs/deploy.yml

echo -e "${GREEN}[LAUNCH_SH]${NC} - All set! Access ArgoCD at https://localhost:8080"

sudo kubectl rollout restart deployment argocd-repo-server -n argocd