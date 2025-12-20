# Workflow Integration

Integrate the CAPS-to-Skills compiler into your development workflows for automated compilation, validation, and deployment.

---

## Standalone Usage

### Manual Compilation

Basic command-line usage for manual compilation:

```bash
# Navigate to project root
cd /path/to/project

# Compile single playbook
bash caps-library/scripts/caps-to-skills.sh <playbook-name> --validate

# Compile multiple playbooks
for playbook in hello-world kafka-k8s-setup postgresql-k8s-setup; do
    bash caps-library/scripts/caps-to-skills.sh $playbook --validate
done
```

**When to use**: Ad-hoc compilation during development, testing single playbooks

---

## Git Pre-Commit Hook

Automatically validate and compile CAPS playbooks before each commit. Blocks commits if validation fails.

### Hook Script

See complete script: [pre-commit](assets/examples/pre-commit)

**Key Features**:
- Validates only modified playbooks
- Compiles validated playbooks
- Stages generated skills automatically
- Blocks commit on validation failure
- Color-coded output for readability

### Installation

```bash
# Copy hook to .git/hooks/
cp caps-library/docs/compiler-guide/assets/examples/pre-commit .git/hooks/pre-commit

# Make executable
chmod +x .git/hooks/pre-commit

# Test the hook
git add caps-library/playbooks/hello-world/playbook.md
git commit -m "test: verify pre-commit hook"
```

**Expected Output**:
```
Running CAPS playbook validation...

Validating playbook: hello-world
  ✓ Validation passed
  Compiling to skill...
  ✓ Compilation successful
  ✓ Staged generated skill

All CAPS playbooks validated successfully!
[001-caps-compiler-guide abc123] test: verify pre-commit hook
 2 files changed, 150 insertions(+)
```

### Hook Behavior

| Scenario | Action | Result |
|----------|--------|--------|
| No playbooks modified | Skip validation | Commit proceeds |
| Playbooks valid | Compile and stage skills | Commit proceeds |
| Validation fails | Show error details | **Commit blocked** |
| Compiler missing | Warn and skip | Commit proceeds (doesn't block) |

### Testing the Hook

```bash
# Create test playbook with intentional error (missing version field)
mkdir -p caps-library/playbooks/test-invalid
cat > caps-library/playbooks/test-invalid/playbook.md << 'EOF'
---
title: Test Invalid
description: Test playbook with validation error
# version field intentionally missing
allowed_tools:
  - bash
prerequisites:
  - none
---

# Test Invalid

This should fail validation.

## Prerequisites
- None

## Instructions
### Step 1: Test
```bash
echo "test"
```

## Validation
- [ ] Test

## Troubleshooting
**Problem**: N/A
**Solution**: N/A
EOF

# Try to commit (should fail)
git add caps-library/playbooks/test-invalid/playbook.md
git commit -m "test: invalid playbook"
```

**Expected Output**:
```
Running CAPS playbook validation...

Validating playbook: test-invalid
  ✗ Validation failed
[ERROR] Missing required field: version
================================================
Commit blocked: CAPS validation failed
================================================

Fix the validation errors and try again.
To skip this hook (not recommended): git commit --no-verify
```

### Bypassing the Hook

```bash
# Skip hook (NOT recommended - only for emergencies)
git commit --no-verify -m "emergency: skip validation"
```

**When to bypass**: Never in normal workflow. Only for emergency hotfixes or when compiler temporarily broken.

---

## GitHub Actions CI/CD

Automate compilation in GitHub Actions workflow. Validates on pull requests, compiles on push to main.

### Workflow YAML

See complete workflow: [caps-compile.yml](assets/examples/caps-compile.yml)

**Key Features**:
- Triggers on playbook or compiler changes
- Validates all modified playbooks
- Compiles and commits generated skills
- Uploads skills as artifacts
- Adds summary to workflow output

### Setup Instructions

#### Step 1: Create Workflow File

```bash
# Create workflows directory
mkdir -p .github/workflows

# Copy workflow file
cp caps-library/docs/compiler-guide/assets/examples/caps-compile.yml .github/workflows/caps-compile.yml

# Commit workflow
git add .github/workflows/caps-compile.yml
git commit -m "ci: add CAPS compilation workflow"
git push
```

#### Step 2: Verify Workflow

1. Navigate to repository on GitHub
2. Click "Actions" tab
3. Verify "CAPS to Skills Compilation" workflow appears
4. Make a test change to any playbook
5. Push and watch workflow execute

### Workflow Triggers

| Event | Trigger Paths | Action |
|-------|---------------|--------|
| **Push** | `caps-library/playbooks/**/*.md` | Validate, compile, commit skills |
| **Push** | `caps-library/scripts/caps-to-skills.sh` | Recompile all playbooks |
| **Pull Request** | `caps-library/playbooks/**/*.md` | Validate only (no commit) |
| **Pull Request** | `caps-library/scripts/caps-to-skills.sh` | Validate all playbooks |

### Customization Options

**Change Output Directory**:
```yaml
- name: Compile playbooks
  run: |
    bash caps-library/scripts/caps-to-skills.sh "$playbook" --validate -o custom-skills/
```

**Skip Auto-Commit**:
```yaml
# Remove this step to prevent auto-commit
- name: Commit generated skills
  if: false  # Disable auto-commit
```

**Add Notifications**:
```yaml
- name: Notify on failure
  if: failure()
  uses: actions/github-script@v6
  with:
    script: |
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: '⚠️ CAPS compilation failed! Check the workflow logs.'
      })
```

### Workflow Artifacts

Generated skills uploaded as artifacts for 7 days:

```bash
# Download artifacts using GitHub CLI
gh run download <run-id> -n compiled-skills

# Or download from GitHub Actions UI:
# Actions → Workflow Run → Artifacts → compiled-skills
```

---

## Makefile Integration

Use Make for local development automation. Simplifies common compilation tasks.

### Makefile

See complete Makefile: [Makefile](assets/examples/Makefile)

**Available Targets**:
- `make help`: Show usage information
- `make validate`: Validate all playbooks
- `make compile`: Compile all playbooks
- `make clean`: Remove generated skills
- `make list`: List available playbooks
- `make test`: Run validation tests
- `make all`: Clean, validate, compile (full rebuild)

**Single Playbook Targets**:
- `make compile-<name>`: Compile specific playbook
- `make validate-<name>`: Validate specific playbook

### Installation

```bash
# Copy Makefile to project root
cp caps-library/docs/compiler-guide/assets/examples/Makefile Makefile

# Verify Make is installed
make --version
```

### Usage Examples

#### Example 1: Validate All Playbooks

```bash
make validate
```

**Output**:
```
Validating all CAPS playbooks...
Validating: hello-world
[INFO] Running validation checks...
[SUCCESS] Validation passed! (0 errors, 0 warnings)
Validating: kafka-k8s-setup
[SUCCESS] Validation passed! (0 errors, 0 warnings)
All playbooks validated successfully!
```

#### Example 2: Compile All Playbooks

```bash
make compile
```

**Output**:
```
Compiling all CAPS playbooks...
Compiling: hello-world
[SUCCESS] Skill compiled successfully!
Compiling: kafka-k8s-setup
[SUCCESS] Skill compiled successfully!
All playbooks compiled successfully!
```

#### Example 3: Full Rebuild

```bash
make all
```

**Output**:
```
Cleaning generated skills...
All skills removed
Validating all CAPS playbooks...
All playbooks validated successfully!
Compiling all CAPS playbooks...
All playbooks compiled successfully!
Full rebuild complete!
```

#### Example 4: Compile Single Playbook

```bash
make compile-hello-world
```

**Output**:
```
Compiling playbook: hello-world
[INFO] CAPS to Claude Skills Compiler v2.0.0
[SUCCESS] Skill compiled successfully!
```

#### Example 5: List Available Playbooks

```bash
make list
```

**Output**:
```
Available CAPS playbooks:
  - hello-world
  - kafka-k8s-setup
  - postgresql-k8s-setup
  - fastapi-dapr-service
  - minikube-setup
```

### Integration with CI/CD

```bash
# In CI pipeline script
make test  # Validate all playbooks

if [[ $? -eq 0 ]]; then
    make compile  # Compile if validation passes
fi
```

---

## Comparison: Which Integration to Use?

| Integration | Use Case | Automation Level | Scope |
|-------------|----------|------------------|-------|
| **Git Hook** | Pre-commit validation | Per-commit | Modified playbooks only |
| **GitHub Actions** | CI/CD pipeline | Per-push/PR | Modified playbooks + full rebuild |
| **Makefile** | Local development | On-demand | All or specific playbooks |
| **Standalone** | Ad-hoc tasks | Manual | Single playbook |

### Recommended Setup

**For Individual Developers**:
1. Git pre-commit hook (catch errors early)
2. Makefile (quick local testing)

**For Teams**:
1. Git pre-commit hook (prevent bad commits)
2. GitHub Actions (CI/CD automation)
3. Makefile (local development)

**For Production**:
1. GitHub Actions (automated deployment)
2. Separate workflows for staging/production environments

---

## Advanced Integration Patterns

### Pattern 1: Multi-Environment Compilation

```bash
# Makefile target for environment-specific compilation
compile-prod:
	@for dir in $(PLAYBOOKS_DIR)/*/; do \
		playbook=$$(basename $$dir); \
		bash $(COMPILER) $$playbook --validate -o production-skills/; \
	done

compile-staging:
	@for dir in $(PLAYBOOKS_DIR)/*/; do \
		playbook=$$(basename $$dir); \
		bash $(COMPILER) $$playbook --validate -o staging-skills/; \
	done
```

### Pattern 2: Conditional Compilation

```bash
# Only compile if playbook modified in last hour
find caps-library/playbooks/ -name "playbook.md" -mmin -60 -exec \
    bash -c 'playbook=$(dirname {} | xargs basename); bash caps-library/scripts/caps-to-skills.sh $playbook --validate' \;
```

### Pattern 3: Parallel Compilation

```bash
# Compile multiple playbooks in parallel (GNU Parallel)
ls caps-library/playbooks/ | parallel -j4 'bash caps-library/scripts/caps-to-skills.sh {} --validate'
```

---

## Troubleshooting Integration

### Issue: Pre-commit hook not executing

**Cause**: Hook not executable or not in correct location

**Solution**:
```bash
# Verify hook location
ls -la .git/hooks/pre-commit

# Make executable
chmod +x .git/hooks/pre-commit

# Test manually
.git/hooks/pre-commit
```

### Issue: GitHub Actions workflow not triggering

**Cause**: Workflow file syntax error or incorrect paths

**Solution**:
```bash
# Validate YAML syntax
yamllint .github/workflows/caps-compile.yml

# Check workflow logs in GitHub Actions UI
# Verify trigger paths match your repository structure
```

### Issue: Make targets not working

**Cause**: Incorrect paths in Makefile variables

**Solution**:
```bash
# Verify Makefile variables
grep "COMPILER :=" Makefile
grep "PLAYBOOKS_DIR :=" Makefile

# Test with dry-run
make -n compile  # Show commands without executing
```

---

## Next Steps

- **Solve Issues**: [Troubleshooting Guide](07-troubleshooting.md)
- **Advanced Patterns**: [Advanced Usage](08-advanced-usage.md)
- **Command Options**: [Command Reference](05-command-reference.md)

---

**Version**: 1.0.0 | **Compiler Version**: 2.0.0 | **Last Updated**: 2025-12-20
