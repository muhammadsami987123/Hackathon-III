# Troubleshooting Guide

Common issues encountered during CAPS compilation and their solutions.

---

## Quick Diagnostics

Before diving into specific issues, run these diagnostic commands:

```bash
# 1. Verify compiler exists and is executable
ls -la caps-library/scripts/caps-to-skills.sh

# 2. Test compiler help
bash caps-library/scripts/caps-to-skills.sh --help

# 3. Check bash version (need 4.0+)
bash --version

# 4. Verify directory structure
ls -la caps-library/playbooks/
ls -la .claude/skills/

# 5. Run validation on problematic playbook
bash caps-library/scripts/caps-to-skills.sh <playbook-name> --validate --dry-run
```

---

## Common Issues

### Issue 1: "Playbook file not found"

**Symptom**:
```
[ERROR] Playbook file not found: /path/to/caps-library/playbooks/<name>/playbook.md
[INFO] Expected structure: caps-library/playbooks/<name>/playbook.md
```

**Root Cause**:
- Playbook doesn't exist at expected location
- Incorrect directory structure
- Typo in playbook name

**Solution**:

**Step 1**: Verify playbook exists
```bash
# Check if playbook file exists
ls -la caps-library/playbooks/<playbook-name>/playbook.md

# If not, check directory contents
ls -la caps-library/playbooks/<playbook-name>/
```

**Step 2**: Verify directory structure
```
Required structure:
caps-library/
└── playbooks/
    └── <playbook-name>/
        └── playbook.md        # Must be named exactly "playbook.md"
```

**Step 3**: Common mistakes
```bash
# ❌ Wrong: File in caps-library/playbooks/ directly
caps-library/playbooks/my-playbook.md

# ✅ Correct: File in caps-library/playbooks/<name>/ subdirectory
caps-library/playbooks/my-playbook/playbook.md

# ❌ Wrong: Different filename
caps-library/playbooks/my-playbook/my-playbook.md

# ✅ Correct: Exact filename "playbook.md"
caps-library/playbooks/my-playbook/playbook.md
```

**Step 4**: Fix structure
```bash
# Create correct directory structure
mkdir -p caps-library/playbooks/<playbook-name>

# Move playbook to correct location
mv wrong-location/playbook.md caps-library/playbooks/<playbook-name>/playbook.md
```

---

### Issue 2: "Invalid YAML frontmatter: Missing --- markers"

**Symptom**:
```
[ERROR] Invalid YAML frontmatter: Missing --- markers
```

**Root Cause**:
- YAML frontmatter not properly delimited
- Missing opening or closing `---` marker
- Extra spaces or characters before/after markers

**Solution**:

**Step 1**: Check YAML structure
```bash
# View first 20 lines of playbook
head -20 caps-library/playbooks/<name>/playbook.md
```

**Expected Format**:
```markdown
---
title: Playbook Title
description: Description text
version: 1.0.0
allowed_tools:
  - tool1
prerequisites:
  - prereq1
---

# Playbook Title
...
```

**Step 2**: Common mistakes

```markdown
# ❌ Wrong: Missing opening ---
title: Playbook Title
description: Description
---

# ✅ Correct: Both markers present
---
title: Playbook Title
description: Description
---

# ❌ Wrong: Extra spaces before marker
   ---
title: Playbook Title
---

# ✅ Correct: No leading spaces
---
title: Playbook Title
---

# ❌ Wrong: Only one marker
---
title: Playbook Title
description: Description
# (missing closing ---)

# ✅ Correct: Both opening and closing
---
title: Playbook Title
description: Description
---
```

**Step 3**: Fix YAML frontmatter
```bash
# Edit playbook file
vim caps-library/playbooks/<name>/playbook.md

# Ensure:
# - First line is exactly "---" (no spaces)
# - YAML content in between
# - Closing "---" on its own line
# - No extra content before first ---
```

---

### Issue 3: "Missing required field"

**Symptom**:
```
[ERROR] Missing required field: version
```

**Root Cause**:
- One or more of 5 required YAML fields missing
- Field name typo (e.g., `versions` instead of `version`)
- Incorrect YAML syntax

**Required Fields**:
1. `title` (string)
2. `description` (string)
3. `version` (string, semver format)
4. `allowed_tools` (array)
5. `prerequisites` (array)

**Solution**:

**Step 1**: Check which field is missing
```bash
# Validation will tell you which field
bash caps-library/scripts/caps-to-skills.sh <name> --validate --dry-run
```

**Step 2**: Add missing field

```yaml
# Complete YAML frontmatter template
---
title: Your Playbook Title
description: Brief description of what this does
version: 1.0.0
allowed_tools:
  - bash
  - kubectl
prerequisites:
  - tool_installed
  - access_configured
---
```

**Step 3**: Common field mistakes

```yaml
# ❌ Wrong: Typo in field name
titel: My Playbook  # Should be "title"

# ❌ Wrong: Missing colon
title My Playbook  # Should be "title: My Playbook"

# ❌ Wrong: Array without items
allowed_tools:
# (empty)

# ✅ Correct: Array with at least one item
allowed_tools:
  - bash

# ❌ Wrong: String for array field
allowed_tools: bash

# ✅ Correct: Array format
allowed_tools:
  - bash
```

---

### Issue 4: "Invalid version format"

**Symptom**:
```
[ERROR] Invalid version format: 1.0 (expected MAJOR.MINOR.PATCH)
```

**Root Cause**:
- Version doesn't follow semantic versioning (semver) format
- Missing patch number or other components

**Solution**:

**Semver Format**: `MAJOR.MINOR.PATCH`
- MAJOR: Breaking changes (1.0.0 → 2.0.0)
- MINOR: New features (1.0.0 → 1.1.0)
- PATCH: Bug fixes (1.0.0 → 1.0.1)

**Valid Examples**:
```yaml
version: 1.0.0   # ✅ Correct
version: 2.5.3   # ✅ Correct
version: 0.1.0   # ✅ Correct (pre-release)
version: 10.20.30  # ✅ Correct (multi-digit)
```

**Invalid Examples**:
```yaml
version: 1.0      # ❌ Wrong: Missing PATCH
version: 1        # ❌ Wrong: Missing MINOR and PATCH
version: v1.0.0   # ❌ Wrong: Has "v" prefix
version: 1.0.0-beta  # ❌ Wrong: Has pre-release label
version: "1.0.0"  # ❌ Wrong: Quoted (remove quotes)
```

**Fix**:
```yaml
# Change this:
version: 1.0

# To this:
version: 1.0.0
```

---

### Issue 5: "Missing required section"

**Symptom**:
```
[ERROR] Missing required section: ## Instructions
```

**Root Cause**:
- One or more of 4 required Markdown sections missing
- Section header typo or wrong level (### instead of ##)
- Extra spaces in section header

**Required Sections**:
1. `## Prerequisites`
2. `## Instructions`
3. `## Validation`
4. `## Troubleshooting`

**Solution**:

**Step 1**: Check existing sections
```bash
# List all H2 headers in playbook
grep "^## " caps-library/playbooks/<name>/playbook.md
```

**Step 2**: Add missing sections

**Complete Template**:
```markdown
---
# YAML frontmatter here
---

# Playbook Title

Description paragraph.

## Prerequisites

- List prerequisites here
- At least one item required

## Instructions

### Step 1: First Action

```bash
# Commands here
```

### Step 2: Second Action

```bash
# More commands
```

## Validation

Success criteria:
- [ ] Criterion 1
- [ ] Criterion 2

## Troubleshooting

**Problem**: Issue description
**Solution**: Fix description
```

**Step 3**: Common section mistakes

```markdown
# ❌ Wrong: Level 3 header (###)
### Instructions

# ✅ Correct: Level 2 header (##)
## Instructions

# ❌ Wrong: Typo in section name
## Instruction  # Missing 's'

# ✅ Correct: Exact name
## Instructions

# ❌ Wrong: Extra spaces
##  Prerequisites  # Extra space after ##

# ✅ Correct: Single space after ##
## Prerequisites
```

---

### Issue 6: "Unmatched code block markers"

**Symptom**:
```
[ERROR] Unmatched code block markers (found 5, must be even)
```

**Root Cause**:
- Odd number of ` ``` ` markers (backticks)
- Missing closing marker for code block
- Typo in marker (` `` ` instead of ` ``` `)

**Solution**:

**Step 1**: Count code block markers
```bash
# Count all ``` markers
grep -c '^```' caps-library/playbooks/<name>/playbook.md

# Show all markers with line numbers
grep -n '^```' caps-library/playbooks/<name>/playbook.md
```

**Example Output**:
```
15:```bash
20:```
35:```yaml
40:```
55:```bash
# (only 5 markers - missing closing marker for last block!)
```

**Step 2**: Find unclosed block

Look for patterns like:
```markdown
### Step 1: Do Something

```bash
echo "hello"
```

### Step 2: Do Another Thing

```bash
echo "world"
# ❌ Missing closing ``` here!

### Step 3: Final Step
```

**Step 3**: Fix code blocks

```markdown
# ✅ Correct: Matched opening and closing
```bash
command here
```

# ❌ Wrong: Only 2 backticks
``bash
command here
``

# ✅ Correct: Exactly 3 backticks
```bash
command here
```

# ❌ Wrong: Missing closing marker
```bash
command here
(no closing marker)

## Next Section

# ✅ Correct: Closing marker present
```bash
command here
```

## Next Section
```

---

### Issue 7: Wrong skill name generated

**Symptom**: Skill name doesn't match expected (e.g., skill named `my-app` but expected `myapp`)

**Root Cause**: Skill name derived from **directory name**, not playbook title

**How It Works**:
```
Directory: caps-library/playbooks/hello-world/
Skill name: hello-world (exact match to directory)

Directory: caps-library/playbooks/kafka-k8s-setup/
Skill name: kafka-k8s-setup (exact match to directory)
```

**Solution**:

**Option 1**: Rename directory (recommended)
```bash
# Rename directory to desired skill name
mv caps-library/playbooks/old-name caps-library/playbooks/new-name

# Recompile
bash caps-library/scripts/caps-to-skills.sh new-name --validate
```

**Option 2**: Accept directory-based naming
```bash
# Skill name will always match directory name
# This is by design - no slugification happens
```

**Naming Best Practices**:
- Use lowercase
- Use hyphens for spaces (`my-app` not `my_app` or `myapp`)
- Keep short but descriptive
- No special characters (stick to `a-z`, `0-9`, `-`)

---

### Issue 8: Permission denied

**Symptom**:
```
mkdir: cannot create directory '.claude/skills': Permission denied
```

**Root Cause**:
- No write permissions on output directory
- Output directory owned by different user
- Filesystem is read-only

**Solution**:

**Step 1**: Check permissions
```bash
# Check output directory permissions
ls -ld .claude/skills/

# Check parent directory
ls -ld .claude/
```

**Step 2**: Fix permissions
```bash
# Option 1: Change ownership (if needed)
sudo chown -R $USER:$USER .claude/

# Option 2: Add write permissions
chmod u+w .claude/skills/

# Option 3: Create directory with correct permissions
mkdir -p .claude/skills
chmod 755 .claude/skills
```

**Step 3**: Use custom output directory
```bash
# Compile to directory where you have permissions
bash caps-library/scripts/caps-to-skills.sh <name> -o ~/my-skills/
```

---

### Issue 9: Compiler script not executable

**Symptom**:
```
bash: ./caps-to-skills.sh: Permission denied
```

**Root Cause**: Script doesn't have execute permissions

**Solution**:
```bash
# Add execute permission
chmod +x caps-library/scripts/caps-to-skills.sh

# Verify permissions
ls -la caps-library/scripts/caps-to-skills.sh

# Should show: -rwxr-xr-x (note the 'x' flags)
```

---

### Issue 10: Incomplete skill.md output

**Symptom**: Generated skill file exists but missing sections or metadata

**Root Cause**:
- Compilation interrupted mid-write
- Disk space full
- Script error during transformation stage

**Solution**:

**Step 1**: Check disk space
```bash
# Check available disk space
df -h .

# Should have at least 10MB free
```

**Step 2**: Remove incomplete file and recompile
```bash
# Remove incomplete skill
rm .claude/skills/<name>/skill.md

# Recompile with validation
bash caps-library/scripts/caps-to-skills.sh <name> --validate
```

**Step 3**: Verify output integrity
```bash
# Check file has all expected sections
cat .claude/skills/<name>/skill.md

# Expected:
# - YAML frontmatter (---)
# - H1 title
# - All playbook sections
# - Metadata footer (Source Playbook, Compiled, etc.)
```

---

## Quality Warnings (Non-Blocking)

These warnings don't block compilation but indicate potential issues:

### Warning: Potential hardcoded secret

**Symptom**:
```
[WARNING] Potential hardcoded secret detected (lines: 45,67,89)
```

**Cause**: Keywords like "password", "apikey", "token", "secret" found in playbook

**Solution**:
```bash
# Check flagged lines
sed -n '45p;67p;89p' caps-library/playbooks/<name>/playbook.md

# If actually secrets: use environment variables
export DB_PASSWORD="secret"

# If false positive: ignore (compilation continues)
```

### Warning: Non-consecutive step numbering

**Symptom**:
```
[WARNING] Non-consecutive step numbering detected (Step 1 → Step 3)
```

**Cause**: Steps numbered 1, 3, 4 (missing Step 2)

**Solution**: Renumber steps sequentially
```markdown
# Before:
### Step 1: First
### Step 3: Second  # ❌ Skipped 2
### Step 4: Third

# After:
### Step 1: First
### Step 2: Second  # ✅ Sequential
### Step 3: Third
```

### Warning: Unknown tool

**Symptom**:
```
[WARNING] Unknown tool in allowed_tools: custom-tool (not in whitelist)
```

**Cause**: Tool name not in known tools whitelist

**Known Tools**: bash, kubectl, helm, docker, git, python, npm, curl, jq, yq, terraform, ansible, minikube, kind, make, cargo, rustc, go, node, ruby, pip, apt, yum, dnf, brew

**Solution**:
- If tool is valid: Ignore warning (compilation continues)
- If typo: Fix tool name
- If custom tool: Ignore warning or add to compiler whitelist (requires editing compiler script)

---

## Getting Help

### Enable Verbose Output

Currently not supported. Feature planned for future version.

### Check Compiler Logs

No separate log file - all output to stdout/stderr. Redirect to file if needed:

```bash
# Capture all output to log file
bash caps-library/scripts/caps-to-skills.sh <name> --validate > compile.log 2>&1

# View log
cat compile.log
```

### Report Issues

If issue not covered in this guide:

1. **Verify compiler version**: Check if using latest version
2. **Minimal reproduction**: Create minimal playbook that reproduces issue
3. **Report bug**: Open issue in project repository with:
   - Compiler version
   - Playbook content (or minimal example)
   - Full error output
   - Operating system and bash version

---

## Next Steps

- **Advanced Patterns**: [Advanced Usage](08-advanced-usage.md)
- **Command Options**: [Command Reference](05-command-reference.md)
- **Architecture**: [How Compilation Works](02-architecture.md)

---

**Version**: 1.0.0 | **Compiler Version**: 2.0.0 | **Last Updated**: 2025-12-20
