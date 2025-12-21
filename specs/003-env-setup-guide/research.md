# Research: Environment Setup Guide

**Feature**: 003-env-setup-guide
**Date**: 2025-12-21
**Phase**: 0 - Outline & Research

## Research Questions

### Q1: Documentation Structure Pattern

**Decision**: Multi-file structure organized by platform and concern

**Rationale**:
- **Clarity**: Each platform (macOS, Linux, Windows WSL) has dedicated file avoiding conditional instructions
- **Maintainability**: Changes to one platform don't affect others
- **User Experience**: Developers navigate directly to their platform without scrolling through irrelevant content
- **Success Criteria Alignment**: SC-001/002/003 specify platform-specific time targets requiring optimized navigation

**Alternatives Considered**:
1. **Single monolithic file**: Rejected - would exceed 800 lines making navigation difficult, violates platform-specific clarity (User Story 4)
2. **Platform folders with duplicated content**: Rejected - maintenance burden with shared content (troubleshooting, verification)
3. **Conditional sections with platform badges**: Considered but rejected - increases cognitive load, risk of following wrong platform instructions

**Best Practices Referenced**:
- GitHub documentation pattern: Separate guides per platform (Docker, Kubernetes official docs)
- Technical writing principle: One concept per page for scanability

---

### Q2: Verification Script Design

**Decision**: Bash script with detailed diagnostic output and remediation steps

**Rationale**:
- **FR-004 Requirement**: "detailed diagnostic output including: tool status (pass/fail), version found, expected version, and remediation steps"
- **Cross-Platform**: Bash available on macOS, Linux, Windows WSL (all target platforms)
- **Testability**: Script can be tested independently on each platform
- **Resume-from-Checkpoint**: Script supports checking existing installations (clarification answer 1)

**Script Design Pattern**:
```bash
# For each tool:
1. Check if command exists (`command -v toolname`)
2. Extract version (`toolname --version | parse`)
3. Compare against required version
4. Output: ✓/✗ status, version found vs expected
5. If failed: Print remediation command specific to platform
```

**Alternatives Considered**:
1. **Python script**: Rejected - adds Python as prerequisite when Bash already required
2. **Platform-specific scripts** (PowerShell for Windows): Rejected - maintenance burden, WSL has Bash
3. **Interactive script with prompts**: Rejected - automation-unfriendly for CI/CD future use

**Best Practices Referenced**:
- HashiCorp Terraform verification patterns
- Kubernetes preflightchecks approach

---

### Q3: Checkpoint Verification Approach

**Decision**: Each installation step includes verification command before proceeding

**Rationale**:
- **Clarification Answer 1**: Resume-from-checkpoint approach required
- **FR-014**: "checkpoint verification commands that allow developers to determine which tools are already installed"
- **User Experience**: Developers can re-run guide from any point without reinstalling working tools
- **Failure Recovery**: If installation breaks mid-process, developer can identify last successful step

**Pattern**:
```markdown
## Step N: Install Tool X

### Verify Current State
```bash
# Check if already installed
tool --version
# Expected: vX.Y.Z or "command not found"
```

### Installation
[... installation commands ...]

### Verify Success
```bash
tool --version
# Expected: vX.Y.Z+
```
```

**Alternatives Considered**:
1. **Verification only at end**: Rejected - doesn't support resume-from-checkpoint
2. **Separate verification section**: Rejected - requires context switching, breaks flow
3. **Optional verification**: Rejected - developers skip it, miss problems

**Best Practices Referenced**:
- Ansible playbook idempotency pattern
- Docker installation guides (verify then proceed)

---

### Q4: Reduced-Resource Configuration

**Decision**: Document standard config (4 CPU/8GB) with collapsible "Low-Resource Alternative" sections

**Rationale**:
- **Clarification Answer 3**: "Warning with reduced-resource instructions"
- **FR-015**: "provide reduced-resource configuration alternatives (minimum 2 CPU/4GB RAM)"
- **SC-010**: Support both recommended and minimum specs
- **User Psychology**: Standard config prominent; low-resource as opt-in avoids implying "inferior" setup

**Pattern**:
```markdown
## Start Minikube

### Recommended Configuration (4 CPU, 8GB RAM)
```bash
minikube start --cpus=4 --memory=8192 --driver=docker
```

<details>
<summary>⚠️ Low-Resource Alternative (2 CPU, 4GB RAM)</summary>

**Warning**: This configuration may experience slower performance and be unable to run full LearnFlow stack.

```bash
minikube start --cpus=2 --memory=4096 --driver=docker
```

**Limitations**:
- Cannot run all LearnFlow services simultaneously
- Suitable for basic testing and skill development only
</details>
```

**Alternatives Considered**:
1. **Separate low-resource guide**: Rejected - maintenance burden, content duplication
2. **Inline warnings without alternatives**: Rejected - doesn't fulfill FR-015
3. **Equal prominence for both configs**: Rejected - confuses "recommended" vs "minimum"

**Best Practices Referenced**:
- GitHub collapsible sections pattern
- Accessibility guidelines for progressive disclosure

---

### Q5: Proxy Configuration Scope

**Decision**: Basic environment variable reference with connectivity test; deep troubleshooting out of scope

**Rationale**:
- **Clarification Answer 5**: "Basic proxy awareness"
- **FR-017**: "mention common proxy environment variables (HTTP_PROXY, HTTPS_PROXY, NO_PROXY)"
- **Out of Scope Clarification**: "Deep network proxy or VPN troubleshooting (basic proxy awareness is in scope)"
- **Pragmatism**: Corporate proxy configs are organization-specific; guide provides hooks for IT departments

**Pattern**:
```markdown
## Network Connectivity Check

### Corporate Firewall/Proxy Users

If behind a corporate firewall, you may need to set proxy environment variables:

```bash
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="http://proxy.company.com:8080"
export NO_PROXY="localhost,127.0.0.1,.local"
```

### Verify Connectivity
```bash
curl -I https://github.com
# Expected: HTTP/2 200
```

**If connectivity fails**: Consult your IT department for proxy configuration. Deep proxy troubleshooting is beyond this guide's scope.
```

**Alternatives Considered**:
1. **Comprehensive proxy guide**: Rejected - out of scope, too organization-specific
2. **No proxy mention**: Rejected - violates FR-017, leaves developers stranded
3. **Proxy auto-detection**: Rejected - unreliable, platform-specific

**Best Practices Referenced**:
- NPM, pip, Docker proxy documentation patterns
- Principle of least surprise: mention common case, defer edge cases

---

### Q6: Version Manager Usage for Side-by-Side Installation

**Decision**: Recommend version managers (asdf, nvm-like tools) for kubectl, recommend Docker/Minikube contexts for isolation

**Rationale**:
- **Clarification Answer 4**: "Side-by-side installation using version managers or isolated environments"
- **FR-016**: "side-by-side installation of required tool versions"
- **Kubernetes Context**: kubectl naturally supports multiple contexts (Minikube, production clusters)
- **Tool-Specific**: Docker Desktop/Minikube have built-in isolation; kubectl/Helm need version managers

**Pattern for kubectl**:
```markdown
### Existing kubectl Installation Detected

If you have an existing kubectl version, we recommend using a version manager for side-by-side installation:

#### Option A: asdf (Recommended)
```bash
asdf plugin add kubectl
asdf install kubectl 1.27.0
asdf local kubectl 1.27.0  # Project-specific version
```

#### Option B: Manual side-by-side
```bash
# Download specific version
curl -LO https://dl.k8s.io/release/v1.27.0/bin/.../kubectl
# Install as kubectl-1.27
sudo install kubectl /usr/local/bin/kubectl-1.27
# Use: kubectl-1.27 version
```
```

**Alternatives Considered**:
1. **Force upgrade**: Rejected - breaks existing workflows (violates clarification answer 4)
2. **Docker/container-based tools**: Rejected - adds complexity for CLI tools
3. **Version tolerance**: Considered but rejected - version skew in K8s causes issues

**Best Practices Referenced**:
- asdf version manager patterns
- Kubernetes version skew policies
- Node.js nvm patterns

---

## Research Summary

**Key Decisions**:
1. **Structure**: Multi-file docs by platform (README.md, 3 platform guides, troubleshooting, verification)
2. **Verification**: Bash script with detailed diagnostic + remediation output
3. **Checkpoints**: Verify-before-install and verify-after-install at each step
4. **Low-Resource**: Collapsible alternatives with warnings
5. **Proxy**: Basic env var reference + connectivity test only
6. **Version Conflicts**: Version managers (asdf) + Kubernetes contexts

**No Unresolved Clarifications** - All Technical Context items resolved.

**Ready for Phase 1: Design**
