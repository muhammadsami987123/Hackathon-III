# Data Model: CAPS Format Specification

**Feature**: CAPS Format Specification and Compilation Infrastructure
**Phase**: Phase 1
**Date**: 2025-12-19

## Overview

This document defines the data structures and relationships for the CAPS (Coding Agent Playbook Specification) format and compilation system. Since this is a file-based transformation system (not a database-backed application), the "data model" describes the structure of markdown files, YAML frontmatter, and in-memory representations during compilation.

## Entity Definitions

### 1. CAPS Playbook (Source Format)

A CAPS Playbook is a markdown file with YAML frontmatter that represents a reusable workflow for AI agents to execute autonomously.

**File Location**: `caps-library/playbooks/<playbook-name>/playbook.md`

**Structure**:

```markdown
---
[YAML Frontmatter]
---

# [Title]

[Markdown Content Sections]
```

#### YAML Frontmatter Fields

| Field | Type | Required | Description | Example | Validation |
|-------|------|----------|-------------|---------|------------|
| `title` | string | ✅ Required | Human-readable playbook name | "Kafka Kubernetes Setup" | 3-80 chars |
| `description` | string | ✅ Required | One-sentence summary | "Deploy Apache Kafka on Kubernetes using Helm" | 10-300 chars |
| `version` | string | ✅ Required | Semantic version | "1.0.0" | MAJOR.MINOR.PATCH format |
| `category` | string | ⚠️ Recommended | Playbook domain | "infrastructure" | Enum: infrastructure/backend/frontend/tools/deployment/integration/testing/database |
| `tags` | array[string] | ⚠️ Recommended | Searchable keywords | ["kafka", "kubernetes", "helm"] | 3-8 tags, lowercase-hyphenated |
| `difficulty` | string | ⚠️ Recommended | Complexity level | "intermediate" | Enum: beginner/intermediate/advanced/expert |
| `estimated_time` | integer | ⚠️ Recommended | Minutes to complete | 15 | Realistic wall-clock time including waits |
| `allowed_tools` | array[string] | ✅ Required | Tools used in playbook | ["kubectl", "helm", "bash"] | Common tools: bash, kubectl, helm, docker, git, python, npm, curl |
| `prerequisites` | array[string] | ✅ Required | Testable conditions | ["kubernetes_cluster_running", "helm_installed"] | Snake_case format, testable via commands |
| `dependencies` | array[string] | Optional | Other playbooks to run first | ["namespace-setup", "helm-repo-setup"] | Playbook names (not paths), direct deps only |
| `skip_conditions` | array[string] | Optional | Conditions to skip playbook | ["kafka_already_deployed"] | Testable via bash/kubectl commands |

#### Markdown Content Sections

| Section | Required | Description | Format |
|---------|----------|-------------|--------|
| `## Prerequisites` | ✅ Required | Human-readable prerequisites with verification commands | Prose + bash code blocks |
| `## Instructions` | ✅ Required | Sequential execution steps | Numbered subsections (### Step N: Title) |
| `### Step N: [Title]` | ✅ Required (multiple) | Individual action with objective, commands, output, validation | **Objective**, ```bash code```, **Expected Output**, **Success Criteria** |
| `## Validation` | ✅ Required | Success criteria as checklist | Markdown checklist items with verification commands |
| `## Troubleshooting` | ✅ Required | Common error documentation | Problem/Symptoms/Root Cause/Check/Fix entries |
| `## Notes & References` | Optional | Additional context | Prose + links |
| `## Rollback Instructions` | Optional | Undo procedure | Numbered steps with bash commands |
| `## Next Steps` | Optional | Post-completion actions | Bulleted list |

**Example**:

```yaml
---
title: Hello World CAPS Playbook
description: A simple CAPS playbook demonstrating the basic structure and compilation workflow
version: 1.0.0
category: example
tags: [documentation, automation, agents]
difficulty: beginner
estimated_time: 10
allowed_tools:
  - bash
prerequisites:
  - bash_4_or_later
  - git_repository_initialized
skip_conditions:
  - agents_md_already_exists
---

# Hello World CAPS Playbook

A simple CAPS playbook demonstrating basic structure.

## Prerequisites

Before starting, verify:
- Bash version: `bash --version | head -1`
- Git repository: `git status`

## Instructions

### Step 1: Create Hello World Script

**Objective:** Create a simple bash script

```bash
cat > hello.sh <<'EOF'
#!/bin/bash
echo "Hello World from CAPS!"
EOF
chmod +x hello.sh
```

**Expected Output:**
```
(No output - files created silently)
```

**Success Criteria:**
- [ ] hello.sh file exists
- [ ] hello.sh has executable permissions

[... more steps ...]

## Validation

Success criteria (all must pass):
- [ ] **File Exists:** `ls hello.sh` shows no error
- [ ] **Executable:** `test -x hello.sh && echo "✓ Executable"`
- [ ] **Output Correct:** `./hello.sh | grep -q "Hello World"`

## Troubleshooting

**Problem:** Permission denied when executing
**Symptoms:** `bash: ./hello.sh: Permission denied`
**Root Cause:** Script not made executable
**Check:** `ls -la hello.sh`
**Fix:**
```bash
chmod +x hello.sh
```
```

---

### 2. Claude Skill (Compiled Format)

A Claude Skill is the compiled output from a CAPS Playbook, formatted for Claude CLI discovery and execution.

**File Location**: `.claude/skills/<skill-name>/skill.md`

**Skill Name**: Same as playbook directory name (lowercase, hyphenated, 3-50 chars)

**Structure**:

```markdown
---
[YAML Frontmatter]
---

# [Title]

[Intro Paragraph]

[Markdown Content Sections]

---

[Metadata Footer]
```

#### YAML Frontmatter Fields

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| `description` | string | CAPS `description` | One-sentence summary |
| `version` | string | CAPS `version` | Semantic version |

**Note**: Minimal frontmatter. Claude CLI uses description for skill discovery. Other CAPS metadata (category, tags, difficulty) not included in skill frontmatter but preserved in source playbook for documentation.

#### Markdown Content Sections

| Section | Source | Notes |
|---------|--------|-------|
| `# {title}` | CAPS `title` | H1 heading |
| Intro paragraph | CAPS `description` | Expanded to full sentence |
| `## Prerequisites` | CAPS `## Prerequisites` | Copied verbatim |
| `## Instructions` | CAPS `## Instructions` | Copied verbatim with all steps |
| `## Validation` | CAPS `## Validation` | Copied verbatim |
| `## Troubleshooting` | CAPS `## Troubleshooting` | Copied verbatim |
| `## Next Steps` | CAPS `## Next Steps` | Copied if present (optional) |

#### Metadata Footer (Auto-generated)

```markdown
---

**Source Playbook:** `caps-library/playbooks/<playbook-name>/playbook.md`
**Compiled:** 2025-12-19 18:56:23 UTC
**CAPS Version:** 1.0.0
```

**Example**:

```yaml
---
description: A simple CAPS playbook demonstrating the basic structure and compilation workflow
version: 1.0.0
---

# Hello World CAPS Playbook

A simple CAPS playbook demonstrating the basic structure and compilation workflow.

## Prerequisites

Before starting, verify:
- Bash version: `bash --version | head -1`
- Git repository: `git status`

[... content copied verbatim from CAPS playbook ...]

---

**Source Playbook:** `caps-library/playbooks/hello-world/playbook.md`
**Compiled:** 2025-12-19 18:56:23 UTC
**CAPS Version:** 1.0.0
```

---

### 3. Playbook Step (Instruction Unit)

A Playbook Step is a subsection within the `## Instructions` section of a CAPS Playbook.

**Format**: `### Step N: [Action Name]`

**Attributes**:

| Attribute | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `step_number` | integer | ✅ Required | Sequential number (1, 2, 3, ...) | 1 |
| `title` | string | ✅ Required | Action name | "Create Hello World Script" |
| `objective` | string | ✅ Required | What this step accomplishes | "Create a simple bash script that prints greeting" |
| `commands` | code block | ✅ Required | Bash commands to execute | ` ```bash\ncat > hello.sh <<EOF\n...` |
| `expected_output` | code block | ⚠️ Recommended | Sample output | ` ```\n(No output - files created silently)\n``` ` |
| `success_criteria` | checklist | ✅ Required | Verification items | `- [ ] hello.sh file exists` |

**Relationship**: Belongs to one CAPS Playbook, ordered sequentially

**Validation Rules**:
- Step numbers MUST be consecutive (1, 2, 3 with no gaps) - warning if violated
- Each step MUST have objective, commands, and success criteria
- Commands MUST be in ` ```bash ` code blocks

**Example**:

```markdown
### Step 2: Verify Script Creation

**Objective:** Verify that the script was created successfully with correct content

**Commands:**
```bash
# Check if file exists
ls -la hello.sh

# Display script content
echo "Script content:"
cat hello.sh
```

**Expected Output:**
```
-rwxr-xr-x 1 user group 245 Dec 19 18:00 hello.sh
Script content:
#!/bin/bash
echo "Hello World from CAPS!"
```

**Success Criteria:**
- [ ] File exists with executable permissions (-rwx)
- [ ] File contains expected content
```

---

### 4. Troubleshooting Entry (Error Documentation)

A Troubleshooting Entry documents a known error case within the `## Troubleshooting` section.

**Attributes**:

| Attribute | Type | Required | Description | Example |
|-----------|------|----------|-------------|---------|
| `problem_name` | string | ✅ Required | Brief problem title | "Permission denied when executing" |
| `symptoms` | code block / prose | ✅ Required | Observable error messages | ` ```bash: ./hello.sh: Permission denied``` ` |
| `root_cause` | string | ✅ Required | Explanation of why error occurs | "Script was not made executable" |
| `check_commands` | code block | ⚠️ Recommended | Diagnostic commands | ` ```bash\nls -la hello.sh\n``` ` |
| `fix_commands` | code block | ✅ Required | Resolution commands | ` ```bash\nchmod +x hello.sh\n``` ` |

**Relationship**: Belongs to one CAPS Playbook, multiple entries per playbook (typically 2-4)

**Format Pattern**:

```markdown
**Problem:** [Problem Name]
**Symptoms:** [Error message or observable behavior]
**Root Cause:** [Explanation]
**Check:**
```bash
[Diagnostic commands]
```
**Fix:**
```bash
[Resolution commands]
```
```

**Example**:

```markdown
**Problem:** Pods stuck in Pending state
**Symptoms:** `kubectl get pods -n kafka` shows Pending for >5 minutes
**Root Cause:** Insufficient cluster resources (memory/CPU)
**Check:**
```bash
# Check resource requirements
kubectl describe pod kafka-0 -n kafka | grep -A 10 "Requests"

# Check node resources
kubectl top nodes
```
**Fix:**
```bash
# Increase Minikube memory and CPUs
minikube delete
minikube start --memory=8192 --cpus=4

# Verify resources available
kubectl top nodes
```
```

---

### 5. Validation Result (Compilation Output)

A Validation Result represents the outcome of compiling a CAPS Playbook to a Claude Skill.

**Lifecycle**: Created during compilation, ephemeral (not persisted to file, logged to STDOUT)

**Attributes**:

| Attribute | Type | Description | Example |
|-----------|------|-------------|---------|
| `overall_status` | enum | PASS or FAIL | "PASS" |
| `errors` | array[Error] | Blocking issues that prevented compilation | `[{type: "MISSING_FIELD", message: "Missing required field: title", location: "playbook.md"}]` |
| `warnings` | array[Warning] | Non-blocking quality issues | `[{type: "HARDCODED_SECRET", message: "Potential secret on line 42", location: "playbook.md:42"}]` |
| `compilation_time` | float | Seconds elapsed | 0.847 |
| `output_path` | string | Generated skill file path | ".claude/skills/hello-world/skill.md" |

#### Error Object

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `type` | enum | Error category | "MISSING_FIELD" / "INVALID_YAML" / "MISSING_SECTION" / "UNMATCHED_CODE_BLOCKS" |
| `message` | string | Human-readable error | "Missing required field: title" |
| `location` | string | File path or line number | "playbook.md" or "playbook.md:42" |

#### Warning Object

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `type` | enum | Warning category | "HARDCODED_SECRET" / "UNTESTABLE_PREREQUISITE" / "NON_CONSECUTIVE_STEPS" / "UNKNOWN_TOOL" |
| `message` | string | Human-readable warning | "Potential hardcoded secret detected" |
| `location` | string | File path or line number | "playbook.md:42" |

**Example STDOUT Output**:

```
[INFO] CAPS to Claude Skills Compiler
[INFO] Playbook: hello-world
[INFO] Source: /path/to/caps-library/playbooks/hello-world/playbook.md
[INFO] Output: /path/to/.claude/skills/hello-world/skill.md

[INFO] Reading CAPS playbook...
[INFO] Title: Hello World CAPS Playbook
[INFO] Description: A simple CAPS playbook...
[INFO] Version: 1.0.0

[INFO] Validating...
[INFO] ✓ Required fields present
[INFO] ✓ YAML syntax valid
[INFO] ✓ Required sections present
[INFO] ✓ Code blocks matched

[WARNING] Potential hardcoded secret detected (line 42)

[INFO] Generating Claude Skill...
[SUCCESS] Skill compiled successfully!
[SUCCESS] Output: /path/to/.claude/skills/hello-world/skill.md
[INFO] Compilation time: 0.847 seconds

[INFO] Next steps:
[INFO] 1. Review the generated skill
[INFO] 2. Test with Claude Code CLI
[INFO] 3. Refine playbook if needed
```

---

## Entity Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                      CAPS Playbook                          │
│  (source: caps-library/playbooks/<name>/playbook.md)       │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ YAML Frontmatter                                   │    │
│  │ - title, description, version                      │    │
│  │ - category, tags, difficulty                       │    │
│  │ - allowed_tools, prerequisites                     │    │
│  │ - dependencies, skip_conditions                    │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Markdown Sections                                  │    │
│  │ - ## Prerequisites                                 │    │
│  │ - ## Instructions                                  │    │
│  │   - ### Step 1: [Title] ──────┐                  │    │
│  │   - ### Step 2: [Title] ──────┤ Playbook Steps   │    │
│  │   - ### Step N: [Title] ──────┘                  │    │
│  │ - ## Validation                                    │    │
│  │ - ## Troubleshooting ──────────┐                 │    │
│  │   - Problem 1 ─────────────────┤ Troubleshooting │    │
│  │   - Problem N ─────────────────┘ Entries         │    │
│  └────────────────────────────────────────────────────┘    │
└───────────────────┬──────────────────────────────────────────┘
                    │
                    │ Compilation (caps-to-skills.sh)
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│                 Validation Result                            │
│                   (ephemeral)                                │
│                                                              │
│  - overall_status: PASS / FAIL                              │
│  - errors: [{type, message, location}, ...]                │
│  - warnings: [{type, message, location}, ...]              │
│  - compilation_time: float seconds                          │
│  - output_path: string                                      │
└───────────────────┬──────────────────────────────────────────┘
                    │
                    │ (if PASS)
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│                     Claude Skill                             │
│     (output: .claude/skills/<name>/skill.md)                │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ YAML Frontmatter (minimal)                         │    │
│  │ - description (from CAPS)                          │    │
│  │ - version (from CAPS)                              │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Markdown Sections (copied verbatim from CAPS)      │    │
│  │ - # Title                                          │    │
│  │ - Intro paragraph                                  │    │
│  │ - ## Prerequisites                                 │    │
│  │ - ## Instructions (all steps)                      │    │
│  │ - ## Validation                                    │    │
│  │ - ## Troubleshooting                               │    │
│  │ - ## Next Steps (if present)                       │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ Metadata Footer (auto-generated)                   │    │
│  │ - Source playbook path                             │    │
│  │ - Compilation timestamp                            │    │
│  │ - CAPS version                                     │    │
│  └────────────────────────────────────────────────────┘    │
└───────────────────┬──────────────────────────────────────────┘
                    │
                    │ Claude CLI Discovery
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│              Claude Code CLI Execution                       │
│                                                              │
│  - Discovers skill in .claude/skills/                       │
│  - Parses frontmatter and sections                          │
│  - Executes steps autonomously                              │
│  - Validates results                                        │
│  - Consults troubleshooting if errors occur                 │
└──────────────────────────────────────────────────────────────┘
```

**Cardinality**:
- 1 CAPS Playbook → 1 Claude Skill (one-to-one)
- 1 CAPS Playbook → 1 Validation Result per compilation (one-to-one, ephemeral)
- 1 CAPS Playbook contains N Playbook Steps (one-to-many, typically 5-20)
- 1 CAPS Playbook contains M Troubleshooting Entries (one-to-many, typically 2-4)

---

## File System Structure

### Input (CAPS Playbooks)

```
caps-library/
└── playbooks/
    ├── hello-world/
    │   └── playbook.md                # CAPS Playbook entity
    ├── kafka-k8s-setup/
    │   └── playbook.md                # CAPS Playbook entity
    └── postgresql-k8s-setup/
        └── playbook.md                # CAPS Playbook entity
```

### Output (Claude Skills)

```
.claude/
└── skills/
    ├── hello-world/
    │   └── skill.md                   # Claude Skill entity
    ├── kafka-k8s-setup/
    │   └── skill.md                   # Claude Skill entity
    └── postgresql-k8s-setup/
        └── skill.md                   # Claude Skill entity
```

**Directory Naming Convention**: Skill directory name MUST match playbook directory name (lowercase, hyphenated).

---

## Data Transformations

### Compilation Transformation (CAPS Playbook → Claude Skill)

**Mapping Rules**:

| CAPS Field/Section | Claude Skill Field/Section | Transformation |
|--------------------|----------------------------|----------------|
| `title` (YAML) | `# Title` (markdown H1) | Copy verbatim |
| `description` (YAML) | `description` (YAML) | Copy verbatim |
| `description` (YAML) | Intro paragraph (markdown) | Expand to full sentence |
| `version` (YAML) | `version` (YAML) | Copy verbatim |
| `category`, `tags`, `difficulty`, `estimated_time` (YAML) | Not included | Omitted (kept in source for documentation) |
| `allowed_tools`, `prerequisites`, `dependencies`, `skip_conditions` (YAML) | Not included | Omitted (Claude reads from Prerequisites section) |
| `## Prerequisites` (markdown) | `## Prerequisites` (markdown) | Copy verbatim (100% content preservation) |
| `## Instructions` (markdown) | `## Instructions` (markdown) | Copy verbatim with all steps |
| `## Validation` (markdown) | `## Validation` (markdown) | Copy verbatim |
| `## Troubleshooting` (markdown) | `## Troubleshooting` (markdown) | Copy verbatim |
| `## Notes & References` (markdown) | Not included | Omitted (internal documentation) |
| `## Rollback Instructions` (markdown) | Not included | Omitted (advanced usage, kept in source) |
| `## Next Steps` (markdown) | `## Next Steps` (markdown) | Copy if present |
| (auto-generated) | Metadata footer (markdown) | Generate: source path, timestamp, version |

**Content Preservation Guarantee**: 100% verbatim copying of Prerequisites, Instructions, Validation, and Troubleshooting sections (zero data loss, SC-007).

---

## Validation Rules Summary

### Required Fields (Block Compilation if Missing)

- YAML: `title`, `description`, `version`, `allowed_tools`, `prerequisites`
- Markdown: `## Prerequisites`, `## Instructions`, `## Validation`, `## Troubleshooting`

### Format Rules (Block Compilation if Violated)

- YAML frontmatter between `---` markers
- Code blocks have matched ` ``` ` markers (even count)
- Version follows semver format (MAJOR.MINOR.PATCH)

### Quality Rules (Warn but Continue)

- Hardcoded secrets (pattern: password|apikey|token|secret)
- Non-consecutive step numbering
- Unknown tools (not in whitelist)
- Untestable prerequisites (subjective)

---

## Usage Examples

### Creating a New CAPS Playbook

```bash
# 1. Create directory
mkdir -p caps-library/playbooks/my-playbook

# 2. Copy template
cp caps-library/docs/caps-playbook-template.md \
   caps-library/playbooks/my-playbook/playbook.md

# 3. Edit playbook.md with required fields and sections

# 4. Compile to skill
bash caps-library/scripts/caps-to-skills.sh my-playbook --validate

# 5. Verify output
ls -la .claude/skills/my-playbook/skill.md
```

### Querying Playbook Metadata (via grep/awk)

```bash
# List all playbook titles
for playbook in caps-library/playbooks/*/playbook.md; do
  grep "^title:" "$playbook" | sed 's/title: //'
done

# Find playbooks by category
for playbook in caps-library/playbooks/*/playbook.md; do
  if grep -q "^category: infrastructure" "$playbook"; then
    basename "$(dirname "$playbook")"
  fi
done

# Check playbook version
grep "^version:" caps-library/playbooks/hello-world/playbook.md | sed 's/version: //'
```

---

## Future Considerations

### Potential Schema Evolution

1. **YAML Schema Validation**: Add JSON Schema definition for CAPS YAML frontmatter (enables IDE autocomplete, stricter validation)

2. **Playbook Registry**: Central catalog of playbooks with searchability (category, tags, dependencies)

3. **Versioned Compilation**: Track which CAPS version compiled each skill (enables compatibility checks)

4. **Dependency Resolution**: Automatically compile dependent playbooks (requires parsing dependencies array)

5. **MCP Integration**: MCP server exposes CAPS library metadata (list playbooks, show compilation status, view diffs)

**These are out of scope for v1.0 but documented for future reference.**
