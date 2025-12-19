# CAPS Authoring Best Practices

**Version**: 1.0.0
**Date**: 2025-12-19
**Audience**: Playbook authors and maintainers

## Overview

This document provides guidelines for authoring high-quality CAPS (Coding Agent Playbook Specification) playbooks that AI agents can execute autonomously with minimal manual intervention.

## Table of Contents

1. [Required Fields](#required-fields)
2. [Step Structure](#step-structure)
3. [Validation Criteria](#validation-criteria)
4. [Idempotency](#idempotency)
5. [Troubleshooting Patterns](#troubleshooting-patterns)
6. [Version Management](#version-management)
7. [Command Best Practices](#command-best-practices)
8. [Documentation Style](#documentation-style)

---

## Required Fields

### YAML Frontmatter (MUST include)

```yaml
---
title: Your Playbook Title
description: One-sentence summary of what this does
version: 1.0.0
allowed_tools:
  - bash
  - kubectl
prerequisites:
  - kubernetes_cluster_running
  - kubectl_installed
---
```

**Critical Requirements**:
- **title**: 3-80 characters, human-readable
- **description**: 10-300 characters, concise summary
- **version**: Semantic versioning (MAJOR.MINOR.PATCH)
- **allowed_tools**: Array of tools used in playbook
- **prerequisites**: Array of testable conditions (snake_case format)

**Validation**: Missing any required field will block compilation with error.

### Required Markdown Sections

All playbooks MUST include these sections:

1. **## Prerequisites**: Verification commands for prerequisites
2. **## Instructions**: Sequential steps with commands
3. **## Validation**: Success criteria checklist
4. **## Troubleshooting**: Common errors and fixes

**Validation**: Missing sections block compilation.

---

## Step Structure

### Anatomy of a Good Step

```markdown
### Step 1: Create Kubernetes Namespace

**Objective:** Create an isolated namespace for the application deployment

**Commands:**
```bash
# Create namespace
kubectl create namespace my-app

# Verify namespace creation
kubectl get namespace my-app
```

**Expected Output:**
```
namespace/my-app created
NAME     STATUS   AGE
my-app   Active   1s
```

**Success Criteria:**
- [ ] Namespace exists in the cluster
- [ ] Namespace status is Active
- [ ] No errors in kubectl output
```

### Step Best Practices

1. **Objective First**: Always explain WHAT and WHY before HOW
   - Good: "Create an isolated namespace for the application deployment"
   - Bad: "Run kubectl create namespace"

2. **Numbered Steps**: Use consecutive numbering (Step 1, Step 2, Step 3)
   - Avoid gaps (Step 1, Step 3 triggers warning)
   - Exception: Parallel steps can use same number with letters (Step 2a, Step 2b)

3. **Command Blocks**: Always use ` ```bash ` for commands
   - Include inline comments for complex commands
   - One logical operation per command group
   - Break long commands into multiple lines with `\`

4. **Expected Output**: Show realistic output
   - Use actual examples from execution
   - Indicate variable parts: `<namespace-name>`, `[TIMESTAMP]`
   - Show both success and informative messages

5. **Success Criteria**: Make them testable
   - Use checkbox format: `- [ ] Criterion`
   - Each criterion should be verifiable with a command
   - Avoid subjective criteria ("looks good", "seems working")

---

## Validation Criteria

### Testable Prerequisites

**Good**:
```yaml
prerequisites:
  - kubernetes_cluster_running
  - kubectl_version_1_27_or_later
  - helm_installed
  - docker_daemon_running
```

Verification in Prerequisites section:
```bash
# Check Kubernetes cluster
kubectl cluster-info

# Check kubectl version
kubectl version --client --output=yaml | grep gitVersion

# Check Helm
helm version --short

# Check Docker
docker info > /dev/null 2>&1 && echo "Docker is running"
```

**Bad** (Not testable):
```yaml
prerequisites:
  - you_should_have_kubernetes  # Vague
  - basic_understanding_of_helm  # Subjective
  - cluster_with_enough_resources  # Not measurable
```

### Success Criteria

**Good** (Testable):
```markdown
## Validation

- [ ] **Pod Running:** `kubectl get pod my-pod -n my-ns -o jsonpath='{.status.phase}'` returns "Running"
- [ ] **Service Accessible:** `kubectl get svc my-service -n my-ns` shows CLUSTER-IP assigned
- [ ] **Endpoint Ready:** `curl -s http://localhost:8080/health` returns HTTP 200
```

**Bad** (Not testable):
```markdown
## Validation

- [ ] Application seems to be working
- [ ] No obvious errors
- [ ] Setup looks correct
```

---

## Idempotency

Playbooks SHOULD be idempotent - safe to run multiple times.

### Techniques for Idempotency

1. **Check Before Create**:
```bash
# Check if namespace exists before creating
if ! kubectl get namespace my-app > /dev/null 2>&1; then
  kubectl create namespace my-app
else
  echo "Namespace my-app already exists (skipping)"
fi
```

2. **Use Apply Instead of Create** (Kubernetes):
```bash
# Idempotent - creates or updates
kubectl apply -f deployment.yaml
```

3. **Use Declarative Tools**:
```bash
# Helm is idempotent by default
helm upgrade --install my-release my-chart
```

4. **Skip Conditions** (Frontmatter):
```yaml
skip_conditions:
  - kafka_already_deployed
```

With check in Prerequisites:
```bash
# Check if Kafka is already deployed
if helm list -n kafka | grep -q kafka; then
  echo "Kafka already deployed - you may skip this playbook"
fi
```

---

## Troubleshooting Patterns

### Problem Entry Format

```markdown
**Problem:** Pods stuck in Pending state
**Symptoms:** `kubectl get pods -n kafka` shows Pending for >5 minutes
**Root Cause:** Insufficient cluster resources (memory/CPU)
**Check:**
```bash
# Check resource requirements
kubectl describe pod kafka-0 -n kafka | grep -A 10 "Requests"

# Check node resources
kubectl top nodes
```
**Fix:**
```bash
# Increase Minikube memory and CPUs
minikube delete
minikube start --memory=8192 --cpus=4

# Verify resources available
kubectl top nodes
```
```

### When to Add Troubleshooting

**Trigger: 3 occurrences of same error** (Constitution Principle VII)

1. First execution fails → Note the error
2. Second execution fails with same error → Consider adding
3. Third execution fails → MUST add to Troubleshooting section

**Include**:
- Common errors (permission denied, command not found, connection refused)
- Configuration mistakes (wrong namespace, missing secret, invalid YAML)
- Environment issues (insufficient resources, missing dependencies)
- Timing problems (pod not ready, service not reachable yet)

**Exclude**:
- One-time edge cases
- User-specific environment quirks (unless common pattern)
- Errors from other playbooks (document in those playbooks)

---

## Version Management

### Semantic Versioning

Use MAJOR.MINOR.PATCH format:

- **MAJOR (X.0.0)**: Breaking changes (incompatible with previous version)
  - Example: Changing from kubectl to Helm
  - Example: Removing a required prerequisite
  - Example: Complete rewrite of step sequence

- **MINOR (0.X.0)**: New features/steps (backwards compatible)
  - Example: Adding optional Troubleshooting entries
  - Example: Adding new validation step
  - Example: Adding optional rollback section

- **PATCH (0.0.X)**: Clarifications/fixes (no functional changes)
  - Example: Fixing typos
  - Example: Improving step descriptions
  - Example: Updating expected output examples

### Version History (Optional but Recommended)

Add to end of playbook:

```markdown
## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0.0 | 2025-12-19 | Initial release | Claude |
| 1.0.1 | 2025-12-20 | Fixed typo in Step 3 command | Claude |
| 1.1.0 | 2025-12-21 | Added rollback instructions | Claude |
```

---

## Command Best Practices

### Writing Shell Commands

1. **Use Full Paths for Clarity** (optional but helpful):
```bash
# Clear
kubectl apply -f /path/to/deployment.yaml

# Acceptable if context clear
kubectl apply -f deployment.yaml
```

2. **Handle Errors Explicitly**:
```bash
# Good - check exit code
if ! kubectl apply -f deployment.yaml; then
  echo "Error: Failed to apply deployment"
  exit 1
fi

# Or use set -e at script level (stops on first error)
```

3. **Use Comments Liberally**:
```bash
# Create secret from environment variables
kubectl create secret generic my-secret \
  --from-literal=username=$DB_USER \   # Database username
  --from-literal=password=$DB_PASS     # Database password
```

4. **Show Wait/Retry Logic**:
```bash
# Wait for deployment to be ready (timeout 5 minutes)
kubectl wait --for=condition=available --timeout=300s \
  deployment/my-deployment -n my-namespace
```

5. **Use Heredocs for Multi-line Content**:
```bash
# Create ConfigMap from inline YAML
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  key: value
EOF
```

### Avoiding Common Pitfalls

1. **Don't Hardcode Secrets**:
```bash
# BAD
export DB_PASSWORD="hardcoded-secret"

# GOOD
# Read from environment or prompt user
if [[ -z "$DB_PASSWORD" ]]; then
  read -sp "Enter database password: " DB_PASSWORD
  echo
fi
```

2. **Don't Assume Current Directory**:
```bash
# BAD
kubectl apply -f deployment.yaml  # What if file not in current dir?

# GOOD
kubectl apply -f "$PROJECT_ROOT/k8s/deployment.yaml"
```

3. **Don't Ignore Exit Codes**:
```bash
# BAD
kubectl create namespace test
kubectl create deployment my-app --image=nginx  # Proceeds even if namespace creation failed

# GOOD
kubectl create namespace test || exit 1
kubectl create deployment my-app --image=nginx
```

---

## Documentation Style

### Writing for AI Agents

Remember: Claude (or other AI) will read and execute these instructions.

1. **Be Unambiguous**:
   - Bad: "Create some secrets"
   - Good: "Create a Kubernetes Secret named `kafka-secrets` with keys `username` and `password`"

2. **Use Active Voice**:
   - Bad: "The namespace should be created"
   - Good: "Create the namespace"

3. **Specify Exact Values When Needed**:
   - Bad: "Set memory limit appropriately"
   - Good: "Set memory limit to 4Gi (4 gigabytes)"

4. **Document Assumptions**:
   - "This playbook assumes a 4-node cluster with 8GB RAM per node"
   - "This playbook targets Kubernetes 1.27+"

5. **Link to External Resources** (when needed):
   - Helm chart documentation
   - Official tool docs
   - Related playbooks

### Code Block Formatting

**Always specify language**:
```bash
# Correct
```

```yaml
# Correct for YAML
```

```
# Correct for plain output
```

**Match indentation to context**:
- Playbook content: No indent
- Nested examples: 2-space indent

---

## Common Validation Errors

These errors will block compilation:

1. **Missing Required Field**: Add field to YAML frontmatter
2. **Missing Required Section**: Add section with ## heading
3. **Unmatched Code Blocks**: Count ` ``` ` markers (must be even)
4. **Invalid YAML Syntax**: Check colons, indentation, quotes

See [validation-guide.md](./validation-guide.md) for detailed error fixes.

---

## Common Validation Warnings

These warnings allow compilation but suggest improvements:

1. **Hardcoded Secret**: Pattern match for `password|apikey|token|secret` (may have false positives)
2. **Non-Consecutive Steps**: Step 1, Step 3 (missing Step 2)
3. **Unknown Tool**: Tool not in whitelist (bash, kubectl, helm, docker, git, python, npm, curl, jq, yq, terraform, ansible)
4. **Untestable Prerequisite**: Subjective condition

Warnings indicate style issues, not broken playbooks.

---

## Target: <5% Manual Intervention

**Constitution Principle VII**: After 3 iterations, playbooks should require less than 5% manual fixes when executed by Claude.

### Measuring Manual Intervention

```
Manual Intervention % = (Manual Fixes / Total Steps) × 100

Example:
- Playbook has 20 steps
- Claude executes autonomously: 19 steps
- Human fixes 1 step manually
- Manual Intervention = (1/20) × 100 = 5%
```

### Reducing Manual Intervention

1. **Iterate Based on Failures**: After each Claude execution, document failures in Troubleshooting
2. **Make Instructions More Specific**: "Create namespace kafka" → "Run: kubectl create namespace kafka"
3. **Add Verification Steps**: Every create/update should have corresponding get/describe
4. **Improve Error Messages**: Include exact error text in Troubleshooting symptoms
5. **Test Prerequisites Thoroughly**: Catch missing deps early

### Example Iteration Log

| Version | Execution | Steps | Manual Fixes | Intervention % |
|---------|-----------|-------|--------------|----------------|
| 1.0.0 | 1st | 15 | 3 | 20% |
| 1.0.1 | 2nd | 15 | 2 | 13.3% |
| 1.1.0 | 3rd | 16 | 0 | 0% ✅ |

After 3 iterations, reached <5% target.

---

## Examples

### Good Playbook Structure

See:
- `caps-library/playbooks/hello-world/playbook.md` - Beginner example
- `caps-library/playbooks/kafka-k8s-setup/playbook.md` - Intermediate infrastructure
- `caps-library/playbooks/fastapi-dapr-service/playbook.md` - Advanced backend

### Quick Reference Checklist

Before compiling, check:

- [ ] YAML frontmatter has all 5 required fields
- [ ] All 4 required sections present (Prerequisites, Instructions, Validation, Troubleshooting)
- [ ] Every step has objective, commands, expected output, success criteria
- [ ] Code blocks use ` ```bash ` format
- [ ] All ` ``` ` markers matched (even count)
- [ ] No hardcoded secrets (use env vars or prompts)
- [ ] Prerequisites are testable with commands
- [ ] Troubleshooting has at least 2 common errors documented
- [ ] Version follows semver (MAJOR.MINOR.PATCH)

---

## Feedback and Improvements

Found a best practice we missed? Discovered a better way to document steps?

1. Document your learnings in your playbook's Troubleshooting section
2. Share patterns that work well with the team
3. Propose updates to this guide

**This guide is a living document** - it improves as we learn from real playbook executions.

---

**Next Steps**:
- Read [validation-guide.md](./validation-guide.md) for common errors
- Review [caps-playbook-template.md](./caps-playbook-template.md) for starter template
- See [quickstart.md](../../specs/001-caps-format-spec/quickstart.md) to author your first playbook
