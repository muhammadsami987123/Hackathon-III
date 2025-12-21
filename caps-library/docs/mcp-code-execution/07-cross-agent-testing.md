---
description: Ensure skill compatibility with both Claude Code and Goose using the 6-item testing checklist
readingTime: 10 minutes
---

# Cross-Agent Testing

## Overview

The LearnFlow project requires feature parity between Claude Code and Goose agents (Constitution Principle VIII). Every skill must work identically across both agents.

This section provides a systematic testing process to ensure cross-agent compatibility.

## Testing with Claude Code

Claude Code reads skills from `.claude/skills/` directory.

### Basic Testing

```bash
# Test skill is recognized
claude list skills | grep kafka-k8s-setup

# Run skill interactively
claude --skill kafka-k8s-setup

# Prompt Claude to use it
claude "Deploy Kafka to my local cluster"

# Verify output
# Expected: ✓ Kafka deployed successfully
```

### Expected Output

```
Starting Kafka deployment to namespace: kafka
Log file: /tmp/kafka-deploy-1234567890.log

✓ Kafka deployed successfully
✓ All validations passed

Next steps:
  1. kubectl get pods -n kafka
  2. Create topics: kubectl exec -it kafka-0 -n kafka -- kafka-topics.sh --create ...
  3. See REFERENCE.md for more options
```

## Testing with Goose

Goose reads `.claude/skills/` directly (same directory structure).

### Basic Testing

```bash
# List available skills
goose list skills

# Run skill
goose --skill kafka-k8s-setup "Deploy Kafka cluster"

# Verify
goose "Are the Kafka pods running?"
```

### Expected Output

Should be identical to Claude Code output (same scripts execute).

## Cross-Agent Testing Checklist

Use this 6-item checklist to verify compatibility:

### 1. Skill Recognition

**Test**: Both agents recognize the skill

**Claude Code**:
```bash
claude list skills | grep {skill-name}
```

**Goose**:
```bash
goose list skills | grep {skill-name}
```

**Pass Criteria**: Both commands return the skill name

---

### 2. Script Execution

**Test**: Both agents execute the main script successfully

**Claude Code**:
```bash
claude --skill {skill-name}
```

**Goose**:
```bash
goose --skill {skill-name}
```

**Pass Criteria**: Both exit with code 0 and produce output

---

### 3. Identical Output

**Test**: Both agents return the same status messages

**Process**:
1. Run skill with Claude Code, capture output
2. Run skill with Goose, capture output
3. Compare outputs line-by-line

**Pass Criteria**: Output messages match (timing/timestamps may differ)

---

### 4. REFERENCE.md Accessibility

**Test**: Both agents can access REFERENCE.md when requested

**Claude Code**:
```bash
claude "Show me the kafka-k8s-setup reference documentation"
```

**Goose**:
```bash
goose "Show me the kafka-k8s-setup reference documentation"
```

**Pass Criteria**: Both agents display REFERENCE.md content

---

### 5. Python 3.8+ Compatibility

**Test**: Scripts work with Python 3.8, 3.9, 3.10, 3.11+

**Process**:
```bash
# Test with different Python versions
python3.8 scripts/deploy.py --namespace test
python3.9 scripts/deploy.py --namespace test
python3.10 scripts/deploy.py --namespace test
python3.11 scripts/deploy.py --namespace test
```

**Pass Criteria**: All versions execute successfully

**Note**: Avoid f-strings with `=` (requires 3.8+), use type hints compatible with 3.8

---

### 6. Bash 4.0+ Compatibility

**Test**: Scripts work with Bash 4.0+

**Process**:
```bash
# Check Bash version
bash --version

# Validate syntax
bash -n scripts/main.sh

# Execute
bash scripts/main.sh
```

**Pass Criteria**: No syntax errors, successful execution

**Note**: Avoid Bash 5.0+ features (e.g., `${var@U}` for uppercase)

---

## Automated Testing Script

A test script is available to automate the 6-item checklist:

**File**: [assets/examples/scripts/test-cross-agent-compat.sh](assets/examples/scripts/test-cross-agent-compat.sh)

### Usage

```bash
# Test a skill
./test-cross-agent-compat.sh kafka-k8s-setup

# Test all skills
./test-cross-agent-compat.sh --all
```

### Example Output

```
Testing skill: kafka-k8s-setup
==============================

[1/6] Skill Recognition
  Claude Code: ✓ PASS
  Goose: ✓ PASS

[2/6] Script Execution
  Claude Code: ✓ PASS
  Goose: ✓ PASS

[3/6] Identical Output
  Comparing outputs...
  ✓ PASS (outputs match)

[4/6] REFERENCE.md Accessibility
  Claude Code: ✓ PASS
  Goose: ✓ PASS

[5/6] Python 3.8+ Compatibility
  Python 3.8: ✓ PASS
  Python 3.9: ✓ PASS
  Python 3.10: ✓ PASS
  Python 3.11: ✓ PASS

[6/6] Bash 4.0+ Compatibility
  Bash 4.4: ✓ PASS

==============================
Result: ALL CHECKS PASSED (6/6)
```

## Common Compatibility Issues

### Issue 1: Agent-Specific Commands

**Problem**: Using Claude-specific or Goose-specific commands in scripts

**Solution**: Use standard CLI tools only (kubectl, helm, python3, bash)

```bash
# BAD: Claude-specific
claude run command

# GOOD: Standard CLI
kubectl get pods
```

---

### Issue 2: Path Differences

**Problem**: Different working directories between agents

**Solution**: Use absolute paths or `$SCRIPT_DIR`

```bash
# BAD: Relative path
./deploy.py

# GOOD: Absolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/deploy.py"
```

---

### Issue 3: Environment Variables

**Problem**: Agents set different environment variables

**Solution**: Don't rely on agent-specific env vars

```bash
# BAD: Assuming $CLAUDE_HOME exists
cd $CLAUDE_HOME/skills

# GOOD: Detect dynamically
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
```

---

### Issue 4: Output Formatting

**Problem**: One agent expects structured output

**Solution**: Keep output simple (plain text, no JSON unless both support it)

```bash
# BAD: JSON output (may break one agent)
echo '{"status": "success"}'

# GOOD: Plain text
echo "✓ Deployment successful"
```

## Python 3.8+ Compatibility Notes

To ensure Python 3.8 compatibility:

1. **Avoid walrus operator** (`:=` requires 3.8+)
   ```python
   # BAD (3.8+ only)
   if (n := len(items)) > 0:
       print(n)

   # GOOD (3.7+)
   n = len(items)
   if n > 0:
       print(n)
   ```

2. **Use typing from typing module**
   ```python
   # BAD (3.9+ only)
   def func(items: list[str]) -> dict[str, int]:
       pass

   # GOOD (3.8+)
   from typing import List, Dict
   def func(items: List[str]) -> Dict[str, int]:
       pass
   ```

3. **Test with Python 3.8** if available

## Bash 4.0+ Compatibility Notes

To ensure Bash 4.0 compatibility:

1. **Avoid Bash 5.0+ features**
   ```bash
   # BAD (Bash 5.0+)
   echo "${var@U}"  # Uppercase transformation

   # GOOD (Bash 4.0+)
   echo "$var" | tr '[:lower:]' '[:upper:]'
   ```

2. **Use `set -euo pipefail`** (supported in 4.0+)

3. **Test with Bash 4.0** if available

## Cross-References

- **Constitution Principle VIII**: See [../../.specify/memory/constitution.md](../../.specify/memory/constitution.md) for Feature Parity requirement
- **Research**: See [research.md](../research.md) for agent behavior analysis

## Next Steps

- Review performance benchmarks: [08-performance-benchmarks.md](08-performance-benchmarks.md)
- Apply best practices: [09-best-practices.md](09-best-practices.md)
- Return to overview: [README.md](README.md)
