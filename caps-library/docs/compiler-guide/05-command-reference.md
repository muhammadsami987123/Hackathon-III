# Command Reference

Complete reference for all CAPS-to-Skills compiler command options.

---

## Basic Syntax

```bash
caps-to-skills.sh <playbook-name> [OPTIONS]
```

**Required Argument**:
- `<playbook-name>`: Directory name of playbook in `caps-library/playbooks/`

**Optional Flags**:
- `-h, --help`: Show usage information
- `-o, --output DIR`: Custom output directory
- `-v, --validate`: Run validation checks
- `--dry-run`: Preview without creating files

---

## Command Options

### `--help` (`-h`)

**Purpose**: Display usage information and exit

**Syntax**:
```bash
caps-to-skills.sh --help
caps-to-skills.sh -h
```

**Description**:
Shows command syntax, available options, and usage examples. Exits with code 1 after displaying help (not an error, just convention).

**Use Case**: First time using compiler, forgot option syntax, quick reference

**Example Output**:
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

**Exit Code**: 1 (after displaying help)

---

### `--validate` (`-v`)

**Purpose**: Run comprehensive validation checks before compilation

**Syntax**:
```bash
caps-to-skills.sh <playbook-name> --validate
caps-to-skills.sh <playbook-name> -v
```

**Description**:
Validates playbook structure, required fields, required sections, code block matching, and quality checks. Blocks compilation if errors found. Continues with warnings.

**Validation Checks**:
1. YAML frontmatter structure (matched `---` markers)
2. 5 required fields (title, description, version, allowed_tools, prerequisites)
3. Semver version format (MAJOR.MINOR.PATCH)
4. 4 required sections (Prerequisites, Instructions, Validation, Troubleshooting)
5. Code block matching (even number of ` ``` ` markers)
6. Quality warnings (hardcoded secrets, step numbering, unknown tools)

**Use Case**:
- Before first compilation of new playbook
- After editing playbook to catch errors
- In CI/CD to prevent bad playbooks from merging
- Recommended for all compilations

**Example**:
```bash
# Validate hello-world playbook
bash caps-to-skills.sh hello-world --validate
```

**Example Output (Success)**:
```
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
  ✓ Code blocks matched (6 markers)

[INFO] Checking quality warnings...

[SUCCESS] Validation passed! (0 errors, 0 warnings)
```

**Example Output (Failure)**:
```
[INFO] Running validation checks...
[ERROR] Missing required field: version
[ERROR] Validation failed with 1 errors
```

**Exit Code**:
- 0 (validation passed)
- 1 (validation failed - compilation blocked)

---

### `--dry-run`

**Purpose**: Preview compilation without creating files

**Syntax**:
```bash
caps-to-skills.sh <playbook-name> --dry-run
```

**Description**:
Shows what files would be created without actually writing them. Useful for testing compiler behavior, checking output paths, or verifying playbook discovery.

**Use Case**:
- Test compilation path before committing
- Verify output directory structure
- Check skill name derived from directory
- Safe testing without side effects

**Example**:
```bash
# Dry run for hello-world playbook
bash caps-to-skills.sh hello-world --dry-run
```

**Example Output**:
```
[INFO] CAPS to Claude Skills Compiler v2.0.0
[INFO] ======================================
[INFO] Playbook: hello-world
[INFO] Source: /path/to/caps-library/playbooks/hello-world/playbook.md
[INFO] Output: /path/to/.claude/skills/hello-world/skill.md

[INFO] DRY RUN - No files will be created
[INFO] Would create: /path/to/.claude/skills/hello-world/skill.md
```

**Exit Code**: 0 (always succeeds if playbook found)

**Note**: Dry run does NOT run validation checks unless `--validate` also specified

---

### `--output` (`-o`)

**Purpose**: Specify custom output directory for generated skills

**Syntax**:
```bash
caps-to-skills.sh <playbook-name> --output <directory>
caps-to-skills.sh <playbook-name> -o <directory>
```

**Arguments**:
- `<directory>`: Path to output directory (absolute or relative)

**Default**: `.claude/skills` (relative to project root)

**Description**:
Override default output location. Useful for testing, multiple skill collections, or custom directory structures. Directory created if doesn't exist.

**Use Case**:
- Separate skill collections (development vs production)
- Testing compilation without affecting main skills
- Custom project structure requirements
- Build multiple skill variants

**Example 1**: Custom output directory
```bash
# Output to custom directory
bash caps-to-skills.sh hello-world -o ./custom-skills
```

**Output**:
```
[INFO] Output: ./custom-skills/hello-world/skill.md
[SUCCESS] Skill compiled successfully!
```

**Example 2**: Absolute path
```bash
# Output to absolute path
bash caps-to-skills.sh hello-world -o /tmp/test-skills
```

**Example 3**: Testing directory
```bash
# Compile to test directory
bash caps-to-skills.sh hello-world -o .claude/skills-test
```

**Exit Code**:
- 0 (compilation successful)
- 1 (error: playbook not found, validation failed, write permission denied)

---

## Combining Options

Multiple options can be combined in any order:

### Example 1: Validate + Dry Run

```bash
# Validate playbook structure without creating files
bash caps-to-skills.sh hello-world --validate --dry-run
```

**Use Case**: Test playbook validity before actual compilation

**Output**:
```
[INFO] Running validation checks...
[SUCCESS] Validation passed! (0 errors, 0 warnings)

[INFO] DRY RUN - No files will be created
[INFO] Would create: .claude/skills/hello-world/skill.md
```

---

### Example 2: Validate + Custom Output

```bash
# Validate and compile to custom directory
bash caps-to-skills.sh kafka-k8s-setup --validate -o ./production-skills
```

**Use Case**: Validate before deploying to production skills collection

**Output**:
```
[INFO] Running validation checks...
[SUCCESS] Validation passed! (0 errors, 0 warnings)

[INFO] Created output directory: ./production-skills/kafka-k8s-setup
[SUCCESS] Skill compiled successfully!
[SUCCESS] Output: ./production-skills/kafka-k8s-setup/skill.md
```

---

### Example 3: All Options

```bash
# Validate, custom output, dry run
bash caps-to-skills.sh postgresql-k8s-setup --validate -o /tmp/test --dry-run
```

**Use Case**: Complete pre-flight check before real compilation

**Output**:
```
[INFO] Running validation checks...
[SUCCESS] Validation passed! (0 errors, 0 warnings)

[INFO] DRY RUN - No files will be created
[INFO] Would create: /tmp/test/postgresql-k8s-setup/skill.md
```

---

## Option Reference Table

| Option | Short | Argument | Default | Effect | Exit Code |
|--------|-------|----------|---------|--------|-----------|
| `--help` | `-h` | None | N/A | Display usage and exit | 1 |
| `--validate` | `-v` | None | Off | Run validation checks | 0 (pass), 1 (fail) |
| `--dry-run` | None | None | Off | Preview without writing files | 0 |
| `--output` | `-o` | Directory path | `.claude/skills` | Custom output location | 0 (success), 1 (error) |

---

## Common Usage Patterns

### Pattern 1: Standard Compilation

```bash
# Basic compilation with validation (recommended)
bash caps-to-skills.sh <playbook-name> --validate
```

**When to use**: Default workflow for all compilations

---

### Pattern 2: Batch Compilation

```bash
# Compile multiple playbooks
for playbook in hello-world kafka-k8s-setup postgresql-k8s-setup; do
    bash caps-to-skills.sh $playbook --validate
done
```

**When to use**: Compile all playbooks after bulk updates

---

### Pattern 3: Safe Testing

```bash
# Test compilation without side effects
bash caps-to-skills.sh <playbook-name> --validate --dry-run
```

**When to use**: Verify playbook before committing to repository

---

### Pattern 4: Production Deployment

```bash
# Validate and compile to production directory
bash caps-to-skills.sh <playbook-name> --validate -o /opt/claude/skills
```

**When to use**: Deploy validated skills to production environment

---

## Exit Codes

| Exit Code | Meaning | Trigger |
|-----------|---------|---------|
| 0 | Success | Compilation completed without errors |
| 1 | Error | Playbook not found, validation failed, permission denied, help displayed |

**Note**: `--help` exits with code 1 by convention (not an error condition)

---

## Environment Variables

The compiler does not currently use environment variables. All configuration via command-line options.

**Future Enhancement**: May add support for:
- `CAPS_PLAYBOOKS_DIR`: Override default playbooks directory
- `CAPS_OUTPUT_DIR`: Override default output directory
- `CAPS_VALIDATE`: Always run validation

---

## Next Steps

- **Automate Workflow**: [Workflow Integration](06-workflow-integration.md)
- **Solve Issues**: [Troubleshooting](07-troubleshooting.md)
- **Advanced Patterns**: [Advanced Usage](08-advanced-usage.md)
- **Learn Architecture**: [How It Works](02-architecture.md)

---

**Version**: 1.0.0 | **Compiler Version**: 2.0.0 | **Last Updated**: 2025-12-20
