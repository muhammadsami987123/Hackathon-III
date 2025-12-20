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
