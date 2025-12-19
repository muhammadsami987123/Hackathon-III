---
title: Dapr Kubernetes Installation
description: Install Dapr service mesh on Kubernetes cluster for microservices communication, state management, and pub/sub messaging
version: 1.0.0
category: infrastructure
tags:
  - dapr
  - kubernetes
  - service-mesh
  - microservices
difficulty: intermediate
estimated_time: 8
allowed_tools:
  - bash
  - dapr
  - kubectl
  - helm
prerequisites:
  - kubernetes_cluster_running
  - kubectl_configured
  - dapr_cli_installed
  - helm_installed
dependencies:
  - minikube-setup
skip_conditions:
  - dapr_already_installed
---

# Dapr Kubernetes Installation

This playbook installs Dapr (Distributed Application Runtime) on a Kubernetes cluster to enable microservices patterns required by LearnFlow. Dapr provides service-to-service invocation, state management, pub/sub messaging, and more per Constitution Principle IV (Kubernetes-Native Architecture).

By the end of this playbook, you will have:
- Dapr control plane deployed in dapr-system namespace
- Dapr sidecar injector configured
- Dapr components ready for state stores and pub/sub
- Validated Dapr installation with dashboard access

## Prerequisites

Before starting this playbook, ensure the following prerequisites are met:

**Required Software:**
```bash
# Check Kubernetes cluster running
kubectl cluster-info
# Expected: Kubernetes control plane is running at https://...

# Check kubectl version
kubectl version --client --short
# Expected: Client Version: v1.27.0 or later

# Check Dapr CLI installed
dapr version
# Expected: CLI version: 1.12.0 or later

# Check Helm installed
helm version --short
# Expected: v3.12.0 or later
```

**Cluster Requirements:**
- Kubernetes cluster running (Minikube recommended)
- At least 2 CPU cores and 4GB RAM available
- kubectl configured with cluster access
- No existing Dapr installation

**Check Existing Installation:**
```bash
# Check if Dapr already installed
kubectl get namespace dapr-system 2>/dev/null || echo "No Dapr installation found"
dapr status -k 2>/dev/null || echo "Dapr not initialized"
```

## Instructions

### Step 1: Verify Prerequisites

**Objective:** Confirm cluster is accessible and Dapr CLI is ready

**Commands:**
```bash
# Verify kubectl context
kubectl config current-context
# Should show your cluster (e.g., "minikube")

# Check cluster nodes
kubectl get nodes
# Should show at least one Ready node

# Verify Dapr CLI version
dapr version
# Should show CLI version 1.12.0+

# Check Helm repos (add Dapr repo if needed)
helm repo list | grep dapr || helm repo add dapr https://dapr.github.io/helm-charts/
helm repo update
```

**Expected Output:**
```
minikube

NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   10m   v1.27.0

CLI version: 1.12.0
Runtime version: n/a

"dapr" has been added to your repositories
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "dapr" chart repository
```

**Success Criteria:**
- [ ] kubectl can access cluster
- [ ] At least one node in Ready state
- [ ] Dapr CLI version >= 1.12.0
- [ ] Dapr Helm repo added

---

### Step 2: Initialize Dapr on Kubernetes

**Objective:** Install Dapr control plane components using Dapr CLI

**Commands:**
```bash
# Initialize Dapr on Kubernetes with Helm (recommended)
dapr init --kubernetes --wait --timeout 300

# This installs:
# - dapr-operator: Manages Dapr components
# - dapr-sidecar-injector: Injects Dapr sidecar into pods
# - dapr-placement: Manages actor placement
# - dapr-sentry: Certificate authority for mTLS

# Wait for installation to complete (may take 2-3 minutes)
```

**Expected Output:**
```
⌛  Making the jump to hyperspace...
ℹ️  Note: To install Dapr using Helm, see here: https://docs.dapr.io/getting-started/install-dapr-kubernetes/#install-with-helm-advanced

✅  Deploying the Dapr control plane to your cluster...
✅  Success! Dapr has been installed to namespace dapr-system. To verify, run `dapr status -k' in your terminal. To get started, go here: https://aka.ms/dapr-getting-started
```

**Success Criteria:**
- [ ] Dapr initialization completes without errors
- [ ] dapr-system namespace created
- [ ] Dapr control plane components deployed

---

### Step 3: Verify Dapr Control Plane Pods

**Objective:** Ensure all Dapr system components are running

**Commands:**
```bash
# Check dapr-system namespace
kubectl get namespace dapr-system

# List Dapr control plane pods
kubectl get pods -n dapr-system

# Check pod status details
kubectl get pods -n dapr-system -o wide

# Wait for all pods to be Ready (if not already)
kubectl wait --for=condition=Ready pods --all -n dapr-system --timeout=180s
```

**Expected Output:**
```
NAME          STATUS   AGE
dapr-system   Active   1m

NAME                                     READY   STATUS    RESTARTS   AGE
dapr-operator-xxxxxxxxxx-xxxxx           1/1     Running   0          1m
dapr-placement-server-0                  1/1     Running   0          1m
dapr-sentry-xxxxxxxxxx-xxxxx             1/1     Running   0          1m
dapr-sidecar-injector-xxxxxxxxxx-xxxxx   1/1     Running   0          1m

pod/dapr-operator-xxxxxxxxxx-xxxxx condition met
pod/dapr-placement-server-0 condition met
pod/dapr-sentry-xxxxxxxxxx-xxxxx condition met
pod/dapr-sidecar-injector-xxxxxxxxxx-xxxxx condition met
```

**Success Criteria:**
- [ ] dapr-system namespace exists
- [ ] 4 Dapr pods running: operator, placement, sentry, sidecar-injector
- [ ] All pods show 1/1 Ready status
- [ ] No pods in CrashLoopBackOff or Error state

---

### Step 4: Check Dapr Status

**Objective:** Verify Dapr installation health using Dapr CLI

**Commands:**
```bash
# Check Dapr status on Kubernetes
dapr status -k

# Check Dapr version (should show runtime version now)
dapr version

# Verify Dapr services
kubectl get svc -n dapr-system
```

**Expected Output:**
```
  NAME                   NAMESPACE    HEALTHY  STATUS   REPLICAS  VERSION  AGE  CREATED
  dapr-operator          dapr-system  True     Running  1         1.12.0   1m   2025-12-19 21:00.00
  dapr-placement-server  dapr-system  True     Running  1         1.12.0   1m   2025-12-19 21:00.00
  dapr-sentry            dapr-system  True     Running  1         1.12.0   1m   2025-12-19 21:00.00
  dapr-sidecar-injector  dapr-system  True     Running  1         1.12.0   1m   2025-12-19 21:00.00

CLI version: 1.12.0
Runtime version: 1.12.0

NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
dapr-api                ClusterIP   10.96.100.1     <none>        80/TCP              1m
dapr-placement-server   ClusterIP   None            <none>        50005/TCP,8201/TCP  1m
dapr-sentry             ClusterIP   10.96.100.2     <none>        80/TCP              1m
dapr-sidecar-injector   ClusterIP   10.96.100.3     <none>        443/TCP             1m
```

**Success Criteria:**
- [ ] All 4 Dapr components show HEALTHY status
- [ ] Runtime version displayed (1.12.0+)
- [ ] Dapr services accessible via ClusterIP

---

### Step 5: Deploy Dapr Dashboard (Optional but Recommended)

**Objective:** Install Dapr dashboard for visual monitoring and debugging

**Commands:**
```bash
# Install Dapr dashboard using Helm
helm upgrade --install dapr-dashboard dapr/dapr-dashboard \
  --namespace dapr-system \
  --wait

# Verify dashboard pod running
kubectl get pods -n dapr-system -l app.kubernetes.io/name=dapr-dashboard

# Get dashboard service
kubectl get svc dapr-dashboard -n dapr-system
```

**Expected Output:**
```
Release "dapr-dashboard" does not exist. Installing it now.
NAME: dapr-dashboard
LAST DEPLOYED: Thu Dec 19 21:00:00 2025
NAMESPACE: dapr-system
STATUS: deployed
REVISION: 1

NAME                                 READY   STATUS    RESTARTS   AGE
dapr-dashboard-xxxxxxxxxx-xxxxx      1/1     Running   0          30s

NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
dapr-dashboard   ClusterIP   10.96.100.10   <none>        8080/TCP   30s
```

**Success Criteria:**
- [ ] Dapr dashboard Helm release installed
- [ ] Dashboard pod Running with 1/1 Ready
- [ ] Dashboard service accessible on port 8080

---

### Step 6: Access Dapr Dashboard

**Objective:** Set up port forwarding to access dashboard from localhost

**Commands:**
```bash
# Port forward dashboard to localhost (run in background)
kubectl port-forward -n dapr-system svc/dapr-dashboard 8080:8080 &

# Get port forward PID for later cleanup
echo "Port forward PID: $!"

# Wait a moment for port forward to establish
sleep 3

# Test dashboard accessibility
curl -s http://localhost:8080 | grep -q "Dapr Dashboard" && echo "✓ Dashboard accessible" || echo "✗ Dashboard not accessible"

# Open dashboard in browser (optional)
# Visit: http://localhost:8080
echo "Dapr Dashboard available at: http://localhost:8080"

# Stop port forward when done (replace PID)
# kill <PID>
```

**Expected Output:**
```
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Port forward PID: 12345
✓ Dashboard accessible
Dapr Dashboard available at: http://localhost:8080
```

**Success Criteria:**
- [ ] Port forward established successfully
- [ ] Dashboard accessible at localhost:8080
- [ ] Dashboard UI loads without errors

---

## Validation

Success criteria (all must pass):

- [ ] **Namespace Exists:** `kubectl get namespace dapr-system && echo "PASS"`
- [ ] **Dapr Healthy:** `dapr status -k | grep -c "True" | grep -q "4" && echo "PASS"`
- [ ] **Pods Running:** `kubectl get pods -n dapr-system | grep -c "Running" | grep -q "4" && echo "PASS"`
- [ ] **Services Created:** `kubectl get svc -n dapr-system | wc -l | grep -q "[4-9]" && echo "PASS"`
- [ ] **Dashboard Accessible:** `curl -s http://localhost:8080 | grep -q "Dapr" && echo "PASS"`

**Quick Validation Script:**
```bash
# Run all validation checks
kubectl get namespace dapr-system >/dev/null 2>&1 && \
  dapr status -k | grep -q "True" && \
  kubectl get pods -n dapr-system | grep -q "Running" && \
  kubectl get svc -n dapr-system | grep -q "dapr-api" && \
  echo "✅ All validation checks passed!" || \
  echo "❌ Some validation checks failed"
```

## Troubleshooting

**Problem:** Dapr init fails with timeout
**Symptoms:** `Error: timed out waiting for the condition` during `dapr init -k`
**Root Cause:** Slow image pulls or insufficient cluster resources
**Check:**
```bash
# Check pod status
kubectl get pods -n dapr-system

# Check pod events
kubectl describe pod -n dapr-system

# Check node resources
kubectl top nodes
```
**Fix:**
```bash
# Uninstall failed Dapr installation
dapr uninstall --kubernetes

# Increase timeout and retry
dapr init --kubernetes --wait --timeout 600

# Or manually verify pods are starting
kubectl wait --for=condition=Ready pods --all -n dapr-system --timeout=300s
```

---

**Problem:** Dapr pods in ImagePullBackOff
**Symptoms:** `kubectl get pods -n dapr-system` shows ImagePullBackOff status
**Root Cause:** Cannot pull Dapr images from registry (network or auth issue)
**Check:**
```bash
# Check pod events for image pull errors
kubectl describe pod -n dapr-system | grep -A 10 "Events:"

# Verify Docker Hub accessibility
curl -s https://registry.hub.docker.com/ | head -5
```
**Fix:**
```bash
# Option 1: Use image mirror (China regions)
dapr uninstall --kubernetes
helm install dapr dapr/dapr --namespace dapr-system --create-namespace \
  --set global.registry=registry.cn-hangzhou.aliyuncs.com/dapr

# Option 2: Pre-pull images manually
docker pull daprio/dapr:1.12.0
docker pull daprio/dashboard:0.14.0
minikube image load daprio/dapr:1.12.0
minikube image load daprio/dashboard:0.14.0

# Retry installation
dapr init --kubernetes --wait
```

---

**Problem:** Dapr sidecar-injector webhook fails
**Symptoms:** New pods with Dapr annotations fail to start, admission webhook errors
**Root Cause:** Sidecar injector not ready or certificate issues
**Check:**
```bash
# Check sidecar injector pod logs
kubectl logs -n dapr-system -l app=dapr-sidecar-injector

# Check webhook configuration
kubectl get mutatingwebhookconfiguration dapr-sidecar-injector

# Test webhook endpoint
kubectl get validatingwebhookconfiguration
```
**Fix:**
```bash
# Restart sidecar injector
kubectl rollout restart deployment dapr-sidecar-injector -n dapr-system

# Wait for rollout to complete
kubectl rollout status deployment dapr-sidecar-injector -n dapr-system

# Regenerate certificates (if certificate errors)
dapr uninstall --kubernetes
dapr init --kubernetes --wait
```

---

**Problem:** Dapr dashboard not accessible
**Symptoms:** Port forward established but `curl localhost:8080` fails
**Root Cause:** Dashboard pod not running or wrong service name
**Check:**
```bash
# Check dashboard pod status
kubectl get pods -n dapr-system -l app.kubernetes.io/name=dapr-dashboard

# Check dashboard pod logs
kubectl logs -n dapr-system -l app.kubernetes.io/name=dapr-dashboard

# Verify service exists
kubectl get svc dapr-dashboard -n dapr-system
```
**Fix:**
```bash
# Kill existing port forward
pkill -f "port-forward.*dapr-dashboard"

# Re-install dashboard
helm uninstall dapr-dashboard -n dapr-system
helm install dapr-dashboard dapr/dapr-dashboard -n dapr-system --wait

# Restart port forward
kubectl port-forward -n dapr-system svc/dapr-dashboard 8080:8080
```

---

**Problem:** Namespace dapr-system stuck in Terminating
**Symptoms:** `kubectl delete namespace dapr-system` hangs indefinitely
**Root Cause:** Finalizers or resources blocking namespace deletion
**Check:**
```bash
# Check namespace details
kubectl get namespace dapr-system -o yaml

# List resources in namespace
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n dapr-system
```
**Fix:**
```bash
# Force remove finalizers
kubectl get namespace dapr-system -o json | \
  jq '.spec.finalizers = []' | \
  kubectl replace --raw "/api/v1/namespaces/dapr-system/finalize" -f -

# Or use Dapr CLI to clean up
dapr uninstall --kubernetes --all

# Force delete if still stuck (last resort)
kubectl delete namespace dapr-system --force --grace-period=0
```

## Notes & References

**Important Considerations:**
- Dapr adds sidecar containers to pods (increases resource usage per pod)
- mTLS enabled by default for service-to-service communication
- Dapr components (state stores, pub/sub) configured separately per application
- Dashboard is for dev/debug only - not production grade

**Performance:**
- Estimated execution time: 8 minutes (2-3 minutes for Dapr init, 1 minute for dashboard)
- Resource usage: ~500MB RAM for Dapr control plane, ~50MB per sidecar
- Network: Downloads ~200MB of Dapr images on first install

**Security:**
- Dapr Sentry provides automatic mTLS between services
- Certificate rotation handled automatically
- Use Kubernetes secrets for sensitive configuration
- Dashboard should not be exposed externally (use port-forward only)

**Related Playbooks:**
- `minikube-setup` - Prerequisite: Set up K8s cluster first
- `kafka-k8s-setup` - Deploy Kafka for Dapr pub/sub component
- `postgresql-k8s-setup` - Deploy PostgreSQL for Dapr state store
- `fastapi-service-template` - Generate FastAPI service with Dapr sidecar

**External References:**
- [Dapr Documentation](https://docs.dapr.io/)
- [Dapr on Kubernetes](https://docs.dapr.io/operations/hosting/kubernetes/)
- [Dapr Components](https://docs.dapr.io/concepts/components-concept/)
- [Dapr Dashboard](https://docs.dapr.io/reference/cli/dapr-dashboard/)

**Common Dapr Components for LearnFlow:**
```yaml
# State Store (PostgreSQL)
# Pub/Sub (Kafka)
# Service Invocation (built-in)
# Secrets (Kubernetes secrets)
```

**Cleanup Commands:**
```bash
# Stop port forward
pkill -f "port-forward.*dapr-dashboard"

# Uninstall Dapr
dapr uninstall --kubernetes

# Delete dashboard
helm uninstall dapr-dashboard -n dapr-system

# Delete namespace (if desired)
kubectl delete namespace dapr-system
```

## Version History

| Version | Date       | Changes                          | Author |
|---------|------------|----------------------------------|--------|
| 1.0.0   | 2025-12-19 | Initial playbook                 | Claude |

---

**Compilation:** This playbook compiles to Claude Skills format using:
```bash
bash caps-library/scripts/caps-to-skills.sh dapr-k8s-install --validate
```

**For authoring guidelines, see**: [`caps-library/docs/best-practices.md`](../../caps-library/docs/best-practices.md)
**For validation errors, see**: [`caps-library/docs/validation-guide.md`](../../caps-library/docs/validation-guide.md)
