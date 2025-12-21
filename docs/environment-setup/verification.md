# Verification

**Post-Installation Validation**: Verify all tools are correctly installed and configured

---

## Quick Verification

Run the automated verification script for comprehensive checking:

```bash
bash docs/environment-setup/scripts/verify-environment.sh
```

**Expected Output**: All checks pass with ✓ indicators

The script checks:
- Git, Docker, Minikube, kubectl, Helm, Claude Code, Goose
- Minikube cluster status
- kubectl cluster connectivity
- Tool versions vs. requirements
- Platform-specific remediation steps for failures

---

## Manual Verification Steps

If you prefer to verify manually or troubleshoot specific tools:

### 1. Git Verification

```bash
git --version
```

**Expected**: `git version 2.40.0` or higher

**If Fails**: Reinstall git following [prerequisites guide](./prerequisites.md#git-installation)

---

### 2. Docker Verification

```bash
docker --version
```

**Expected**: `Docker version 20.10.0` or higher

**Test Docker Functionality**:
```bash
docker ps
```

**Expected**: No errors (table of running containers, may be empty)

**If Fails**: Check [troubleshooting - Docker](./troubleshooting.md#docker-issues)

---

### 3. Minikube Verification

```bash
minikube version
```

**Expected**: `minikube version: v1.30.0` or higher

**Check Cluster Status**:
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
kubeconfig: Configured
```

**If Fails**: Check [troubleshooting - Minikube](./troubleshooting.md#minikube-issues)

---

### 4. kubectl Verification

```bash
kubectl version --client --short
```

**Expected**: `Client Version: v1.27.0` or higher

**Test Cluster Connectivity**:
```bash
kubectl cluster-info
```

**Expected**: Shows Kubernetes control plane and CoreDNS URLs

**List Nodes**:
```bash
kubectl get nodes
```

**Expected**: Shows minikube node in Ready status

**If Fails**: Check [troubleshooting - kubectl](./troubleshooting.md#kubectl-issues)

---

### 5. Helm Verification

```bash
helm version
```

**Expected**: `version.BuildInfo{Version:"v3.12.0"...}` or higher

**List Repositories**:
```bash
helm repo list
```

**Expected**: May show "no repositories" initially (this is normal)

**If Fails**: Reinstall helm following your platform guide

---

### 6. Claude Code Verification

```bash
claude --version
```

**Expected**: `Claude Code v1.0.0` or higher

**Authentication Check**:
```bash
# Check if authenticated (may prompt for login)
claude auth status
```

**Expected**: Shows authenticated status or prompts to login

**If Fails**: Check [troubleshooting - Authentication](./troubleshooting.md#claude-code-and-goose-authentication)

---

### 7. Goose Verification

```bash
goose --version
```

**Expected**: `Goose v0.1.0` or higher

**If Fails**: Reinstall goose following your platform guide

---

## Cluster Functionality Test

### Create a Test Deployment

```bash
# Create a test nginx deployment
kubectl create deployment test-nginx --image=nginx

# Check deployment status
kubectl get deployments

# Expected: test-nginx deployment shows READY 1/1
```

### Expose the Deployment

```bash
# Expose as a service
kubectl expose deployment test-nginx --port=80 --type=NodePort

# Get service URL
minikube service test-nginx --url
```

**Expected**: Returns a URL (e.g., `http://192.168.49.2:31234`)

### Test Access

```bash
# Get the URL and curl it
curl $(minikube service test-nginx --url)
```

**Expected**: HTML output from nginx welcome page

### Cleanup

```bash
# Delete test resources
kubectl delete deployment test-nginx
kubectl delete service test-nginx
```

**If Test Fails**: Check [troubleshooting - Minikube/kubectl](./troubleshooting.md)

---

## Verification Checklist

After completing verification, ensure:

- [ ] Git version 2.40+ installed
- [ ] Docker version 20.10+ installed and running
- [ ] Minikube version 1.30+ installed
- [ ] Minikube cluster is running (status: Running)
- [ ] kubectl version 1.27+ installed
- [ ] kubectl can connect to Minikube cluster
- [ ] Helm version 3.12+ installed
- [ ] Claude Code latest version installed and authenticated
- [ ] Goose latest version installed
- [ ] Test deployment/service creation works

**All checked?** Your environment is ready for Hackathon III!

---

## Verification Script Details

The automated verification script (`scripts/verify-environment.sh`) provides:

- **Detailed Diagnostics**: Shows version found vs. expected for each tool
- **Colored Output**: Green ✓ for pass, Red ✗ for fail
- **Remediation Steps**: Platform-specific commands to fix failures
- **Exit Codes**: 0 (all pass), 1 (failures), 2 (script error)

**Script Usage**:
```bash
# Run from repository root
bash docs/environment-setup/scripts/verify-environment.sh

# Or make executable and run
chmod +x docs/environment-setup/scripts/verify-environment.sh
./docs/environment-setup/scripts/verify-environment.sh
```

---

## Next Steps

✅ **Environment Verified**: Proceed to [Repository Setup](./repository-setup.md)

❌ **Verification Failed**: Check [Troubleshooting Guide](./troubleshooting.md)

**Need Help?** Consult troubleshooting section or project team.

---

*This verification process ensures all tools are correctly installed and configured for CAPS-first development and Kubernetes-native architecture per project constitution.*
