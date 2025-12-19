---
# YAML Frontmatter - Required for CAPS compilation
# See: caps-library/docs/best-practices.md for detailed field descriptions

title: Your Playbook Title Here
# REQUIRED: Human-readable playbook name (3-80 characters)
# Example: "Kafka Kubernetes Setup"

description: One-sentence summary of what this playbook accomplishes
# REQUIRED: Brief description (10-300 characters)
# Example: "Deploy Apache Kafka on Kubernetes using Helm with topic creation and testing"

version: 1.0.0
# REQUIRED: Semantic version (MAJOR.MINOR.PATCH)
# - MAJOR: Breaking changes (incompatible with previous version)
# - MINOR: New features/steps (backwards compatible)
# - PATCH: Clarifications/fixes (no functional changes)

category: infrastructure
# RECOMMENDED: Playbook domain
# Options: infrastructure, backend, frontend, tools, deployment, integration, testing, database, documentation

tags:
  - kubernetes
  - helm
  - example
# RECOMMENDED: Searchable keywords (3-8 tags, lowercase-hyphenated)
# Use tags that users would search for

difficulty: intermediate
# RECOMMENDED: Complexity level
# Options: beginner, intermediate, advanced, expert

estimated_time: 20
# RECOMMENDED: Minutes to complete (wall-clock time including waits)
# Be realistic - include time for pods to start, downloads, etc.

allowed_tools:
  - bash
  - kubectl
  - helm
# REQUIRED: Array of tools used in playbook
# Common tools: bash, kubectl, helm, docker, git, python, npm, curl, jq, yq, terraform, ansible
# Validation will warn for unknown tools (but still compile)

prerequisites:
  - kubernetes_cluster_running
  - kubectl_configured
  - helm_installed
# REQUIRED: Array of testable conditions (snake_case format)
# Each prerequisite should be verifiable with a command
# Example: kubernetes_cluster_running → verified by `kubectl cluster-info`

dependencies:
  - namespace-setup
# OPTIONAL: Other playbook names that should run first (direct dependencies only)
# Use playbook directory names, not paths

skip_conditions:
  - resource_already_deployed
# OPTIONAL: Conditions where this playbook can be skipped
# Should be testable via bash/kubectl commands
---

# Your Playbook Title Here

<!-- Brief introduction paragraph expanding on the description -->
This playbook guides you through [detailed explanation of what the playbook does and why]. By the end, you will have [expected outcome].

## Prerequisites

<!-- Human-readable prerequisites with verification commands -->
Before starting this playbook, ensure the following prerequisites are met:

**Required Software:**
```bash
# Check Kubernetes cluster
kubectl cluster-info
# Expected: Kubernetes control plane is running at https://...

# Check kubectl version
kubectl version --client --output=yaml | grep gitVersion
# Expected: v1.27.0 or later

# Check Helm installed
helm version --short
# Expected: v3.12.0 or later
```

**Required Permissions:**
- Cluster admin access (for namespace creation)
- Ability to install Helm charts

**Required Environment Variables:**
```bash
# Check environment variables (if any)
echo $KUBECONFIG
# Should point to valid kubeconfig file
```

**Resource Requirements:**
- Kubernetes cluster with 4+ CPUs and 8GB+ RAM
- Available storage: 10GB for persistent volumes

## Instructions

<!-- Sequential execution steps with bash commands -->
<!-- Each step must have: Objective, Commands, Expected Output, Success Criteria -->

### Step 1: Create Namespace

**Objective:** Create an isolated Kubernetes namespace for the deployment

**Commands:**
```bash
# Create namespace
kubectl create namespace my-app

# Verify namespace creation
kubectl get namespace my-app
```

**Expected Output:**
```
namespace/my-app created

NAME     STATUS   AGE
my-app   Active   1s
```

**Success Criteria:**
- [ ] Namespace `my-app` exists in cluster
- [ ] Namespace status is `Active`
- [ ] No errors in kubectl output

---

### Step 2: Add Helm Repository

**Objective:** Add the Helm chart repository to local Helm configuration

**Commands:**
```bash
# Add Helm repository
helm repo add my-repo https://charts.example.com

# Update repository index
helm repo update

# Verify repository added
helm repo list
```

**Expected Output:**
```
"my-repo" has been added to your repositories

Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "my-repo" chart repository

NAME       URL
my-repo    https://charts.example.com
```

**Success Criteria:**
- [ ] Repository `my-repo` added successfully
- [ ] Repository index updated without errors
- [ ] Repository appears in `helm repo list`

---

### Step 3: Install Helm Chart

**Objective:** Deploy the application using Helm chart with custom values

**Commands:**
```bash
# Install Helm chart
helm install my-release my-repo/my-chart \
  --namespace my-app \
  --set replicas=3 \
  --set image.tag=v1.0.0 \
  --wait --timeout=5m

# Verify installation
helm list -n my-app
```

**Expected Output:**
```
NAME: my-release
LAST DEPLOYED: Thu Dec 19 19:00:00 2025
NAMESPACE: my-app
STATUS: deployed
REVISION: 1

NAME         NAMESPACE  REVISION  UPDATED                                  STATUS    CHART          APP VERSION
my-release   my-app     1         2025-12-19 19:00:00.000000000 +0000 UTC  deployed  my-chart-1.0.0 1.0.0
```

**Success Criteria:**
- [ ] Helm release `my-release` created successfully
- [ ] Release status is `deployed`
- [ ] All pods reach `Running` state (within 5 minutes)

---

### Step 4: Verify Deployment

**Objective:** Confirm that all resources are running and healthy

**Commands:**
```bash
# Check pod status
kubectl get pods -n my-app

# Check deployment status
kubectl get deployment -n my-app

# Check service
kubectl get svc -n my-app
```

**Expected Output:**
```
NAME                          READY   STATUS    RESTARTS   AGE
my-release-abc123-xyz         1/1     Running   0          2m

NAME         READY   UP-TO-DATE   AVAILABLE   AGE
my-release   3/3     3            3           2m

NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
my-release   ClusterIP   10.96.100.50   <none>        8080/TCP   2m
```

**Success Criteria:**
- [ ] All pods show `Running` status
- [ ] Deployment shows all replicas ready (3/3)
- [ ] Service has ClusterIP assigned
- [ ] No pods in `CrashLoopBackOff` or `Error` state

---

<!-- Add more steps as needed (Step 5, Step 6, etc.) -->
<!-- Maintain consecutive numbering (Step 1, Step 2, Step 3, ...) -->

## Validation

<!-- Success criteria as testable checklist items -->
Success criteria (all must pass):

- [ ] **Namespace Exists:** `kubectl get namespace my-app` returns Active status
- [ ] **Helm Release Deployed:** `helm list -n my-app` shows release with `deployed` status
- [ ] **Pods Running:** `kubectl get pods -n my-app` shows all pods in `Running` state
- [ ] **Service Accessible:** `kubectl get svc my-app -n my-app` shows CLUSTER-IP assigned
- [ ] **Endpoints Ready:** `kubectl get endpoints -n my-app` shows ready endpoints

**Quick Validation Script:**
```bash
# Run all validation checks
kubectl get namespace my-app && \
  helm list -n my-app | grep -q "deployed" && \
  kubectl get pods -n my-app | grep -q "Running" && \
  kubectl get svc -n my-app | grep -q "ClusterIP" && \
  echo "✅ All validation checks passed!" || \
  echo "❌ Some validation checks failed"
```

## Troubleshooting

<!-- Common errors documented with Problem/Symptoms/Root Cause/Check/Fix format -->

**Problem:** Pods stuck in Pending state
**Symptoms:** `kubectl get pods -n my-app` shows `Pending` for more than 5 minutes
**Root Cause:** Insufficient cluster resources (CPU/memory) or no available nodes
**Check:**
```bash
# Check pod events
kubectl describe pod <pod-name> -n my-app | grep -A 10 Events

# Check node resources
kubectl top nodes

# Check resource requests
kubectl describe pod <pod-name> -n my-app | grep -A 5 "Requests:"
```
**Fix:**
```bash
# If using Minikube, increase resources
minikube delete
minikube start --memory=8192 --cpus=4

# Verify resources available
kubectl top nodes

# Redeploy
helm upgrade my-release my-repo/my-chart -n my-app
```

---

**Problem:** ImagePullBackOff error
**Symptoms:** `kubectl get pods -n my-app` shows `ImagePullBackOff` or `ErrImagePull`
**Root Cause:** Container image not found in registry or authentication required
**Check:**
```bash
# Check pod events for image pull errors
kubectl describe pod <pod-name> -n my-app | grep -A 5 "Failed to pull image"

# Verify image name
kubectl get deployment my-release -n my-app -o yaml | grep image:
```
**Fix:**
```bash
# Verify image exists
docker pull <image-name>:<tag>

# If authentication required, create image pull secret
kubectl create secret docker-registry regcred \
  --docker-server=<registry-url> \
  --docker-username=<username> \
  --docker-password=<password> \
  -n my-app

# Update deployment to use secret
helm upgrade my-release my-repo/my-chart \
  --namespace my-app \
  --set imagePullSecrets[0].name=regcred
```

---

**Problem:** Helm installation timeout
**Symptoms:** `Error: timed out waiting for the condition` during helm install
**Root Cause:** Pods taking longer than timeout to become ready
**Check:**
```bash
# Check pod status
kubectl get pods -n my-app

# Check pod events
kubectl describe pod <pod-name> -n my-app
```
**Fix:**
```bash
# Increase timeout
helm install my-release my-repo/my-chart \
  --namespace my-app \
  --wait --timeout=10m  # Increased from 5m to 10m

# Or skip waiting and monitor manually
helm install my-release my-repo/my-chart \
  --namespace my-app \
  --wait=false

# Monitor progress
watch kubectl get pods -n my-app
```

---

<!-- Add more troubleshooting entries based on actual execution failures -->
<!-- After 3 occurrences of same error, MUST add troubleshooting entry -->

## Notes & References

<!-- Optional section for additional context -->

**Important Considerations:**
- This playbook creates resources that consume cluster resources
- Cleanup is required to free resources after testing
- Default configuration uses 3 replicas - adjust for your cluster size

**Performance:**
- Estimated execution time: 20 minutes (includes pod startup)
- Resource usage: ~2 CPU cores, ~4GB RAM
- Network bandwidth: ~500MB for image pulls

**Security:**
- Uses default service account (no RBAC configuration)
- No TLS/HTTPS configured (add for production)
- No network policies applied (cluster-default)

**Related Playbooks:**
- `namespace-setup` - Prerequisite for namespace creation
- `postgresql-k8s-setup` - Database setup for this application

**External References:**
- [Helm Chart Documentation](https://charts.example.com/my-chart)
- [Kubernetes Deployment Guide](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)

## Rollback Instructions

<!-- Optional section for undoing changes -->

If you need to rollback this deployment:

### Step 1: Uninstall Helm Release
```bash
# Remove Helm release
helm uninstall my-release -n my-app

# Verify removal
helm list -n my-app
# Should show no releases
```

### Step 2: Delete Namespace (Optional)
```bash
# Delete namespace (removes all resources)
kubectl delete namespace my-app

# Verify deletion
kubectl get namespace my-app
# Should show: Error from server (NotFound)
```

### Step 3: Verify Cleanup
```bash
# Verify no resources remain
kubectl get all -n my-app
# Should show: No resources found

# Verify no persistent volumes left
kubectl get pv | grep my-app
# Should show no results
```

## Next Steps

<!-- Optional section for post-completion actions -->

After completing this playbook:

1. **Configure Monitoring**: Set up Prometheus/Grafana for metrics
2. **Enable Logging**: Configure log aggregation (ELK/Loki)
3. **Add Ingress**: Expose service via Ingress controller
4. **Configure Autoscaling**: Set up HPA for automatic scaling
5. **Security Hardening**: Apply network policies and RBAC

## Version History

<!-- Track playbook evolution -->

| Version | Date       | Changes                          | Author |
|---------|------------|----------------------------------|--------|
| 1.0.0   | 2025-12-19 | Initial playbook                 | Claude |

---

**Compilation:** This playbook compiles to Claude Skills format using:
```bash
bash caps-library/scripts/caps-to-skills.sh <playbook-name> --validate
```

**For authoring guidelines, see**: [`caps-library/docs/best-practices.md`](./best-practices.md)
**For validation errors, see**: [`caps-library/docs/validation-guide.md`](./validation-guide.md)
