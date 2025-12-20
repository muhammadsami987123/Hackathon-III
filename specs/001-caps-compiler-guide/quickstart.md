# CAPS-to-Skills Compiler Quickstart

**Goal**: Get from zero to first compiled skill in 15 minutes or less.

**Prerequisites**: bash 4.0+, Unix-like environment (Linux/macOS/WSL)

**Status**: Template - Ready for validation during Phase 5 (User Story 3) implementation

---

## Step 1: Verify Prerequisites (2 minutes)

Check that you have required tools:

```bash
# Check bash version (need 4.0+)
bash --version

# Verify Unix tools present
which find grep sed awk
```

All commands should return paths or version info. If any fail, install missing tools for your OS.

---

## Step 2: Get Compiler (1 minute)

If you forked spec-kit-plus:

```bash
cd spec-kit-plus
ls -la caps-to-skills.sh  # Verify script exists
```

If missing, download or create the script (see Installation guide).

---

## Step 3: Make Executable & Verify (1 minute)

```bash
# Make script executable
chmod +x caps-to-skills.sh

# Test help output
./caps-to-skills.sh --help
```

You should see help message with usage instructions.

---

## Step 4: Setup Directories (1 minute)

```bash
# Create required directories
mkdir -p playbooks
mkdir -p .claude/skills

# Verify structure
ls -la playbooks/
ls -la .claude/skills/
```

---

## Step 5: Create Test Playbook (3 minutes)

Create a simple test playbook:

```bash
mkdir -p playbooks/test/hello
cat > playbooks/test/hello/playbook.md << 'EOF'
---
title: Hello World Test
description: Simple test playbook for compiler validation
version: 1.0.0
allowed_tools:
  - bash
prerequisites:
  - bash_installed
---

# Hello World Test

Simple test playbook.

## Prerequisites

- bash installed

## Instructions

### Step 1: Print Message

```bash
echo "Hello from CAPS playbook!"
```

## Validation

Success criteria:
- [ ] Message printed to console

## Troubleshooting

**Problem**: Command not found
**Solution**: Verify bash is in PATH
EOF
```

---

## Step 6: Validate Playbook (1 minute)

```bash
# Run validation
./caps-to-skills.sh --validate
```

Expected output: `✓ Valid playbook: playbooks/test/hello/playbook.md`

---

## Step 7: Compile to Skill (1 minute)

```bash
# Compile all playbooks
./caps-to-skills.sh
```

Expected output: `✓ Compiled: hello-world-test`

---

## Step 8: Verify Output (2 minutes)

```bash
# Check generated skill
ls -la .claude/skills/hello-world-test/
cat .claude/skills/hello-world-test/skill.md
```

You should see a `skill.md` file with YAML frontmatter and Markdown content.

---

## Step 9: Use Skill with Claude CLI (3 minutes)

If you have Claude CLI installed:

```bash
# List available skills
claude list skills

# Run the skill
claude --skill hello-world-test
```

Claude should execute the skill instructions.

---

## ✅ Success!

You've completed the full cycle:
1. ✅ Prerequisites verified
2. ✅ Compiler installed and tested
3. ✅ Directories created
4. ✅ Test playbook authored
5. ✅ Playbook validated
6. ✅ Skill compiled
7. ✅ Skill output verified
8. ✅ Skill executed with Claude CLI

**Total Time**: ~15 minutes

---

## Next Steps

1. **Understand the Pipeline**: Read [Compiler Architecture](02-architecture.md) to learn how compilation works
2. **Learn All Options**: See [Command Reference](05-command-reference.md) for full capabilities
3. **Automate Your Workflow**: Explore [Workflow Integration](06-workflow-integration.md) for Git hooks and CI/CD
4. **Write Your Own Playbooks**: Apply the CAPS format to your own automation tasks

---

## Troubleshooting

**Problem**: `caps-to-skills.sh: command not found`
**Solution**: Make sure you're in the directory containing the script, or use full path

**Problem**: `playbooks directory not found`
**Solution**: Verify you created `playbooks/` directory in correct location (same dir as script)

**Problem**: Validation fails with "Missing required field"
**Solution**: Check YAML frontmatter has closing `---` and all required fields present

For more issues, see [Troubleshooting Guide](07-troubleshooting.md).

---

**Quickstart Template Complete**: This guide will be validated during Phase 5 (User Story 3) task execution (T056-T066). All bash commands must pass shellcheck validation, and the complete workflow must be tested end-to-end.
