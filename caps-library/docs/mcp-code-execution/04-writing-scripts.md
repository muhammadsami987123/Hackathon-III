---
description: Master Python and Bash script patterns with error handling, exit codes, and minimal output for token-efficient skills
readingTime: 12 minutes
---

# Writing Efficient Scripts

## Script Philosophy

The core principle of the MCP Code Execution Pattern is moving all complex processing from the agent's context window into external scripts. This reduces token consumption from 50,000+ to less than 110.

**Rule 1:** Do all work in scripts, not context
**Rule 2:** Return only final status to agent
**Rule 3:** Handle errors gracefully
**Rule 4:** Exit with meaningful codes

## Python Script Pattern

### Structure

Every Python script for Skills should follow this pattern:

```python
#!/usr/bin/env python3
"""
Script: Deploy Kafka to Kubernetes
Returns: Minimal status, errors handled internally
"""

import subprocess
import sys
import json
from typing import Dict, List

class KafkaDeployer:
    """Handles Kafka deployment with error handling"""

    def __init__(self, namespace: str = "kafka"):
        self.namespace = namespace
        self.errors = []

    def run_command(self, cmd: List[str]) -> bool:
        """Execute command, capture output, handle errors"""
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=300,
                check=True
            )
            return True
        except subprocess.CalledProcessError as e:
            self.errors.append(f"Command failed: {' '.join(cmd)}")
            self.errors.append(f"Error: {e.stderr}")
            return False
        except TimeoutError:
            self.errors.append(f"Command timed out: {' '.join(cmd)}")
            return False

    def deploy(self) -> bool:
        """Deploy Kafka - all work happens here"""

        # Add Helm repo
        if not self.run_command([
            "helm", "repo", "add", "bitnami",
            "https://charts.bitnami.com/bitnami"
        ]):
            return False

        if not self.run_command(["helm", "repo", "update"]):
            return False

        # Create namespace
        if not self.run_command([
            "kubectl", "create", "namespace", self.namespace,
            "--dry-run=client", "-o", "yaml", "|", "kubectl", "apply", "-f", "-"
        ]):
            return False

        # Install Kafka
        if not self.run_command([
            "helm", "install", "kafka", "bitnami/kafka",
            "--namespace", self.namespace,
            "--set", "replicaCount=1",
            "--set", "zookeeper.replicaCount=1",
            "--wait", "--timeout", "5m"
        ]):
            return False

        return True

    def get_status(self) -> Dict:
        """Return only minimal status to agent"""
        if self.errors:
            return {
                "status": "failed",
                "errors": self.errors[:3],  # First 3 errors only
                "message": f"Deployment failed: {self.errors[0]}"
            }
        else:
            return {
                "status": "success",
                "message": "✓ Kafka deployed to namespace 'kafka'"
            }

def main():
    deployer = KafkaDeployer(namespace="kafka")
    success = deployer.deploy()

    status = deployer.get_status()

    # Print only what agent needs to see
    print(status["message"])

    # All work is done, only minimal output goes to context
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
```

**What agent sees in context:**
```
✓ Kafka deployed to namespace 'kafka'
```

**What happens behind scenes:** Helm repos, kubectl calls, error handling, retries - all invisible to token counter.

### Error Handling Pattern

Always use try/except blocks with meaningful error messages:

```python
try:
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=300,
        check=True
    )
    return True
except subprocess.CalledProcessError as e:
    # Log error internally, return minimal message
    self.errors.append(f"Command failed: {e.stderr}")
    return False
except TimeoutError:
    self.errors.append(f"Timeout: {' '.join(cmd)}")
    return False
```

## Bash Script Pattern

### Structure

Every Bash script should follow this pattern:

```bash
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
```

### Error Handling with set -euo pipefail

Always start Bash scripts with:

```bash
set -euo pipefail
```

This ensures:
- `set -e`: Exit on any error
- `set -u`: Exit on undefined variable
- `set -o pipefail`: Exit on pipe failures

### Meaningful Exit Codes

```bash
exit 0   # Success
exit 1   # General failure
exit 2   # Warning (recoverable)
```

## Verification Script Pattern

### Python Verification Example

```python
#!/usr/bin/env python3
"""
Script: Verify Kafka deployment
Returns: Simple status, no raw pod data
"""

import subprocess
import json
import sys

def check_pods(namespace: str) -> bool:
    """Check if all pods running"""
    result = subprocess.run(
        ["kubectl", "get", "pods", "-n", namespace, "-o", "json"],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        print(f"✗ Cannot access namespace {namespace}")
        return False

    pods = json.loads(result.stdout)["items"]

    if not pods:
        print(f"✗ No pods found in {namespace}")
        return False

    running = sum(1 for p in pods if p["status"]["phase"] == "Running")
    total = len(pods)

    # Return only summary, not full pod list
    if running == total:
        print(f"✓ All {total} pods running")
        return True
    else:
        print(f"⚠ {running}/{total} pods running")
        return False

def check_services(namespace: str) -> bool:
    """Check if services created"""
    result = subprocess.run(
        ["kubectl", "get", "svc", "-n", namespace],
        capture_output=True,
        text=True
    )

    if "kafka" in result.stdout:
        print("✓ Kafka service exists")
        return True
    else:
        print("✗ Kafka service not found")
        return False

def main():
    namespace = "kafka"

    all_ok = True
    all_ok = check_pods(namespace) and all_ok
    all_ok = check_services(namespace) and all_ok

    # Simple exit code
    sys.exit(0 if all_ok else 1)

if __name__ == "__main__":
    main()
```

**What agent sees:**
```
✓ All 3 pods running
✓ Kafka service exists
```

**What doesn't appear in context:** Full pod descriptions, service specs, status conditions - all filtered out by script.

## Script Pattern References

Complete, runnable examples are available in the assets directory:

- **Python Pattern**: [assets/examples/scripts/python-pattern.py](assets/examples/scripts/python-pattern.py)
- **Bash Pattern**: [assets/examples/scripts/bash-pattern.sh](assets/examples/scripts/bash-pattern.sh)
- **Verification Pattern**: [assets/examples/scripts/verification-pattern.py](assets/examples/scripts/verification-pattern.py)

These files contain production-ready templates you can copy and customize for your skills.

## Error Handling Examples

### Example 1: Timeout Handling

```python
try:
    result = subprocess.run(cmd, timeout=300, check=True)
except TimeoutError:
    print("✗ Command timed out after 5 minutes")
    sys.exit(1)
```

### Example 2: Retries with Backoff

```python
import time

def run_with_retry(cmd: List[str], max_retries: int = 3) -> bool:
    for attempt in range(max_retries):
        try:
            subprocess.run(cmd, check=True, timeout=60)
            return True
        except subprocess.CalledProcessError:
            if attempt < max_retries - 1:
                wait_time = 2 ** attempt  # Exponential backoff
                time.sleep(wait_time)
            else:
                return False
    return False
```

### Example 3: Graceful Degradation

```python
def deploy(self) -> bool:
    # Critical step - must succeed
    if not self.install_core():
        return False

    # Optional step - warn but continue
    if not self.install_monitoring():
        print("⚠ Monitoring install failed (non-critical)")

    return True
```

### Example 4: Resource Cleanup

```python
def cleanup(namespace: str):
    """Always cleanup, even on failure"""
    try:
        subprocess.run(["kubectl", "delete", "namespace", namespace], check=False)
    except Exception:
        pass  # Cleanup failure shouldn't block

try:
    deploy()
except Exception as e:
    print(f"✗ Deployment failed: {e}")
    cleanup("kafka")
    sys.exit(1)
```

### Example 5: Input Validation

```python
def validate_namespace(name: str) -> bool:
    """Validate before executing"""
    if not name or len(name) > 63:
        print("✗ Invalid namespace name")
        return False
    if not name.replace('-', '').isalnum():
        print("✗ Namespace must be alphanumeric with hyphens")
        return False
    return True

if not validate_namespace(args.namespace):
    sys.exit(1)
```

## Cross-References

- **Complete Example**: See [05-kafka-example.md](05-kafka-example.md) for full Kafka skill implementation
- **Best Practices**: See [09-best-practices.md](09-best-practices.md#error-handling) for additional error handling patterns
- **Constitution**: See [../../.specify/memory/constitution.md](../../.specify/memory/constitution.md) Principle VII for Test-Driven Playbook Refinement

## Next Steps

- Study the complete Kafka example: [05-kafka-example.md](05-kafka-example.md)
- Understand on-demand documentation: [06-reference-pattern.md](06-reference-pattern.md)
- Review best practices: [09-best-practices.md](09-best-practices.md)
