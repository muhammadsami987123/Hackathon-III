# Kafka Kubernetes Setup - Reference Documentation

## Architecture Overview

```
kafka namespace
├── kafka-0 (broker)
├── kafka-zookeeper-0 (zookeeper)
└── Services
    ├── kafka (headless)
    └── kafka-zookeeper
```

## Configuration Options

### Replica Count

Number of Kafka brokers to deploy:

```bash
# In deploy.py, modify:
--set replicaCount=3
```

Default: 1 (for Minikube)
Production: 3+

### Storage

Persistent volume configuration:

```bash
--set primary.persistence.enabled=true
--set primary.persistence.size=10Gi
--set primary.persistence.storageClassName=fast-ssd
```

Default: 10Gi local storage

### Resource Requests

CPU and memory per broker:

```bash
--set resources.requests.cpu=500m
--set resources.requests.memory=2Gi
--set resources.limits.cpu=1000m
--set resources.limits.memory=4Gi
```

## Topic Management

### Creating Topics

```bash
kubectl exec -it kafka-0 -n kafka -- \
  kafka-topics.sh --create \
  --topic my-topic \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 1
```

### Listing Topics

```bash
kubectl exec -it kafka-0 -n kafka -- \
  kafka-topics.sh --list \
  --bootstrap-server localhost:9092
```

### Deleting Topics

```bash
kubectl exec -it kafka-0 -n kafka -- \
  kafka-topics.sh --delete \
  --topic my-topic \
  --bootstrap-server localhost:9092
```

## Testing Connectivity

### Producer Test

Send test message:

```bash
kubectl exec -it kafka-0 -n kafka -- \
  kafka-console-producer.sh \
  --broker-list localhost:9092 \
  --topic test-topic
# Type a message and press Enter
```

### Consumer Test

Receive messages:

```bash
kubectl exec -it kafka-0 -n kafka -- \
  kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic test-topic \
  --from-beginning
```

## Troubleshooting

### Problem: Pods stuck in Pending

**Check:**
```bash
kubectl describe pod kafka-0 -n kafka
kubectl get events -n kafka
```

**Solution:**
- Insufficient cluster memory: `minikube start --memory=8192`
- No storage class: Create local storage provisioner
- Missing namespace: Manually create with `kubectl create namespace kafka`

### Problem: Service not accessible

**Check:**
```bash
kubectl get svc -n kafka
kubectl get endpoints -n kafka
```

**Solution:**
- Port-forward: `kubectl port-forward svc/kafka 9092:9092 -n kafka`
- Check pod logs: `kubectl logs kafka-0 -n kafka`

### Problem: Topics not created

**Check:**
```bash
kubectl exec kafka-0 -n kafka -- \
  kafka-topics.sh --list --bootstrap-server localhost:9092
```

**Solution:**
- Manually create topics (see Topic Management section)
- Verify Kafka is fully started (wait 30 seconds)

## Performance Tuning

### For High Throughput

```bash
--set brokerConfiguration="
  log.flush.interval.ms=10000
  num.network.threads=16
  num.io.threads=16
"
```

### For Low Latency

```bash
--set brokerConfiguration="
  compression.type=lz4
  linger.ms=0
  batch.size=16384
"
```

## Monitoring

### Check Broker Status

```bash
kubectl describe pod kafka-0 -n kafka
kubectl logs kafka-0 -n kafka -f
```

### Check Disk Usage

```bash
kubectl exec kafka-0 -n kafka -- \
  du -h /bitnami/kafka/data
```

### Check Memory

```bash
kubectl top pod -n kafka
```

## Helm Chart Upgrade

Update to latest chart:

```bash
helm repo update
helm upgrade kafka bitnami/kafka -n kafka
```

## Uninstall

Remove Kafka completely:

```bash
helm uninstall kafka -n kafka
kubectl delete namespace kafka
```

⚠️ This is destructive - all data will be lost.

## References

- [Bitnami Kafka Chart](https://github.com/bitnami/charts/tree/main/bitnami/kafka)
- [Kafka Documentation](https://kafka.apache.org/documentation/)
- [Kubernetes Helm](https://helm.sh/docs/)
