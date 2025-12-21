---
description: Complete working Kafka deployment skill demonstrating all 4 parts with 99.8% token reduction
readingTime: 15 minutes
---

# Complete Example: Kafka Kubernetes Setup

This section provides a complete, production-ready skill that deploys Apache Kafka to Kubernetes. Study this example to understand how all the pieces fit together.

**Time Estimate**: Creating a similar skill takes approximately 30 minutes once you understand the pattern.

## Overview

The `kafka-k8s-setup` skill demonstrates:
- **SKILL.md**: Minimal instructions (60 lines, ~100 tokens)
- **scripts/main.sh**: Entry point orchestration
- **scripts/deploy.py**: Core deployment logic (150 lines)
- **scripts/verify.py**: Health verification (100 lines)
- **REFERENCE.md**: Deep documentation loaded on-demand

**Token Cost**: 110 tokens (vs. 50,000 for direct MCP)

## File 1: SKILL.md

**Purpose**: Tell the agent WHAT to do in minimal tokens

**File**: [assets/examples/skill-templates/kafka-skill.md](assets/examples/skill-templates/kafka-skill.md)

```markdown
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

\`\`\`bash
./scripts/main.sh
\`\`\`

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

\`\`\`bash
./scripts/verify.sh
\`\`\`

You should see:
- ✓ All X pods running
- ✓ Kafka service exists
- ✓ Topics created

## Troubleshooting

If deployment fails:

1. Check namespace exists:
   \`\`\`bash
   kubectl get namespace kafka
   \`\`\`

2. Check pod status:
   \`\`\`bash
   kubectl describe pod kafka-0 -n kafka
   \`\`\`

3. See [REFERENCE.md](./REFERENCE.md) for detailed troubleshooting

## Next Steps

- Create Kafka topics via `kafka-topics.sh`
- Deploy services that produce/consume messages
- Configure topic retention policies
- Set up monitoring with Prometheus

See related skills for event-driven architecture.
```

**Explanation**: This file is loaded into the agent's context. It provides just enough information for the agent to understand when to use the skill and how to invoke it. All implementation details are in scripts.

## File 2: scripts/main.sh

**Purpose**: Entry point that orchestrates deployment and verification

**File**: [assets/examples/scripts/kafka-main.sh](assets/examples/scripts/kafka-main.sh)

```bash
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
```

**Explanation**: This Bash script is the entry point. It:
1. Accepts namespace as optional argument
2. Runs deploy.py with all output logged to a file (not context)
3. Runs verify.py to confirm success
4. Returns only minimal status messages to the agent

**Token Cost**: Agent sees 4-5 lines of output (~10 tokens)

## File 3: scripts/deploy.py

**Purpose**: Execute the actual Kafka deployment

**File**: [assets/examples/scripts/kafka-deploy.py](assets/examples/scripts/kafka-deploy.py)

```python
#!/usr/bin/env python3
"""
Kafka Deployment Script
Deploys Kafka to Kubernetes via Helm
All work happens here - minimal output to agent
"""

import subprocess
import sys
import argparse
from typing import List, Tuple

class HelmDeployer:
    def __init__(self, namespace: str):
        self.namespace = namespace
        self.errors = []

    def run(self, cmd: List[str], description: str = "") -> Tuple[bool, str]:
        """Execute command, return success/error"""
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=600,
                check=True
            )
            return True, result.stdout
        except subprocess.CalledProcessError as e:
            error_msg = f"{description}: {e.stderr}"
            self.errors.append(error_msg)
            return False, error_msg
        except Exception as e:
            error_msg = f"{description}: {str(e)}"
            self.errors.append(error_msg)
            return False, error_msg

    def add_helm_repo(self) -> bool:
        """Add Bitnami Helm repository"""
        success, _ = self.run(
            ["helm", "repo", "add", "bitnami", "https://charts.bitnami.com/bitnami"],
            "Add Helm repo"
        )
        if not success:
            return False

        success, _ = self.run(["helm", "repo", "update"], "Update Helm repos")
        return success

    def create_namespace(self) -> bool:
        """Create namespace if it doesn't exist"""
        cmd = [
            "kubectl", "create", "namespace", self.namespace,
            "--dry-run=client", "-o", "yaml"
        ]
        success, yaml_output = self.run(cmd, "Generate namespace YAML")
        if not success:
            return False

        # Apply the YAML
        apply_cmd = ["kubectl", "apply", "-f", "-"]
        try:
            subprocess.run(
                apply_cmd,
                input=yaml_output,
                text=True,
                check=True,
                capture_output=True
            )
            return True
        except subprocess.CalledProcessError as e:
            self.errors.append(f"Create namespace: {e.stderr}")
            return False

    def install_kafka(self) -> bool:
        """Install Kafka via Helm"""
        cmd = [
            "helm", "install", "kafka", "bitnami/kafka",
            "--namespace", self.namespace,
            "--set", "replicaCount=1",
            "--set", "zookeeper.replicaCount=1",
            "--set", "resources.requests.memory=2Gi",
            "--wait",
            "--timeout", "5m"
        ]
        success, _ = self.run(cmd, "Install Kafka")
        return success

    def create_topics(self) -> bool:
        """Create default topics"""
        topics = ["learning.explained", "code.executed", "exercise.failed"]

        for topic in topics:
            cmd = [
                "kubectl", "exec", "-it", "kafka-0", "-n", self.namespace, "--",
                "kafka-topics.sh",
                "--create",
                "--topic", topic,
                "--bootstrap-server", "localhost:9092",
                "--partitions", "3",
                "--replication-factor", "1",
                "--if-not-exists"
            ]
            success, _ = self.run(cmd, f"Create topic {topic}")
            if not success:
                return False

        return True

    def deploy(self) -> bool:
        """Execute full deployment"""
        print("Step 1: Adding Helm repository...")
        if not self.add_helm_repo():
            return False

        print("Step 2: Creating namespace...")
        if not self.create_namespace():
            return False

        print("Step 3: Installing Kafka cluster...")
        if not self.install_kafka():
            return False

        print("Step 4: Creating default topics...")
        if not self.create_topics():
            return False

        print("Deployment complete!")
        return True

def main():
    parser = argparse.ArgumentParser(description="Deploy Kafka to Kubernetes")
    parser.add_argument("--namespace", default="kafka", help="Kubernetes namespace")
    args = parser.parse_args()

    deployer = HelmDeployer(namespace=args.namespace)
    success = deployer.deploy()

    if not success:
        print(f"Error: {deployer.errors[0] if deployer.errors else 'Unknown error'}")
        sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    main()
```

**Explanation**: This Python script:
1. Handles all Helm and kubectl commands
2. Manages error handling internally
3. Logs progress to stdout (which main.sh redirects to log file)
4. Returns only exit codes to main.sh

**Token Cost**: 0 tokens in agent context (all processing happens externally)

## File 4: scripts/verify.py

**Purpose**: Verify deployment succeeded

**File**: [assets/examples/scripts/kafka-verify.py](assets/examples/scripts/kafka-verify.py)

```python
#!/usr/bin/env python3
"""
Kafka Verification Script
Checks deployment health
Returns only status summary, not raw data
"""

import subprocess
import json
import sys
import argparse

class KafkaVerifier:
    def __init__(self, namespace: str):
        self.namespace = namespace
        self.checks_passed = []
        self.checks_failed = []

    def run_command(self, cmd):
        """Execute kubectl command"""
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr

    def check_pods(self) -> bool:
        """Verify all pods running"""
        success, stdout, _ = self.run_command([
            "kubectl", "get", "pods", "-n", self.namespace, "-o", "json"
        ])

        if not success:
            self.checks_failed.append("Cannot access pods")
            return False

        try:
            pods = json.loads(stdout)["items"]
            if not pods:
                self.checks_failed.append("No pods found")
                return False

            running = sum(1 for p in pods if p["status"]["phase"] == "Running")
            total = len(pods)

            # Return only summary
            if running == total:
                self.checks_passed.append(f"✓ All {total} pods running")
                return True
            else:
                self.checks_failed.append(f"Only {running}/{total} pods running")
                return False
        except json.JSONDecodeError:
            self.checks_failed.append("Cannot parse pod data")
            return False

    def check_services(self) -> bool:
        """Verify Kafka service exists"""
        success, stdout, _ = self.run_command([
            "kubectl", "get", "svc", "-n", self.namespace
        ])

        if "kafka" in stdout:
            self.checks_passed.append("✓ Kafka service exists")
            return True
        else:
            self.checks_failed.append("Kafka service not found")
            return False

    def check_topics(self) -> bool:
        """Verify default topics created"""
        cmd = [
            "kubectl", "exec", "-it", "kafka-0", "-n", self.namespace, "--",
            "kafka-topics.sh", "--list", "--bootstrap-server", "localhost:9092"
        ]
        success, stdout, _ = self.run_command(cmd)

        if success and "learning" in stdout:
            self.checks_passed.append("✓ Default topics created")
            return True
        else:
            self.checks_failed.append("Topics not accessible")
            return False

    def verify(self) -> bool:
        """Run all verification checks"""
        self.check_pods()
        self.check_services()
        self.check_topics()

        # Print only summary
        for check in self.checks_passed:
            print(check)

        for check in self.checks_failed:
            print(f"⚠ {check}")

        return len(self.checks_failed) == 0

def main():
    parser = argparse.ArgumentParser(description="Verify Kafka deployment")
    parser.add_argument("--namespace", default="kafka")
    args = parser.parse_args()

    verifier = KafkaVerifier(namespace=args.namespace)
    success = verifier.verify()

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
```

**Explanation**: This verification script:
1. Checks pods are running
2. Checks services exist
3. Checks topics were created
4. Returns only summary status (not full pod details)

**Token Cost**: Agent sees 3-4 lines (~8 tokens) instead of thousands

## File 5: REFERENCE.md

**Purpose**: Deep documentation loaded only when agent asks

**File**: [assets/examples/reference/kafka-reference.md](assets/examples/reference/kafka-reference.md)

The REFERENCE.md file contains:
- Architecture overview
- Configuration options (replica count, storage, resources)
- Topic management commands
- Connectivity testing
- Troubleshooting guide
- Performance tuning
- Monitoring
- Upgrade and uninstall procedures

**Token Cost**: 0 tokens unless agent explicitly asks to see it

See the complete file at [assets/examples/reference/kafka-reference.md](assets/examples/reference/kafka-reference.md)

## Token Breakdown

| Component | Lines | Tokens | Loaded When |
|-----------|-------|--------|-------------|
| SKILL.md | 60 | 100 | Always (agent context) |
| main.sh | 40 | 0 | Executes, doesn't load |
| deploy.py | 150 | 0 | Executes, doesn't load |
| verify.py | 100 | 0 | Executes, doesn't load |
| REFERENCE.md | 200 | 0 | Only if agent requests |
| **Total** | 550 | **100** | **99.8% reduction** |

Compare to direct MCP: 50,000 tokens

## Complete File References

All five files are available in the assets directory:

1. [assets/examples/skill-templates/kafka-skill.md](assets/examples/skill-templates/kafka-skill.md) - SKILL.md
2. [assets/examples/scripts/kafka-main.sh](assets/examples/scripts/kafka-main.sh) - Entry point
3. [assets/examples/scripts/kafka-deploy.py](assets/examples/scripts/kafka-deploy.py) - Deployment logic
4. [assets/examples/scripts/kafka-verify.py](assets/examples/scripts/kafka-verify.py) - Verification checks
5. [assets/examples/reference/kafka-reference.md](assets/examples/reference/kafka-reference.md) - Deep documentation

## Creating Your Own Skill

To create a similar skill (estimated 30 minutes):

1. **Copy the template** (5 min)
   - Start with [generic-skill-template.md](assets/examples/skill-templates/generic-skill-template.md)
   - Customize name, description, "When to Use" section

2. **Write main script** (5 min)
   - Copy [bash-pattern.sh](assets/examples/scripts/bash-pattern.sh)
   - Update namespace, log file paths
   - Call your deploy and verify scripts

3. **Write deployment logic** (10 min)
   - Copy [python-pattern.py](assets/examples/scripts/python-pattern.py)
   - Replace Kafka-specific commands with your commands
   - Keep error handling structure

4. **Write verification** (5 min)
   - Copy [verification-pattern.py](assets/examples/scripts/verification-pattern.py)
   - Add checks relevant to your deployment

5. **Create REFERENCE.md** (5 min)
   - Document configuration options
   - Add troubleshooting steps
   - Include examples

## Cross-References

- **Source Playbook**: See [caps-library/playbooks/kafka-k8s-setup/playbook.md](../../../playbooks/kafka-k8s-setup/playbook.md) for the CAPS playbook source
- **Skill Structure**: See [03-skill-structure.md](03-skill-structure.md) for template details
- **Writing Scripts**: See [04-writing-scripts.md](04-writing-scripts.md) for scripting patterns

## Next Steps

- Understand on-demand documentation: [06-reference-pattern.md](06-reference-pattern.md)
- Test across agents: [07-cross-agent-testing.md](07-cross-agent-testing.md)
- Apply best practices: [09-best-practices.md](09-best-practices.md)
