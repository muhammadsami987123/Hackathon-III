---
title: My First CAPS Playbook
description: Create a simple text file with timestamp and system information
version: 1.0.0
category: example
tags:
  - tutorial
  - beginner
  - filesystem
difficulty: beginner
estimated_time: 5
allowed_tools:
  - bash
prerequisites:
  - bash_4_or_later
  - write_permission_current_directory
---

# My First CAPS Playbook

This playbook guides you through creating a simple text file with system information. It demonstrates the basic structure of a CAPS playbook with sequential steps, validation criteria, and troubleshooting guidance. By the end, you will have created and verified a system information file.

## Prerequisites

Before starting this playbook, ensure the following prerequisites are met:

**Required Software:**
```bash
# Check Bash version
bash --version | head -1
# Expected: GNU bash, version 4.0 or later

# Check write permissions
touch test.txt && rm test.txt && echo "✓ Write permission OK"
# Expected: ✓ Write permission OK
```

**Required Permissions:**
- Write permission in current directory

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

---

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

---

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

## Validation

Success criteria (all must pass):

- [ ] **File Created:** `test -f system-info.txt && echo "PASS" || echo "FAIL"`
- [ ] **Contains Timestamp:** `grep -q "Generated:" system-info.txt && echo "PASS"`
- [ ] **Contains User Info:** `grep -q "User:" system-info.txt && echo "PASS"`
- [ ] **File Readable:** `cat system-info.txt` displays content without errors

**Quick Validation Script:**
```bash
# Run all checks
test -f system-info.txt && \
  grep -q "Generated:" system-info.txt && \
  grep -q "User:" system-info.txt && \
  echo "✅ All validation checks passed!" || \
  echo "❌ Some validation checks failed"
```

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

## Notes & References

**Important Considerations:**
- This is a beginner-friendly playbook for learning CAPS format
- No persistent changes are made if cleanup step is executed
- Safe to run multiple times

**Performance:**
- Estimated execution time: 5 minutes
- Resource usage: Minimal (text file operations only)

**Related Playbooks:**
- `hello-world` - Another beginner example
- `kafka-k8s-setup` - Intermediate Kubernetes deployment
- `postgresql-k8s-setup` - Database setup example

## Version History

<!-- Track playbook evolution -->

| Version | Date       | Changes                          | Author |
|---------|------------|----------------------------------|--------|
| 1.0.0   | 2025-12-19 | Initial playbook                 | Claude |

---

**Compilation:** This playbook compiles to Claude Skills format using:
```bash
bash caps-library/scripts/caps-to-skills.sh <playbook-name> --validate
```

**For authoring guidelines, see**: [`caps-library/docs/best-practices.md`](./best-practices.md)
**For validation errors, see**: [`caps-library/docs/validation-guide.md`](./validation-guide.md)
