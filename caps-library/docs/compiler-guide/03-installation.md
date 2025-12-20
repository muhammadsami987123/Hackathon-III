# Installation

## Prerequisites

Before installing the CAPS-to-Skills compiler, ensure your system meets these requirements:

### System Requirements

| Requirement | Minimum Version | Verification Command |
|-------------|-----------------|---------------------|
| **bash** | 4.0+ | `bash --version` |
| **find** | GNU findutils | `find --version` |
| **grep** | GNU grep | `grep --version` |
| **sed** | GNU sed | `sed --version` |
| **awk** | GNU awk (gawk) | `awk --version` |

### Verify Prerequisites

Run these commands to check your system:

```bash
# Check bash version (need 4.0+)
bash --version

# Verify Unix tools are available
which find grep sed awk

# All commands should return paths or version info
# If any fail, install missing tools for your OS
```

**Expected Output**:
```
GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)
/usr/bin/find
/usr/bin/grep
/usr/bin/sed
/usr/bin/awk
```

### Operating System Support

| OS | Status | Notes |
|----|--------|-------|
| **Linux** | ✅ Fully supported | Ubuntu, Debian, Fedora, CentOS, Arch |
| **macOS** | ✅ Fully supported | bash 4.0+ may need installation via Homebrew |
| **Windows WSL** | ✅ Fully supported | Use WSL2 with Ubuntu or Debian |
| **Windows (Git Bash)** | ✅ Supported | Included with Git for Windows |
| **Windows (native)** | ❌ Not supported | Use WSL2 instead |

---

## Step-by-Step Setup

### Step 1: Locate the Compiler Script

The compiler script is included in the CAPS library:

```bash
# Navigate to your project root
cd /path/to/your/project

# Verify script exists
ls -la caps-library/scripts/caps-to-skills.sh
```

**Expected Output**:
```
-rwxr-xr-x 1 user group 8945 Dec 20 10:30 caps-library/scripts/caps-to-skills.sh
```

If the file doesn't exist, check that you've cloned the complete repository including the `caps-library/` directory.

---

### Step 2: Make Script Executable

Ensure the script has execute permissions:

```bash
# Make executable
chmod +x caps-library/scripts/caps-to-skills.sh

# Verify permissions
ls -la caps-library/scripts/caps-to-skills.sh
```

**Expected Output**: First column should show `-rwxr-xr-x` (note the `x` flags for execute permission)

---

### Step 3: Verify Directory Structure

The compiler expects a specific directory structure:

```
project-root/
├── caps-library/
│   ├── scripts/
│   │   └── caps-to-skills.sh          # Compiler script
│   └── playbooks/
│       └── <playbook-name>/
│           └── playbook.md             # Your CAPS playbooks
└── .claude/
    └── skills/
        └── <skill-name>/
            └── skill.md                 # Generated skills (created by compiler)
```

**Create Required Directories**:

```bash
# Create playbooks directory (if not exists)
mkdir -p caps-library/playbooks

# Create skills output directory (if not exists)
mkdir -p .claude/skills

# Verify structure
ls -la caps-library/
ls -la .claude/
```

**Expected Output**:
```
drwxr-xr-x ... caps-library/
drwxr-xr-x ... caps-library/scripts/
drwxr-xr-x ... caps-library/playbooks/
drwxr-xr-x ... .claude/
drwxr-xr-x ... .claude/skills/
```

---

### Step 4: Test Installation

Verify the compiler works by running the help command:

```bash
# Run help command
cd caps-library/scripts
bash caps-to-skills.sh --help
```

**Expected Output**:
```
Usage: caps-to-skills.sh <playbook-name> [options]

Compiles a CAPS playbook to Claude CLI Skill format

Options:
  -h, --help           Show this help message
  -o, --output DIR     Output directory (default: .claude/skills)
  -v, --validate       Run validation checks (recommended)
  --dry-run            Show what would be done without doing it

Examples:
  caps-to-skills.sh hello-world
  caps-to-skills.sh deploy-k8s --validate
  caps-to-skills.sh fastapi-service -o .claude/skills --validate
```

If you see this output, installation is successful!

---

### Step 5: Create Test Playbook (Optional)

Create a simple test playbook to verify end-to-end compilation:

```bash
# Create test playbook directory
mkdir -p ../../caps-library/playbooks/test-hello

# Create playbook file
cat > ../../caps-library/playbooks/test-hello/playbook.md << 'EOF'
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

Simple test playbook to verify CAPS-to-Skills compiler installation.

## Prerequisites

- bash 4.0+ installed
- Write access to `.claude/skills/` directory

## Instructions

### Step 1: Print Message

```bash
# Print hello message
echo "Hello from CAPS playbook!"
```

### Step 2: Verify Environment

```bash
# Check bash version
bash --version | head -1
```

## Validation

Success criteria:
- [ ] Message printed to console
- [ ] Bash version displayed
- [ ] No error messages

## Troubleshooting

**Problem**: Command not found
**Solution**: Verify bash is in PATH with `which bash`

**Problem**: Permission denied
**Solution**: Ensure write permissions on output directory
EOF
```

Alternatively, copy the test playbook from the examples:
- [test-playbook.md](assets/examples/test-playbook.md)

---

### Step 6: Compile Test Playbook

Test the compilation process:

```bash
# Compile with validation
bash caps-to-skills.sh test-hello --validate

# Or compile without validation
bash caps-to-skills.sh test-hello
```

**Expected Output**:
```
[INFO] CAPS to Claude Skills Compiler v2.0.0
[INFO] ======================================
[INFO] Playbook: test-hello
[INFO] Source: /path/to/caps-library/playbooks/test-hello/playbook.md
[INFO] Output: /path/to/.claude/skills/test-hello/skill.md

[INFO] Running validation checks...

[INFO] Validating required fields...
  ✓ Field 'title' present
  ✓ Field 'description' present
  ✓ Field 'version' present
  ✓ Field 'allowed_tools' present
  ✓ Field 'prerequisites' present
  ✓ Version format valid: 1.0.0

[INFO] Validating required sections...
  ✓ Section '## Prerequisites' present
  ✓ Section '## Instructions' present
  ✓ Section '## Validation' present
  ✓ Section '## Troubleshooting' present

[INFO] Validating code blocks...
  ✓ Code blocks matched (4 markers)

[INFO] Checking quality warnings...

[SUCCESS] Validation passed! (0 errors, 0 warnings)

[INFO] Created output directory: /path/to/.claude/skills/test-hello
[INFO] Reading CAPS playbook...
[INFO] Skill Name: test-hello (from directory)
[INFO] Title: Hello World Test
[INFO] Description: Simple test playbook for compiler validation
[INFO] Version: 1.0.0
[INFO] Generating Claude Skill...
[SUCCESS] Skill compiled successfully!
[SUCCESS] Output: /path/to/.claude/skills/test-hello/skill.md

[INFO] Next steps:
[INFO] 1. Review the generated skill: cat /path/to/.claude/skills/test-hello/skill.md
[INFO] 2. Test with Claude Code CLI
[INFO] 3. Refine CAPS playbook if needed
[INFO] 4. Commit both playbook and skill to git
```

---

### Step 7: Verify Output

Check that the skill was generated correctly:

```bash
# Navigate back to project root
cd ../..

# View generated skill
cat .claude/skills/test-hello/skill.md
```

**Expected Output**: A markdown file with:
- YAML frontmatter (description, version)
- H1 title
- Prerequisites section
- Instructions with code blocks
- Validation section
- Troubleshooting section
- Metadata footer (source playbook path, compilation timestamp, skill name)

---

## Installation Complete! ✅

You're now ready to:
1. **Compile your own playbooks**: See [Quick Start](04-quickstart.md)
2. **Understand all options**: See [Command Reference](05-command-reference.md)
3. **Automate your workflow**: See [Workflow Integration](06-workflow-integration.md)

---

## Troubleshooting Installation

### Issue: "bash: ./caps-to-skills.sh: Permission denied"

**Cause**: Script doesn't have execute permissions

**Solution**:
```bash
chmod +x caps-library/scripts/caps-to-skills.sh
```

---

### Issue: "Playbooks directory not found"

**Cause**: Missing `caps-library/playbooks/` directory

**Solution**:
```bash
mkdir -p caps-library/playbooks
```

---

### Issue: "bash: caps-to-skills.sh: command not found"

**Cause**: Not running from correct directory or script not in PATH

**Solution**:
```bash
# Option 1: Run from scripts directory
cd caps-library/scripts
bash caps-to-skills.sh <playbook-name>

# Option 2: Use full path
bash /full/path/to/caps-library/scripts/caps-to-skills.sh <playbook-name>
```

---

### Issue: bash version too old (< 4.0)

**Cause**: System has bash 3.x installed

**Solution**:

**On macOS**:
```bash
# Install bash 5.x via Homebrew
brew install bash

# Verify version
/usr/local/bin/bash --version
```

**On Linux** (if outdated):
```bash
# Update bash via package manager
sudo apt update && sudo apt install bash  # Debian/Ubuntu
sudo yum update bash                      # CentOS/RHEL
```

---

### Issue: "sed: invalid option" or "awk: unknown option"

**Cause**: Non-GNU versions of sed/awk (common on macOS)

**Solution on macOS**:
```bash
# Install GNU versions via Homebrew
brew install gnu-sed gawk

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
```

---

## Next Steps

- **Quick Start**: [Compile your first playbook in 15 minutes](04-quickstart.md)
- **Command Reference**: [Learn all compiler options](05-command-reference.md)
- **Architecture**: [Understand how compilation works](02-architecture.md)

---

**Version**: 1.0.0 | **Compiler Version**: 2.0.0 | **Last Updated**: 2025-12-20
