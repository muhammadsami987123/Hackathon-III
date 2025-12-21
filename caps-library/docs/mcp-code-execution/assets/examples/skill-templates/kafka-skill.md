---
name: kafka-k8s-setup
description: Deploy Apache Kafka on Kubernetes with Helm, create topics, and verify deployment
---

# Kafka Kubernetes Setup

Deploy a production-ready Apache Kafka cluster on Kubernetes with automated configuration, topic creation, and health verification.

## When to Use

- User asks: "Deploy Kafka"
- Setting up event-driven microservices
- Creating message streaming infrastructure
- Initializing pub/sub messaging system

## Quick Start

Deploy Kafka with a single command:

```bash
./scripts/main.sh
```

The script will:
1. Add Bitnami Helm repository
2. Create kafka namespace
3. Install Kafka cluster
4. Create default topics
5. Verify all pods are running

## What Happens

The deployment script:
- Adds the official Bitnami Helm repository
- Creates an isolated `kafka` namespace
- Deploys 1 Kafka broker + 1 Zookeeper (customizable)
- Creates topics: `learning.explained`, `code.executed`, `exercise.failed`
- Waits for all pods to reach Running state
- Verifies service connectivity

All details are handled by the script - you only see success/failure.

## Customization

For custom deployments, see [REFERENCE.md](./REFERENCE.md):
- Number of replicas
- Storage configuration
- Topic creation settings
- Resource limits
- Security policies

## Validation

After deployment, verify success:

```bash
./scripts/verify.sh
```

You should see:
- ✓ All X pods running
- ✓ Kafka service exists
- ✓ Topics created

## Troubleshooting

If deployment fails:

1. Check namespace exists:
   ```bash
   kubectl get namespace kafka
   ```

2. Check pod status:
   ```bash
   kubectl describe pod kafka-0 -n kafka
   ```

3. See [REFERENCE.md](./REFERENCE.md) for detailed troubleshooting

## Next Steps

- Create Kafka topics via `kafka-topics.sh`
- Deploy services that produce/consume messages
- Configure topic retention policies
- Set up monitoring with Prometheus

See related skills for event-driven architecture.
