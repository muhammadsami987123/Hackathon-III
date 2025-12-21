# Windows Installation (WSL 2)

**Platform**: Windows 10/11 with WSL 2
**Package Manager**: apt-get (within Ubuntu WSL)
**Estimated Time**: 25-35 minutes

**Prerequisites**: [Check Prerequisites](./prerequisites.md) before starting

---

## Overview

Installing tools for Hackathon III on Windows using WSL 2 (Windows Subsystem for Linux):
1. Enable WSL 2
2. Install Ubuntu 22.04 LTS
3. Docker Desktop (WSL integration)
4. Minikube (within WSL)
5. Helm
6. kubectl
7. Claude Code
8. Goose

**Note**: All development tools run inside WSL Ubuntu environment.

---

## Step 1: Enable WSL 2

### Check Current State

```powershell
# In PowerShell (as Administrator)
wsl --version
```

If WSL version shown → skip to Step 2
If command fails → proceed

### Installation (PowerShell as Administrator)

```powershell
# Enable WSL
wsl --install

# Restart computer (REQUIRED)
```

After restart, verify:
```powershell
wsl --version
wsl --list --verbose  # Should show VERSION 2
```

---

## Step 2: Install Ubuntu in WSL

```powershell
# Install Ubuntu 22.04 LTS
wsl --install -d Ubuntu-22.04

# Verify
wsl --list --verbose
```

**Expected**: Ubuntu-22.04 with VERSION 2

### First Launch

Launch "Ubuntu 22.04" from Start Menu:
- Create username and password (remember these!)
- Wait for setup to complete

---

## Step 3: Update WSL Ubuntu

**Inside WSL terminal**:

```bash
# Update package lists
sudo apt-get update
sudo apt-get upgrade -y

# Verify git
git --version  # Expected: 2.40+
```

---

## Step 4: Install Docker Desktop

### Download and Install

1. Download Docker Desktop for Windows from docker.com
2. Install Docker Desktop
3. **IMPORTANT**: Enable WSL 2 integration

### Configure WSL Integration

1. Open Docker Desktop Settings
2. Go to **Resources → WSL integration**
3. Enable **Ubuntu-22.04**
4. Click **Apply & Restart**

### Verify (in WSL)

```bash
docker --version  # Expected: 20.10.0+
docker ps  # Should work without errors
```

---

## Step 5: Install Docker in WSL (if Docker Desktop not used)

**Alternative if Docker Desktop unavailable**:

```bash
# Install Docker
sudo apt-get install -y docker.io docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
```

---

## Step 6: Install Minikube

```bash
# Download Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify
minikube version  # Expected: v1.30.0+
```

---

## Step 7: Start Minikube

```bash
# Recommended configuration
minikube start --cpus=4 --memory=8192 --driver=docker
```

<details>
<summary>⚠️ Low-Resource Alternative</summary>

```bash
minikube start --cpus=2 --memory=4096 --driver=docker
```

**Warning**: Basic testing only, limited performance.

</details>

### Verify

```bash
minikube status  # All Running
```

---

## Step 8: Install Helm

```bash
# Download and install
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version  # Expected: v3.12.0+
```

---

## Step 9: Verify kubectl

```bash
kubectl version --client --short  # Expected: v1.27.0+
kubectl cluster-info
kubectl get nodes  # minikube Ready
```

---

## Step 10: Install Claude Code

```bash
# Download and install
curl -fsSL https://claude.ai/install.sh | bash

# Authenticate
claude auth login  # Opens browser

# Verify
claude --version  # Expected: v1.0.0+
```

---

## Step 11: Install Goose

```bash
# Download and install
curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash

# Verify
goose --version  # Expected: v0.1.0+
```

---

## Step 12: Network Connectivity (Optional)

<details>
<summary>Corporate Firewall/Proxy</summary>

```bash
# Add to ~/.bashrc
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="http://proxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1,.local"

# Apply
source ~/.bashrc

# Test
curl -I https://github.com
```

</details>

---

## Step 13: Run Verification

```bash
bash docs/environment-setup/scripts/verify-environment.sh
```

**Expected**: All ✓

---

## Environment Variables

Add to `~/.bashrc`:

```bash
export KUBECONFIG=~/.kube/config
export HELM_HOME=~/.helm
export CLAUDE_HOME=~/.claude
export MINIKUBE_HOME=~/.minikube
```

Apply: `source ~/.bashrc`

---

## WSL-Specific Tips

### Accessing Windows Files from WSL

```bash
# Windows C: drive
cd /mnt/c/Users/YourUsername/

# Windows Downloads folder
cd /mnt/c/Users/YourUsername/Downloads/
```

### Accessing WSL Files from Windows

In Windows Explorer, navigate to:
```
\\wsl$\Ubuntu-22.04\home\yourusername\
```

### WSL Commands (PowerShell)

```powershell
# List WSL distributions
wsl --list --verbose

# Set default distribution
wsl --set-default Ubuntu-22.04

# Shutdown WSL
wsl --shutdown

# Start specific distro
wsl -d Ubuntu-22.04
```

---

## Troubleshooting

- **WSL Issues**: Ensure WSL 2 enabled, restart if needed
- **Docker**: Check Docker Desktop WSL integration enabled
- **Minikube**: [Troubleshooting Guide](./troubleshooting.md#minikube-issues)
- **kubectl**: [Troubleshooting Guide](./troubleshooting.md#kubectl-issues)

---

## Next Steps

1. [Verification Guide](./verification.md)
2. [Repository Setup](./repository-setup.md)
3. Start building with CAPS playbooks

**Windows WSL Installation Complete!** 🎉

*Estimated: 25-35 minutes*
*Part of Hackathon III: SP Constitution (Spec-Kit Plus)*
