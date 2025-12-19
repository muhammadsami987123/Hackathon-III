---
title: Kafka Kubernetes Setup
description: Deploy Apache Kafka on Kubernetes using Helm with topic creation, producer/consumer testing, and troubleshooting
version: 1.0.0
category: infrastructure
tags:
  - kafka
  - kubernetes
  - helm
  - messaging
  - event-streaming
difficulty: intermediate
estimated_time: 20
allowed_tools:
  - bash
  - kubectl
  - helm
prerequisites:
  - kubernetes_cluster_running
  - kubectl_configured
  - helm_installed
  - cluster_resources_4cpu_8gb_ram
dependencies: []
skip_conditions:
  - kafka_already_deployed
---

# Kafka Kubernetes Setup

Deploy Apache Kafka on Kubernetes using the Bitnami Helm chart. This playbook sets up a 3-broker Kafka cluster with ZooKeeper, creates test topics, and validates the deployment with producer/consumer tests.

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

# Check if Kafka already deployed (skip condition)
helm list -n kafka 2>/dev/null | grep -q kafka && echo "⚠️  Kafka already deployed - consider skipping" || echo "✓ No existing Kafka deployment"
```

**Required Environment:**
- Kubernetes cluster with 4+ CPUs and 8GB+ RAM
- Cluster admin permissions (for namespace creation)
- Available storage for persistent volumes (10GB+)

**Resource Requirements:**
- Kafka brokers: 3 replicas × 1GB RAM each
- ZooKeeper: 3 replicas × 512MB RAM each
- Total: ~5GB RAM, 3 CPU cores

## Instructions

### Step 1: Create Kafka Namespace

**Objective:** Create an isolated namespace for Kafka deployment

**Commands:**
```bash
# Create kafka namespace
kubectl create namespace kafka

# Verify namespace creation
kubectl get namespace kafka
```

**Expected Output:**
```
namespace/kafka created

NAME    STATUS   AGE
kafka   Active   1s
```

**Success Criteria:**
- [ ] Namespace `kafka` exists
- [ ] Namespace status is `Active`

---

### Step 2: Add Bitnami Helm Repository

**Objective:** Add the Bitnami Helm chart repository for Kafka

**Commands:**
```bash
# Add Bitnami repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repository index
helm repo update

# Verify repository added
helm repo list | grep bitnami
```

**Expected Output:**
```
"bitnami" has been added to your repositories

Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "bitnami" chart repository

NAME     URL
bitnami  https://charts.bitnami.com/bitnami
```

**Success Criteria:**
- [ ] Bitnami repository added successfully
- [ ] Repository index updated
- [ ] Repository appears in `helm repo list`

---

### Step 3: Install Kafka using Helm

**Objective:** Deploy Kafka cluster with ZooKeeper using Helm chart

**Commands:**
```bash
# Install Kafka with 3 brokers
helm install kafka bitnami/kafka \
  --namespace kafka \
  --set replicaCount=3 \
  --set zookeeper.replicaCount=3 \
  --set persistence.enabled=true \
  --set persistence.size=8Gi \
  --wait --timeout=10m

# Verify installation
helm list -n kafka
```

**Expected Output:**
```
NAME: kafka
LAST DEPLOYED: Thu Dec 19 19:30:00 2025
NAMESPACE: kafka
STATUS: deployed
REVISION: 1

NAME   NAMESPACE  REVISION  UPDATED                                  STATUS    CHART         APP VERSION
kafka  kafka      1         2025-12-19 19:30:00.000000000 +0000 UTC  deployed  kafka-30.1.5  3.8.1
```

**Success Criteria:**
- [ ] Helm release `kafka` created
- [ ] Release status is `deployed`
- [ ] Pods start within 10 minutes

---

### Step 4: Verify Kafka Pods are Running

**Objective:** Confirm all Kafka and ZooKeeper pods are healthy

**Commands:**
```bash
# Check all pods in kafka namespace
kubectl get pods -n kafka

# Wait for all pods to be ready (up to 5 minutes)
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kafka -n kafka --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=zookeeper -n kafka --timeout=300s
```

**Expected Output:**
```
NAME                READY   STATUS    RESTARTS   AGE
kafka-0             1/1     Running   0          3m
kafka-1             1/1     Running   0          2m30s
kafka-2             1/1     Running   0          2m
kafka-zookeeper-0   1/1     Running   0          3m
kafka-zookeeper-1   1/1     Running   0          2m45s
kafka-zookeeper-2   1/1     Running   0          2m15s

pod/kafka-0 condition met
pod/kafka-1 condition met
pod/kafka-2 condition met
pod/kafka-zookeeper-0 condition met
pod/kafka-zookeeper-1 condition met
pod/kafka-zookeeper-2 condition met
```

**Success Criteria:**
- [ ] 3 Kafka broker pods running
- [ ] 3 ZooKeeper pods running
- [ ] All pods show `Running` status with `1/1` ready
- [ ] No `CrashLoopBackOff` or `Error` states

---

### Step 5: Create Test Topic

**Objective:** Create a test Kafka topic to validate cluster functionality

**Commands:**
```bash
# Create test topic with 3 partitions and replication factor 2
kubectl run kafka-client --restart='Never' --image=bitnami/kafka:3.8.1 --namespace kafka \
  --command -- sleep infinity

# Wait for client pod
kubectl wait --for=condition=ready pod/kafka-client -n kafka --timeout=60s

# Create topic
kubectl exec -it kafka-client -n kafka -- \
  kafka-topics.sh --create \
  --bootstrap-server kafka:9092 \
  --topic test-topic \
  --partitions 3 \
  --replication-factor 2

# List topics to verify
kubectl exec -it kafka-client -n kafka -- \
  kafka-topics.sh --list \
  --bootstrap-server kafka:9092
```

**Expected Output:**
```
pod/kafka-client created
pod/kafka-client condition met

Created topic test-topic.

test-topic
```

**Success Criteria:**
- [ ] Client pod created successfully
- [ ] Topic `test-topic` created
- [ ] Topic appears in topic list

---

### Step 6: Test Producer (Send Messages)

**Objective:** Send test messages to Kafka topic to validate producer functionality

**Commands:**
```bash
# Produce 3 test messages
kubectl exec -it kafka-client -n kafka -- bash -c '
echo "Message 1: Hello Kafka" | kafka-console-producer.sh --bootstrap-server kafka:9092 --topic test-topic
echo "Message 2: CAPS Playbook" | kafka-console-producer.sh --bootstrap-server kafka:9092 --topic test-topic
echo "Message 3: Kubernetes Deployment" | kafka-console-producer.sh --bootstrap-server kafka:9092 --topic test-topic
'

echo "✓ 3 messages produced successfully"
```

**Expected Output:**
```
✓ 3 messages produced successfully
```

**Success Criteria:**
- [ ] Producer commands execute without errors
- [ ] No connection errors to Kafka brokers

---

### Step 7: Test Consumer (Read Messages)

**Objective:** Read messages from Kafka topic to validate consumer functionality

**Commands:**
```bash
# Consume messages from beginning (timeout after 10 seconds)
kubectl exec -it kafka-client -n kafka -- \
  kafka-console-consumer.sh \
  --bootstrap-server kafka:9092 \
  --topic test-topic \
  --from-beginning \
  --max-messages 3
```

**Expected Output:**
```
Message 1: Hello Kafka
Message 2: CAPS Playbook
Message 3: Kubernetes Deployment
Processed a total of 3 messages
```

**Success Criteria:**
- [ ] All 3 messages received in order
- [ ] Consumer reads from beginning successfully
- [ ] No errors in consumer output

---

### Step 8: Verify Kafka Service

**Objective:** Confirm Kafka service is accessible within the cluster

**Commands:**
```bash
# Check Kafka service
kubectl get svc -n kafka kafka

# Check service endpoints
kubectl get endpoints -n kafka kafka
```

**Expected Output:**
```
NAME    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
kafka   ClusterIP   10.96.100.200   <none>        9092/TCP,9093/TCP   5m

NAME    ENDPOINTS                                           AGE
kafka   10.244.1.10:9092,10.244.1.11:9092,10.244.1.12:9092  5m
```

**Success Criteria:**
- [ ] Kafka service has ClusterIP assigned
- [ ] Service has 3 endpoints (one per broker)
- [ ] Ports 9092 (internal) and 9093 (external) exposed

---

### Step 9: Cleanup Test Resources (Optional)

**Objective:** Remove test client pod and topic after validation

**Commands:**
```bash
# Delete test topic
kubectl exec -it kafka-client -n kafka -- \
  kafka-topics.sh --delete \
  --bootstrap-server kafka:9092 \
  --topic test-topic

# Delete client pod
kubectl delete pod kafka-client -n kafka

# Verify cleanup
kubectl get pods -n kafka | grep kafka-client || echo "✓ Client pod removed"
```

**Expected Output:**
```
Topic test-topic is marked for deletion.

pod "kafka-client" deleted

✓ Client pod removed
```

**Success Criteria:**
- [ ] Test topic deleted
- [ ] Client pod removed

## Validation

Success criteria (all must pass):

- [ ] **Namespace Exists:** `kubectl get namespace kafka` shows Active status
- [ ] **Helm Release Deployed:** `helm list -n kafka` shows `kafka` release with `deployed` status
- [ ] **Kafka Pods Running:** `kubectl get pods -n kafka -l app.kubernetes.io/name=kafka` shows 3/3 pods Running
- [ ] **ZooKeeper Pods Running:** `kubectl get pods -n kafka -l app.kubernetes.io/name=zookeeper` shows 3/3 pods Running
- [ ] **Topic Created:** Topic creation successful (or already exists)
- [ ] **Producer Works:** Messages sent without errors
- [ ] **Consumer Works:** Messages received successfully
- [ ] **Service Accessible:** `kubectl get svc kafka -n kafka` shows ClusterIP assigned

**Quick Validation Script:**
```bash
# Run all validation checks
kubectl get namespace kafka && \
  helm list -n kafka | grep -q "deployed" && \
  [[ $(kubectl get pods -n kafka -l app.kubernetes.io/name=kafka --no-headers | wc -l) -eq 3 ]] && \
  [[ $(kubectl get pods -n kafka -l app.kubernetes.io/name=zookeeper --no-headers | wc -l) -eq 3 ]] && \
  kubectl get svc kafka -n kafka | grep -q "ClusterIP" && \
  echo "✅ All validation checks passed!" || \
  echo "❌ Some validation checks failed"
```

## Troubleshooting

**Problem:** Pods stuck in Pending state
**Symptoms:** `kubectl get pods -n kafka` shows `Pending` for more than 5 minutes
**Root Cause:** Insufficient cluster resources (CPU/memory) or no persistent volume available
**Check:**
```bash
# Check pod events for scheduling issues
kubectl describe pod kafka-0 -n kafka | grep -A 10 Events

# Check node resources
kubectl top nodes

# Check persistent volume claims
kubectl get pvc -n kafka
```
**Fix:**
```bash
# If using Minikube, increase resources
minikube delete
minikube start --memory=8192 --cpus=4

# Redeploy Kafka
helm uninstall kafka -n kafka
helm install kafka bitnami/kafka --namespace kafka \
  --set replicaCount=3 --set zookeeper.replicaCount=3 \
  --wait --timeout=10m
```

---

**Problem:** Kafka pods in CrashLoopBackOff
**Symptoms:** `kubectl get pods -n kafka` shows `CrashLoopBackOff` for kafka-0/1/2
**Root Cause:** ZooKeeper not ready or connection issues
**Check:**
```bash
# Check ZooKeeper pods first
kubectl get pods -n kafka -l app.kubernetes.io/name=zookeeper

# Check Kafka logs
kubectl logs kafka-0 -n kafka --tail=50
```
**Fix:**
```bash
# Ensure ZooKeeper is healthy first
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=zookeeper -n kafka --timeout=300s

# If ZooKeeper is stuck, restart it
kubectl rollout restart statefulset kafka-zookeeper -n kafka

# Wait for ZooKeeper to stabilize
sleep 30

# Restart Kafka
kubectl rollout restart statefulset kafka -n kafka
```

---

**Problem:** Topic creation fails with "Connection refused"
**Symptoms:** `kafka-topics.sh` command fails with connection error
**Root Cause:** Kafka service not accessible or brokers not ready
**Check:**
```bash
# Verify Kafka service exists
kubectl get svc kafka -n kafka

# Check if brokers are ready
kubectl exec kafka-0 -n kafka -- kafka-broker-api-versions.sh --bootstrap-server kafka:9092
```
**Fix:**
```bash
# Wait for all Kafka brokers to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kafka -n kafka --timeout=300s

# Test connectivity from client pod
kubectl exec -it kafka-client -n kafka -- \
  nc -zv kafka 9092

# Retry topic creation after brokers are ready
```

---

**Problem:** Producer/Consumer timeout
**Symptoms:** Producer or consumer commands hang or timeout
**Root Cause:** Network policy blocking traffic or incorrect bootstrap server address
**Check:**
```bash
# Check if client can resolve kafka service
kubectl exec kafka-client -n kafka -- nslookup kafka

# Check if port is accessible
kubectl exec kafka-client -n kafka -- nc -zv kafka 9092

# Check for network policies
kubectl get networkpolicy -n kafka
```
**Fix:**
```bash
# Use fully qualified service name if needed
kubectl exec -it kafka-client -n kafka -- \
  kafka-console-producer.sh --bootstrap-server kafka.kafka.svc.cluster.local:9092 --topic test-topic

# Or port-forward for debugging
kubectl port-forward svc/kafka 9092:9092 -n kafka &
```

## Notes & References

**Important Considerations:**
- Kafka deployment uses persistent volumes - data survives pod restarts
- 3-broker setup provides high availability (can tolerate 1 broker failure)
- Default replication factor of 2 ensures data durability
- ZooKeeper manages Kafka cluster coordination

**Performance:**
- Estimated execution time: 15-20 minutes (includes pod startup and image pulls)
- Resource usage: ~5GB RAM, 3 CPU cores
- Network bandwidth: ~500MB for image pulls

**Security:**
- No authentication configured (development setup)
- No TLS/SSL encryption (add for production)
- Internal ClusterIP service only (not exposed externally)

**Production Considerations:**
- Enable authentication (SASL/PLAIN or SASL/SCRAM)
- Configure TLS encryption
- Increase replication factor to 3
- Set up monitoring (Prometheus/Grafana)
- Configure resource limits and requests

**Related Playbooks:**
- `postgresql-k8s-setup` - Database for application state
- `fastapi-dapr-service` - Backend service consuming Kafka events

**External References:**
- [Bitnami Kafka Helm Chart](https://github.com/bitnami/charts/tree/main/bitnami/kafka)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Kafka on Kubernetes Best Practices](https://strimzi.io/docs/operators/latest/overview.html)

## Rollback Instructions

If you need to completely remove Kafka:

### Step 1: Uninstall Helm Release
```bash
# Remove Kafka deployment
helm uninstall kafka -n kafka

# Verify removal
helm list -n kafka
# Should show no releases
```

### Step 2: Delete Persistent Volume Claims
```bash
# List PVCs
kubectl get pvc -n kafka

# Delete all Kafka PVCs (data will be lost!)
kubectl delete pvc -n kafka -l app.kubernetes.io/name=kafka
kubectl delete pvc -n kafka -l app.kubernetes.io/name=zookeeper

# Verify deletion
kubectl get pvc -n kafka
# Should show no resources
```

### Step 3: Delete Namespace (Optional)
```bash
# Delete entire kafka namespace
kubectl delete namespace kafka

# Verify deletion
kubectl get namespace kafka
# Should show: Error from server (NotFound)
```

### Step 4: Verify Cleanup
```bash
# Check no resources remain
kubectl get all -n kafka 2>&1 || echo "✓ Namespace removed"

# Check no persistent volumes left
kubectl get pv | grep kafka
# Should show no results
```

## Next Steps

After completing this playbook:

1. **Configure Persistent Topics**: Create application-specific topics with proper retention policies
2. **Enable Monitoring**: Install Kafka Exporter for Prometheus metrics
3. **Set Up Schema Registry**: Add Confluent Schema Registry for Avro/JSON schemas
4. **Configure Kafka Connect**: Set up connectors for data integration
5. **Production Hardening**: Enable authentication, TLS, resource limits

## Version History

| Version | Date       | Changes                          | Author          |
|---------|------------|----------------------------------|-----------------|
| 1.0.0   | 2025-12-19 | Initial Kafka K8s setup playbook | Claude Sonnet 4.5 |

---

**Compilation:** This playbook compiles to Claude Skills format using:
```bash
bash caps-library/scripts/caps-to-skills.sh kafka-k8s-setup --validate
```
