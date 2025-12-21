# macOS Installation

**Platform**: macOS (Intel & Apple Silicon)
**Package Manager**: Homebrew
**Estimated Time**: 15-20 minutes

**Prerequisites**: [Check Prerequisites](./prerequisites.md) before starting

---

## Overview

This guide walks you through installing all required tools for Hackathon III on macOS:
1. Homebrew (package manager)
2. Docker Desktop
3. Minikube
4. Helm
5. kubectl (installed with Minikube)
6. Claude Code
7. Goose

Each step includes **checkpoint verification** to support resume-from-failure.

---

## Step 0: Prerequisites Check

### Verify System Resources

```bash
# Check CPU cores (recommended: 4+, minimum: 2)
sysctl -n hw.ncpu

# Check RAM in GB
echo "$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 )) GB"

# Check free disk space
df -h /
```

### Verify Git

```bash
git --version
```

**Expected**: `git version 2.40.0+`

**If missing**: Run `xcode-select --install`

---

## Step 1: Install Homebrew

### Check Current State

```bash
brew --version
```

If command found → skip to Step 2
If "command not found" → proceed with installation

### Installation

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow on-screen instructions. May require password and Xcode Command Line Tools.

### Verify Success

```bash
brew --version
```

**Expected**: `Homebrew 4.0.0` or higher

---

## Step 2: Install Docker

### Check Current State

```bash
docker --version
```

If version 20.10+ → skip to Step 3
If command not found or older → proceed

### Installation

```bash
# Install Docker Desktop
brew install --cask docker

# Start Docker Desktop
open -a Docker
```

**Wait 30-60 seconds** for Docker to fully start (Docker icon appears in menu bar).

### Verify Success

```bash
docker --version
docker ps
```

**Expected**: `Docker version 20.10.0+` and no errors on `docker ps`

**Troubleshooting**: If Docker doesn't start:
1. Open Applications → Docker manually
2. Authorize with your password
3. Wait for Docker icon in menu bar

---

## Step 3: Install Minikube

### Check Current State

```bash
minikube version
```

If version 1.30+ → skip to Step 4
If command not found → proceed

### Installation

```bash
# Install Minikube
brew install minikube
```

### Verify Success

```bash
minikube version
```

**Expected**: `minikube version: v1.30.0+`

---

## Step 4: Start Minikube

### Recommended Configuration (4 CPU, 8GB RAM)

```bash
# Start Minikube cluster
minikube start --cpus=4 --memory=8192 --driver=docker
```

**First-time startup takes 2-3 minutes**. Expected output: `Done! kubectl is now configured...`

<details>
<summary>⚠️ Low-Resource Alternative (2 CPU, 4GB RAM)</summary>

**Warning**: This configuration may experience slower performance and cannot run full LearnFlow stack.

```bash
minikube start --cpus=2 --memory=4096 --driver=docker
```

**Limitations**:
- Cannot run all LearnFlow services simultaneously
- Suitable for basic testing and skill development only
- May experience pod evictions under memory pressure

</details>

### Verify Cluster Running

```bash
minikube status
```

**Expected Output**:
```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
```

---

## Step 5: Install Helm

### Check Current State

```bash
helm version
```

If version 3.12+ → skip to Step 6
If command not found → proceed

### Installation

```bash
# Install Helm
brew install helm
```

### Verify Success

```bash
helm version
```

**Expected**: `version.BuildInfo{Version:"v3.12.0"...}` or higher

---

## Step 6: Verify kubectl

kubectl is automatically installed with Minikube.

### Check Version

```bash
kubectl version --client --short
```

**Expected**: `Client Version: v1.27.0` or higher

### Test Cluster Connectivity

```bash
kubectl cluster-info
kubectl get nodes
```

**Expected**: Shows Kubernetes control plane URL and minikube node in Ready status

**Troubleshooting**: If connection fails:
```bash
minikube update-context
kubectl config use-context minikube
```

---

## Step 7: Install Claude Code

### Check Current State

```bash
claude --version
```

If version found → skip to Step 8
If command not found → proceed

### Installation

```bash
# Install Claude Code
brew install --cask claude-code

# Authenticate (opens browser)
claude auth login
```

Follow browser authentication flow. Login with your Claude account.

### Verify Success

```bash
claude --version
```

**Expected**: `Claude Code v1.0.0` or higher

---

## Step 8: Install Goose

### Check Current State

```bash
goose --version
```

If version found → you're done!
If command not found → proceed

### Installation

```bash
# Install Goose
brew install --cask block-goose
```

### Verify Success

```bash
goose --version
```

**Expected**: `Goose v0.1.0` or higher

---

## Step 9: Network Connectivity (Optional)

<details>
<summary>Corporate Firewall/Proxy Configuration</summary>

If you're behind a corporate firewall, set proxy environment variables:

### Set Proxy Variables

```bash
# Add to ~/.zshrc or ~/.bash_profile
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="http://proxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1,.local"
```

### Apply Changes

```bash
source ~/.zshrc  # or source ~/.bash_profile
```

### Test Connectivity

```bash
curl -I https://github.com
```

**Expected**: `HTTP/2 200`

**If fails**: Consult your IT department. Deep proxy troubleshooting is beyond this guide's scope.

</details>

---

## Step 10: Run Full Verification

```bash
# Run automated verification script
bash docs/environment-setup/scripts/verify-environment.sh
```

**Expected**: All checks pass with ✓ indicators

See [Verification Guide](./verification.md) for details.

---

## Next Steps

✅ **Installation Complete!**

1. **Run verification script** (if not already done)
2. **Set up repositories**: [Repository Setup Guide](./repository-setup.md)
3. **Start building**: Explore CAPS playbooks in `caps-library/playbooks/`

---

## Troubleshooting

If you encounter problems:
- **Docker issues**: [Troubleshooting - Docker](./troubleshooting.md#docker-issues)
- **Minikube issues**: [Troubleshooting - Minikube](./troubleshooting.md#minikube-issues)
- **kubectl issues**: [Troubleshooting - kubectl](./troubleshooting.md#kubectl-issues)
- **Authentication issues**: [Troubleshooting - Auth](./troubleshooting.md#claude-code-and-goose-authentication)

---

## Environment Variables (Shell Profile Configuration)

Add these to `~/.zshrc` (zsh) or `~/.bash_profile` (bash):

```bash
# Kubernetes
export KUBECONFIG=~/.kube/config

# Helm
export HELM_HOME=~/.helm

# Claude Code
export CLAUDE_HOME=~/.claude

# Minikube
export MINIKUBE_HOME=~/.minikube
```

**Apply changes**:
```bash
source ~/.zshrc  # or source ~/.bash_profile
```

---

**macOS Installation Complete!** 🎉

*Estimated completion time: 15-20 minutes*
*Part of Hackathon III: SP Constitution (Spec-Kit Plus)*
