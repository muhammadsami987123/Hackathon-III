#!/bin/bash
# scripts/main.sh - Entry point
# Philosophy: Orchestrate work, return minimal status

set -euo pipefail

NAMESPACE="${1:-kafka}"
LOG_FILE="/tmp/kafka-deploy-$(date +%s).log"

# All work logged to file, not context
{
    echo "Starting Kafka deployment..."

    # Deploy
    ./scripts/deploy.py --namespace "$NAMESPACE" || {
        echo "Deployment failed"
        exit 1
    }

    # Verify
    ./scripts/verify.py --namespace "$NAMESPACE" || {
        echo "Verification failed"
        exit 1
    }

    echo "Deployment complete"
} >> "$LOG_FILE" 2>&1

# Only final status to agent
if [ $? -eq 0 ]; then
    echo "✓ Kafka deployed successfully"
    echo "  Namespace: $NAMESPACE"
    echo "  Check logs: $LOG_FILE"
    exit 0
else
    echo "✗ Deployment failed - check logs: $LOG_FILE"
    tail -20 "$LOG_FILE"
    exit 1
fi
