#!/bin/bash
# verify-environment.sh
# Hackathon III Environment Verification
# Checks: git, docker, minikube, kubectl, helm, claude, goose

echo "=========================================="
echo "Hackathon III Environment Verification"
echo "=========================================="
echo ""

# Color output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAIL_COUNT=0

# Detect OS for platform-specific remediation
OS_TYPE=$(uname -s)

check_command() {
    tool=$1
    version_cmd=$2
    expected_pattern=$3
    remediation_macos=$4
    remediation_linux=$5
    remediation_wsl=$6

    echo -n "Checking $tool..."

    if command -v $tool &> /dev/null; then
        version=$($version_cmd 2>&1 | head -1)
        echo -e " ${GREEN}✓${NC} found"
        echo "  Version: $version"

        if [[ $version =~ $expected_pattern ]] || [[ $expected_pattern == "." ]]; then
            echo -e "  Status: ${GREEN}PASS${NC} (meets requirement)"
        else
            echo -e "  Status: ${RED}FAIL${NC} (expected pattern: $expected_pattern)"
            echo "  Remediation:"
            case $OS_TYPE in
                Darwin)
                    echo "    macOS: $remediation_macos"
                    ;;
                Linux)
                    if grep -qi microsoft /proc/version 2>/dev/null; then
                        echo "    Windows WSL: $remediation_wsl"
                    else
                        echo "    Linux: $remediation_linux"
                    fi
                    ;;
                *)
                    echo "    $remediation_linux"
                    ;;
            esac
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        echo -e " ${RED}✗${NC} not found"
        echo "  Remediation:"
        case $OS_TYPE in
            Darwin)
                echo "    macOS: $remediation_macos"
                ;;
            Linux)
                if grep -qi microsoft /proc/version 2>/dev/null; then
                    echo "    Windows WSL: $remediation_wsl"
                else
                    echo "    Linux: $remediation_linux"
                fi
                ;;
            *)
                echo "    $remediation_linux"
                ;;
        esac
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    echo ""
}

echo "=========================================="
echo "Core Tools Verification"
echo "=========================================="
echo ""

check_command "git" \
    "git --version" \
    "2\.[4-9][0-9]|[3-9]\." \
    "brew install git" \
    "sudo apt-get install git" \
    "sudo apt-get install git"

check_command "docker" \
    "docker --version" \
    "20\.1[0-9]|2[1-9]\.|[3-9][0-9]\." \
    "brew install --cask docker && open -a Docker" \
    "sudo apt-get install docker.io" \
    "Enable Docker Desktop WSL integration in Settings"

echo "=========================================="
echo "Kubernetes Tools Verification"
echo "=========================================="
echo ""

check_command "minikube" \
    "minikube version" \
    "v1\.3[0-9]|v1\.[4-9][0-9]|v[2-9]\." \
    "brew install minikube" \
    "curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo install minikube-linux-amd64 /usr/local/bin/minikube" \
    "curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo install minikube-linux-amd64 /usr/local/bin/minikube"

check_command "kubectl" \
    "kubectl version --client --short" \
    "v1\.2[7-9]|v1\.[3-9][0-9]|v[2-9]\." \
    "Installed with Minikube" \
    "Installed with Minikube" \
    "Installed with Minikube"

check_command "helm" \
    "helm version" \
    "v3\.1[2-9]|v3\.[2-9][0-9]|v[4-9]\." \
    "brew install helm" \
    "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash" \
    "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"

echo "=========================================="
echo "AI Agent Tools Verification"
echo "=========================================="
echo ""

check_command "claude" \
    "claude --version" \
    "." \
    "brew install --cask claude-code" \
    "curl -fsSL https://claude.ai/install.sh | bash" \
    "curl -fsSL https://claude.ai/install.sh | bash"

check_command "goose" \
    "goose --version" \
    "." \
    "brew install --cask block-goose" \
    "curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash" \
    "curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash"

echo "=========================================="
echo "Cluster Connectivity"
echo "=========================================="
echo ""

if minikube status > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Minikube cluster is running"
else
    echo -e "${RED}✗${NC} Minikube cluster is NOT running"
    echo "  Remediation: Run 'minikube start --cpus=4 --memory=8192 --driver=docker'"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

if kubectl cluster-info > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} kubectl can connect to cluster"
else
    echo -e "${RED}✗${NC} kubectl cannot connect"
    echo "  Remediation: Check 'minikube status' and run 'minikube update-context'"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

echo ""
echo "=========================================="
echo "Verification Summary"
echo "=========================================="
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Your environment is ready for Hackathon III."
    echo ""
    echo "Next steps:"
    echo "  1. Set up repositories: docs/environment-setup/repository-setup.md"
    echo "  2. Explore CAPS playbooks: caps-library/playbooks/"
    echo "  3. Read project constitution: .specify/memory/constitution.md"
    exit 0
else
    echo -e "${RED}✗ $FAIL_COUNT check(s) failed${NC}"
    echo ""
    echo "Please review the remediation steps above."
    echo "For detailed troubleshooting: docs/environment-setup/troubleshooting.md"
    exit 1
fi
