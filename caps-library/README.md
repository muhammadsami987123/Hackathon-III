# CAPS Library - Common Agent Playbook Specification

Welcome to the CAPS Library for Hackathon III: SP Constitution (Spec-Kit Plus)

## Overview

The CAPS (Common Agent Playbook Specification) Library is a collection of reusable, agent-agnostic playbooks that can be compiled to both **Claude Skills** and **Goose Recipes**. This enables the paradigm shift from "write code" to "write playbooks → AI agents write code."

## Directory Structure

```
caps-library/
├── README.md                    # This file
├── playbooks/                   # CAPS playbook source files
│   ├── hello-world/
│   │   ├── playbook.md         # CAPS playbook
│   │   └── README.md           # Playbook-specific docs
│   └── <playbook-name>/
│       ├── playbook.md
│       └── README.md
├── scripts/                     # Compilation scripts
│   ├── caps-to-skills.sh       # CAPS → Claude Skills compiler
│   ├── caps-to-recipes.sh      # CAPS → Goose Recipes compiler
│   └── validate-output.sh      # Output validation script
├── docs/                        # Documentation
│   ├── caps-playbook-template.md  # Starter template for new playbooks
│   ├── best-practices.md          # Authoring guidelines
│   └── validation-guide.md        # Common errors and fixes
└── examples/                    # Example invocations
    └── hello-world-usage.md

Generated outputs:
.claude/skills/                  # Compiled Claude Skills
└── <skill-name>/
    └── skill.md

.goose/recipes/                  # Compiled Goose Recipes
└── <recipe-name>.md
```

## Quick Start

### 1. Create a New CAPS Playbook

```bash
# Create playbook directory
mkdir -p caps-library/playbooks/my-playbook

# Copy template
cp caps-library/docs/caps-playbook-template.md \
   caps-library/playbooks/my-playbook/playbook.md

# Edit the playbook
code caps-library/playbooks/my-playbook/playbook.md
```

### 2. Compile to Claude Skill

```bash
# Compile with validation
bash caps-library/scripts/caps-to-skills.sh my-playbook --validate

# Output: .claude/skills/my-playbook/skill.md
```

### 3. Compile to Goose Recipe

```bash
# Compile with validation
bash caps-library/scripts/caps-to-recipes.sh my-playbook --validate

# Output: .goose/recipes/my-playbook.md
```

### 4. Test with Agents

**Claude Code:**
```bash
# Skills are automatically discovered from .claude/skills/
# Use them directly in Claude Code CLI
```

**Goose:**
```bash
# Recipes are loaded from .goose/recipes/
# Invoke via Goose CLI
```

## CAPS Playbook Structure

Every CAPS playbook MUST include these sections:

### Required Sections

1. **Title & Metadata** - Name, version, author, category
2. **Description** - Brief overview (1-2 sentences)
3. **Prerequisites** - Requirements before execution
4. **Steps** - Sequential execution steps with commands
5. **Validation** - Success verification commands
6. **Troubleshooting** - Common errors and solutions

### Optional Sections

7. **Rollback Procedure** - How to undo changes
8. **Examples** - Real-world usage scenarios
9. **Notes** - Performance, security considerations
10. **References** - Related documentation

## Writing Guidelines

### ✅ DO

- Use clear, imperative language ("Create file", not "We create file")
- Include exact commands with full flags and parameters
- Show expected output for every command
- Provide success criteria for every step
- Document all prerequisites explicitly
- Include troubleshooting for common errors
- Use consistent formatting throughout
- Add version history for tracking changes

### ❌ DON'T

- Use ambiguous instructions ("Run the setup")
- Omit command flags or use shortcuts
- Assume prerequisites are met
- Skip validation steps
- Leave error handling to agents
- Use platform-specific commands without alternatives
- Forget to document rollback procedures

## Compilation Scripts

### caps-to-skills.sh

Compiles CAPS playbooks to Claude CLI Skills format.

**Usage:**
```bash
bash caps-library/scripts/caps-to-skills.sh <playbook-name> [options]

Options:
  -h, --help           Show help message
  -o, --output DIR     Output directory (default: .claude/skills)
  -v, --validate       Validate output after compilation
  --dry-run            Show what would be done

Examples:
  bash caps-library/scripts/caps-to-skills.sh hello-world
  bash caps-library/scripts/caps-to-skills.sh deploy-k8s --validate
```

### caps-to-recipes.sh

Compiles CAPS playbooks to Goose Recipes format.

**Usage:**
```bash
bash caps-library/scripts/caps-to-recipes.sh <playbook-name> [options]

Options:
  -h, --help           Show help message
  -o, --output DIR     Output directory (default: .goose/recipes)
  -v, --validate       Validate output after compilation
  --dry-run            Show what would be done

Examples:
  bash caps-library/scripts/caps-to-recipes.sh hello-world
  bash caps-library/scripts/caps-to-recipes.sh deploy-k8s --validate
```

## Validation & Testing

### Automated Validation

The compilation script includes built-in validation to catch errors early:

```bash
# Compile with validation (recommended)
bash caps-library/scripts/caps-to-skills.sh <playbook-name> --validate
```

**What Gets Validated**:

**Critical Errors** (Block Compilation):
- ✅ Required YAML frontmatter fields (`title`, `description`, `version`, `allowed_tools`, `prerequisites`)
- ✅ Valid YAML syntax (colons, indentation, quotes)
- ✅ Required markdown sections (`## Prerequisites`, `## Instructions`, `## Validation`, `## Troubleshooting`)
- ✅ Matched code block markers (even number of ` ``` `)

**Quality Warnings** (Allow Compilation):
- ⚠️ Hardcoded secrets (pattern: `password|apikey|token|secret`)
- ⚠️ Non-consecutive step numbering (Step 1, Step 3)
- ⚠️ Unknown tools (not in whitelist: bash, kubectl, helm, docker, git, python, npm, curl, etc.)
- ⚠️ Untestable prerequisites (vague/subjective conditions)

**For detailed error fixes, see**: [`docs/validation-guide.md`](./docs/validation-guide.md)

### Pre-Compilation Validation

Before compiling, ensure your playbook:

- [ ] Has all 5 required YAML fields (title, description, version, allowed_tools, prerequisites)
- [ ] Has all 4 required sections (Prerequisites, Instructions, Validation, Troubleshooting)
- [ ] Uses ` ```bash ` for all command blocks
- [ ] Has matched code block markers (count with: `grep -c '^```' playbook.md`)
- [ ] Includes success criteria for each step
- [ ] Documents all prerequisites with verification commands
- [ ] Provides troubleshooting for common errors

**Quick Validation Checklist**:
```bash
# Check required fields exist
grep "^title:\|^description:\|^version:\|^allowed_tools:\|^prerequisites:" playbook.md

# Check required sections exist
grep "^## Prerequisites\|^## Instructions\|^## Validation\|^## Troubleshooting" playbook.md

# Count code blocks (should be even)
grep -c '^```' playbook.md

# Look for potential hardcoded secrets
grep -i "password\|apikey\|token\|secret" playbook.md
```

### Post-Compilation Testing

After compiling:

```bash
# 1. Verify output files exist
ls -la .claude/skills/<playbook-name>/skill.md
ls -la .goose/recipes/<playbook-name>.md

# 2. Check file content
cat .claude/skills/<playbook-name>/skill.md

# 3. Verify YAML frontmatter and sections
head -10 .claude/skills/<playbook-name>/skill.md  # Check YAML
grep "^## " .claude/skills/<playbook-name>/skill.md  # Check sections

# 4. Test with actual agents
# - Claude: Use the skill in Claude Code CLI
# - Goose: Invoke via Goose CLI

# 5. Refine playbook based on results
# - Document failures in Troubleshooting section
# - Update Steps with more clarity
# - Re-compile and re-test
```

### Common Validation Errors & Fixes

**Error**: `Missing required field: title`
**Fix**: Add to YAML frontmatter:
```yaml
---
title: Your Playbook Title
```

**Error**: `Missing required section: ## Prerequisites`
**Fix**: Add section with ## heading:
```markdown
## Prerequisites

Before starting, verify:
```bash
# Verification commands here
```
```

**Error**: `Unmatched code block markers (found 7)`
**Fix**: Every ` ``` ` opening must have matching ` ``` ` closing. Count and fix.

**For complete error reference**: See [`docs/validation-guide.md`](./docs/validation-guide.md)

## Examples

### Example 1: Hello World Playbook

See: `caps-library/playbooks/hello-world/playbook.md`

A complete example demonstrating:
- Basic CAPS structure
- Script creation and execution
- Validation and troubleshooting
- Cleanup procedures

**Try it:**
```bash
# Compile to both formats
bash caps-library/scripts/caps-to-skills.sh hello-world --validate
bash caps-library/scripts/caps-to-recipes.sh hello-world --validate

# Review outputs
cat .claude/skills/hello-world/skill.md
cat .goose/recipes/hello-world.md
```

## Best Practices

### 1. Start Simple, Iterate

- Begin with minimal viable playbook
- Test with real agents
- Document failures
- Refine instructions
- Target: <5% manual fixes to AI-generated code

### 2. Make Commands Copy-Pastable

```bash
# ✅ GOOD - Complete, exact command
kubectl apply -f manifests/deployment.yaml --namespace production

# ❌ BAD - Ambiguous
kubectl apply the deployment
```

### 3. Include Expected Outputs

```bash
# ✅ GOOD - Shows what success looks like
kubectl get pods
# Expected:
# NAME                     READY   STATUS    RESTARTS   AGE
# my-app-7d8f5b9c-xyz      1/1     Running   0          2m

# ❌ BAD - No expected output shown
kubectl get pods
```

### 4. Document Error Cases

```bash
# If you see: "Error: ImagePullBackOff"
# Cause: Container image not found
# Fix: Check image name in deployment.yaml
kubectl describe pod <pod-name>
```

### 5. Zero Tolerance for Ambiguity

Every instruction must be AI-executable without human interpretation.

## Playbook Categories

Organize playbooks by category:

- `infrastructure/` - K8s, Kafka, PostgreSQL setup
- `deployment/` - Application deployment workflows
- `development/` - Dev environment setup
- `testing/` - Test execution and validation
- `documentation/` - Doc generation workflows
- `utilities/` - General-purpose tools

## Version Control

### Playbook Versioning

Use semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR** - Breaking changes to playbook structure
- **MINOR** - New steps or significant updates
- **PATCH** - Bug fixes, clarifications

### Git Commit Pattern

```bash
# For CAPS playbooks
git commit -m "CAPS: add hello-world playbook v1.0.0"

# For compiled outputs
git commit -m "Claude: compiled hello-world to skill"
```

## CI/CD Integration

### GitHub Actions Workflow

Validate all playbooks on commit:

```yaml
name: CAPS Validation
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Compile all playbooks
        run: |
          for playbook in caps-library/playbooks/*/; do
            name=$(basename "$playbook")
            bash caps-library/scripts/caps-to-skills.sh "$name" --validate
            bash caps-library/scripts/caps-to-recipes.sh "$name" --validate
          done
```

## Troubleshooting

### Compilation Fails

**Error:** `Playbook file not found`

**Solution:**
```bash
# Check playbook exists
ls caps-library/playbooks/<name>/playbook.md

# Ensure correct directory structure
# Expected: caps-library/playbooks/<name>/playbook.md
```

### Validation Fails

**Error:** `Validation warning: No YAML frontmatter found`

**Solution:**
Ensure your playbook starts with metadata:
```markdown
# Playbook Title

Version: 1.0.0
```

### Output File Empty

**Error:** `Validation failed: Output file is empty`

**Solution:**
- Check playbook has content in Steps section
- Ensure proper markdown formatting
- Verify no syntax errors in playbook.md

## Quick Reference

### Common Compilation Commands

```bash
# Basic compilation
bash caps-library/scripts/caps-to-skills.sh <playbook-name>

# With validation (recommended)
bash caps-library/scripts/caps-to-skills.sh <playbook-name> --validate

# Dry-run (show what would be done)
bash caps-library/scripts/caps-to-skills.sh <playbook-name> --dry-run

# Custom output directory
bash caps-library/scripts/caps-to-skills.sh <playbook-name> --output /custom/path

# Compile all playbooks
for playbook in caps-library/playbooks/*/; do
  name=$(basename "$playbook")
  bash caps-library/scripts/caps-to-skills.sh "$name" --validate
done
```

### Quick Validation Checks

```bash
# Check playbook exists
ls caps-library/playbooks/<playbook-name>/playbook.md

# Validate YAML frontmatter fields
grep "^title:\|^description:\|^version:\|^allowed_tools:\|^prerequisites:" playbook.md

# Validate required sections
grep "^## Prerequisites\|^## Instructions\|^## Validation\|^## Troubleshooting" playbook.md

# Count code blocks (should be even)
grep -c '^```' playbook.md

# Check for hardcoded secrets
grep -Ei "password|apikey|token|secret" playbook.md
```

### Troubleshooting Tips

| Issue | Quick Fix |
|-------|-----------|
| Compilation fails | Check error message, see [validation-guide.md](./docs/validation-guide.md) |
| Missing required field | Add field to YAML frontmatter |
| Missing section | Add `## SectionName` heading |
| Unmatched code blocks | Count ` ``` ` markers (must be even) |
| Validation warnings | Review but don't block (warnings are informational) |
| Output file empty | Check playbook has content in Steps section |

## Resources

### Documentation

- **CAPS Template**: [`caps-library/docs/caps-playbook-template.md`](./docs/caps-playbook-template.md) - Starter template
- **Best Practices**: [`caps-library/docs/best-practices.md`](./docs/best-practices.md) - Authoring guidelines
- **Validation Guide**: [`caps-library/docs/validation-guide.md`](./docs/validation-guide.md) - Common errors and fixes
- **Quickstart Guide**: [`specs/001-caps-format-spec/quickstart.md`](../specs/001-caps-format-spec/quickstart.md) - Author your first playbook in 15 min
- **Constitution**: [`.specify/memory/constitution.md`](../.specify/memory/constitution.md) - Project principles
- **Claude CLI**: [`CLAUDE.md`](../CLAUDE.md) - Claude Code rules
- **MCP Code Execution Pattern**: [`caps-library/docs/mcp-code-execution/README.md`](./docs/mcp-code-execution/README.md) - Build token-efficient skills (99% reduction)

### External Links

- [Claude Code Documentation](https://claude.com/claude-code)
- [Goose Documentation](https://github.com/square/goose)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## Contributing

### Creating a New Playbook

1. Fork/branch from `main`
2. Create playbook directory: `caps-library/playbooks/<name>/`
3. Write playbook using template
4. Compile to both Skills and Recipes
5. Test with actual agents (Claude AND Goose)
6. Document results in playbook
7. Submit PR with both playbook and compiled outputs

### Review Checklist

Before submitting:

- [ ] CAPS playbook compiles to both Skills and Recipes
- [ ] Generated outputs are syntactically valid
- [ ] Tested with Claude Code CLI
- [ ] Tested with Goose (if available)
- [ ] All troubleshooting scenarios documented
- [ ] Version history updated
- [ ] README.md in playbook directory

## Support

For issues or questions:

1. Check documentation: `caps-library/docs/`
2. Review examples: `caps-library/playbooks/hello-world/`
3. Consult constitution: `.specify/memory/constitution.md`
4. Ask in project channels

---

**Version:** 1.0.0
**Last Updated:** 2025-12-19
**Maintained By:** Hackathon III Team
