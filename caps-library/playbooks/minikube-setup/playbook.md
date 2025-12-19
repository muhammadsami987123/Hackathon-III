---
title: Minikube Kubernetes Cluster Setup
description: Create local Kubernetes cluster with Minikube optimized for LearnFlow development (4 CPU, 8GB RAM)
version: 1.0.0
category: infrastructure
tags:
  - kubernetes
  - minikube
  - local-development
  - cluster-setup
difficulty: beginner
estimated_time: 10
allowed_tools:
  - bash
  - minikube
  - kubectl
prerequisites:
  - minikube_installed
  - kubectl_installed
  - virtualization_enabled
skip_conditions:
  - minikube_already_running
---

# Minikube Kubernetes Cluster Setup

This playbook sets up a local Kubernetes cluster using Minikube with resource allocations optimized for LearnFlow development. The cluster is configured with 4 CPUs and 8GB RAM per Constitution Principle IV (Kubernetes-Native Architecture).

By the end of this playbook, you will have:
- Minikube cluster running with adequate resources
- kubectl configured to access the cluster
- Cluster validated and ready for Dapr installation
- Ingress addon enabled for external access

## Prerequisites

Before starting this playbook, ensure the following prerequisites are met:

**Required Software:**
```bash
# Check Minikube installed
minikube version
# Expected: minikube version: v1.30.0 or later

# Check kubectl installed
kubectl version --client --short
# Expected: Client Version: v1.27.0 or later

# Check virtualization support
# Linux/macOS:
egrep -q 'vmx|svm' /proc/cpuinfo && echo "✓ Virtualization enabled" || echo "✗ Virtualization disabled"
# Windows (PowerShell):
# systeminfo | findstr /i "Virtualization"
# Should show: Enabled
```

**System Requirements:**
- At least 8GB RAM available (system should have 12GB+ total)
- At least 4 CPU cores available
- 20GB free disk space
- Virtualization enabled in BIOS

**Check Existing Cluster:**
```bash
# Check if Minikube is already running
minikube status 2>/dev/null || echo "No cluster running"
# If running, consider deleting first: minikube delete
```

## Instructions

### Step 1: Stop and Delete Existing Cluster (If Any)

**Objective:** Clean slate by removing any existing Minikube cluster

**Commands:**
```bash
# Check current status
minikube status 2>/dev/null

# Delete existing cluster if present
minikube delete

# Verify deletion
minikube status 2>/dev/null || echo "✓ No cluster exists"
```

**Expected Output:**
```
🔥  Deleting "minikube" in docker ...
🔥  Deleting container "minikube" ...
🔥  Removing /home/user/.minikube/machines/minikube ...
💀  Removed all traces of the "minikube" cluster.
✓ No cluster exists
```

**Success Criteria:**
- [ ] Previous Minikube cluster deleted (if existed)
- [ ] minikube status returns "not found" or similar

---

### Step 2: Start Minikube with LearnFlow Configuration

**Objective:** Create new Minikube cluster with 4 CPU and 8GB RAM per constitution

**Commands:**
```bash
# Start Minikube with LearnFlow-optimized configuration
minikube start \
  --cpus=4 \
  --memory=8192 \
  --disk-size=20g \
  --driver=docker \
  --kubernetes-version=v1.27.0

# Wait for cluster to be ready (this may take 2-5 minutes)
# Minikube will download images on first run
```

**Expected Output:**
```
😄  minikube v1.30.1 on Ubuntu 22.04
✨  Using the docker driver based on user configuration
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
🔥  Creating docker container (CPUs=4, Memory=8192MB) ...
🐳  Preparing Kubernetes v1.27.0 on Docker 24.0.4 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

**Success Criteria:**
- [ ] Minikube cluster created successfully
- [ ] Cluster has 4 CPUs allocated
- [ ] Cluster has 8GB RAM allocated
- [ ] kubectl context switched to minikube

---

### Step 3: Verify Cluster Resources

**Objective:** Confirm cluster is running with correct resource allocations

**Commands:**
```bash
# Check cluster status
minikube status

# Verify node resources
kubectl get nodes

# Check node capacity (CPU and memory)
kubectl describe node minikube | grep -A 5 "Capacity:"

# Verify kubectl context
kubectl config current-context
# Expected: minikube
```

**Expected Output:**
```
# minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

# kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   2m    v1.27.0

# kubectl describe node (capacity section)
Capacity:
  cpu:                4
  ephemeral-storage:  20Gi
  hugepages-2Mi:      0
  memory:             8192Mi
  pods:               110
```

**Success Criteria:**
- [ ] Cluster status shows all components Running
- [ ] Node shows Ready status
- [ ] CPU capacity is 4
- [ ] Memory capacity is 8192Mi (8GB)
- [ ] kubectl context is "minikube"

---

### Step 4: Enable Essential Addons

**Objective:** Enable Minikube addons required for LearnFlow (ingress, metrics)

**Commands:**
```bash
# Enable ingress addon (for external access)
minikube addons enable ingress

# Enable metrics-server addon (for kubectl top)
minikube addons enable metrics-server

# List enabled addons
minikube addons list | grep enabled
```

**Expected Output:**
```
🔎  Verifying ingress addon...
🌟  The 'ingress' addon is enabled

🔎  Verifying metrics-server addon...
🌟  The 'metrics-server' addon is enabled

# Enabled addons:
✅  default-storageclass: enabled
✅  ingress: enabled
✅  metrics-server: enabled
✅  storage-provisioner: enabled
```

**Success Criteria:**
- [ ] Ingress addon enabled
- [ ] Metrics-server addon enabled
- [ ] Both addons show as active in addon list

---

### Step 5: Wait for Ingress Controller to Be Ready

**Objective:** Ensure ingress-nginx controller is fully deployed before proceeding

**Commands:**
```bash
# Wait for ingress-nginx namespace to be created
kubectl wait --for=condition=Ready namespace/ingress-nginx --timeout=60s 2>/dev/null || echo "Namespace not yet ready, checking pods..."

# Check ingress controller pods
kubectl get pods -n ingress-nginx

# Wait for ingress controller to be ready (may take 1-2 minutes)
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

**Expected Output:**
```
namespace/ingress-nginx condition met

NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-xxxxx        0/1     Completed   0          1m
ingress-nginx-admission-patch-xxxxx         0/1     Completed   1          1m
ingress-nginx-controller-xxxxxxxxxx-xxxxx   1/1     Running     0          1m

pod/ingress-nginx-controller-xxxxxxxxxx-xxxxx condition met
```

**Success Criteria:**
- [ ] ingress-nginx namespace exists
- [ ] ingress-nginx-controller pod is Running
- [ ] Pod shows 1/1 Ready status

---

### Step 6: Verify Cluster Accessibility

**Objective:** Validate kubectl can communicate with cluster and create resources

**Commands:**
```bash
# Check cluster info
kubectl cluster-info

# Create test namespace to verify write permissions
kubectl create namespace test-minikube

# List namespaces (should include test-minikube)
kubectl get namespaces

# Delete test namespace (cleanup)
kubectl delete namespace test-minikube

# Check default service account exists
kubectl get serviceaccount default -n default
```

**Expected Output:**
```
Kubernetes control plane is running at https://192.168.49.2:8443
CoreDNS is running at https://192.168.49.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

namespace/test-minikube created

NAME              STATUS   AGE
default           Active   5m
ingress-nginx     Active   3m
kube-node-lease   Active   5m
kube-public       Active   5m
kube-system       Active   5m
test-minikube     Active   1s

namespace "test-minikube" deleted

NAME      SECRETS   AGE
default   0         5m
```

**Success Criteria:**
- [ ] Cluster info shows control plane URL
- [ ] Able to create namespace successfully
- [ ] Able to delete namespace successfully
- [ ] Default service account exists

---

## Validation

Success criteria (all must pass):

- [ ] **Cluster Running:** `minikube status | grep -q "Running" && echo "PASS"`
- [ ] **Correct CPU:** `kubectl get node minikube -o jsonpath='{.status.capacity.cpu}' | grep -q "4" && echo "PASS"`
- [ ] **Correct Memory:** `kubectl get node minikube -o jsonpath='{.status.capacity.memory}' | grep -q "8[0-9]*Mi" && echo "PASS"`
- [ ] **Kubectl Context:** `kubectl config current-context | grep -q "minikube" && echo "PASS"`
- [ ] **Ingress Enabled:** `minikube addons list | grep ingress | grep -q enabled && echo "PASS"`
- [ ] **Node Ready:** `kubectl get node minikube | grep -q "Ready" && echo "PASS"`

**Quick Validation Script:**
```bash
# Run all validation checks
minikube status | grep -q "Running" && \
  kubectl get node minikube -o jsonpath='{.status.capacity.cpu}' | grep -q "4" && \
  kubectl get node minikube -o jsonpath='{.status.capacity.memory}' | grep -q "8[0-9]*Mi" && \
  kubectl config current-context | grep -q "minikube" && \
  kubectl get node minikube | grep -q "Ready" && \
  echo "✅ All validation checks passed!" || \
  echo "❌ Some validation checks failed"
```

## Troubleshooting

**Problem:** Insufficient system resources
**Symptoms:** `Error: Insufficient memory` or `Error: Insufficient CPUs` during minikube start
**Root Cause:** System doesn't have 8GB RAM or 4 CPUs available
**Check:**
```bash
# Check available system resources
# Linux/macOS:
free -h
nproc

# Windows (PowerShell):
# systeminfo | findstr /C:"Total Physical Memory"
```
**Fix:**
```bash
# Option 1: Reduce resource allocation (not recommended for LearnFlow)
minikube start --cpus=2 --memory=4096

# Option 2: Close other applications to free resources

# Option 3: Increase system RAM (hardware upgrade)
```

---

**Problem:** Driver not found or virtualization disabled
**Symptoms:** `Error: No compatible driver found` or `VT-x is disabled`
**Root Cause:** Virtualization not enabled in BIOS or Docker/VirtualBox not installed
**Check:**
```bash
# Check virtualization support
# Linux:
egrep -q 'vmx|svm' /proc/cpuinfo && echo "Enabled" || echo "Disabled"

# Check Docker running
docker ps
# Should not error

# Check available drivers
minikube start --help | grep "driver string"
```
**Fix:**
```bash
# Option 1: Enable virtualization in BIOS (restart required)
# Access BIOS during boot (F2/Del key), enable Intel VT-x or AMD-V

# Option 2: Use Docker driver (if Docker installed)
minikube start --driver=docker --cpus=4 --memory=8192

# Option 3: Install Docker Desktop
# https://docs.docker.com/get-docker/
```

---

**Problem:** Minikube start hangs or times out
**Symptoms:** `Waiting for control plane...` hangs for >10 minutes
**Root Cause:** Network issues, slow image download, or corrupted cache
**Check:**
```bash
# Check Docker daemon running (if using docker driver)
docker ps

# Check network connectivity
ping -c 3 registry.k8s.io

# Check Minikube logs
minikube logs
```
**Fix:**
```bash
# Stop hung process
minikube stop
minikube delete

# Clear Minikube cache
rm -rf ~/.minikube/cache

# Retry with verbose output
minikube start --cpus=4 --memory=8192 --driver=docker -v=7

# If network issues, try different image repository
minikube start --cpus=4 --memory=8192 --image-repository=registry.aliyuncs.com/google_containers
```

---

**Problem:** Ingress controller not starting
**Symptoms:** `ingress-nginx-controller` pod stuck in Pending or CrashLoopBackOff
**Root Cause:** Port conflict or insufficient resources
**Check:**
```bash
# Check pod events
kubectl describe pod -n ingress-nginx -l app.kubernetes.io/component=controller

# Check pod logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller

# Check if ports 80/443 are available on host
# Linux/macOS:
sudo lsof -i :80
sudo lsof -i :443
```
**Fix:**
```bash
# Restart Minikube with port bindings
minikube stop
minikube start --cpus=4 --memory=8192

# Re-enable ingress
minikube addons disable ingress
sleep 10
minikube addons enable ingress

# Wait for controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s
```

---

**Problem:** kubectl commands fail with connection refused
**Symptoms:** `The connection to the server 127.0.0.1:8443 was refused`
**Root Cause:** Cluster not running or kubectl not configured
**Check:**
```bash
# Check Minikube status
minikube status

# Check kubectl config
kubectl config view

# Check current context
kubectl config current-context
```
**Fix:**
```bash
# Restart Minikube
minikube stop
minikube start --cpus=4 --memory=8192

# Update kubectl context
minikube update-context

# Verify connection
kubectl cluster-info
```

## Notes & References

**Important Considerations:**
- Minikube uses 8GB RAM - ensure system has 12GB+ total to avoid swapping
- First start downloads images (~2GB) - subsequent starts are faster
- Cluster persists across reboots (data in ~/.minikube/)
- Use `minikube stop` (not delete) to preserve state between sessions

**Performance:**
- Estimated execution time: 10 minutes (5 minutes first run with image downloads)
- Resource usage: 4 CPU cores, 8GB RAM (dedicated to Minikube)
- Disk usage: ~20GB for cluster, images, and persistent volumes

**Security:**
- Minikube runs on localhost - not exposed externally by default
- No TLS/HTTPS configured for ingress (add for production)
- Default RBAC policies active - follow principle of least privilege

**Related Playbooks:**
- `dapr-k8s-install` - Install Dapr on this cluster (next step)
- `kafka-k8s-setup` - Deploy Kafka for messaging (requires Dapr)
- `postgresql-k8s-setup` - Deploy PostgreSQL for storage
- `learnflow-project-init` - Bootstrap LearnFlow project structure

**External References:**
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Ingress NGINX Controller](https://kubernetes.github.io/ingress-nginx/)

**Stopping and Restarting:**
```bash
# Stop cluster (preserves state)
minikube stop

# Start existing cluster
minikube start

# Delete cluster (removes all data)
minikube delete
```

## Version History

| Version | Date       | Changes                          | Author |
|---------|------------|----------------------------------|--------|
| 1.0.0   | 2025-12-19 | Initial playbook                 | Claude |

---

**Compilation:** This playbook compiles to Claude Skills format using:
```bash
bash caps-library/scripts/caps-to-skills.sh minikube-setup --validate
```

**For authoring guidelines, see**: [`caps-library/docs/best-practices.md`](../../caps-library/docs/best-practices.md)
**For validation errors, see**: [`caps-library/docs/validation-guide.md`](../../caps-library/docs/validation-guide.md)
