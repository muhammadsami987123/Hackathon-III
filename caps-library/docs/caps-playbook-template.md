# [Playbook Title]

**CAPS Playbook Template**
Version: 1.0.0

## Description

[Brief description of what this playbook does - 1-2 sentences]

## Metadata

- **Version:** 1.0.0
- **Author:** [Agent/Team Name]
- **Created:** [YYYY-MM-DD]
- **Last Updated:** [YYYY-MM-DD]
- **Category:** [infrastructure/deployment/development/testing/other]
- **Allowed Tools:** [bash, kubectl, docker, npm, etc.]

## Prerequisites

List all prerequisites that must be satisfied before executing this playbook:

- [ ] Prerequisite 1 (e.g., Minikube running)
- [ ] Prerequisite 2 (e.g., kubectl configured)
- [ ] Prerequisite 3 (e.g., Required environment variables set)
- [ ] Prerequisite 4 (e.g., Specific packages installed)

### Required Environment

- **Operating System:** [Linux/macOS/Windows/Any]
- **Required Software:**
  - Tool 1 (version X.Y.Z+)
  - Tool 2 (version X.Y.Z+)
- **Required Permissions:** [sudo/admin/regular user]

### Required Files/Directories

- `/path/to/required/file`
- `/path/to/required/directory/`

## Steps

### Step 1: [Action Name]

**Objective:** [What this step accomplishes]

**Commands:**
```bash
# Command 1 with explanation
command --flag value

# Command 2 with explanation
another-command
```

**Expected Output:**
```
Sample expected output here
```

**Success Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2

---

### Step 2: [Action Name]

**Objective:** [What this step accomplishes]

**Commands:**
```bash
# Commands for step 2
```

**Expected Output:**
```
Expected output
```

**Success Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2

---

### Step 3: [Action Name]

**Objective:** [What this step accomplishes]

**Commands:**
```bash
# Commands for step 3
```

**Expected Output:**
```
Expected output
```

**Success Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2

---

[Add more steps as needed...]

## Validation

### Automated Validation

Run these commands to verify successful execution:

```bash
# Validation command 1
validation-command-1

# Validation command 2
validation-command-2
```

### Manual Verification Checklist

- [ ] Verification item 1
- [ ] Verification item 2
- [ ] Verification item 3

### Success Indicators

List observable indicators that the playbook executed successfully:

1. Indicator 1 (e.g., Pod is running)
2. Indicator 2 (e.g., Service is accessible on port X)
3. Indicator 3 (e.g., Logs show successful startup)

## Troubleshooting

### Common Error 1: [Error Name]

**Symptom:**
```
Error message or symptom description
```

**Root Cause:**
[Explanation of what causes this error]

**Solution:**
```bash
# Commands to fix the issue
fix-command
```

---

### Common Error 2: [Error Name]

**Symptom:**
```
Error message or symptom description
```

**Root Cause:**
[Explanation of what causes this error]

**Solution:**
```bash
# Commands to fix the issue
fix-command
```

---

### Common Error 3: [Error Name]

**Symptom:**
```
Error message or symptom description
```

**Root Cause:**
[Explanation of what causes this error]

**Solution:**
```bash
# Commands to fix the issue
fix-command
```

## Rollback Procedure

If something goes wrong, follow these steps to rollback:

### Step 1: [Rollback Action]
```bash
# Rollback command
```

### Step 2: [Rollback Action]
```bash
# Rollback command
```

### Step 3: Verify Rollback
```bash
# Verification command
```

## Notes

### Important Considerations

- Note 1
- Note 2
- Note 3

### Performance Impact

- Expected execution time: [X minutes]
- Resource requirements: [CPU/Memory/Disk]
- Network bandwidth: [if applicable]

### Security Considerations

- Security note 1
- Security note 2

## Examples

### Example 1: [Use Case Name]

**Scenario:** [Description]

**Commands:**
```bash
# Example commands
```

**Result:**
```
Expected outcome
```

---

### Example 2: [Use Case Name]

**Scenario:** [Description]

**Commands:**
```bash
# Example commands
```

**Result:**
```
Expected outcome
```

## References

- [Related documentation link 1]
- [Related documentation link 2]
- [External resource link 3]

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0.0 | YYYY-MM-DD | Initial playbook | [Name] |

## CAPS Compliance

This playbook conforms to CAPS (Common Agent Playbook Specification) format and can be compiled to:
- Claude Skills (`.claude/skills/`)
- Goose Recipes (`.goose/recipes/`)

**Compilation Commands:**
```bash
# Compile to Claude Skill
bash caps-library/scripts/caps-to-skills.sh [playbook-name] --validate

# Compile to Goose Recipe
bash caps-library/scripts/caps-to-recipes.sh [playbook-name] --validate
```
