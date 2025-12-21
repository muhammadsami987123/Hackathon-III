#!/bin/bash
# scripts/main.sh - Kafka deployment orchestrator
# Entry point for kafka-k8s-setup skill

set -euo pipefail

NAMESPACE="${1:-kafka}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/kafka-deploy-$(date +%s).log"

# Create log file
mkdir -p /tmp
touch "$LOG_FILE"

echo "Starting Kafka deployment to namespace: $NAMESPACE"
echo "Log file: $LOG_FILE"
echo ""

# Run deployment (all details logged, not displayed)
if ! python3 "$SCRIPT_DIR/deploy.py" \
    --namespace "$NAMESPACE" \
    >> "$LOG_FILE" 2>&1; then
    echo "✗ Deployment failed"
    echo ""
    echo "Last 10 lines of log:"
    tail -10 "$LOG_FILE"
    exit 1
fi

echo "✓ Kafka deployed successfully"

# Run verification
if ! python3 "$SCRIPT_DIR/verify.py" \
    --namespace "$NAMESPACE" \
    >> "$LOG_FILE" 2>&1; then
    echo "⚠ Verification incomplete - check logs"
    tail -5 "$LOG_FILE"
    exit 1
fi

echo "✓ All validations passed"
echo ""
echo "Next steps:"
echo "  1. kubectl get pods -n $NAMESPACE"
echo "  2. Create topics: kubectl exec -it kafka-0 -n $NAMESPACE -- kafka-topics.sh --create ..."
echo "  3. See REFERENCE.md for more options"

exit 0
