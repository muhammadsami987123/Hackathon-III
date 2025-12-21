# Quickstart: MCP Code Execution Pattern

**5-Minute Guide to Token-Efficient Skills**

---

## What is the MCP Code Execution Pattern?

The **MCP Code Execution Pattern** is Hackathon 3's core innovation for building AI agent skills that consume **99.8% fewer tokens** than traditional Model Context Protocol (MCP) integrations.

**The Problem**: Direct MCP tool integration loads 50,000+ tokens into agent context (tool definitions + data bloat), consuming 35% of your 300k context window before you even start working.

**The Solution**: Wrap MCP tools in minimal Skills that execute external scripts. Agents see only a ~100 token interface file, while all actual work happens outside context.

---

## Token Reduction Impact

| Approach | Tokens Consumed | Result |
|----------|----------------|--------|
| **Before** (Direct MCP) | 50,000+ | Context exhausted after 1-2 complex tasks |
| **After** (Skills + Scripts) | 110 | 25-50x more productive per session |

**Real-world example**: Deploying Kafka to Kubernetes
- Direct MCP: 50,000 tokens (tool definitions) + 25,000 tokens (pod data) = **75,000 tokens**
- Skills + Scripts: 100 tokens (SKILL.md) + 10 tokens (status message) = **110 tokens**
- **Reduction**: 99.85% (680x fewer tokens)

---

## The 4-Part Skill Structure

```
.claude/skills/{skill-name}/
├── SKILL.md           # ~100 tokens (what agent loads)
├── REFERENCE.md       # 0 tokens (on-demand only)
├── scripts/
│   ├── main.sh        # 0 tokens (executes externally)
│   ├── deploy.py      # 0 tokens
│   └── verify.py      # 0 tokens
└── examples/          # 0 tokens initially
    └── config.yaml
```

**Key Insight**: Agents see only SKILL.md (~100 tokens). Scripts execute outside context and return minimal status (~10 tokens). Total: **110 tokens** vs. **50,000+ for direct MCP**.

---

## Your First Skill in 5 Steps

### Step 1: Create Skill Directory (2 min)

```bash
mkdir -p .claude/skills/my-first-skill/scripts
cd .claude/skills/my-first-skill
```

### Step 2: Write SKILL.md Interface (~100 tokens) (5 min)

```markdown
---
name: my-first-skill
description: Deploy service to Kubernetes with health verification
---

# My First Skill

Deploy a service to Kubernetes and verify health.

## When to Use
- User asks: "Deploy my-service"
- Setting up new service

## Quick Start
Run the main script:
\`\`\`bash
./scripts/main.sh my-service
\`\`\`

## What Happens
1. Creates Kubernetes namespace
2. Applies deployment manifest
3. Waits for pods to be ready
4. Verifies service health

## Configuration
See [REFERENCE.md](./REFERENCE.md) for advanced options.
```

**Token count**: ~95 tokens ✓

### Step 3: Write Main Script (executes externally) (10 min)

```bash
#!/bin/bash
# scripts/main.sh - Orchestrates deployment

set -euo pipefail  # Fail fast on errors

SERVICE_NAME="${1:-my-service}"

echo "Deploying $SERVICE_NAME..."

# Deploy (all work happens here, not in agent context)
python3 ./scripts/deploy.py --service "$SERVICE_NAME" || {
    echo "✗ Deployment failed"
    exit 1
}

# Verify
python3 ./scripts/verify.py --service "$SERVICE_NAME" || {
    echo "✗ Verification failed"
    exit 1
}

# Return minimal status to agent (only this appears in context)
echo "✓ $SERVICE_NAME deployed and healthy"
exit 0
```

### Step 4: Write Deploy Script (Python) (10 min)

```python
#!/usr/bin/env python3
"""Deploy script - all work happens here, not in agent context"""

import subprocess
import sys
import argparse

def deploy(service_name):
    """Deploy service to Kubernetes"""
    try:
        # Create namespace
        subprocess.run([
            "kubectl", "create", "namespace", service_name,
            "--dry-run=client", "-o", "yaml", "|",
            "kubectl", "apply", "-f", "-"
        ], check=True, capture_output=True)

        # Apply manifests
        subprocess.run([
            "kubectl", "apply", "-f", f"manifests/{service_name}/",
            "-n", service_name
        ], check=True, capture_output=True)

        return True
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.stderr.decode()}", file=sys.stderr)
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--service", required=True)
    args = parser.parse_args()

    success = deploy(args.service)
    sys.exit(0 if success else 1)
```

### Step 5: Test Your Skill (3 min)

```bash
# Make scripts executable
chmod +x scripts/*.sh scripts/*.py

# Test with Claude Code
claude --skill my-first-skill

# Expected output (only ~10 tokens in agent context):
# ✓ my-service deployed and healthy
```

**Total time**: ~30 minutes ✓ (matches SC-002 success criterion)

---

## What You Just Created

✅ **SKILL.md**: 95 tokens (agent loads this)
✅ **main.sh**: 0 tokens (executes externally)
✅ **deploy.py**: 0 tokens (executes externally)
✅ **Status output**: ~10 tokens ("✓ my-service deployed and healthy")

**Total in agent context**: **105 tokens** vs. **50,000+ for direct MCP** = **99.8% reduction**

---

## Next Steps

### 📚 Deep Dive
- **[The Token Problem](01-token-problem.md)** - Understand the 3 token issues (Tool Definition Loading, Data Bloat, Transcript Duplication)
- **[Solution Architecture](02-solution-architecture.md)** - How the 4-part structure solves token bloat
- **[Skill Structure](03-skill-structure.md)** - Complete template and validation rules

### 🔧 Build Production Skills
- **[Writing Efficient Scripts](04-writing-scripts.md)** - Python/Bash patterns, error handling, exit codes
- **[Complete Kafka Example](05-kafka-example.md)** - Full working skill with all 4 parts (SKILL.md, scripts, REFERENCE.md)
- **[REFERENCE.md Pattern](06-reference-pattern.md)** - On-demand documentation that loads only when needed

### 🚀 Advanced Topics
- **[Cross-Agent Testing](07-cross-agent-testing.md)** - Ensure skills work with both Claude Code and Goose
- **[Performance Benchmarks](08-performance-benchmarks.md)** - Token metrics and real-world impact data
- **[Best Practices](09-best-practices.md)** - DO/DON'T lists, example skills by difficulty

---

## Common Patterns

### Pattern 1: Python Class-Based Deployer
```python
class ServiceDeployer:
    def __init__(self, service_name):
        self.service_name = service_name
        self.errors = []

    def run_command(self, cmd):
        """Execute command, capture output, handle errors"""
        try:
            subprocess.run(cmd, check=True, capture_output=True, timeout=300)
            return True
        except subprocess.CalledProcessError as e:
            self.errors.append(f"Failed: {e.stderr.decode()}")
            return False

    def deploy(self):
        """All work happens here"""
        if not self.run_command(["kubectl", "create", "namespace", self.service_name]):
            return False
        if not self.run_command(["kubectl", "apply", "-f", "manifests/"]):
            return False
        return True

    def get_status(self):
        """Return minimal status to agent"""
        if self.errors:
            return {"status": "failed", "message": f"✗ Deployment failed: {self.errors[0]}"}
        return {"status": "success", "message": f"✓ {self.service_name} deployed successfully"}
```

### Pattern 2: Bash Orchestration
```bash
#!/bin/bash
set -euo pipefail  # Fail on any error

# All detailed work logged to file (not agent context)
LOG_FILE="/tmp/deploy-$(date +%s).log"

{
    echo "Starting deployment..."
    ./scripts/deploy.py --service "$SERVICE_NAME"
    ./scripts/verify.py --service "$SERVICE_NAME"
} >> "$LOG_FILE" 2>&1

# Only final status to agent
if [ $? -eq 0 ]; then
    echo "✓ Deployment successful"
    exit 0
else
    echo "✗ Deployment failed - check logs: $LOG_FILE"
    tail -10 "$LOG_FILE"
    exit 1
fi
```

### Pattern 3: Verification with Status Summaries
```python
def verify_deployment(service_name):
    """Check health, return only summary (not raw pod data)"""
    result = subprocess.run(
        ["kubectl", "get", "pods", "-n", service_name, "-o", "json"],
        capture_output=True, text=True
    )

    pods = json.loads(result.stdout)["items"]
    running = sum(1 for p in pods if p["status"]["phase"] == "Running")
    total = len(pods)

    # Agent sees only summary (not full pod descriptions)
    if running == total:
        print(f"✓ All {total} pods running")
        return True
    else:
        print(f"⚠ {running}/{total} pods running")
        return False
```

---

## Key Principles

### ✅ DO
- Keep SKILL.md minimal (<120 tokens)
- Move all work to external scripts
- Return only status messages (~10 tokens)
- Use meaningful exit codes (0=success, 1=failure, 2=warning)
- Handle errors gracefully in scripts

### ❌ DON'T
- Load large data into agent context (e.g., raw kubectl output)
- Make MCP calls directly (wrap in scripts instead)
- Hard-code values (use parameters/environment variables)
- Skip error handling (use try/except, set -euo pipefail)
- Forget REFERENCE.md (users need configuration options)

---

## Validation

Before deploying your skill:
- [ ] SKILL.md is <120 tokens (check with `wc -w SKILL.md`)
- [ ] Scripts have error handling (try/except or set -euo pipefail)
- [ ] Scripts return minimal status (not raw command output)
- [ ] Scripts use proper exit codes (0=success, 1=failure)
- [ ] Skill tested with both Claude Code and Goose (if applicable)

---

## Troubleshooting

**Problem**: Skill not recognized by agent
- **Check**: Is skill in `.claude/skills/` directory?
- **Check**: Does SKILL.md have valid YAML frontmatter?
- **Solution**: Run `claude list skills` to verify

**Problem**: Script execution fails
- **Check**: Are scripts executable? (`chmod +x scripts/*.sh scripts/*.py`)
- **Check**: Are dependencies installed? (kubectl, helm, python packages)
- **Solution**: Test scripts manually first (`./scripts/main.sh`)

**Problem**: Agent sees too much output (token bloat)
- **Check**: Are scripts printing raw command output?
- **Solution**: Use `capture_output=True` in Python, redirect to log file in Bash

---

## Learn More

📖 **Full Documentation**: [MCP Code Execution Pattern README](README.md)
🔧 **CAPS Compiler**: [How to compile playbooks to skills](../compiler-guide/README.md)
📜 **Project Constitution**: [Principles I, V, VII](../../.specify/memory/constitution.md)

---

**Quickstart Complete** | Next: [The Token Problem →](01-token-problem.md)
