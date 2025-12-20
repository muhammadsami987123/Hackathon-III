# Documentation Contract: CAPS-to-Skills Compiler Guide

**Version**: 1.0.0
**Date**: 2025-12-20
**Binding Requirements**: All sections must meet listed criteria
**Status**: Complete - Ready for content authoring

---

## Section 1: Overview

### Required Elements
- [ ] Visual diagram: CAPS Playbooks → Compiler → Skills → Claude CLI (FR-001)
- [ ] "What It Does" paragraph (2-3 sentences)
- [ ] Key Capabilities table with 6 rows minimum (FR-001):
  - Validation
  - Transformation
  - Automation
  - Logging
  - Safety (dry-run)
  - Recovery (error handling)
- [ ] Link to Quick Start section

### Word Count Target
300-500 words

### Diagrams
1. Compilation flow diagram (Mermaid/ASCII/SVG)

### Examples
None required (conceptual section)

---

## Section 2: Compiler Architecture

### Required Elements
- [ ] Processing Pipeline description with 5 stages (FR-002):
  1. Discovery
  2. Validation
  3. Extraction
  4. Transformation
  5. Reporting
- [ ] Stage-by-stage breakdown (what happens in each stage)
- [ ] Transformation Rules table (FR-003):
  - CAPS Element column
  - Transformation column
  - SKILL.md Result column
  - Minimum 7 rows (title, description, allowed_tools, prerequisites, instructions, validation, troubleshooting)
- [ ] Example Transformation (FR-004): Input CAPS → Output SKILL.md side-by-side

### Word Count Target
800-1200 words

### Diagrams
1. 5-stage pipeline flow
2. Optional: Data flow diagram

### Examples
1. Input CAPS playbook (complete example)
2. Output SKILL.md (complete example)

---

## Section 3: Installation

### Required Elements
- [ ] Prerequisites subsection (FR-005):
  - bash 4.0+
  - Unix tools (find, grep, sed, awk)
  - Directory structure requirements
  - Verification commands for each prerequisite
- [ ] Step-by-step setup (FR-006):
  - Step 1: Get compiler script
  - Step 2: Make executable
  - Step 3: Verify directory structure
  - Step 4: (Optional) Create test playbook
- [ ] Verification after each step
- [ ] Troubleshooting subsection for common install issues

### Word Count Target
600-900 words

### Diagrams
None required (procedural section)

### Examples
1. Prerequisite verification commands
2. Installation commands
3. Test playbook (complete YAML + Markdown)
4. Validation command output

---

## Section 4: Quick Start

### Required Elements
- [ ] 3-Minute Setup workflow (FR-007):
  - Step 1: Verify compiler
  - Step 2: Validate playbooks
  - Step 3: Compile
  - Step 4: Check output
- [ ] Using Generated Skills subsection:
  - List skills
  - Run specific skill
  - Run with custom instructions

### Word Count Target
400-600 words

### Diagrams
None required (procedural section)

### Examples
1. Quick Start command sequence (4 commands)
2. Claude CLI skill invocation (3 examples)

---

## Section 5: Command Reference

### Required Elements
- [ ] Basic Syntax subsection
- [ ] Options subsection (FR-008, FR-009) with 7 options:
  1. `--help` (syntax, description, use case, output)
  2. `--validate` (syntax, description, use case, output)
  3. `--compile` (syntax, description, use case, output)
  4. `--clean` (syntax, description, use case, output)
  5. `--dry-run` (syntax, description, use case, output)
  6. `--verbose` (syntax, description, use case, output)
  7. `--log-file FILE` (syntax, description, use case, output)
- [ ] Combining Options subsection (3+ examples)

### Word Count Target
1200-1800 words

### Diagrams
None required (reference section)

### Examples
1. Each option with example invocation (7 examples)
2. Combined options (3 examples)

---

## Section 6: Workflow Integration

### Required Elements
- [ ] Standalone Usage subsection
- [ ] Git Pre-Commit Hook subsection (FR-010):
  - Complete bash script
  - Installation instructions
  - Testing instructions
- [ ] GitHub Actions CI/CD subsection (FR-010):
  - Complete YAML workflow
  - Setup instructions
  - Validation steps
- [ ] Makefile Integration subsection (FR-010):
  - Complete Makefile
  - Target descriptions
  - Usage examples

### Word Count Target
1000-1500 words

### Diagrams
Optional: Workflow flowcharts

### Examples
1. Git pre-commit hook (complete script with comments)
2. GitHub Actions workflow (complete YAML)
3. Makefile (complete with targets)
4. Usage examples for each integration

---

## Section 7: Troubleshooting

### Required Elements
- [ ] Common Issues subsection (FR-011) with 5+ issues:
  1. "Playbooks directory not found" (symptom, solution)
  2. "Validation failed" for valid playbook (symptom, solution)
  3. "Unmatched code block markers" (symptom, solution)
  4. Wrong skill name generated (symptom, solution)
  5. Incomplete SKILL.md output (symptom, solution)
- [ ] Each issue with:
  - Symptom (error message or behavior)
  - Root Cause
  - Solution (step-by-step)
- [ ] Getting Help subsection:
  - Log file inspection
  - Verbose output usage
  - Where to report issues

### Word Count Target
800-1200 words

### Diagrams
Optional: Decision tree for common issues

### Examples
1. Error messages (verbatim from compiler)
2. Diagnostic commands
3. Fix procedures

---

## Section 8: Advanced Usage

### Required Elements
- [ ] Selective Compilation subsection (FR-012)
- [ ] Batch Processing subsection (FR-012)
- [ ] Output Analysis subsection (FR-012)
- [ ] Version Control Integration subsection (FR-012)
- [ ] Each pattern with:
  - Use case description
  - Complete example
  - Expected output

### Word Count Target
800-1200 words

### Diagrams
None required (advanced procedural)

### Examples
1. Selective compilation commands (3 examples)
2. Batch processing script (complete)
3. Output analysis commands (3 examples)
4. Git integration commands (2 examples)

---

## Master Document (README.md)

### Required Elements
- [ ] Table of Contents (FR-014):
  - All 8 sections linked
  - Major subsections linked (2-level depth)
- [ ] Document metadata:
  - Version number
  - Last updated date
  - Compiler version compatibility
- [ ] Next Steps section (FR-015):
  - Link to Part 3 (if applicable)
  - Link to CAPS playbook authoring guide
  - Link to issue tracker for questions

### Word Count Target
50-100 words (introduction only; master includes all sections)

---

## Code Example Standards (FR-013)

### Requirements for ALL Code Blocks
- [ ] Language identifier in fenced block (```bash, ```yaml, etc.)
- [ ] Comments for non-obvious lines
- [ ] Copy-paste ready (no placeholders like <YOUR_VALUE>)
- [ ] Maximum 30 lines per example (split if longer)
- [ ] Validated with appropriate linter (shellcheck, yamllint, etc.)

### Example Format
```bash
# Comment explaining what this does
command --option argument

# Comment explaining next step
another-command | piped-command
```

---

## Validation Checklist (All Sections)

- [ ] All functional requirements (FR-001 to FR-015) addressed
- [ ] All user stories (1-7) supported by content
- [ ] All success criteria (SC-001 to SC-010) achievable with documented guidance
- [ ] All 8 edge cases addressed in Troubleshooting or content
- [ ] Links are valid (no broken anchors)
- [ ] Examples are tested and work
- [ ] Grammar and spelling checked
- [ ] Consistent terminology throughout

---

**Contract Finalized**: Ready for implementation (Phase 3+ tasks - User Story implementation)

This contract ensures:
- ✅ All FR-001 to FR-015 requirements have clear implementation criteria
- ✅ All sections have defined word count targets for scope management
- ✅ All required diagrams and examples are specified
- ✅ Code example standards are consistent (FR-013)
- ✅ Validation checklist covers all quality gates
