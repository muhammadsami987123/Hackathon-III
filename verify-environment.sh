#!/bin/bash
# verify-environment.sh
# Complete environment verification

echo "=========================================="
echo "Hackathon 3 Environment Verification"
echo "=========================================="
echo ""

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo -e "${RED}✗${NC} $1 is NOT installed"
        return 1
    fi
}

echo "Checking core tools..."
check_command git
check_command docker
check_command minikube
check_command kubectl
check_command helm
check_command claude
check_command goose

echo ""
echo "Checking Kubernetes cluster..."
if minikube status > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Minikube is running"
else
    echo -e "${RED}✗${NC} Minikube is NOT running"
    echo "  Start with: minikube start --cpus=4 --memory=8192 --driver=docker"
fi

echo ""
echo "Checking cluster connectivity..."
if kubectl cluster-info > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} kubectl can connect to cluster"
else
    echo -e "${RED}✗${NC} kubectl cannot connect"
fi

echo ""
echo "Checking repositories..."
if [ -d "F:/Hackathon/Hackathon III/skills-library" ]; then
    echo -e "${GREEN}✓${NC} skills-library repository exists"
else
    echo -e "${RED}✗${NC} skills-library repository NOT found"
fi

if [ -d "F:/Hackathon/Hackathon III/learnflow-app" ]; then
    echo -e "${GREEN}✓${NC} learnflow-app repository exists"
else
    echo -e "${RED}✗${NC} learnflow-app repository NOT found"
fi

echo ""
echo "=========================================="
echo "Verification Complete!"
echo "=========================================="
