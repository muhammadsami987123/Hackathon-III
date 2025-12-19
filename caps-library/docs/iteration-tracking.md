# CAPS Playbook Iteration Tracking

**Version**: 1.0.0
**Date**: 2025-12-19
**Purpose**: Track playbook evolution toward <5% manual intervention target (Constitution Principle VII)

## Overview

This document provides a framework for tracking CAPS playbook iterations as they are refined through actual execution. Per Constitution Principle VII, playbooks should require less than 5% manual intervention after 3 iterations.

## Table of Contents

1. [Iteration Framework](#iteration-framework)
2. [Tracking Template](#tracking-template)
3. [Playbook Iteration Logs](#playbook-iteration-logs)
4. [Common Failure Patterns](#common-failure-patterns)
5. [Improvement Strategies](#improvement-strategies)

---

## Iteration Framework

### Goal

After 3 iterations of execution and refinement, a playbook should achieve:
- **<5% manual intervention rate**
- **Comprehensive troubleshooting** (2-4 documented errors)
- **Clear, unambiguous instructions**
- **Proper version progression** (1.0.0 → 1.0.1 → 1.1.0 → ...)

### Iteration Cycle

```
┌─────────────────────────────────────────────────────────┐
│  1. Execute playbook with Claude CLI or manually        │
│  2. Track execution: count steps, note failures         │
│  3. Calculate manual intervention %                     │
│  4. Document failures in Troubleshooting section        │
│  5. Refine instructions for clarity                     │
│  6. Increment version (PATCH/MINOR as appropriate)      │
│  7. Re-compile and repeat                               │
└─────────────────────────────────────────────────────────┘
```

### Manual Intervention Calculation

```
Manual Intervention % = (Manual Fixes / Total Steps) × 100

Example:
- Playbook has 15 steps
- Claude executes autonomously: 13 steps
- Human manually fixes: 2 steps
- Manual Intervention = (2/15) × 100 = 13.3%
```

**Target**: <5% after 3 iterations

---

## Tracking Template

### Per-Iteration Tracking Table

| Version | Date | Executor | Steps | Auto | Manual | Intervention % | Failures Documented | Notes |
|---------|------|----------|-------|------|--------|----------------|---------------------|-------|
| 1.0.0 | YYYY-MM-DD | Claude/Human | 15 | 12 | 3 | 20% | 2 new errors | Initial execution |
| 1.0.1 | YYYY-MM-DD | Claude/Human | 15 | 13 | 2 | 13.3% | 1 refined | Clarified Step 3 |
| 1.1.0 | YYYY-MM-DD | Claude/Human | 16 | 16 | 0 | 0% ✅ | All covered | Added validation step |

**Target Achievement**: Version 1.1.0 achieved <5% ✅

### Failure Documentation Template

For each execution failure:

| Failure | Step | Symptom | Root Cause | Added to Troubleshooting? | Version |
|---------|------|---------|------------|---------------------------|---------|
| Permission denied | Step 4 | kubectl error | Missing cluster-admin role | ✅ Yes | 1.0.1 |
| Timeout | Step 7 | Pod pending 5+ min | Insufficient resources | ✅ Yes | 1.0.1 |
| Image pull | Step 5 | ImagePullBackOff | Image not in Minikube | ✅ Yes | 1.1.0 |

**Rule**: After 3 occurrences of same error → MUST add to Troubleshooting section

---

## Playbook Iteration Logs

### hello-world Playbook

**Current Version**: 1.0.0
**Status**: ✅ Baseline working, no iterations needed yet

| Version | Date | Executor | Steps | Auto | Manual | Intervention % | Notes |
|---------|------|----------|-------|------|--------|----------------|-------|
| 1.0.0 | 2025-12-19 | System | 4 | 4 | 0 | 0% ✅ | Initial release, compiles successfully |

**Failures Documented**: 3 (permission denied, script not found, command not found)
**Status**: Ready for use ✅

---

### kafka-k8s-setup Playbook

**Current Version**: 1.0.0
**Status**: ⏳ Awaiting first execution

| Version | Date | Executor | Steps | Auto | Manual | Intervention % | Notes |
|---------|------|----------|-------|------|--------|----------------|-------|
| 1.0.0 | 2025-12-19 | - | 9 | - | - | - | Created with 4 preemptive troubleshooting entries |
| 1.0.1 | TBD | TBD | TBD | TBD | TBD | TBD | Planned: First execution results |
| 1.1.0 | TBD | TBD | TBD | TBD | TBD | TBD | Planned: Second iteration refinement |
| 1.2.0 | TBD | TBD | TBD | TBD | TBD | <5% Target | Planned: Third iteration |

**Preemptive Troubleshooting**: 4 entries documented
**Expected Issues**:
- Pods pending (resource constraints)
- CrashLoopBackOff (ZooKeeper dependencies)
- Connection timeout (broker readiness)
- Producer/consumer failures (network policies)

**Next Action**: Execute with Claude CLI or manually, track results, update table

---

### postgresql-k8s-setup Playbook

**Current Version**: 1.0.0
**Status**: ⏳ Awaiting first execution

| Version | Date | Executor | Steps | Auto | Manual | Intervention % | Notes |
|---------|------|----------|-------|------|--------|----------------|-------|
| 1.0.0 | 2025-12-19 | - | 9 | - | - | - | Created with 4 preemptive troubleshooting entries |
| 1.0.1 | TBD | TBD | TBD | TBD | TBD | TBD | Planned: First execution results |
| 1.1.0 | TBD | TBD | TBD | TBD | TBD | TBD | Planned: Second iteration refinement |
| 1.2.0 | TBD | TBD | TBD | TBD | TBD | <5% Target | Planned: Third iteration |

**Preemptive Troubleshooting**: 4 entries documented
**Expected Issues**:
- Pod pending (PVC binding)
- Authentication failures (secret mounting)
- CrashLoopBackOff (data corruption)
- Connection timeout (network policies)

**Next Action**: Execute with Claude CLI or manually, track results, update table

---

### fastapi-dapr-service Playbook

**Current Version**: 1.0.0
**Status**: ⏳ Awaiting first execution

| Version | Date | Executor | Steps | Auto | Manual | Intervention % | Notes |
|---------|------|----------|-------|------|--------|----------------|-------|
| 1.0.0 | 2025-12-19 | - | 8 | - | - | - | Created with 3 preemptive troubleshooting entries |
| 1.0.1 | TBD | TBD | TBD | TBD | TBD | TBD | Planned: First execution results |
| 1.1.0 | TBD | TBD | TBD | TBD | TBD | TBD | Planned: Second iteration refinement |
| 1.2.0 | TBD | TBD | TBD | TBD | TBD | <5% Target | Planned: Third iteration |

**Preemptive Troubleshooting**: 3 entries documented
**Expected Issues**:
- Container readiness (1/2 vs 2/2)
- Image pull errors (Minikube caching)
- State store failures (Dapr component config)

**Next Action**: Execute with Claude CLI or manually, track results, update table

---

## Common Failure Patterns

Based on playbook complexity and technology, common patterns emerge:

### Infrastructure Playbooks (Kafka, PostgreSQL)

**Common Failures**:
1. **Resource Constraints**: Pods pending due to insufficient CPU/RAM
2. **Storage Issues**: PVC binding failures, no storage class
3. **Timing Issues**: Services not ready when next step tries to use them
4. **Network Policies**: Default deny policies blocking traffic

**Typical Intervention Rate**:
- First iteration (1.0.0): 15-25% (3-5 manual fixes out of 15-20 steps)
- Second iteration (1.0.1): 8-15% (1-3 manual fixes)
- Third iteration (1.1.0): <5% (0-1 manual fixes) ✅

### Backend Service Playbooks (FastAPI, Dapr)

**Common Failures**:
1. **Image Build Issues**: Dockerfile syntax, missing dependencies
2. **Container Runtime**: Application crashes, port conflicts
3. **Sidecar Injection**: Dapr annotations incorrect or missing
4. **State Management**: Component configuration errors

**Typical Intervention Rate**:
- First iteration (1.0.0): 20-30% (more complex workflow)
- Second iteration (1.0.1): 10-20%
- Third iteration (1.1.0): <5% ✅

---

## Improvement Strategies

### When Manual Intervention Rate is >10%

**1. Analyze Failure Patterns**
```
Questions to ask:
- Which steps failed most often?
- Are failures due to unclear instructions or environment issues?
- Can we add prerequisite checks to catch issues earlier?
- Are expected outputs realistic?
```

**2. Improve Instructions**
- Add more specific commands (full paths, explicit flags)
- Include wait/retry logic where needed
- Add intermediate verification steps
- Show exact expected output (not generalized)

**3. Enhance Prerequisites**
- Add verification commands for all prerequisites
- Check resources available before starting
- Validate tool versions explicitly
- Test connectivity/permissions upfront

**4. Expand Troubleshooting**
- Document every failure encountered
- Add Check commands for each problem
- Provide exact Fix commands (not "try this")
- Include multiple resolution paths

### When Manual Intervention Rate is 5-10%

**1. Refine Edge Cases**
- Document alternative paths (different K8s versions, etc.)
- Add skip conditions for already-deployed resources
- Handle idempotency explicitly

**2. Improve Error Messages**
- Add context to error checks
- Suggest next steps in failure messages
- Link to troubleshooting entry

### When Manual Intervention Rate is <5% ✅

**Playbook is production-ready!**
- Consider it a gold standard
- Use as reference for other playbooks
- Share patterns with team
- Minimal updates needed (only for version/API changes)

---

## Measurement Methodology

### Execution Tracking

For each playbook execution:

1. **Before Execution**:
   - Note version number
   - Count total steps (`grep "^### Step [0-9]" playbook.md | wc -l`)
   - Record executor (Claude CLI / Manual / Mixed)

2. **During Execution**:
   - Execute each step sequentially
   - Mark step as "Auto" if Claude/script succeeded without modification
   - Mark step as "Manual" if human intervention required:
     - Command needed modification
     - Error required troubleshooting not in playbook
     - Expected output didn't match
     - Prerequisites missing

3. **After Execution**:
   - Count auto steps (succeeded without intervention)
   - Count manual steps (required human fix)
   - Calculate intervention % = (Manual / Total) × 100
   - Document failures in table

4. **Update Playbook**:
   - Add new Troubleshooting entries (if 3+ occurrences)
   - Clarify ambiguous instructions
   - Update expected outputs based on reality
   - Increment version appropriately

### Version Increment Rules

**PATCH (X.X.+1)** - Bug fixes, clarifications:
- Fix typos in commands
- Clarify expected output
- Update tool version numbers
- Improve step descriptions

**MINOR (X.+1.0)** - New features, steps:
- Add new verification step
- Add new troubleshooting entry
- Add optional cleanup step
- Extend existing step with more commands

**MAJOR (+1.0.0)** - Breaking changes:
- Change tool (kubectl → Helm)
- Restructure step order
- Remove required prerequisite
- Incompatible with previous version

---

## Example: Tracking kafka-k8s-setup Iterations

### Iteration 1 (v1.0.0)

**Execution Date**: 2025-12-20
**Executor**: Claude Code CLI
**Total Steps**: 9
**Auto Succeeded**: 6 steps
**Manual Fixes Required**: 3 steps

**Manual Interventions**:
1. **Step 3** (Helm install): Timeout increased from 10m to 15m (cluster slow)
2. **Step 5** (Create topic): Had to wait 2 minutes for brokers to be ready (added wait command)
3. **Step 6** (Producer test): Client pod not found (needed to create first)

**Intervention Rate**: 3/9 = **33.3%**

**Actions Taken**:
- Added troubleshooting entry for Helm timeout
- Added explicit wait command before topic creation
- Clarified client pod creation prerequisite
- Version incremented to 1.0.1

---

### Iteration 2 (v1.0.1)

**Execution Date**: 2025-12-21
**Executor**: Claude Code CLI
**Total Steps**: 9
**Auto Succeeded**: 8 steps
**Manual Fixes Required**: 1 step

**Manual Interventions**:
1. **Step 4** (Verify pods): ZooKeeper pods took 8 minutes (timeout was 5m, increased to 10m)

**Intervention Rate**: 1/9 = **11.1%**

**Actions Taken**:
- Updated wait timeout to 10 minutes
- Added note about ZooKeeper startup time
- Version incremented to 1.1.0 (added validation step)

---

### Iteration 3 (v1.1.0)

**Execution Date**: 2025-12-22
**Executor**: Claude Code CLI
**Total Steps**: 10 (added validation step)
**Auto Succeeded**: 10 steps
**Manual Fixes Required**: 0 steps

**Intervention Rate**: 0/10 = **0%** ✅

**Status**: **ACHIEVED TARGET** (<5% manual intervention)
**Version**: 1.1.0 is production-ready

---

## Playbook Iteration Logs

### Template for New Playbooks

Copy this template to track your playbook:

```markdown
### <playbook-name> Playbook

**Current Version**: X.Y.Z
**Target Version**: X.Y.Z (with <5% intervention)
**Status**: ⏳ In Progress / ✅ Target Achieved

| Version | Date | Executor | Steps | Auto | Manual | Intervention % | Failures | Notes |
|---------|------|----------|-------|------|--------|----------------|----------|-------|
| 1.0.0 | YYYY-MM-DD | Name | N | N-M | M | % | Count | Initial execution |
| 1.0.1 | YYYY-MM-DD | Name | N | N-M | M | % | Count | Clarified instructions |
| 1.1.0 | YYYY-MM-DD | Name | N | N | 0 | 0% ✅ | All | Target achieved |

**Failures Documented**:
1. [Failure description] - Added to Troubleshooting in v1.0.1
2. [Failure description] - Added to Troubleshooting in v1.0.1
3. [Failure description] - Refined in v1.1.0

**Key Improvements**:
- v1.0.0 → v1.0.1: [List changes]
- v1.0.1 → v1.1.0: [List changes]
```

---

## Common Failure Patterns

### Pattern 1: Resource Constraints

**Symptoms**: Pods pending, insufficient memory/CPU
**Frequency**: Very common (30-40% of infrastructure playbooks)
**Solution**: Add resource requirement checks in Prerequisites, document mitigation in Troubleshooting

### Pattern 2: Timing Issues

**Symptoms**: Service not ready, connection refused
**Frequency**: Common (20-30% of multi-step playbooks)
**Solution**: Add explicit wait commands, increase timeouts, poll for readiness

### Pattern 3: Missing Prerequisites

**Symptoms**: Command not found, tool not installed
**Frequency**: Moderate (15-20%)
**Solution**: Add verification commands in Prerequisites section, fail early

### Pattern 4: Configuration Errors

**Symptoms**: YAML syntax errors, incorrect values
**Frequency**: Moderate (10-15%)
**Solution**: Provide exact YAML examples, validate before apply

### Pattern 5: Permission Denied

**Symptoms**: kubectl forbidden, file write errors
**Frequency**: Less common (5-10%)
**Solution**: Document required permissions, provide RBAC examples

---

## Improvement Strategies

### Strategy 1: Front-Load Validation

**Before** (failure prone):
```bash
# Step 1: Deploy application
kubectl apply -f deployment.yaml
```

**After** (resilient):
```bash
# Step 1: Validate prerequisites
kubectl cluster-info  # Ensure cluster is reachable
kubectl auth can-i create deployments  # Check permissions
cat deployment.yaml  # Verify file exists

# Step 2: Deploy application
kubectl apply -f deployment.yaml
```

### Strategy 2: Add Explicit Waits

**Before** (timing issues):
```bash
kubectl create namespace app
kubectl apply -f deployment.yaml  # May fail if namespace not ready
```

**After** (reliable):
```bash
kubectl create namespace app
kubectl wait --for=jsonpath='{.status.phase}'=Active namespace/app --timeout=30s
kubectl apply -f deployment.yaml
```

### Strategy 3: Idempotency Checks

**Before** (fails on re-run):
```bash
kubectl create namespace app  # ERROR if already exists
```

**After** (idempotent):
```bash
if ! kubectl get namespace app > /dev/null 2>&1; then
  kubectl create namespace app
else
  echo "Namespace app already exists (skipping)"
fi
```

### Strategy 4: Better Error Messages

**Before** (unclear):
```bash
helm install kafka bitnami/kafka
# What if it fails?
```

**After** (informative):
```bash
if ! helm install kafka bitnami/kafka --namespace kafka --wait --timeout=10m; then
  echo "❌ Helm installation failed"
  echo "Check: kubectl get pods -n kafka"
  echo "Logs: kubectl logs -l app.kubernetes.io/name=kafka -n kafka"
  exit 1
fi
```

---

## Success Indicators

### Playbook is Ready When:

✅ **3 iterations completed**
✅ **Manual intervention <5%**
✅ **All common failures documented in Troubleshooting**
✅ **Instructions are unambiguous**
✅ **Prerequisites verify all requirements**
✅ **Validation criteria are comprehensive**
✅ **Version history shows clear progression**

### Example Success Profile

```
Playbook: kafka-k8s-setup
Iterations: 3
Final Version: 1.1.0
Manual Intervention: 0% (0 fixes out of 10 steps)
Troubleshooting Entries: 4 comprehensive entries
Status: ✅ PRODUCTION READY
```

---

## Using This Document

### For Playbook Authors

1. **Start tracking** after first execution
2. **Update after each iteration** (same day or next day)
3. **Document every failure** (even if you fix it immediately)
4. **Calculate intervention %** honestly
5. **Iterate until <5%** achieved

### For Team Leads

1. **Review iteration logs** weekly
2. **Identify problematic playbooks** (>10% after 2 iterations)
3. **Share successful patterns** across team
4. **Recognize gold standards** (<5% achieved)
5. **Allocate refinement time** for high-intervention playbooks

---

## Next Steps

1. **Execute playbooks**: Run kafka, postgresql, fastapi with Claude CLI
2. **Track results**: Fill in iteration tables above
3. **Document failures**: Add to Troubleshooting sections
4. **Refine and iterate**: Target <5% by version 1.3.0
5. **Share learnings**: Update this document with common patterns

---

**Related Documentation**:
- [Best Practices](./best-practices.md) - Authoring guidelines
- [Validation Guide](./validation-guide.md) - Error troubleshooting
- [Constitution](../../.specify/memory/constitution.md) - Principle VII

**Maintained By**: Hackathon III Team
**Last Updated**: 2025-12-19
