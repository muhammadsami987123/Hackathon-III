# Troubleshooting

**Common Installation Problems and Solutions**

---

## TABLE OF CONTENTS

1. [Docker Issues](#docker-issues)
2. [Minikube Issues](#minikube-issues)
3. [kubectl Issues](#kubectl-issues)
4. [Claude Code and Goose Authentication](#claude-code-and-goose-authentication)
5. [General Issues](#general-issues)

---

## Docker Issues

### Problem: Docker Won't Start

**Symptoms**:
- "Cannot connect to Docker daemon" error
- Docker Desktop shows error state
- `docker ps` fails

**Solutions by Platform**:

**macOS**:
```bash
# Option 1: Open Docker Desktop manually
open -a Docker

# Wait 30-60 seconds for startup

# Option 2: Restart Docker Desktop
pkill Docker && open -a Docker

# Option 3: Check Docker Desktop in Applications
# - Go to Applications folder
# - Right-click Docker → Open
# - Authorize with password if prompted
```

**Linux**:
```bash
# Check Docker daemon status
sudo systemctl status docker

# Start Docker daemon
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Verify user in docker group
groups $USER
# If 'docker' not listed:
sudo usermod -aG docker $USER
newgrp docker
```

**Windows WSL**:
```bash
# Option 1: Restart Docker Desktop (in Windows)
# - Right-click Docker Desktop icon in system tray
# - Select "Restart"

# Option 2: Enable WSL integration in Docker Desktop
# - Open Docker Desktop Settings
# - Go to Resources → WSL integration
# - Enable Ubuntu-22.04
# - Apply & Restart

# Option 3: Check Docker is running in WSL
docker ps
# If fails, restart Docker Desktop in Windows
```

---

### Problem: "Permission Denied" When Running Docker

**Symptom**: `Got permission denied while trying to connect to the Docker daemon socket`

**Solution (Linux/WSL)**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply changes
newgrp docker

# Or logout and login again

# Verify
docker ps  # Should work without sudo
```

---

### Problem: Docker Out of Disk Space

**Symptoms**:
- "no space left on device"
- Minikube fails to start
- Container creation fails

**Solutions**:

```bash
# Clean up Docker resources
docker system prune -a --volumes

# Check disk usage
docker system df

# Remove unused images
docker image prune -a

# Remove stopped containers
docker container prune

# Remove unused volumes
docker volume prune
```

---

## Minikube Issues

### Problem: "Exiting due to DRV_NOT_HEALTHY"

**Symptom**: `Exiting due to DRV_NOT_HEALTHY: Found driver(s) but none were healthy`

**Solutions**:

```bash
# Solution 1: Delete and recreate cluster
minikube delete
minikube start --cpus=4 --memory=8192 --driver=docker

# Solution 2: Check Docker is running
docker ps
# If fails, fix Docker first (see Docker Issues above)

# Solution 3: For Mac M1/M2 (Apple Silicon)
minikube start --cpus=4 --memory=8192 --driver=docker --alsologtostderr
```

---

### Problem: "Insufficient Disk Space"

**Symptom**: `Exiting due to RSRC_INSUFFICIENT_SYS_INFO: not enough disk space`

**Solutions**:

```bash
# Check Minikube disk usage
minikube ssh "df -h"

# Delete and recreate with more disk space
minikube delete
minikube start --cpus=4 --memory=8192 --disk-size=50000mb --driver=docker

# Free up Docker space
docker system prune -a
```

---

### Problem: Minikube Won't Start After System Restart

**Solutions**:

```bash
# Check Minikube status
minikube status

# If stopped, restart
minikube start

# If fails, delete and recreate
minikube delete
minikube start --cpus=4 --memory=8192 --driver=docker
```

---

### Problem: Version Conflicts with Existing Minikube

**Symptom**: `Version skew detected` or incompatibility errors

**Solutions**:

**Using asdf (Recommended for side-by-side versions)**:
```bash
# Install asdf
brew install asdf  # macOS
# or follow https://asdf-vm.com/guide/getting-started.html

# Add minikube plugin
asdf plugin add minikube

# Install specific version
asdf install minikube 1.30.0

# Set local version
asdf local minikube 1.30.0

# Verify
minikube version
```

**Manual side-by-side installation**:
```bash
# Download specific version
curl -LO https://storage.googleapis.com/minikube/releases/v1.30.0/minikube-linux-amd64

# Install with version suffix
sudo install minikube-linux-amd64 /usr/local/bin/minikube-1.30

# Use versioned command
minikube-1.30 start --cpus=4 --memory=8192
```

---

## kubectl Issues

### Problem: "The connection to the server was refused"

**Symptom**: `The connection to the server localhost:8080 was refused`

**Solutions**:

```bash
# Check Minikube is running
minikube status

# If stopped, start it
minikube start

# Update kubectl context
minikube update-context

# Verify context
kubectl config current-context
# Should show: minikube

# Test connection
kubectl cluster-info
kubectl get nodes
```

---

### Problem: kubectl Not Found or Wrong Version

**Solutions**:

```bash
# Check version
kubectl version --client

# If missing or wrong version, reinstall

# macOS
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/kubectl

# Verify
kubectl version --client
```

---

### Problem: Multiple kubectl Contexts Confusion

**Symptoms**:
- Commands affect wrong cluster
- "context not found" errors

**Solutions**:

```bash
# List all contexts
kubectl config get-contexts

# Switch to minikube context
kubectl config use-context minikube

# Verify current context
kubectl config current-context

# View context details
kubectl config view
```

---

## Claude Code and Goose Authentication

### Problem: Claude Code Authentication Fails

**Symptoms**:
- Browser doesn't open
- "Authentication failed" error
- Token expired

**Solutions**:

```bash
# Solution 1: Logout and re-authenticate
claude auth logout
claude auth login
# Browser should open automatically

# Solution 2: Check Claude Code is latest version
claude --version

# macOS: Update
brew upgrade claude-code

# Linux/WSL: Reinstall
curl -fsSL https://claude.ai/install.sh | bash

# Solution 3: Manual browser authentication
# If browser doesn't open automatically:
# 1. Run: claude auth login
# 2. Copy the URL displayed
# 3. Open URL manually in browser
# 4. Complete authentication
# 5. Return to terminal
```

---

### Problem: Goose Not Recognized After Installation

**Solutions**:

```bash
# Check if in PATH
which goose

# If not found, add to PATH
# macOS/Linux: Add to ~/.zshrc or ~/.bashrc
export PATH="$PATH:$HOME/.goose/bin"

# Apply changes
source ~/.zshrc  # or source ~/.bashrc

# Verify
goose --version

# If still fails, reinstall
curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash
```

---

## General Issues

### Problem: Corporate Firewall/Proxy Blocks Downloads

**Symptoms**:
- "Connection timed out"
- "SSL certificate problem"
- Package installation fails

**Solutions**:

```bash
# Set proxy environment variables
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="http://proxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1,.local"

# For persistent configuration, add to shell profile
# ~/.zshrc (macOS) or ~/.bashrc (Linux/WSL)

# Test connectivity
curl -I https://github.com
# Should return: HTTP/2 200

# If SSL certificate issues
# Consult IT department for corporate CA certificate
```

**Note**: Deep proxy troubleshooting is beyond this guide's scope. Contact your IT department for organization-specific proxy configuration.

---

### Problem: Installation Fails Mid-Process

**Resume-from-Checkpoint Approach**:

1. **Identify last successful step**:
   - Check which tools are installed: Run verification commands
   - Review error messages

2. **Resume from failed step**:
   - Each platform guide includes "Check Current State" sections
   - Run checkpoint verification for failed tool
   - Restart installation from that step

3. **Verify partial installation**:
   ```bash
   # Check what's installed
   git --version
   docker --version
   minikube version
   kubectl version
   helm version
   claude --version
   goose --version
   ```

4. **Continue installation**:
   - Return to platform guide
   - Skip completed steps
   - Resume from first failed step

---

### Problem: Version Conflicts with Existing Installations

**Symptom**: Newer/older version already installed, conflicts with requirements

**Solution**: Use version managers for side-by-side installation

**asdf (Universal Version Manager)**:
```bash
# Install asdf
# macOS
brew install asdf

# Linux/WSL
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
source ~/.bashrc

# Add plugins for tools
asdf plugin add kubectl
asdf plugin add helm

# Install specific versions
asdf install kubectl 1.27.0
asdf install helm 3.12.0

# Set versions for current directory
asdf local kubectl 1.27.0
asdf local helm 3.12.0

# Verify
kubectl version
helm version
```

---

### Problem: Low-Resource System Performance Issues

**Symptoms**:
- Slow Minikube startup
- Pod evictions
- "Insufficient memory" errors

**Solutions**:

1. **Use reduced-resource configuration**:
   ```bash
   minikube start --cpus=2 --memory=4096 --driver=docker
   ```

2. **Limit deployed services**:
   - Run only essential services
   - Don't run full LearnFlow stack simultaneously

3. **Monitor resource usage**:
   ```bash
   # Check Minikube resources
   kubectl top nodes
   kubectl top pods

   # If commands fail, enable metrics-server
   minikube addons enable metrics-server
   ```

4. **Upgrade hardware if possible**:
   - Minimum viable: 2 CPU, 4GB RAM (basic testing only)
   - Recommended: 4+ CPU, 8GB+ RAM (full development)

---

### Problem: "Command Not Found" After Installation

**Symptom**: Tool installed but command not recognized

**Solutions**:

```bash
# Restart terminal to refresh PATH
# Or manually refresh:
source ~/.zshrc  # macOS (zsh)
source ~/.bashrc  # Linux/WSL (bash)

# Check PATH
echo $PATH

# Find where tool is installed
# macOS
which <command>
brew list <package> | grep bin

# Linux/WSL
whereis <command>
dpkg -L <package> | grep bin

# Add to PATH if needed (example)
export PATH="$PATH:/usr/local/bin"
# Add to ~/.zshrc or ~/.bashrc for persistence
```

---

## Still Having Issues?

If problems persist after trying these solutions:

1. **Run verification script**:
   ```bash
   bash docs/environment-setup/scripts/verify-environment.sh
   ```
   Review detailed diagnostic output

2. **Check logs**:
   - Docker: Docker Desktop → Troubleshoot → View logs
   - Minikube: `minikube logs`
   - kubectl: `kubectl logs <pod-name>`

3. **Review prerequisites**:
   - [Prerequisites Guide](./prerequisites.md)
   - Ensure system meets minimum requirements

4. **Consult project team**:
   - Check project constitution: `.specify/memory/constitution.md`
   - Review CAPS playbooks: `caps-library/playbooks/`
   - Ask team for assistance

---

**Troubleshooting Guide - Covers 80%+ Common Issues** ✓

*Part of Hackathon III: SP Constitution (Spec-Kit Plus)*
