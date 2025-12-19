# Quickstart Guide: Author Your First CAPS Playbook in 15 Minutes

**Feature**: CAPS Format Specification and Compilation Infrastructure
**Phase**: Phase 1
**Date**: 2025-12-19
**Audience**: Developers new to CAPS format

## Overview

This quickstart guide will walk you through creating your first CAPS (Coding Agent Playbook Specification) playbook, compiling it to a Claude CLI Skill, and testing it with Claude Code. By the end, you'll have a working playbook that Claude can execute autonomously.

**Time Required**: ~15 minutes

## Prerequisites

Before starting, ensure you have:

- ✅ Bash 4.0+ available (`bash --version`)
- ✅ Text editor (VS Code, Vim, nano, etc.)
- ✅ Git repository cloned (this Hackathon III project)
- ✅ Basic familiarity with markdown and YAML
- ✅ Claude Code CLI installed (for testing)

**Verify Prerequisites**:

```bash
# Check Bash version
bash --version | head -1
# Expected: GNU bash, version 4.x or later

# Check repository
pwd
# Expected: /path/to/Hackathon III

# Check caps-library exists
ls caps-library/
# Expected: README.md  docs/  playbooks/  scripts/
```

---

## Step 1: Understand CAPS Format (3 minutes)

CAPS playbooks are markdown files with YAML frontmatter. They have two main parts:

### Part 1: YAML Frontmatter (Metadata)

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

**Required Fields**:
- `title`: Human-readable name (3-80 chars)
- `description`: Summary (10-300 chars)
- `version`: Semantic version (MAJOR.MINOR.PATCH)
- `allowed_tools`: Array of tools used (bash, kubectl, helm, docker, etc.)
- `prerequisites`: Array of testable conditions (snake_case)

**Optional Fields** (recommended):
- `category`: infrastructure/backend/frontend/tools/etc.
- `tags`: Searchable keywords
- `difficulty`: beginner/intermediate/advanced/expert
- `estimated_time`: Minutes to complete

### Part 2: Markdown Content (Instructions)

```markdown
# Your Playbook Title

[Description paragraph]

## Prerequisites

[Human-readable prerequisites with verification commands]

## Instructions

### Step 1: [Action Name]

**Objective:** [What this step accomplishes]

```bash
# Your bash commands here
```

**Expected Output:**
```
Expected output here
```

**Success Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2

### Step 2: [Next Action]

[... more steps ...]

## Validation

Success criteria (all must pass):
- [ ] **Check 1:** `command to verify`
- [ ] **Check 2:** `another verification command`

## Troubleshooting

**Problem:** [Error name]
**Symptoms:** [What user sees]
**Root Cause:** [Why it happens]
**Fix:**
```bash
# Commands to resolve
```
```

**Required Sections**:
- `## Prerequisites`: What must be true before starting
- `## Instructions`: Sequential steps with bash commands
- `## Validation`: Success criteria as checklist
- `## Troubleshooting`: Common errors and fixes

**Key Takeaways**:
- YAML metadata describes the playbook
- Markdown sections provide step-by-step instructions
- Bash commands in triple-backtick code blocks
- Every step has objective, commands, expected output, success criteria
- Troubleshooting documents common failures

---

## Step 2: Create Playbook Directory (1 minute)

Choose a descriptive name for your playbook (lowercase, hyphenated). This will be the skill name.

```bash
# Navigate to caps-library playbooks directory
cd caps-library/playbooks/

# Create your playbook directory
mkdir my-first-playbook

# Navigate into it
cd my-first-playbook

# Verify you're in the right place
pwd
# Expected: /path/to/caps-library/playbooks/my-first-playbook
```

**Naming Convention**:
- Use lowercase letters
- Separate words with hyphens (not underscores or spaces)
- Be descriptive but concise (2-4 words)
- Examples: `hello-world`, `kafka-k8s-setup`, `fastapi-dapr-service`

---

## Step 3: Copy Template and Fill In (8 minutes)

### Copy the Template

```bash
# From caps-library/playbooks/my-first-playbook/
cp ../../docs/caps-playbook-template.md playbook.md

# Verify file created
ls -la playbook.md
```

### Fill in the Template

Open `playbook.md` in your editor and fill in these sections:

#### 3a. YAML Frontmatter (2 minutes)

Replace placeholders with your playbook details:

```yaml
---
title: My First CAPS Playbook
description: Create a simple text file with timestamp and system information
version: 1.0.0
category: example
tags: [tutorial, beginner, filesystem]
difficulty: beginner
estimated_time: 5
allowed_tools:
  - bash
prerequisites:
  - bash_4_or_later
  - write_permission_current_directory
---
```

**Tips**:
- Keep title clear and specific
- Description should explain the outcome, not the how
- Version starts at 1.0.0
- List all tools you'll use (bash is almost always needed)
- Prerequisites should be testable (can verify with a command)

#### 3b. Fill Prerequisites Section (1 minute)

```markdown
## Prerequisites

Before starting, verify:

```bash
# Check Bash version
bash --version | head -1
# Should be 4.0 or later

# Check write permissions
touch test.txt && rm test.txt && echo "✓ Write permission OK"
```
```

#### 3c. Write Instructions Steps (4 minutes)

Example: Create a file with system info

```markdown
## Instructions

### Step 1: Create System Info File

**Objective:** Create a text file with current timestamp and system information

**Commands:**
```bash
# Create file with timestamp
cat > system-info.txt <<EOF
System Information Report
Generated: $(date)
User: $(whoami)
Directory: $(pwd)
Bash Version: $(bash --version | head -1)
EOF

# Display file content
cat system-info.txt
```

**Expected Output:**
```
System Information Report
Generated: Thu Dec 19 19:00:00 UTC 2025
User: your-username
Directory: /current/directory
Bash Version: GNU bash, version 5.x...
```

**Success Criteria:**
- [ ] system-info.txt file exists
- [ ] File contains timestamp
- [ ] File contains user and directory information

### Step 2: Verify File Contents

**Objective:** Validate that the file was created correctly with expected content

**Commands:**
```bash
# Check file exists and is readable
test -f system-info.txt && echo "✓ File exists"
test -r system-info.txt && echo "✓ File is readable"

# Check file has content
wc -l system-info.txt
# Expected: 5 or more lines
```

**Expected Output:**
```
✓ File exists
✓ File is readable
5 system-info.txt
```

**Success Criteria:**
- [ ] File exists and is readable
- [ ] File has 5+ lines

### Step 3: Cleanup (Optional)

**Objective:** Remove the generated file

**Commands:**
```bash
# Remove file
rm system-info.txt

# Verify removal
ls system-info.txt 2>&1 || echo "✓ File removed"
```

**Expected Output:**
```
ls: cannot access 'system-info.txt': No such file or directory
✓ File removed
```

**Success Criteria:**
- [ ] File no longer exists
```

#### 3d. Add Validation Section (1 minute)

```markdown
## Validation

Success criteria (all must pass):

- [ ] **File Created:** `test -f system-info.txt && echo "PASS" || echo "FAIL"`
- [ ] **Contains Timestamp:** `grep -q "Generated:" system-info.txt && echo "PASS"`
- [ ] **Contains User Info:** `grep -q "User:" system-info.txt && echo "PASS"`
- [ ] **File Readable:** `cat system-info.txt` displays content without errors

Quick validation script:
```bash
# Run all checks
test -f system-info.txt && \
  grep -q "Generated:" system-info.txt && \
  grep -q "User:" system-info.txt && \
  echo "✅ All validation checks passed!" || \
  echo "❌ Some validation checks failed"
```
```

#### 3e. Add Troubleshooting (1 minute)

```markdown
## Troubleshooting

**Problem:** Permission denied when creating file
**Symptoms:** `cat: system-info.txt: Permission denied` or similar error
**Root Cause:** No write permission in current directory
**Check:**
```bash
# Check directory permissions
ls -ld .
# Should show 'w' permission for user

# Try creating test file
touch test.txt
```
**Fix:**
```bash
# Change to a directory where you have write permission
cd ~
mkdir caps-test
cd caps-test

# Or request write permissions from system administrator
```

---

**Problem:** Command not found errors
**Symptoms:** `bash: date: command not found` or similar
**Root Cause:** Required commands not in PATH
**Check:**
```bash
# Verify commands exist
which bash
which date
which cat
```
**Fix:**
```bash
# Ensure PATH includes standard directories
echo $PATH
# Should include /bin and /usr/bin

# If not, add them:
export PATH=$PATH:/bin:/usr/bin
```
```

#### 3f. Optional Sections

Add these if relevant:

- `## Notes & References`: Additional context, links to documentation
- `## Rollback Instructions`: How to undo changes
- `## Next Steps`: What to do after this playbook completes

---

## Step 4: Compile to Claude Skill (1 minute)

Navigate back to the repository root and run the compilation script:

```bash
# From caps-library/playbooks/my-first-playbook/, go to repo root
cd ../../..

# Compile with validation
bash caps-library/scripts/caps-to-skills.sh my-first-playbook --validate
```

**Expected Output**:

```
[INFO] CAPS to Claude Skills Compiler
[INFO] ==============================
[INFO] Playbook: my-first-playbook
[INFO] Source: caps-library/playbooks/my-first-playbook/playbook.md
[INFO] Output: .claude/skills/my-first-playbook/skill.md

[INFO] Created output directory: .claude/skills/my-first-playbook
[INFO] Reading CAPS playbook...
[INFO] Title: My First CAPS Playbook
[INFO] Description: Create a simple text file...
[INFO] Version: 1.0.0
[INFO] Generating Claude Skill...
[SUCCESS] Skill compiled successfully!
[SUCCESS] Output: .claude/skills/my-first-playbook/skill.md

[INFO] Validation passed!

[INFO] Next steps:
[INFO] 1. Review the generated skill
[INFO] 2. Test the skill with Claude Code CLI
[INFO] 3. Refine the CAPS playbook if needed
```

**If Compilation Fails**:

Check error messages. Common issues:
- Missing required field → Add to YAML frontmatter
- Missing required section → Add `## Prerequisites`, `## Instructions`, etc.
- Unmatched code blocks → Ensure every ` ``` ` has a closing ` ``` `

**Verify Generated Skill**:

```bash
# Check output file exists
ls -la .claude/skills/my-first-playbook/skill.md

# View generated skill
cat .claude/skills/my-first-playbook/skill.md
```

The skill should have:
- YAML frontmatter with `description` and `version`
- Markdown sections copied from your playbook
- Metadata footer with source path and compilation timestamp

---

## Step 5: Test with Claude (2 minutes)

### Option A: Test with Claude Code CLI (Recommended)

1. **Open Claude Code CLI** in this project directory
2. **Ask Claude to help with your workflow**:
   ```
   "Can you help me create a system info file? I have a skill for that."
   ```
3. **Claude will discover the skill** in `.claude/skills/my-first-playbook/`
4. **Claude will reference and execute** the playbook steps

### Option B: Manual Test (Without Claude)

Execute the playbook steps manually to verify they work:

```bash
# Navigate to a test directory
mkdir -p ~/caps-test
cd ~/caps-test

# Run Step 1 commands
cat > system-info.txt <<EOF
System Information Report
Generated: $(date)
User: $(whoami)
Directory: $(pwd)
Bash Version: $(bash --version | head -1)
EOF

# Run Step 2 commands
test -f system-info.txt && echo "✓ File exists"
test -r system-info.txt && echo "✓ File is readable"
wc -l system-info.txt

# Run validation checks
test -f system-info.txt && \
  grep -q "Generated:" system-info.txt && \
  grep -q "User:" system-info.txt && \
  echo "✅ All validation checks passed!"

# Cleanup
rm system-info.txt
cd -
```

**Expected Result**: All commands execute successfully, validation passes, file is created and removed.

---

## Success Criteria

By the end of this quickstart, you should have:

- [x] Created a CAPS playbook directory (`caps-library/playbooks/my-first-playbook/`)
- [x] Written a valid playbook.md with all required sections
- [x] Compiled the playbook to a Claude Skill (`.claude/skills/my-first-playbook/skill.md`)
- [x] Verified the skill passes validation
- [x] (Optional) Tested the skill with Claude Code CLI or manually executed steps

---

## Next Steps

### Learn More

1. **Review Example Playbooks**:
   - `caps-library/playbooks/hello-world/` - Simple script creation
   - `caps-library/playbooks/kafka-k8s-setup/` - Infrastructure deployment (intermediate)
   - `caps-library/playbooks/postgresql-k8s-setup/` - Database setup (intermediate)
   - `caps-library/playbooks/fastapi-dapr-service/` - Backend service (advanced)

2. **Read Best Practices**:
   - `caps-library/docs/best-practices.md` - Authoring guidelines
   - `sp.abc.md` - Complete CAPS v1.0.0 specification

3. **Understand Validation**:
   - `caps-library/docs/validation-guide.md` - Common errors and fixes

### Iterate on Your Playbook

1. **Test the playbook** with real execution (manually or with Claude)
2. **Document any failures** in the Troubleshooting section
3. **Refine instructions** based on execution results
4. **Update version number** (1.0.0 → 1.0.1 for clarifications, 1.1.0 for new steps)
5. **Re-compile** and test again

**Target**: After 3 iterations, your playbook should require <5% manual intervention (aligned with constitution Principle VII).

### Create More Playbooks

Apply what you learned to create playbooks for:
- Infrastructure deployments (Kubernetes, Helm)
- Service creation (FastAPI, Docker)
- Testing workflows (pytest, integration tests)
- Documentation generation (Docusaurus, AGENTS.md)

---

## Troubleshooting This Quickstart

### Issue: Template file not found

**Error**: `cp: cannot stat '../../docs/caps-playbook-template.md': No such file or directory`

**Fix**:
```bash
# Verify you're in the right directory
pwd
# Should be: /path/to/caps-library/playbooks/my-first-playbook

# Check template exists
ls -la ../../docs/caps-playbook-template.md

# If missing, use hello-world as template instead
cp ../../playbooks/hello-world/playbook.md playbook.md
```

### Issue: Compilation script not found

**Error**: `bash: caps-library/scripts/caps-to-skills.sh: No such file or directory`

**Fix**:
```bash
# Verify you're in repository root
pwd
# Should be: /path/to/Hackathon III (not caps-library/playbooks/...)

# Navigate to root
cd /path/to/Hackathon\ III

# Verify script exists
ls -la caps-library/scripts/caps-to-skills.sh

# Run from root
bash caps-library/scripts/caps-to-skills.sh my-first-playbook --validate
```

### Issue: Validation fails with "Missing required field"

**Error**: `[ERROR] Missing required field: title`

**Fix**:
```bash
# Check YAML frontmatter has all required fields
head -20 caps-library/playbooks/my-first-playbook/playbook.md

# Required fields:
# - title:
# - description:
# - version:
# - allowed_tools:
# - prerequisites:

# Add missing fields to YAML frontmatter
# Re-compile
```

### Issue: Claude CLI doesn't discover the skill

**Cause**: Claude looks in `.claude/skills/` directory

**Fix**:
```bash
# Verify skill file exists
ls -la .claude/skills/my-first-playbook/skill.md

# If missing, re-compile
bash caps-library/scripts/caps-to-skills.sh my-first-playbook --validate

# Restart Claude Code CLI to refresh skill discovery
```

---

## Completion

Congratulations! You've successfully created your first CAPS playbook and compiled it to a Claude CLI Skill.

**What You Learned**:
- ✅ CAPS format structure (YAML frontmatter + markdown sections)
- ✅ Required fields and sections
- ✅ Writing executable instructions with bash commands
- ✅ Validation criteria and troubleshooting documentation
- ✅ Compilation workflow (CAPS → Claude Skill)
- ✅ Testing with Claude Code CLI

**Time Invested**: ~15 minutes
**Skills Gained**: CAPS playbook authoring, Claude CLI Skills creation
**Next Challenge**: Create a more complex playbook for a real workflow in your project!

---

**Feedback**: Found an issue with this quickstart? Open an issue or improve the guide directly.
