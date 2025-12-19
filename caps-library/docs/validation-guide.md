# CAPS Playbook Validation Guide

**Version**: 1.0.0
**Date**: 2025-12-19
**Purpose**: Troubleshooting guide for compilation errors and warnings

## Overview

The CAPS compilation script (`caps-to-skills.sh`) validates playbooks before generating Claude Skills. This guide documents common validation errors, their causes, and how to fix them.

## Table of Contents

1. [Critical Errors (Block Compilation)](#critical-errors-block-compilation)
2. [Quality Warnings (Allow Compilation)](#quality-warnings-allow-compilation)
3. [Quick Fixes](#quick-fixes)
4. [Validation Workflow](#validation-workflow)

---

## Critical Errors (Block Compilation)

These errors prevent skill generation and MUST be fixed before compilation succeeds.

### Error 1: Missing Required Field

**Error Message**:
```
[ERROR] Missing required field: title
```

**Cause**: YAML frontmatter is missing a required field.

**Required Fields**:
- `title`
- `description`
- `version`
- `allowed_tools`
- `prerequisites`

**Fix**:

```yaml
---
# Add missing field(s) to YAML frontmatter
title: Your Playbook Title               # REQUIRED
description: One-sentence summary        # REQUIRED
version: 1.0.0                           # REQUIRED
allowed_tools:                           # REQUIRED
  - bash
prerequisites:                           # REQUIRED
  - some_prerequisite
---
```

**Verification**:
```bash
# Check frontmatter has all fields
grep "^title:" caps-library/playbooks/your-playbook/playbook.md
grep "^description:" caps-library/playbooks/your-playbook/playbook.md
grep "^version:" caps-library/playbooks/your-playbook/playbook.md
grep "^allowed_tools:" caps-library/playbooks/your-playbook/playbook.md
grep "^prerequisites:" caps-library/playbooks/your-playbook/playbook.md
```

---

### Error 2: Invalid YAML Syntax

**Error Message**:
```
[ERROR] Invalid YAML syntax in frontmatter
```

**Cause**: YAML frontmatter has syntax errors (missing colons, incorrect indentation, unmatched quotes).

**Common YAML Mistakes**:

1. **Missing Colon After Key**:
```yaml
# BAD
title Your Playbook

# GOOD
title: Your Playbook
```

2. **Incorrect Indentation** (YAML uses 2 spaces):
```yaml
# BAD
allowed_tools:
    - bash  # 4 spaces (wrong)

# GOOD
allowed_tools:
  - bash    # 2 spaces (correct)
```

3. **Unmatched Quotes**:
```yaml
# BAD
description: "This is a description

# GOOD
description: "This is a description"
# OR (no quotes for simple strings)
description: This is a description
```

4. **Mixing Tabs and Spaces**:
```yaml
# BAD (tabs not allowed in YAML)
allowed_tools:
	- bash

# GOOD (spaces only)
allowed_tools:
  - bash
```

**Fix**: Validate YAML syntax using online validator or editor with YAML support.

**Verification**:
```bash
# Extract frontmatter and validate
sed -n '/^---$/,/^---$/p' playbook.md > /tmp/frontmatter.yaml

# Use yq or python to validate (if available)
yq eval /tmp/frontmatter.yaml
# OR
python3 -c "import yaml; yaml.safe_load(open('/tmp/frontmatter.yaml'))"
```

---

### Error 3: Missing Required Section

**Error Message**:
```
[ERROR] Missing required section: ## Prerequisites
```

**Cause**: Playbook is missing one of the four required markdown sections.

**Required Sections**:
1. `## Prerequisites`
2. `## Instructions`
3. `## Validation`
4. `## Troubleshooting`

**Fix**: Add missing section with proper ## heading.

```markdown
## Prerequisites

Before starting, verify:

```bash
# Add verification commands here
bash --version | head -1
```

## Instructions

### Step 1: Your First Step

**Objective:** What this step does

**Commands:**
```bash
# Your commands here
```

**Expected Output:**
```
Expected output here
```

**Success Criteria:**
- [ ] Criterion 1

## Validation

Success criteria (all must pass):
- [ ] **Check 1:** `command to verify`

## Troubleshooting

**Problem:** Common error name
**Symptoms:** Observable error message
**Root Cause:** Why it happens
**Fix:**
```bash
# Resolution commands
```
```

**Verification**:
```bash
# Check all required sections exist
grep "^## Prerequisites" playbook.md
grep "^## Instructions" playbook.md
grep "^## Validation" playbook.md
grep "^## Troubleshooting" playbook.md
```

---

### Error 4: Unmatched Code Block Markers

**Error Message**:
```
[ERROR] Unmatched code block markers (found 7)
```

**Cause**: Odd number of ` ``` ` markers in playbook (every opening ` ``` ` must have matching closing ` ``` `).

**Common Causes**:
1. Forgot closing ` ``` ` after code block
2. Used ` ``` ` inside code block without escaping
3. Copy-paste error

**Fix**: Count and match all ` ``` ` markers.

```markdown
# BAD (3 markers - unmatched)
```bash
echo "Hello"

Some text here

```bash
echo "World"
```

# GOOD (4 markers - matched)
```bash
echo "Hello"
```

Some text here

```bash
echo "World"
```
```

**Verification**:
```bash
# Count code block markers (should be even)
grep -c '^```' playbook.md

# Show all occurrences with line numbers
grep -n '^```' playbook.md
```

**Pro Tip**: Use editor with markdown preview (VS Code, Typora) to visually identify unmatched blocks.

---

## Quality Warnings (Allow Compilation)

These warnings indicate potential issues but do NOT block compilation. Review and fix if appropriate.

### Warning 1: Hardcoded Secret

**Warning Message**:
```
[WARNING] Potential hardcoded secret detected (line 42)
```

**Cause**: Pattern match detected keywords: `password`, `apikey`, `token`, `secret` in playbook.

**Important**: This is a pattern-based check and may have false positives (e.g., variable names, documentation).

**False Positives** (Safe to ignore):
```bash
# These trigger warning but are NOT actual secrets:
DB_PASSWORD="$DB_PASSWORD"              # Reading from environment variable
read -sp "Enter password: " PASSWORD    # Prompting user
echo "Set API_KEY environment variable" # Documentation
```

**Actual Problems** (MUST fix):
```bash
# BAD - Hardcoded secrets
export DB_PASSWORD="my-secret-password"
API_KEY="sk-1234567890abcdef"
kubectl create secret generic my-secret --from-literal=token="hardcoded-value"
```

**Fix**: Use environment variables or prompt user.

```bash
# GOOD - Read from environment
if [[ -z "$DB_PASSWORD" ]]; then
  echo "Error: DB_PASSWORD environment variable not set"
  exit 1
fi

# GOOD - Prompt user
read -sp "Enter database password: " DB_PASSWORD
echo

# GOOD - Reference Kubernetes secret (not hardcoded)
kubectl create secret generic my-secret \
  --from-env-file=.env.secrets  # File not committed to git
```

**Verification**:
```bash
# Search for potential secrets
grep -in "password\|apikey\|token\|secret" playbook.md

# Review each occurrence manually
```

---

### Warning 2: Non-Consecutive Step Numbering

**Warning Message**:
```
[WARNING] Non-consecutive step numbering detected (found Step 1, Step 3 - missing Step 2)
```

**Cause**: Instructions section has gaps in step numbers.

**Fix**: Renumber steps to be consecutive.

```markdown
# BAD
### Step 1: First Step
### Step 3: Third Step   # Missing Step 2

# GOOD
### Step 1: First Step
### Step 2: Second Step
### Step 3: Third Step
```

**Exception**: Parallel steps may use letters:
```markdown
### Step 2a: Do This (Can run in parallel)
### Step 2b: Do That (Can run in parallel)
### Step 3: Continue Here
```

**Verification**:
```bash
# List all step headings
grep "^### Step" playbook.md
```

---

### Warning 3: Unknown Tool

**Warning Message**:
```
[WARNING] Unknown tool in allowed_tools: myspecialtool
```

**Cause**: Tool in `allowed_tools` array is not in the known whitelist.

**Known Tools** (no warning):
- bash
- kubectl
- helm
- docker
- git
- python
- npm
- curl
- jq
- yq
- terraform
- ansible
- minikube
- kind

**Fix Options**:

1. **Typo**: Correct tool name
```yaml
# BAD
allowed_tools:
  - kubetcl  # Typo

# GOOD
allowed_tools:
  - kubectl
```

2. **Legitimate New Tool**: Keep it (warning is informational)
```yaml
# OK - Custom tool not in whitelist
allowed_tools:
  - bash
  - my-custom-cli  # Will trigger warning, but that's fine
```

**Verification**:
```bash
# Check tool name spelling
grep "^allowed_tools:" -A 10 playbook.md
```

---

### Warning 4: Untestable Prerequisite

**Warning Message**:
```
[WARNING] Untestable prerequisite: basic_kubernetes_knowledge
```

**Cause**: Prerequisite cannot be verified with a command (subjective or vague).

**Untestable** (trigger warning):
```yaml
prerequisites:
  - basic_kubernetes_knowledge         # Subjective
  - familiarity_with_helm              # Vague
  - cluster_with_enough_resources      # Not specific
  - you_should_have_docker             # Not testable
```

**Testable** (no warning):
```yaml
prerequisites:
  - kubernetes_cluster_running         # Can test: kubectl cluster-info
  - kubectl_version_1_27_or_later      # Can test: kubectl version
  - helm_installed                     # Can test: helm version
  - docker_daemon_running              # Can test: docker info
```

**Fix**: Make prerequisites testable.

```markdown
## Prerequisites

Before starting, verify:

```bash
# Check Kubernetes cluster
kubectl cluster-info
# Should show control plane URL

# Check kubectl version
kubectl version --client --output=yaml | grep gitVersion
# Should be v1.27 or later

# Check Helm installed
helm version --short
# Should show version

# Check Docker daemon
docker info > /dev/null 2>&1 && echo "Docker is running"
```
```

**Verification**:
```bash
# List prerequisites
grep "^prerequisites:" -A 10 playbook.md
```

---

## Quick Fixes

### Compilation Failed - Where to Start?

1. **Read the error message** - It tells you exactly what's wrong
2. **Check line number** (if provided) - `playbook.md:42` means line 42
3. **Look up error in this guide** - Find matching error message
4. **Apply fix** - Follow the documented solution
5. **Re-compile** - Run `bash caps-library/scripts/caps-to-skills.sh your-playbook --validate`

### Common Fix Patterns

| Error | Quick Fix Command |
|-------|-------------------|
| Missing field | Add field to YAML frontmatter |
| Invalid YAML | Check indentation (2 spaces), colons, quotes |
| Missing section | Add `## SectionName` heading |
| Unmatched code blocks | Count ` ``` ` markers with `grep -c '^```' playbook.md` |
| Hardcoded secret | Replace with env var or prompt |
| Non-consecutive steps | Renumber steps |
| Unknown tool | Check spelling or keep (warning only) |
| Untestable prerequisite | Add verification command |

---

## Validation Workflow

### 1. Before Compilation

**Checklist**:
```bash
# Check file exists
ls -la caps-library/playbooks/your-playbook/playbook.md

# Check YAML frontmatter
head -20 caps-library/playbooks/your-playbook/playbook.md

# Count code blocks (should be even)
grep -c '^```' caps-library/playbooks/your-playbook/playbook.md

# Check required sections
grep "^## Prerequisites\|^## Instructions\|^## Validation\|^## Troubleshooting" \
  caps-library/playbooks/your-playbook/playbook.md
```

### 2. Compile with Validation

```bash
# Run compilation with --validate flag
bash caps-library/scripts/caps-to-skills.sh your-playbook --validate

# Check exit code
echo $?
# 0 = success, 1 = failed
```

### 3. Review Output

**Success**:
```
[INFO] CAPS to Claude Skills Compiler
...
[SUCCESS] Skill compiled successfully!
[SUCCESS] Output: .claude/skills/your-playbook/skill.md
[INFO] Validation passed!
```

**Failure**:
```
[INFO] CAPS to Claude Skills Compiler
...
[ERROR] Missing required field: title
```

### 4. Fix and Retry

1. Fix the reported error
2. Save playbook.md
3. Re-compile
4. Repeat until validation passes

### 5. Verify Generated Skill

```bash
# Check output file
ls -la .claude/skills/your-playbook/skill.md

# Review content
cat .claude/skills/your-playbook/skill.md

# Check YAML frontmatter present
head -10 .claude/skills/your-playbook/skill.md | grep "^---"

# Check title present
grep "^# " .claude/skills/your-playbook/skill.md

# Check sections copied
grep "^## " .claude/skills/your-playbook/skill.md
```

---

## Advanced Validation

### Validate All Playbooks

```bash
#!/bin/bash
# Compile all playbooks and report status

for playbook_dir in caps-library/playbooks/*/; do
  playbook_name=$(basename "$playbook_dir")
  echo "Compiling: $playbook_name"

  if bash caps-library/scripts/caps-to-skills.sh "$playbook_name" --validate > /dev/null 2>&1; then
    echo "✅ $playbook_name - PASSED"
  else
    echo "❌ $playbook_name - FAILED"
  fi
done
```

### Pre-Commit Hook (Optional)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Validate CAPS playbooks before commit

changed_playbooks=$(git diff --cached --name-only | grep "caps-library/playbooks/.*/playbook.md")

if [[ -n "$changed_playbooks" ]]; then
  echo "Validating changed CAPS playbooks..."

  for playbook_file in $changed_playbooks; do
    playbook_name=$(basename "$(dirname "$playbook_file")")

    if ! bash caps-library/scripts/caps-to-skills.sh "$playbook_name" --validate > /dev/null 2>&1; then
      echo "❌ Validation failed for: $playbook_name"
      echo "Fix errors before committing"
      exit 1
    fi
  done

  echo "✅ All playbooks validated"
fi
```

---

## FAQ

### Q: Can I ignore warnings and still compile?

**A**: Yes! Warnings do NOT block compilation. They indicate potential issues that should be reviewed, but you can proceed if the warnings are false positives or intentional.

### Q: How do I know if a warning is a false positive?

**A**: Review the specific line mentioned in the warning. For example, `password` in a comment or variable name is safe. `password="hardcoded-value"` is not.

### Q: What if I need to use a tool not in the whitelist?

**A**: Add it to `allowed_tools` anyway. You'll get a warning, but compilation will succeed. This is intentional to allow extensibility.

### Q: Can I disable validation?

**A**: Yes, don't use the `--validate` flag. But validation is recommended to catch errors early.

```bash
# Compile without validation
bash caps-library/scripts/caps-to-skills.sh your-playbook

# Compile with validation (recommended)
bash caps-library/scripts/caps-to-skills.sh your-playbook --validate
```

### Q: How do I validate YAML frontmatter syntax?

**A**: Use a YAML validator:

1. **Online**: [yamllint.com](http://www.yamllint.com/)
2. **CLI**: `yq eval playbook.md` (if yq installed)
3. **Python**: `python3 -c "import yaml; yaml.safe_load(open('playbook.md'))"`
4. **Editor**: Use VS Code with YAML extension

### Q: My playbook has 7 code blocks - is that a problem?

**A**: Yes! Code block markers (` ``` `) must come in pairs. 7 is odd, meaning one is unmatched. Find and close the open block.

---

## Examples

### Example 1: Fixing Missing Field Error

**Before** (compilation fails):
```yaml
---
title: My Playbook
description: Does something cool
# version field missing
allowed_tools:
  - bash
prerequisites:
  - something
---
```

**Error**:
```
[ERROR] Missing required field: version
```

**After** (compilation succeeds):
```yaml
---
title: My Playbook
description: Does something cool
version: 1.0.0                # Added
allowed_tools:
  - bash
prerequisites:
  - something
---
```

### Example 2: Fixing Unmatched Code Blocks

**Before** (odd number of markers):
```markdown
### Step 1: Install Tool

```bash
sudo apt install mytool

### Step 2: Configure Tool

```bash
mytool config
```
```

**After** (matched pairs):
```markdown
### Step 1: Install Tool

```bash
sudo apt install mytool
```

### Step 2: Configure Tool

```bash
mytool config
```
```

---

## Next Steps

- Read [best-practices.md](./best-practices.md) for authoring guidelines
- See [caps-playbook-template.md](./caps-playbook-template.md) for starter template
- Review example playbooks in `caps-library/playbooks/`

---

**Questions or Issues?** Open a GitHub issue or consult the team.
