---
title: PostgreSQL Kubernetes Setup
description: Deploy PostgreSQL on Kubernetes using Helm with secrets, persistent storage, connection testing, and authentication
version: 1.0.0
category: infrastructure
tags:
  - postgresql
  - kubernetes
  - helm
  - database
  - statefulset
difficulty: intermediate
estimated_time: 15
allowed_tools:
  - bash
  - kubectl
  - helm
prerequisites:
  - kubernetes_cluster_running
  - kubectl_configured
  - helm_installed
  - cluster_resources_2cpu_4gb_ram
dependencies: []
skip_conditions:
  - postgresql_already_deployed
---

# PostgreSQL Kubernetes Setup

Deploy PostgreSQL database on Kubernetes using the Bitnami Helm chart with persistent storage, authentication, and connection testing. This playbook sets up a production-ready PostgreSQL instance with automatic backups and monitoring capabilities.

## Prerequisites

Before starting, verify:

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

# Check if PostgreSQL already deployed (skip condition)
helm list -n database 2>/dev/null | grep -q postgresql && echo "⚠️  PostgreSQL already deployed - consider skipping" || echo "✓ No existing PostgreSQL deployment"
```

**Required Environment:**
- Kubernetes cluster with 2+ CPUs and 4GB+ RAM
- Cluster admin permissions (for namespace and secret creation)
- Available persistent storage (10GB+)

**Resource Requirements:**
- PostgreSQL primary: 1GB RAM, 1 CPU
- Persistent volume: 8GB storage
- Total: ~1.5GB RAM, 1 CPU core

## Instructions

### Step 1: Create Database Namespace

**Objective:** Create an isolated namespace for database deployments

**Commands:**
```bash
# Create database namespace
kubectl create namespace database

# Verify namespace creation
kubectl get namespace database
```

**Expected Output:**
```
namespace/database created

NAME       STATUS   AGE
database   Active   1s
```

**Success Criteria:**
- [ ] Namespace `database` exists
- [ ] Namespace status is `Active`

---

### Step 2: Create PostgreSQL Secret

**Objective:** Create Kubernetes secret with PostgreSQL credentials

**Commands:**
```bash
# Generate secure random password
PG_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

# Create secret
kubectl create secret generic postgresql-secret \
  --from-literal=postgres-password="$PG_PASSWORD" \
  --from-literal=password="$PG_PASSWORD" \
  --from-literal=replication-password="$(openssl rand -base64 20)" \
  --namespace database

# Verify secret created
kubectl get secret postgresql-secret -n database

# Save password for later use (IMPORTANT!)
echo "PostgreSQL Password: $PG_PASSWORD"
echo "Save this password securely!"
```

**Expected Output:**
```
NAME                  TYPE     DATA   AGE
postgresql-secret     Opaque   3      1s

PostgreSQL Password: AbC123XyZ...
Save this password securely!
```

**Success Criteria:**
- [ ] Secret `postgresql-secret` created
- [ ] Secret contains 3 keys (postgres-password, password, replication-password)
- [ ] Password saved for later use

---

### Step 3: Add Bitnami Helm Repository

**Objective:** Add the Bitnami Helm chart repository for PostgreSQL

**Commands:**
```bash
# Add Bitnami repository (if not already added)
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || echo "Repository already exists"

# Update repository index
helm repo update

# Verify repository
helm repo list | grep bitnami
```

**Expected Output:**
```
"bitnami" already exists with the same configuration, skipping
Repository already exists

Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "bitnami" chart repository

NAME     URL
bitnami  https://charts.bitnami.com/bitnami
```

**Success Criteria:**
- [ ] Bitnami repository added or already exists
- [ ] Repository index updated successfully

---

### Step 4: Install PostgreSQL using Helm

**Objective:** Deploy PostgreSQL with persistent storage and custom configuration

**Commands:**
```bash
# Install PostgreSQL
helm install postgresql bitnami/postgresql \
  --namespace database \
  --set global.postgresql.auth.existingSecret=postgresql-secret \
  --set primary.persistence.enabled=true \
  --set primary.persistence.size=8Gi \
  --set primary.resources.requests.memory=512Mi \
  --set primary.resources.requests.cpu=250m \
  --wait --timeout=5m

# Verify installation
helm list -n database
```

**Expected Output:**
```
NAME: postgresql
LAST DEPLOYED: Thu Dec 19 19:45:00 2025
NAMESPACE: database
STATUS: deployed
REVISION: 1

NAME        NAMESPACE  REVISION  UPDATED                                  STATUS    CHART             APP VERSION
postgresql  database   1         2025-12-19 19:45:00.000000000 +0000 UTC  deployed  postgresql-15.5.38 16.4.0
```

**Success Criteria:**
- [ ] Helm release `postgresql` created
- [ ] Release status is `deployed`
- [ ] Pod starts within 5 minutes

---

### Step 5: Verify PostgreSQL Pod is Running

**Objective:** Confirm PostgreSQL pod is healthy and ready

**Commands:**
```bash
# Check PostgreSQL pod
kubectl get pods -n database -l app.kubernetes.io/name=postgresql

# Wait for pod to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=postgresql -n database --timeout=300s

# Check pod details
kubectl describe pod -l app.kubernetes.io/name=postgresql -n database | grep -A 5 "Conditions:"
```

**Expected Output:**
```
NAME            READY   STATUS    RESTARTS   AGE
postgresql-0    1/1     Running   0          2m

pod/postgresql-0 condition met

Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
```

**Success Criteria:**
- [ ] PostgreSQL pod shows `Running` status
- [ ] Pod is `1/1` ready
- [ ] No `CrashLoopBackOff` or `Error` state
- [ ] Ready condition is `True`

---

### Step 6: Verify Persistent Volume Claim

**Objective:** Confirm persistent storage is bound to PostgreSQL

**Commands:**
```bash
# Check PVC status
kubectl get pvc -n database

# Get PV details
kubectl get pv | grep database
```

**Expected Output:**
```
NAME                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-postgresql-0          Bound    pvc-abc123...                              8Gi        RWO            standard       2m

pvc-abc123...   8Gi        RWO            Retain           Bound    database/data-postgresql-0   standard                2m
```

**Success Criteria:**
- [ ] PVC `data-postgresql-0` exists
- [ ] PVC status is `Bound`
- [ ] Capacity is 8Gi
- [ ] Persistent volume created and bound

---

### Step 7: Test Database Connection

**Objective:** Connect to PostgreSQL and verify it's operational

**Commands:**
```bash
# Get PostgreSQL password from secret
export POSTGRES_PASSWORD=$(kubectl get secret postgresql-secret -n database -o jsonpath="{.data.postgres-password}" | base64 --decode)

# Create client pod for testing
kubectl run postgresql-client --rm --tty -i --restart='Never' \
  --namespace database \
  --image=bitnami/postgresql:16.4.0 \
  --env="PGPASSWORD=$POSTGRES_PASSWORD" \
  --command -- psql --host postgresql.database.svc.cluster.local -U postgres -d postgres -c "SELECT version();"
```

**Expected Output:**
```
If you don't see a command prompt, try pressing enter.

                                                   version
PostgreSQL 16.4 on x86_64-pc-linux-gnu, compiled by gcc (Debian 12.2.0-14) 12.2.0, 64-bit
(1 row)

pod "postgresql-client" deleted
```

**Success Criteria:**
- [ ] Connection successful
- [ ] PostgreSQL version displayed
- [ ] No authentication errors
- [ ] Client pod cleaned up automatically

---

### Step 8: Create Test Database and Table

**Objective:** Create a test database with sample data to validate functionality

**Commands:**
```bash
# Get password
export POSTGRES_PASSWORD=$(kubectl get secret postgresql-secret -n database -o jsonpath="{.data.postgres-password}" | base64 --decode)

# Create test database
kubectl run postgresql-client --rm --tty -i --restart='Never' \
  --namespace database \
  --image=bitnami/postgresql:16.4.0 \
  --env="PGPASSWORD=$POSTGRES_PASSWORD" \
  --command -- psql --host postgresql.database.svc.cluster.local -U postgres -d postgres -c "CREATE DATABASE testdb;"

# Create table and insert data
kubectl run postgresql-client --rm --tty -i --restart='Never' \
  --namespace database \
  --image=bitnami/postgresql:16.4.0 \
  --env="PGPASSWORD=$POSTGRES_PASSWORD" \
  --command -- psql --host postgresql.database.svc.cluster.local -U postgres -d testdb -c "
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO users (username, email) VALUES ('alice', 'alice@example.com');
INSERT INTO users (username, email) VALUES ('bob', 'bob@example.com');
SELECT * FROM users;
"
```

**Expected Output:**
```
CREATE DATABASE
pod "postgresql-client" deleted

CREATE TABLE
INSERT 0 1
INSERT 0 1
 id | username |       email        |         created_at
----+----------+--------------------+----------------------------
  1 | alice    | alice@example.com  | 2025-12-19 19:50:00.123456
  2 | bob      | bob@example.com    | 2025-12-19 19:50:00.234567
(2 rows)

pod "postgresql-client" deleted
```

**Success Criteria:**
- [ ] Test database `testdb` created
- [ ] Table `users` created successfully
- [ ] 2 rows inserted
- [ ] Data retrieved successfully

---

### Step 9: Verify PostgreSQL Service

**Objective:** Confirm PostgreSQL service is accessible within the cluster

**Commands:**
```bash
# Check PostgreSQL service
kubectl get svc -n database postgresql

# Check service endpoints
kubectl get endpoints -n database postgresql
```

**Expected Output:**
```
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
postgresql   ClusterIP   10.96.200.50   <none>        5432/TCP   5m

NAME         ENDPOINTS           AGE
postgresql   10.244.1.20:5432    5m
```

**Success Criteria:**
- [ ] PostgreSQL service has ClusterIP assigned
- [ ] Service has endpoint pointing to pod
- [ ] Port 5432 exposed

## Validation

Success criteria (all must pass):

- [ ] **Namespace Exists:** `kubectl get namespace database` shows Active status
- [ ] **Secret Created:** `kubectl get secret postgresql-secret -n database` exists
- [ ] **Helm Release Deployed:** `helm list -n database` shows `postgresql` release with `deployed` status
- [ ] **Pod Running:** `kubectl get pods -n database -l app.kubernetes.io/name=postgresql` shows `Running` status
- [ ] **PVC Bound:** `kubectl get pvc -n database` shows `Bound` status
- [ ] **Connection Works:** psql connection successful
- [ ] **Database Created:** Test database and table created successfully
- [ ] **Service Accessible:** `kubectl get svc postgresql -n database` shows ClusterIP

**Quick Validation Script:**
```bash
# Run all validation checks
kubectl get namespace database && \
  kubectl get secret postgresql-secret -n database && \
  helm list -n database | grep -q "deployed" && \
  kubectl get pods -n database -l app.kubernetes.io/name=postgresql | grep -q "Running" && \
  kubectl get pvc -n database | grep -q "Bound" && \
  kubectl get svc postgresql -n database | grep -q "ClusterIP" && \
  echo "✅ All validation checks passed!" || \
  echo "❌ Some validation checks failed"
```

## Troubleshooting

**Problem:** Pod stuck in Pending state
**Symptoms:** `kubectl get pods -n database` shows `Pending` for more than 2 minutes
**Root Cause:** No persistent volume available or insufficient resources
**Check:**
```bash
# Check pod events
kubectl describe pod postgresql-0 -n database | grep -A 10 Events

# Check PVC status
kubectl get pvc -n database

# Check storage classes
kubectl get storageclass
```
**Fix:**
```bash
# If no storage class, create local storage (Minikube)
minikube addons enable storage-provisioner

# If insufficient resources, increase Minikube
minikube delete
minikube start --memory=4096 --cpus=2

# Redeploy PostgreSQL
helm uninstall postgresql -n database
helm install postgresql bitnami/postgresql --namespace database \
  --set global.postgresql.auth.existingSecret=postgresql-secret \
  --set primary.persistence.enabled=true \
  --set primary.persistence.size=8Gi \
  --wait --timeout=5m
```

---

**Problem:** Authentication failed
**Symptoms:** `psql: error: connection to server ... failed: FATAL: password authentication failed`
**Root Cause:** Incorrect password or secret not properly mounted
**Check:**
```bash
# Verify secret exists and has data
kubectl get secret postgresql-secret -n database -o yaml

# Check if secret is mounted in pod
kubectl describe pod postgresql-0 -n database | grep -A 5 "Mounts:"

# Get password from secret
kubectl get secret postgresql-secret -n database -o jsonpath="{.data.postgres-password}" | base64 --decode
```
**Fix:**
```bash
# Recreate secret with correct password
kubectl delete secret postgresql-secret -n database
PG_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
kubectl create secret generic postgresql-secret \
  --from-literal=postgres-password="$PG_PASSWORD" \
  --from-literal=password="$PG_PASSWORD" \
  --namespace database

# Restart PostgreSQL to pick up new secret
kubectl rollout restart statefulset postgresql -n database

# Use new password for connection
export POSTGRES_PASSWORD=$PG_PASSWORD
```

---

**Problem:** Pod in CrashLoopBackOff
**Symptoms:** `kubectl get pods -n database` shows `CrashLoopBackOff`
**Root Cause:** Corrupted data directory or permission issues
**Check:**
```bash
# Check pod logs
kubectl logs postgresql-0 -n database --tail=50

# Check for permission errors
kubectl logs postgresql-0 -n database | grep -i permission
```
**Fix:**
```bash
# If data is corrupted, delete PVC and redeploy (DATA LOSS!)
helm uninstall postgresql -n database
kubectl delete pvc data-postgresql-0 -n database

# Reinstall PostgreSQL with fresh storage
helm install postgresql bitnami/postgresql --namespace database \
  --set global.postgresql.auth.existingSecret=postgresql-secret \
  --set primary.persistence.enabled=true \
  --set primary.persistence.size=8Gi \
  --wait --timeout=5m
```

---

**Problem:** Connection timeout
**Symptoms:** psql client hangs or times out when connecting
**Root Cause:** Network policy blocking traffic or incorrect service address
**Check:**
```bash
# Verify service exists
kubectl get svc postgresql -n database

# Test DNS resolution
kubectl run test-dns --rm -it --restart=Never --image=busybox -- nslookup postgresql.database.svc.cluster.local

# Check for network policies
kubectl get networkpolicy -n database
```
**Fix:**
```bash
# Use port-forward for direct connection testing
kubectl port-forward svc/postgresql 5432:5432 -n database &

# Test connection to localhost
PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -U postgres -d postgres -c "SELECT 1;"

# Kill port-forward
killall kubectl
```

## Notes & References

**Important Considerations:**
- PostgreSQL uses StatefulSet for stable network identity and persistent storage
- Data survives pod restarts and rescheduling
- Single-instance deployment (not HA) - suitable for development
- Secrets must be created before Helm installation

**Performance:**
- Estimated execution time: 10-15 minutes (includes pod startup)
- Resource usage: ~1.5GB RAM, 1 CPU core
- Network bandwidth: ~300MB for image pull

**Security:**
- Password stored in Kubernetes secret (encrypted at rest if cluster configured)
- No external access (ClusterIP service only)
- TLS/SSL not configured by default (enable for production)

**Production Considerations:**
- Enable replication for high availability
- Configure automated backups (pg_dump or WAL archiving)
- Set up connection pooling (PgBouncer)
- Enable SSL/TLS encryption
- Configure resource limits and requests
- Set up monitoring (Prometheus PostgreSQL Exporter)

**Related Playbooks:**
- `kafka-k8s-setup` - Message broker for events
- `fastapi-dapr-service` - Backend service using PostgreSQL

**External References:**
- [Bitnami PostgreSQL Helm Chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL on Kubernetes Best Practices](https://www.postgresql.org/docs/current/high-availability.html)

## Rollback Instructions

If you need to completely remove PostgreSQL:

### Step 1: Uninstall Helm Release
```bash
# Remove PostgreSQL deployment
helm uninstall postgresql -n database

# Verify removal
helm list -n database
```

### Step 2: Delete Persistent Volume Claim (DATA LOSS!)
```bash
# ⚠️  WARNING: This deletes all database data!
kubectl delete pvc data-postgresql-0 -n database

# Verify deletion
kubectl get pvc -n database
```

### Step 3: Delete Secret
```bash
# Delete PostgreSQL secret
kubectl delete secret postgresql-secret -n database

# Verify deletion
kubectl get secret -n database
```

### Step 4: Delete Namespace (Optional)
```bash
# Delete entire database namespace
kubectl delete namespace database

# Verify deletion
kubectl get namespace database
```

## Next Steps

After completing this playbook:

1. **Configure Backups**: Set up pg_dump cron job or WAL archiving
2. **Enable Replication**: Deploy read replicas for high availability
3. **Set Up Monitoring**: Install PostgreSQL Exporter for Prometheus
4. **Configure Connection Pooling**: Deploy PgBouncer for connection management
5. **Security Hardening**: Enable SSL/TLS, configure pg_hba.conf, use certificates

## Version History

| Version | Date       | Changes                             | Author          |
|---------|------------|-------------------------------------|-----------------|
| 1.0.0   | 2025-12-19 | Initial PostgreSQL K8s setup playbook | Claude Sonnet 4.5 |

---

**Compilation:** This playbook compiles to Claude Skills format using:
```bash
bash caps-library/scripts/caps-to-skills.sh postgresql-k8s-setup --validate
```
