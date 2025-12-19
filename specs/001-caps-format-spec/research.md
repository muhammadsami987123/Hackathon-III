# Research & Discovery: CAPS Format Specification

**Feature**: CAPS Format Specification and Compilation Infrastructure
**Phase**: Phase 0
**Date**: 2025-12-19

## Overview

This document captures research decisions made during planning for the CAPS format enhancement. Since the CAPS format is already defined in sp.abc.md and the compilation script exists (caps-to-skills.sh), research focuses on enhancement areas and validation best practices.

## Research Task 1: Bash Script Best Practices for Validation

### Question
What are the most robust patterns for validating YAML frontmatter and markdown structure in Bash scripts?

### Options Evaluated

**Option 1: Use `yq` tool for YAML parsing**
- **Pros**: Dedicated YAML parser, handles complex YAML structures, widely used
- **Cons**: External dependency (may not be installed), adds installation complexity, not POSIX-compliant
- **Assessment**: Overkill for simple field presence checks

**Option 2: Use `python -c 'import yaml'` for YAML parsing**
- **Pros**: Python widely available, robust YAML library (PyYAML), handles edge cases
- **Cons**: Requires Python (additional dependency), slower startup time, not portable to all environments
- **Assessment**: Introduces dependency not needed for basic validation

**Option 3: Use native Bash with `grep`/`awk`/`sed` for pattern matching**
- **Pros**: No external dependencies (all POSIX tools), fast execution, works everywhere Bash works, already used in existing script
- **Cons**: Limited to pattern matching (not full YAML parsing), may miss complex syntax errors
- **Assessment**: Sufficient for validation needs (checking required fields exist)

### Decision

✅ **Option 3: Native Bash pattern matching**

### Rationale

1. **Zero Additional Dependencies**: Bash 4.0+ is already a stated requirement. `grep`, `awk`, `sed` are POSIX-standard tools available wherever Bash is.

2. **Proven Approach**: Existing caps-to-skills.sh already uses this pattern successfully for extracting sections and metadata.

3. **Portability**: Works on Linux, macOS, and Windows (Git Bash / WSL) without additional installation steps.

4. **Performance**: Pattern matching is faster than spawning Python interpreters or loading YAML libraries.

5. **Fit for Purpose**: We need to check:
   - Required fields are present (`grep -q "^title:"`)
   - Code blocks are matched (count `^```` occurrences)
   - Sections exist (`grep -q "^## Prerequisites"`)
   - NOT: Deep YAML structure validation or type checking

### Implementation Pattern

```bash
#!/bin/bash

# Extract YAML frontmatter (between --- markers)
YAML=$(sed -n '/^---$/,/^---$/p' "$PLAYBOOK_FILE")

# Validate required field presence
REQUIRED_FIELDS=("title" "description" "version" "allowed_tools" "prerequisites")
for field in "${REQUIRED_FIELDS[@]}"; do
  if ! echo "$YAML" | grep -q "^$field:"; then
    echo "❌ ERROR: Missing required field: $field"
    exit 1
  fi
done

# Validate code block matching
CODE_BLOCK_COUNT=$(grep -c '^```' "$PLAYBOOK_FILE" || true)
if [ $((CODE_BLOCK_COUNT % 2)) -ne 0 ]; then
  echo "❌ ERROR: Unmatched code block markers (found $CODE_BLOCK_COUNT)"
  exit 1
fi

# Validate required sections
REQUIRED_SECTIONS=("## Prerequisites" "## Instructions" "## Validation" "## Troubleshooting")
for section in "${REQUIRED_SECTIONS[@]}"; do
  if ! grep -q "^$section" "$PLAYBOOK_FILE"; then
    echo "❌ ERROR: Missing required section: $section"
    exit 1
  fi
done
```

---

## Research Task 2: Validation Enforcement Strategy

### Question
Should validation failures block compilation (errors) or just warn (allow compilation to proceed)?

### Context
From spec "Open Question 2: Validation Failure Enforcement Level" - need to balance quality gates with developer velocity.

### Options Evaluated

**Option 1: Block all validation failures (high quality bar)**
- **Pros**: Enforces strict quality standards, prevents any broken skills from being generated
- **Cons**: May slow initial playbook development, false positives block workflow
- **Assessment**: Too rigid, reduces developer velocity unnecessarily

**Option 2: Block critical errors, warn on quality issues (balanced)**
- **Pros**: Prevents genuinely broken skills (invalid YAML, missing sections) while allowing author judgment on subjective issues, balances quality and velocity
- **Cons**: Requires defining "critical" vs "quality" (needs clear categories)
- **Assessment**: Best balance of safety and productivity

**Option 3: All warnings only (maximum velocity)**
- **Pros**: Never blocks authors, fastest development cycle, allows experimentation
- **Cons**: Broken skills may reach production, no quality enforcement
- **Assessment**: Too permissive, defeats validation purpose

### Decision

✅ **Option 2: Block critical errors, warn on quality issues**

### Rationale

1. **Critical Errors (MUST block compilation)**:
   - **Missing required fields** (title, description, version, allowed_tools, prerequisites) → Can't generate valid skill frontmatter
   - **Invalid YAML syntax** (unparseable frontmatter) → Claude CLI can't read skill metadata
   - **Missing required sections** (Prerequisites, Instructions, Validation) → Skill is incomplete
   - **Unmatched code block markers** (broken markdown) → Skill renders incorrectly

2. **Quality Warnings (MUST NOT block compilation)**:
   - **Hardcoded secrets** (password/apikey/token patterns) → Pattern matching may have false positives (e.g., variable names)
   - **Untestable prerequisites** (vague conditions) → Subjective judgment, author may have context
   - **Non-consecutive step numbering** (Step 1, Step 3) → May be intentional (parallel workflows)
   - **Unknown tools** (not in whitelist) → Allows extensibility for new tools

3. **Benefits**:
   - Prevents fundamentally broken skills from being generated
   - Allows authors to make informed decisions on warnings
   - Clear mental model: Errors = broken output, Warnings = style/best-practices

### Implementation Pattern

```bash
#!/bin/bash

# Error handling function
validation_error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

# Warning function
validation_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Critical validation (blocks compilation)
if ! grep -q "^title:" "$YAML"; then
  validation_error "Missing required field: title"
fi

# Quality warning (continues compilation)
if grep -Eq "password|apikey|token|secret" "$PLAYBOOK_FILE"; then
  validation_warning "Potential hardcoded secret detected (line $(grep -n -E 'password|apikey|token|secret' "$PLAYBOOK_FILE" | head -1 | cut -d: -f1))"
fi
```

---

## Research Task 3: Naming Collision Strategy

### Question
How should skill name collisions be handled when multiple playbooks might generate the same slugified name?

### Context
From spec "Open Question 1: Skill Naming Collision Handling Strategy". Example: Two playbooks titled "Kafka Setup" and "Kafka-Setup" would both slugify to "kafka-setup".

### Options Evaluated

**Option 1: Fail with error "Skill name already exists"**
- **Pros**: Forces authors to choose unique titles, simple to implement, clear error message
- **Cons**: Blocks compilation, requires author to rename (disruptive), may be surprising (titles seem different)
- **Assessment**: Too restrictive, poor UX for authors

**Option 2: Append numeric suffix automatically (kafka-setup-2)**
- **Pros**: Always succeeds, no author intervention needed
- **Cons**: Generates non-intuitive names (user expects "kafka-setup", gets "kafka-setup-2"), harder to reference, breaks if original is deleted
- **Assessment**: Confusing, unpredictable behavior

**Option 3: Use playbook directory name instead of slugified title**
- **Pros**: Guarantees uniqueness (file system enforces), predictable (skill name = directory name), author has explicit control, no slugification surprises
- **Cons**: Title and skill name may differ (minor documentation burden)
- **Assessment**: Best solution - uniqueness guaranteed, predictable, simple

### Decision

✅ **Option 3: Use playbook directory name for skill name**

### Rationale

1. **Guaranteed Uniqueness**: File system enforces unique directory names within same parent. Two directories named "hello-world" cannot coexist in `caps-library/playbooks/`.

2. **Predictability**: Skill name = directory name. No slugification algorithm to understand or debug.

3. **Author Control**: When creating playbook, developer explicitly chooses directory name:
   ```bash
   mkdir caps-library/playbooks/my-unique-name
   ```

4. **Consistency**: Existing hello-world playbook already follows this pattern:
   - Directory: `caps-library/playbooks/hello-world/`
   - Skill: `.claude/skills/hello-world/skill.md`
   - Name: "hello-world"

5. **Simplicity**: No collision detection logic needed in compilation script.

### Implementation Change

```bash
#!/bin/bash

# OLD APPROACH (slugify title):
# TITLE=$(grep -m 1 "^# " "$PLAYBOOK_FILE" | sed 's/^# //')
# SKILL_NAME=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

# NEW APPROACH (use directory name):
PLAYBOOK_DIR=$(basename "$(dirname "$PLAYBOOK_FILE")")
SKILL_NAME="$PLAYBOOK_DIR"

echo "Skill name: $SKILL_NAME (from directory: $PLAYBOOK_DIR)"
```

### Migration Impact

- ✅ No breaking changes: hello-world already follows this pattern
- ✅ Future playbooks will use directory name directly
- ✅ Documentation updated to reflect convention

---

## Research Task 4: Example Playbook Selection

### Question
Which additional example playbooks best demonstrate CAPS format diversity and align with hackathon goals?

### Context
Spec mentions kafka-setup, postgresql-setup, fastapi-service, agents-md-gen as potential examples. Need to select a manageable set that covers complexity range and demonstrates all CAPS features.

### Selection Criteria

1. **Complexity Range**: Beginner → Intermediate → Advanced
2. **Category Coverage**: infrastructure, backend, tools
3. **CAPS Feature Demonstration**:
   - Prerequisites with verification commands
   - Multi-step instructions with bash commands
   - Expected output documentation
   - Comprehensive troubleshooting (Problem/Symptoms/Root Cause/Fix)
   - Validation checklists
4. **Hackathon Alignment**:
   - Phase 3 (Infrastructure CAPS): Kubernetes, Helm, Kafka, PostgreSQL
   - Phase 4 (Backend): FastAPI, Dapr, microservices
5. **Reusability**: Likely to be used in actual LearnFlow development

### Options Evaluated

**Short List (3 examples)**:
- hello-world (exists), kafka-k8s-setup (new), postgresql-k8s-setup (new)
- **Pros**: Focused, easier to maintain, covers infrastructure basics
- **Cons**: Missing backend example, limited complexity range

**Medium List (4 examples)**:
- hello-world (exists), kafka-k8s-setup (new), postgresql-k8s-setup (new), fastapi-dapr-service (new)
- **Pros**: Covers beginner → advanced, demonstrates infrastructure + backend, aligns with Phases 3-4
- **Cons**: More maintenance, 4th example may be too complex initially

**Long List (5+ examples)**:
- Above 4 + agents-md-gen, docusaurus-deploy, minikube-setup, namespace-setup
- **Pros**: Comprehensive coverage, many reference implementations
- **Cons**: Overwhelming for new users, high maintenance burden, diminishing returns

### Decision

✅ **Medium List (4 examples)**

### Selected Examples

1. **hello-world** (EXISTS)
   - **Complexity**: Beginner
   - **Category**: example
   - **Steps**: ~5 (create script, verify, execute, cleanup)
   - **Demonstrates**: Basic CAPS structure, simple bash commands, minimal troubleshooting
   - **Purpose**: First playbook tutorial, quickstart reference

2. **kafka-k8s-setup** (NEW)
   - **Complexity**: Intermediate
   - **Category**: infrastructure
   - **Steps**: ~15 (add Helm repo, install chart, create topics, verify, test producer/consumer)
   - **Demonstrates**: Helm usage, Kubernetes resources, multiple validation steps, complex troubleshooting (pod pending, version incompatibility)
   - **Purpose**: Phase 3 infrastructure, demonstrates event streaming setup

3. **postgresql-k8s-setup** (NEW)
   - **Complexity**: Intermediate
   - **Category**: infrastructure
   - **Steps**: ~12 (create secrets, install chart, verify StatefulSet, port-forward, connection test)
   - **Demonstrates**: Kubernetes secrets, persistent storage, StatefulSets, connection validation, authentication troubleshooting
   - **Purpose**: Phase 3 infrastructure, demonstrates database setup

4. **fastapi-dapr-service** (NEW)
   - **Complexity**: Advanced
   - **Category**: backend
   - **Steps**: ~20 (project structure, FastAPI app, Dockerfile, K8s manifests, Dapr sidecar, deployment, testing)
   - **Demonstrates**: Multi-step workflow, Python code creation, containerization, K8s deployment, Dapr integration, service testing
   - **Purpose**: Phase 4 backend, demonstrates microservice creation

### Rationale

1. **Full Complexity Spectrum**: Beginner (hello-world) → Intermediate (kafka, postgresql) → Advanced (fastapi-dapr)

2. **Category Coverage**:
   - Example: hello-world
   - Infrastructure: kafka-k8s-setup, postgresql-k8s-setup
   - Backend: fastapi-dapr-service

3. **CAPS Feature Demonstration**:
   - Prerequisites: All examples show testable conditions
   - Instructions: Range from 5 steps (simple) to 20 steps (complex)
   - Validation: Checklists with verification commands
   - Troubleshooting: 2-4 common problems documented per playbook

4. **Hackathon Alignment**:
   - kafka-k8s-setup, postgresql-k8s-setup align with Phase 3 (Infrastructure CAPS)
   - fastapi-dapr-service aligns with Phase 4 (Backend)
   - All use Kubernetes (Principle IV: Kubernetes-Native Architecture)

5. **Manageable Scope**: 4 examples (1 exists, 3 new) provides good coverage without overwhelming users or creating excessive maintenance burden.

### Not Selected (Deferred)

- **agents-md-gen**: Simpler than hello-world, covered in sp.abc.md already
- **docusaurus-deploy**: Covered in Phase 6 (Integration), deferred
- **minikube-setup**: Prerequisite playbook, may be added later for completeness
- **namespace-setup**: Too trivial (1-2 kubectl commands), not worth separate playbook

---

## Research Summary

### Key Decisions

| Decision | Choice | Impact |
|----------|--------|--------|
| Validation Approach | Native Bash (grep/awk/sed) | Zero dependencies, fast, portable |
| Enforcement Strategy | Block critical errors, warn on quality issues | Balances quality and velocity |
| Naming Strategy | Use directory name for skill name | Guaranteed uniqueness, predictable |
| Example Selection | 4 playbooks (hello-world + 3 new) | Covers beginner to advanced, aligns with Phases 3-4 |

### Implementation Impact

1. **caps-to-skills.sh enhancements**:
   - Add validation checks (required fields, sections, code blocks)
   - Implement error vs warning differentiation
   - Use directory name instead of slugified title
   - Estimated: ~100 additional lines of code

2. **New Documentation**:
   - best-practices.md: Authoring guidelines (validation rules, common patterns)
   - validation-guide.md: Common errors and fixes (troubleshooting reference)
   - README.md updates: Add validation section, example compilation commands

3. **New Example Playbooks**:
   - kafka-k8s-setup: ~200 lines
   - postgresql-k8s-setup: ~180 lines
   - fastapi-dapr-service: ~300 lines
   - Total: ~680 lines of new playbook content

### Success Criteria Validation

All research decisions support spec success criteria:

- ✅ SC-001: Author in <30 min (template + examples + quickstart)
- ✅ SC-002: 100% content preservation (verbatim section copying unchanged)
- ✅ SC-003: Catch common errors (validation checks for critical issues)
- ✅ SC-004: <5% manual intervention (quality warnings guide improvements)
- ✅ SC-005: 90% first-attempt (validation catches errors before Claude execution)
- ✅ SC-006: <5 sec compilation (pattern matching is fast, no external process spawning)
- ✅ SC-007: Zero data loss (no data transformation, only copying)
- ✅ SC-008: Clear versioning (semantic version in frontmatter, no change needed)

### Next Steps

Phase 0 research complete. Proceed to Phase 1 (Design & Contracts) to document data model and create quickstart guide.
