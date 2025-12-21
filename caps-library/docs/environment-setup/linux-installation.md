# Linux Installation (Ubuntu/Debian)

**Platform**: Ubuntu 20.04+ / Debian 10+
**Package Manager**: apt-get
**Estimated Time**: 20-30 minutes

**Prerequisites**: [Check Prerequisites](./prerequisites.md) before starting

---

## Overview

Installing tools for Hackathon III on Linux (Ubuntu/Debian):
1. System Update
2. Docker
3. Minikube
4. Helm
5. kubectl (with Minikube)
6. Claude Code
7. Goose

Each step includes **checkpoint verification**.

---

## Step 0: Prerequisites & System Update

```bash
# Update package lists
sudo apt-get update

# Upgrade installed packages
sudo apt-get upgrade -y

# Verify git
git --version  # Expected: 2.40+

# If git missing
sudo apt-get install -y git
```

---

## Step 1: Install Docker

### Check Current State

```bash
docker --version
```

### Installation

```bash
# Install Docker
sudo apt-get install -y docker.io docker-compose

# Add user to docker group (avoid sudo)
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker
```

### Verify Success

```bash
docker --version  # Expected: 20.10.0+
docker ps  # Should work without sudo
```

---

## Step 2: Install Minikube

### Check Current State

```bash
minikube version
```

### Installation

```bash
# Download Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify
minikube version  # Expected: v1.30.0+
```

---

## Step 3: Start Minikube

### Recommended Configuration

```bash
minikube start --cpus=4 --memory=8192 --driver=docker
```

<details>
<summary>⚠️ Low-Resource Alternative (2 CPU, 4GB)</summary>

```bash
minikube start --cpus=2 --memory=4096 --driver=docker
```

**Warning**: Limited performance, basic testing only.

</details>

### Verify

```bash
minikube status  # All components: Running
```

---

## Step 4: Install Helm

### Installation

```bash
# Download and install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Verify

```bash
helm version  # Expected: v3.12.0+
```

---

## Step 5: Verify kubectl

```bash
kubectl version --client --short  # Expected: v1.27.0+
kubectl cluster-info  # Shows Kubernetes control plane
kubectl get nodes  # minikube Ready
```

---

## Step 6: Install Claude Code

```bash
# Download and install
curl -fsSL https://claude.ai/install.sh | bash

# Authenticate (opens browser)
claude auth login

# Verify
claude --version  # Expected: v1.0.0+
```

---

## Step 7: Install Goose

```bash
# Download and install
curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash

# Verify
goose --version  # Expected: v0.1.0+
```

---

## Step 8: Network Connectivity (Optional)

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
curl -I https://github.com  # Expected: HTTP/2 200
```

</details>

---

## Step 9: Run Verification

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

## Troubleshooting

- **Docker**: [Troubleshooting Guide](./troubleshooting.md#docker-issues)
- **Minikube**: [Troubleshooting Guide](./troubleshooting.md#minikube-issues)
- **kubectl**: [Troubleshooting Guide](./troubleshooting.md#kubectl-issues)

---

## Next Steps

1. [Verification Guide](./verification.md)
2. [Repository Setup](./repository-setup.md)
3. Start building with CAPS playbooks

**Linux Installation Complete!** 🎉

*Estimated: 20-30 minutes*
