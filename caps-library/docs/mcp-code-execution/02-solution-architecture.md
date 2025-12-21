# Solution Architecture

## Core Insight

**Move processing from Agent Context to Script Execution**

The fundamental breakthrough: instead of loading tool definitions and data into the agent's context, wrap MCP operations in external scripts that execute outside the context window. The agent only sees minimal instructions and final results.

---

## Before/After Comparison

### Before (Direct MCP): 50,000+ Tokens

```
┌─────────────────────────────────────────┐
│ Agent Context Window (300k tokens)      │
├─────────────────────────────────────────┤
│ MCP Tool Definitions (15k tokens)       │
│   - kubectl_get_pods (800 tokens)       │
│   - kubectl_apply (800 tokens)          │
│   - kubectl_logs (800 tokens)           │
│   - ... (22 more tools)                 │
│                                         │
│ Previous Results (25k tokens)           │
│   - Full pod descriptions               │
│   - Complete service specs              │
│   - Raw log outputs                     │
│                                         │
│ Conversation History (rest)             │
├─────────────────────────────────────────┤
│ 45,000 tokens consumed before task      │
│ Only 255,000 tokens available for work  │
└─────────────────────────────────────────┘
```

### After (Skills + Scripts): 110 Tokens

```
┌─────────────────────────────────────────┐
│ Agent Context Window (300k tokens)      │
├─────────────────────────────────────────┤
│ SKILL.md (~100 tokens)                  │
│   - Brief instructions                  │
│   - Script path                         │
│   - When to use                         │
│                                         │
│ Script Output (~10 tokens)              │
│   - ✓ Kafka deployed successfully       │
│   - ✓ All 3 pods running                │
│                                         │
│ Conversation History (rest)             │
├─────────────────────────────────────────┤
│ 110 tokens consumed, 299,890 available  │
│ 99.96% of context window free           │
└─────────────────────────────────────────┘
```

**Improvement**: 99.8% token reduction (50,000 → 110 tokens)

See [assets/diagrams/before-after-tokens.mermaid](assets/diagrams/before-after-tokens.mermaid) for visual comparison.

---

## The 4-Part Structure

The solution consists of four components working together:

```
.claude/skills/{skill-name}/
├── SKILL.md           # What agent loads (~100 tokens)
├── REFERENCE.md       # Deep docs (loaded on-demand only)
├── scripts/
│   ├── main.sh        # Entry point
│   ├── deploy.py      # Does actual work
│   └── verify.py      # Checks success
└── examples/
    └── config.yaml    # Optional: Usage examples
```

See [assets/diagrams/4-part-structure.mermaid](assets/diagrams/4-part-structure.mermaid) for component relationships.

---

## Part 1: SKILL.md (~100 tokens)

**Purpose**: Minimal instructions for the agent

**Token Cost**: ~100 tokens (loaded into context)

**Content**:
```markdown
---
name: kafka-k8s-setup
description: Deploy Apache Kafka on Kubernetes
---

# Kafka Kubernetes Setup

Deploy Kafka cluster with topics and verification.

## When to Use
- User asks to deploy Kafka
- Setting up event-driven microservices

## Instructions
1. Run: `./scripts/main.sh`
2. Monitor: Script outputs progress
3. Verify: Check validation output

See [REFERENCE.md](./REFERENCE.md) for configuration options.
```

**What agent sees**: ~100 tokens
- Title and description
- Brief instructions
- When to invoke the skill
- Link to deeper documentation

**What agent doesn't see**: Configuration details, troubleshooting, advanced options (moved to REFERENCE.md)

---

## Part 2: scripts/ (0 tokens)

**Purpose**: Execute actual work outside agent context

**Token Cost**: 0 tokens (never loaded, only executed)

**Entry Point**: `scripts/main.sh`
```bash
#!/bin/bash
set -euo pipefail

echo "Deploying Kafka..."

# Execute deploy (no context bloat)
./scripts/deploy.py \
  --namespace kafka \
  --replicaCount 1

# Return minimal result to context
if [ $? -eq 0 ]; then
  echo "✓ Kafka deployed successfully"
  exit 0
else
  echo "✗ Deployment failed"
  exit 1
fi
```

**What agent sees**: Only final status message (~10 tokens)
```
✓ Kafka deployed successfully
```

**What happens behind the scenes** (invisible to agent):
- Helm repo added
- Namespace created
- Kafka installed
- Topics created
- Pods verified
- Services checked

**All work executes externally, consuming 0 tokens from context window.**

---

## Part 3: REFERENCE.md (0 tokens initially)

**Purpose**: Deep documentation loaded only when explicitly requested

**Token Cost**: 0 tokens until agent asks for it

**Content**:
```markdown
# Kafka Setup Reference

## Configuration Options

### replicaCount
Number of Kafka broker replicas (default: 1, production: 3+)

### persistenceSize
Storage per broker (default: 10Gi, production: 100Gi+)

## Troubleshooting

If pods stuck in Pending:
- Check: kubectl describe pod kafka-0 -n kafka
- Solution: Increase Minikube memory: minikube start --memory=8192
```

**When agent loads this**: Only if it explicitly asks "show me the reference" or "what are the configuration options"

**Token cost when loaded**: ~1,000 tokens (on-demand only)

---

## Part 4: examples/ (0 tokens initially)

**Purpose**: Sample configurations and usage examples

**Token Cost**: 0 tokens until referenced

**Content**:
```yaml
# examples/production.yaml
replicaCount: 3
persistence:
  size: 100Gi
monitoring: true
resources:
  requests:
    memory: 4Gi
    cpu: 2000m
```

**When agent loads this**: Only if it needs to see example configurations

---

## Token Budget Breakdown

| Component | Loaded Initially | Loaded On-Demand | Notes |
|-----------|------------------|------------------|-------|
| SKILL.md | ~100 tokens | Always | Brief instructions only |
| scripts/ | 0 tokens | Never | Executes externally |
| REFERENCE.md | 0 tokens | ~1,000 tokens | Only when requested |
| examples/ | 0 tokens | ~200 tokens | Only when referenced |
| **Script Output** | ~10 tokens | Always | Minimal status messages |
| **Total** | **110 tokens** | 0-1,200 tokens | 99.8% reduction |

---

## How It Works: Step-by-Step

### User Request
```
User: "Deploy Kafka to my cluster"
```

### Agent Flow
1. **Agent reads SKILL.md** (~100 tokens loaded)
   - Sees: "Deploy Kafka cluster with topics and verification"
   - Finds: Instructions to run `./scripts/main.sh`

2. **Agent executes script** (0 tokens consumed)
   - Script runs outside context window
   - Helm commands execute
   - Kubernetes resources created
   - All processing happens externally

3. **Agent receives result** (~10 tokens loaded)
   - Sees: `✓ Kafka deployed successfully`
   - Reports back to user

**Total token consumption**: 110 tokens (100 + 10)

**Equivalent direct MCP**: 50,000+ tokens (15k tool defs + 35k data)

---

## Why This Works

### Problem → Solution Mapping

| Token Problem | How Solution Fixes It |
|---------------|----------------------|
| **Problem 1: Tool Definition Loading** | No MCP tool definitions in SKILL.md - just script path |
| **Problem 2: Data Bloat in Context** | Scripts process data externally, return only summaries |
| **Problem 3: Transcript Duplication** | Single script execution, no tool-to-tool handoffs |

### Key Principles

1. **Minimal Instructions**: SKILL.md contains only what agent needs to know
2. **External Execution**: All processing happens outside context window
3. **Filtered Results**: Scripts return summaries, not raw data
4. **On-Demand Documentation**: REFERENCE.md loaded only when needed

---

## Comparison: Same Task, Different Approaches

### Task: Deploy Kafka and Verify

**Direct MCP Approach**:
```
1. Load MCP tool definitions: 15,000 tokens
2. Call kubectl_create_namespace: +5,000 tokens
3. Call helm_install: +10,000 tokens
4. Call kubectl_get_pods: +25,000 tokens
5. Call kubectl_get_services: +10,000 tokens
Total: 65,000 tokens
```

**Skills + Scripts Approach**:
```
1. Load SKILL.md: 100 tokens
2. Execute ./scripts/main.sh: 0 tokens (external)
3. Receive result: 10 tokens
Total: 110 tokens
```

**Savings**: 64,890 tokens (99.83% reduction)

---

## Related Documentation

- **Previous**: [The Token Problem](01-token-problem.md) - Problems being solved
- **Next**: [Skill Structure](03-skill-structure.md) - Detailed structure breakdown
- **Reference**: [CAPS-to-Skills Compiler](../compiler-guide/02-architecture.md) - How CAPS playbooks compile to this structure

---

## Next Steps

Now that you understand the architecture:

1. **Learn the structure**: Read [Skill Structure](03-skill-structure.md) for SKILL.md template details
2. **Write your first script**: See [Writing Efficient Scripts](04-writing-scripts.md) for Python/Bash patterns
3. **Study an example**: Review [Complete Kafka Example](05-kafka-example.md) for a working implementation

---

**Key Takeaway**: By moving processing outside the agent's context window, we achieve 99.8% token reduction while maintaining full functionality.

---

[← Previous: The Token Problem](01-token-problem.md) | [Back to README](README.md) | [Next: Skill Structure →](03-skill-structure.md)
