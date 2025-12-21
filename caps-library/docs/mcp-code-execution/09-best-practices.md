---
description: Production-grade patterns and anti-patterns with DO/DON'T lists and example skills by difficulty level
readingTime: 14 minutes
---

# Best Practices

## Overview

This section provides production-grade patterns and anti-patterns for building efficient Skills. Following these practices ensures 99% token reduction while maintaining reliability.

## DO: Essential Best Practices

### 1. Keep SKILL.md Minimal

**Practice**: Limit SKILL.md to 100-120 tokens

**Why**: Every token in SKILL.md is loaded into agent context every time the skill is used

**Example**:
```markdown
## Configuration

See [REFERENCE.md](./REFERENCE.md) for all options.
```

Instead of:
```markdown
## Configuration

### replicaCount
Number of replicas (1-5). Default: 1. Production: 3+.

### persistenceSize
Storage per replica (10Gi-1Ti). Default: 10Gi.

### resources
CPU: 500m-2000m. Memory: 2Gi-8Gi.
```

**Result**: 10 tokens vs. 80 tokens (87.5% reduction)

---

### 2. Move All Work to Scripts

**Practice**: Execute all logic in external scripts, not in agent context

**Why**: Script processing happens outside context window (0 tokens)

**Example**:
```bash
# SKILL.md tells agent to run this
./scripts/main.sh
```

**main.sh does**:
- Validates inputs
- Calls APIs
- Processes responses
- Handles errors
- Returns minimal status

**Agent sees**: "✓ Success" (2 tokens) instead of 25,000 tokens of API responses

---

### 3. Return Minimal Output

**Practice**: Scripts return status messages only, not raw data

**Why**: Every line of output consumes tokens

**Example**:
```python
# BAD: Return full pod list
pods = get_pods()
for pod in pods:
    print(json.dumps(pod))  # 1000+ tokens

# GOOD: Return summary
pods = get_pods()
running = sum(1 for p in pods if p["status"]["phase"] == "Running")
print(f"✓ All {len(pods)} pods running")  # 8 tokens
```

**Result**: 8 tokens vs. 1000+ tokens (99.2% reduction)

---

### 4. Test Both Agents

**Practice**: Validate skills work identically with Claude Code and Goose

**Why**: Constitution Principle VIII requires feature parity

**Process**:
1. Run skill with Claude Code
2. Run skill with Goose
3. Compare outputs
4. Fix any discrepancies

**Tool**: [test-cross-agent-compat.sh](assets/examples/scripts/test-cross-agent-compat.sh)

---

### 5. Use Exit Codes Properly

**Practice**: Return meaningful exit codes from scripts

**Why**: Agents need to know if operations succeeded without reading logs

**Pattern**:
```bash
exit 0   # Success - all operations completed
exit 1   # Failure - critical error occurred
exit 2   # Warning - completed with non-critical issues
```

**Example**:
```python
if deploy_succeeded:
    sys.exit(0)
elif critical_failure:
    print("✗ Deployment failed: {error}")
    sys.exit(1)
else:
    print("⚠ Deployed with warnings")
    sys.exit(2)
```

---

### 6. Handle Errors Gracefully

**Practice**: Catch errors, log internally, return user-friendly messages

**Why**: Stack traces consume tokens and confuse agents

**Pattern**:
```python
try:
    result = subprocess.run(cmd, check=True, capture_output=True)
    return True
except subprocess.CalledProcessError as e:
    # Log full error internally
    self.errors.append(f"Command failed: {e.stderr}")
    # Return minimal message
    print("✗ Deployment failed (see logs)")
    return False
```

**Examples in documentation**:
- Timeout handling (04-writing-scripts.md#example-1)
- Retries with backoff (04-writing-scripts.md#example-2)
- Graceful degradation (04-writing-scripts.md#example-3)
- Resource cleanup (04-writing-scripts.md#example-4)
- Input validation (04-writing-scripts.md#example-5)

---

## DON'T: Common Anti-Patterns

### 1. Don't Load Large Data into Context

**Problem**: Returning raw API responses to agent

**Why**: Consumes thousands of tokens unnecessarily

**Example**:
```python
# BAD: Echo full kubectl output
result = subprocess.run(["kubectl", "get", "pods", "-o", "json"], capture_output=True)
print(result.stdout)  # 5,000+ tokens

# GOOD: Parse and summarize
pods = json.loads(result.stdout)["items"]
print(f"✓ {len(pods)} pods running")  # 5 tokens
```

**Consequence**: Context exhaustion after 2-3 operations

---

### 2. Don't Make MCP Calls Directly

**Problem**: Loading MCP servers in agent context

**Why**: Defeats the purpose of the MCP Code Execution Pattern

**Example**:
```json
// BAD: Direct MCP in agent config
{
  "mcpServers": {
    "kubernetes": {
      "command": "mcp-k8s-server"
    }
  }
}
```

**Solution**: Wrap MCP calls in scripts
```bash
# GOOD: Script calls MCP, returns minimal output
./scripts/kubectl-wrapper.sh get pods
# Returns: "✓ 3 pods running" instead of full JSON
```

**Consequence**: 50,000+ tokens loaded before any work

---

### 3. Don't Hard-code Values

**Problem**: Embedding configuration in scripts

**Why**: Reduces reusability and flexibility

**Example**:
```python
# BAD: Hard-coded namespace
kubectl.create_namespace("kafka")

# GOOD: Parameterized
def create_namespace(name: str):
    kubectl.create_namespace(name)
```

**Solution**:
- Use command-line arguments
- Support environment variables
- Provide sensible defaults

**Consequence**: Need separate skills for dev/staging/prod

---

### 4. Don't Skip Error Handling

**Problem**: Assuming commands always succeed

**Why**: Silent failures lead to inconsistent state

**Example**:
```python
# BAD: No error handling
subprocess.run(["helm", "install", "kafka", "bitnami/kafka"])

# GOOD: Handle errors
try:
    subprocess.run(
        ["helm", "install", "kafka", "bitnami/kafka"],
        check=True,
        timeout=300
    )
except subprocess.CalledProcessError as e:
    print(f"✗ Helm install failed: {e}")
    sys.exit(1)
except TimeoutError:
    print("✗ Helm install timed out")
    sys.exit(1)
```

**Consequence**: Deployments fail silently, difficult to debug

---

### 5. Don't Forget REFERENCE.md

**Problem**: Omitting deep documentation

**Why**: Users need configuration guidance and troubleshooting

**Example**:
```
# BAD: Only SKILL.md exists
.claude/skills/my-skill/
├── SKILL.md
└── scripts/

# GOOD: Complete documentation
.claude/skills/my-skill/
├── SKILL.md
├── REFERENCE.md          # Configuration, troubleshooting
└── scripts/
```

**Consequence**: Repeated clarification questions, support burden

---

## Example Skills to Build

### Foundation Skills (Beginner)

Perfect for learning the pattern:

#### 1. agents-md-gen
- **Purpose**: Generate AGENTS.md file for repositories
- **Complexity**: Simple file generation
- **Script Size**: ~30 lines
- **Learning Focus**: Basic script structure, file I/O

#### 2. k8s-health-check
- **Purpose**: Check Kubernetes cluster health
- **Complexity**: Simple kubectl commands
- **Script Size**: ~50 lines
- **Learning Focus**: Command execution, status aggregation

---

### Infrastructure Skills (Intermediate)

Production infrastructure deployment:

#### 1. kafka-k8s-setup
- **Purpose**: Deploy Apache Kafka on Kubernetes
- **Complexity**: Multi-step Helm deployment
- **Script Size**: ~200 lines
- **Learning Focus**: Orchestration, verification, topics

**See**: [05-kafka-example.md](05-kafka-example.md) for complete walkthrough

#### 2. postgres-k8s-setup
- **Purpose**: Deploy PostgreSQL on Kubernetes
- **Complexity**: Secrets, persistent volumes, migrations
- **Script Size**: ~250 lines
- **Learning Focus**: State management, database initialization

#### 3. helm-chart-deploy
- **Purpose**: Generic Helm chart deployment
- **Complexity**: Parameterized deployment
- **Script Size**: ~150 lines
- **Learning Focus**: Reusability, configuration handling

---

### Application Skills (Advanced)

Application code generation and deployment:

#### 1. fastapi-dapr-agent
- **Purpose**: Generate FastAPI microservice with Dapr sidecar
- **Complexity**: Code generation, templates, configuration
- **Script Size**: ~300 lines
- **Learning Focus**: Template rendering, multi-file generation

#### 2. mcp-code-execution
- **Purpose**: Wrapper pattern for MCP code execution
- **Complexity**: MCP integration, sandboxing, result filtering
- **Script Size**: ~400 lines
- **Learning Focus**: MCP wrapping, security, output filtering

#### 3. nextjs-k8s-deploy
- **Purpose**: Build and deploy Next.js application
- **Complexity**: Docker build, image push, K8s deployment
- **Script Size**: ~200 lines
- **Learning Focus**: Multi-stage builds, registry integration

---

## Error Handling Examples Summary

This documentation includes 5+ error handling examples:

1. **Timeout Handling** (04-writing-scripts.md#example-1): Handling long-running operations
2. **Retries with Backoff** (04-writing-scripts.md#example-2): Resilient network calls
3. **Graceful Degradation** (04-writing-scripts.md#example-3): Optional components
4. **Resource Cleanup** (04-writing-scripts.md#example-4): Always cleanup on failure
5. **Input Validation** (04-writing-scripts.md#example-5): Prevent invalid operations

All examples provide copy-paste ready code with explanations.

## Cross-References

- **Constitution Principles**: See [../../.specify/memory/constitution.md](../../.specify/memory/constitution.md) for project governance
- **Script Patterns**: See [04-writing-scripts.md](04-writing-scripts.md) for detailed implementation
- **REFERENCE.md Pattern**: See [06-reference-pattern.md](06-reference-pattern.md) for documentation strategy

## Validation Checklist

Before deploying a skill, verify:

- [ ] SKILL.md is <120 tokens
- [ ] All work happens in scripts (not context)
- [ ] Output is minimal (status only)
- [ ] Tested with both Claude Code and Goose
- [ ] Exit codes are meaningful (0/1/2)
- [ ] Errors handled gracefully (try/except, set -euo pipefail)
- [ ] REFERENCE.md exists for complex skills
- [ ] No hard-coded values (use parameters)
- [ ] Python 3.8+ compatible
- [ ] Bash 4.0+ compatible

## Next Steps

1. **Review the complete example**: [05-kafka-example.md](05-kafka-example.md)
2. **Test your skills**: [07-cross-agent-testing.md](07-cross-agent-testing.md)
3. **Verify benchmarks**: [08-performance-benchmarks.md](08-performance-benchmarks.md)
4. **Start building**: Choose a Foundation skill and implement it
5. **Iterate**: Refine based on test results

## Success Criteria

Your skill is ready for production when:

1. **Token Usage**: <200 tokens per invocation (target: 110)
2. **Cross-Agent**: Passes all 6 checklist items
3. **Error Handling**: Never crashes, always returns meaningful errors
4. **Documentation**: SKILL.md + REFERENCE.md both exist
5. **Testing**: Verified with real deployments

---

**Best Practices Complete** ✓

You now have all the knowledge needed to build production-grade Skills with the MCP Code Execution Pattern!
