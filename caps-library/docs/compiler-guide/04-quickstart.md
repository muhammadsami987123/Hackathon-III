# Quick Start Guide

Get from zero to first compiled skill in 15 minutes.

**Prerequisites**: Completed [Installation](03-installation.md) (bash 4.0+, compiler script available)

---

## 3-Minute Setup Workflow

### Step 1: Verify Compiler (30 seconds)

```bash
# Navigate to project root
cd /path/to/your/project

# Test compiler help
bash caps-library/scripts/caps-to-skills.sh --help
```

**Expected**: Usage message with options displayed

**If fails**: Review [Installation Guide](03-installation.md)

---

### Step 2: Validate Existing Playbooks (1 minute)

If you have existing playbooks, validate them before compiling:

```bash
# Validate a specific playbook
bash caps-library/scripts/caps-to-skills.sh <playbook-name> --validate --dry-run
```

**Example**:
```bash
# Validate hello-world playbook
bash caps-library/scripts/caps-to-skills.sh hello-world --validate --dry-run
```

**Expected Output**:
```
[INFO] CAPS to Claude Skills Compiler v2.0.0
[INFO] ======================================
[INFO] Playbook: hello-world
...
[SUCCESS] Validation passed! (0 errors, 0 warnings)
[INFO] DRY RUN - No files will be created
[INFO] Would create: .claude/skills/hello-world/skill.md
```

**If validation fails**: See error message for specific issue, then check [Troubleshooting](07-troubleshooting.md)

---

### Step 3: Compile Playbook (30 seconds)

Compile the validated playbook to generate skill:

```bash
# Compile with validation
bash caps-library/scripts/caps-to-skills.sh <playbook-name> --validate
```

**Example**:
```bash
# Compile hello-world
bash caps-library/scripts/caps-to-skills.sh hello-world --validate
```

**Expected Output**:
```
[INFO] CAPS to Claude Skills Compiler v2.0.0
[INFO] ======================================
[INFO] Playbook: hello-world
[INFO] Source: .../caps-library/playbooks/hello-world/playbook.md
[INFO] Output: .../.claude/skills/hello-world/skill.md

[INFO] Running validation checks...
[SUCCESS] Validation passed! (0 errors, 0 warnings)

[INFO] Created output directory: .claude/skills/hello-world
[INFO] Reading CAPS playbook...
[INFO] Skill Name: hello-world (from directory)
[INFO] Title: Hello World Example
[INFO] Description: Simple example playbook
[INFO] Version: 1.0.0
[INFO] Generating Claude Skill...
[SUCCESS] Skill compiled successfully!
[SUCCESS] Output: .claude/skills/hello-world/skill.md
```

---

### Step 4: Verify Output (1 minute)

Check the generated skill file:

```bash
# View generated skill
cat .claude/skills/hello-world/skill.md

# Or open in editor
code .claude/skills/hello-world/skill.md  # VS Code
vim .claude/skills/hello-world/skill.md   # Vim
```

**What to verify**:
- ✅ YAML frontmatter (description, version)
- ✅ H1 title matches playbook title
- ✅ All sections present (Prerequisites, Instructions, Validation, Troubleshooting)
- ✅ Code blocks preserved with syntax highlighting
- ✅ Metadata footer (source path, timestamp, skill name)

---

## Using Generated Skills

### List Available Skills

```bash
# List all compiled skills
ls .claude/skills/

# List with details
ls -la .claude/skills/*/skill.md
```

**Expected Output**:
```
hello-world/
kafka-k8s-setup/
postgresql-k8s-setup/
...
```

---

### Run Skill with Claude Code CLI

If you have Claude Code CLI installed:

```bash
# Run specific skill
claude --skill hello-world

# Run with custom instructions
claude --skill hello-world "Deploy to production environment"

# List all available skills
claude --list-skills
```

**Expected**: Claude Code CLI loads the skill and executes instructions

**If Claude CLI not installed**: See [Claude Code documentation](https://github.com/anthropics/claude-code) for installation

---

### Inspect Skill Content

```bash
# View full skill content
cat .claude/skills/hello-world/skill.md

# View only YAML frontmatter
head -10 .claude/skills/hello-world/skill.md

# Search for specific section
grep "## Instructions" -A 20 .claude/skills/hello-world/skill.md
```

---

## Complete Workflow Example

Here's a complete example from creating a playbook to executing with Claude:

### 1. Create Playbook

```bash
# Create playbook directory
mkdir -p caps-library/playbooks/deploy-app

# Create playbook file
cat > caps-library/playbooks/deploy-app/playbook.md << 'EOF'
---
title: Deploy Application
description: Deploy application to production
version: 1.0.0
allowed_tools:
  - bash
  - kubectl
prerequisites:
  - kubectl_configured
  - production_access
---

# Deploy Application

Deploy application to production Kubernetes cluster.

## Prerequisites

- kubectl configured with production cluster context
- Production deployment credentials
- Application image tagged and pushed to registry

## Instructions

### Step 1: Verify Cluster Access

```bash
# Check cluster connection
kubectl cluster-info

# Verify namespace exists
kubectl get namespace production
```

### Step 2: Deploy Application

```bash
# Apply deployment manifest
kubectl apply -f deployment.yaml -n production

# Wait for rollout
kubectl rollout status deployment/myapp -n production
```

### Step 3: Verify Deployment

```bash
# Check pods are running
kubectl get pods -n production -l app=myapp

# Test application endpoint
curl https://myapp.production.example.com/health
```

## Validation

Success criteria:
- [ ] All pods in Running state
- [ ] Health endpoint returns 200 OK
- [ ] Application version matches expected
- [ ] No error logs in pod output

## Troubleshooting

**Problem**: Pods stuck in ImagePullBackOff
**Solution**: Verify image tag and registry credentials with `kubectl describe pod <pod-name>`

**Problem**: Health check fails
**Solution**: Check application logs with `kubectl logs -n production -l app=myapp`
EOF
```

### 2. Validate Playbook

```bash
# Validate structure
bash caps-library/scripts/caps-to-skills.sh deploy-app --validate --dry-run
```

### 3. Compile to Skill

```bash
# Compile with validation
bash caps-library/scripts/caps-to-skills.sh deploy-app --validate
```

### 4. Use with Claude

```bash
# Execute deployment workflow
claude --skill deploy-app
```

---

## Success Checklist

After completing this quick start, you should be able to:

- ✅ Run compiler help command successfully
- ✅ Validate existing playbooks without errors
- ✅ Compile playbooks to skills
- ✅ Verify generated skill.md files
- ✅ List all available skills
- ✅ Understand compilation workflow (playbook → compiler → skill → Claude)
- ✅ Create new playbooks following CAPS format
- ✅ Execute skills with Claude Code CLI (if installed)

**Total Time**: ~15 minutes from installation to first execution

---

## Next Steps

### Learn More

- **Understand Architecture**: [How compilation works](02-architecture.md)
- **Master All Options**: [Command Reference](05-command-reference.md)
- **Automate Workflow**: [Workflow Integration](06-workflow-integration.md)
- **Solve Problems**: [Troubleshooting Guide](07-troubleshooting.md)

### Advanced Topics

- **Batch Compilation**: [Compile multiple playbooks](08-advanced-usage.md#batch-processing)
- **CI/CD Integration**: [Automate in pipelines](06-workflow-integration.md#github-actions)
- **Custom Output Locations**: [Use -o flag](05-command-reference.md#output-option)

### Write Your Own Playbooks

**CAPS Format Requirements**:
1. YAML frontmatter with 5 required fields
2. 4 required Markdown sections
3. Matched code blocks
4. Semver version numbering

**Template**:
```markdown
---
title: Your Playbook Title
description: Brief description
version: 1.0.0
allowed_tools:
  - tool1
  - tool2
prerequisites:
  - prereq1
  - prereq2
---

# Your Playbook Title

Description paragraph.

## Prerequisites

- List prerequisites here

## Instructions

### Step 1: First Action

\```bash
# Your command
\```

## Validation

- [ ] Success criterion 1
- [ ] Success criterion 2

## Troubleshooting

**Problem**: Issue description
**Solution**: Fix description
```

---

## Troubleshooting Quick Start

### Issue: Playbook not found

**Symptom**: `[ERROR] Playbook file not found: ...`

**Solution**:
1. Verify directory structure: `ls caps-library/playbooks/<name>/playbook.md`
2. Check playbook name matches directory name
3. Ensure playbook file named exactly `playbook.md`

---

### Issue: Validation fails

**Symptom**: `[ERROR] Missing required field: ...` or `[ERROR] Missing required section: ...`

**Solution**:
1. Check YAML frontmatter has all 5 fields
2. Verify 4 required sections present
3. See complete example: [test-playbook.md](assets/examples/test-playbook.md)

---

### Issue: Unmatched code blocks

**Symptom**: `[ERROR] Unmatched code block markers (found X, must be even)`

**Solution**:
1. Count ` ``` ` markers in playbook (must be even)
2. Ensure every opening ` ``` ` has closing ` ``` `
3. Check for typos like ` `` ` (2 backticks) instead of ` ``` ` (3 backticks)

---

For more issues, see [Troubleshooting Guide](07-troubleshooting.md).

---

**Version**: 1.0.0 | **Compiler Version**: 2.0.0 | **Last Updated**: 2025-12-20
