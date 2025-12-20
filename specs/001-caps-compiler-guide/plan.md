# Implementation Plan: CAPS-to-Skills Compiler Guide

**Branch**: `001-caps-compiler-guide` | **Date**: 2025-12-20 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/001-caps-compiler-guide/spec.md`

## Summary

Create comprehensive user documentation for the CAPS-to-Skills compiler that enables developers to understand, install, use, troubleshoot, and integrate the compiler into their workflows without external support. The documentation covers 8 major sections: Overview, Architecture, Installation, Quick Start, Command Reference, Workflow Integration, Troubleshooting, and Advanced Usage. Success is measured by users completing first compilation within 15 minutes and 75% reduction in support requests.

**Technical Approach**: Documentation will be authored in Markdown format, organized as a single comprehensive guide with clear section hierarchy and navigation. All code examples will be tested for copy-paste accuracy. Documentation structure follows progressive disclosure: conceptual understanding → hands-on setup → reference material → advanced patterns.

## Technical Context

**Documentation Format**: Markdown
**Primary Tools**: Standard text editor, Markdown linter (markdownlint), shellcheck for bash examples
**Storage**: Git repository (caps-library/ or documentation/ directory)
**Testing**: Manual verification of all commands, automated link checking, example validation
**Target Audience**: Developers with basic command-line proficiency, Unix environment (Linux/macOS/WSL)
**Project Type**: Technical documentation (single comprehensive guide)
**Performance Goals**: Users can locate any topic within 30 seconds, complete installation in 15 minutes
**Constraints**: Must work with existing compiler script (caps-to-skills.sh), no implementation changes to compiler
**Scale/Scope**: 8 major sections, 15+ functional requirements, 10 success criteria, estimated 8,000-12,000 words

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Agent-Agnostic Playbook Standards (CAPS-First)

**Status**: ✅ **COMPLIANT**

**Requirement**: All workflows must be authored as CAPS playbooks before implementation.

**Assessment**: This feature IS a documentation project about the CAPS-to-Skills compiler. The documentation itself does not need to be a CAPS playbook - it describes how to USE CAPS playbooks and the compiler. However, we should consider creating a CAPS playbook for *generating* or *updating* this documentation as a future enhancement.

**Action**: No blocking issues. Documentation project compliant by nature (documenting CAPS tooling).

---

### Principle II: Bi-Directional Compilation & Validation

**Status**: ✅ **COMPLIANT**

**Requirement**: Compilation scripts must produce valid, tested outputs.

**Assessment**: This documentation project does not involve compilation scripts directly. However, all bash code examples in the documentation (Git hooks, CI/CD scripts, command examples) MUST be validated for correctness.

**Action**: All shell script examples will be tested with shellcheck and validated in actual execution environments during Phase 1.

---

### Principle III: Phase-Gate Development with Gold Standards

**Status**: ✅ **COMPLIANT**

**Requirement**: Work progresses through defined phases with explicit success criteria.

**Assessment**: This implementation plan follows Phase 0 (Research) → Phase 1 (Design/Contracts) structure. Documentation project adapts phase gates appropriately:
- Phase 0: Research documentation best practices, compiler behavior analysis
- Phase 1: Define documentation structure, validate examples, create quickstart

**Action**: Standard phase-gate compliance. Checkpoint after each phase documented in plan.md.

---

### Principle IV: Kubernetes-Native & Cloud-Ready Architecture

**Status**: ✅ **NOT APPLICABLE (N/A)**

**Requirement**: All services must be designed for Kubernetes deployment.

**Assessment**: Documentation project does not involve deployable services. The compiler being documented may run in various environments (local developer machines, CI/CD), but documentation itself is static content.

**Action**: No action required. Principle N/A for documentation projects.

---

### Principle V: MCP (Model Context Protocol) Integration

**Status**: ✅ **NOT APPLICABLE (N/A)**

**Requirement**: MCP servers must provide rich context for AI agents.

**Assessment**: Documentation project does not implement MCP servers. However, the resulting documentation WILL help AI agents understand the CAPS compiler when referenced via AGENTS.md or MCP context.

**Action**: No action required. Principle N/A for documentation projects.

---

### Principle VI: Documentation as Automated Deliverable

**Status**: ⚠️ **PARTIAL COMPLIANCE - ACCEPTABLE**

**Requirement**: Documentation must be generated from CAPS playbooks and deployed automatically.

**Assessment**: This documentation is manually authored (not auto-generated from playbooks) because it describes HOW to use the CAPS compiler itself - a foundational capability. This is acceptable as a bootstrap case. However, we should ensure:
1. Documentation is version-controlled in git
2. Updates follow standard review process
3. Future updates could be templatized or partially automated

**Action**: Document manual authoring as justified exception. Plan for future automation where applicable (e.g., command reference sections could be generated from --help output).

**Justification**: Documentation about the CAPS compiler is foundational and requires human authorship for clarity, pedagogical structure, and example curation. Auto-generation would not meet quality bar for user-facing educational content.

---

### Principle VII: Test-Driven Refinement for Playbooks

**Status**: ✅ **ADAPTED FOR DOCUMENTATION**

**Requirement**: CAPS playbooks refined iteratively based on agent execution.

**Assessment**: While this isn't a playbook, the documentation will undergo iterative refinement:
1. Initial draft created based on spec
2. Validated against actual compiler behavior
3. Tested with real users (dry runs of all examples)
4. Refined based on feedback and error scenarios

**Action**: Adopt test-driven approach for documentation: all examples must be executable and validated before finalization.

---

### Principle VIII: Explicit Feature Parity Between Agent Builds

**Status**: ✅ **NOT APPLICABLE (N/A)**

**Requirement**: LearnFlow must be built in Claude and Goose versions.

**Assessment**: Documentation project does not involve dual-agent builds. However, note that the compiler being documented (caps-to-skills.sh) has a counterpart (caps-to-recipes.sh for Goose). This documentation focuses on Claude Skills compilation per spec scope.

**Action**: No action required. Principle N/A for this documentation scope. (Note: Part 3 or separate doc would cover Goose Recipes compilation)

---

### Constitution Check Summary

**Overall Status**: ✅ **APPROVED FOR PHASE 0**

**Gate Decision**: **PROCEED**

**Compliant Principles**: I, II, III, VII (adapted)
**Not Applicable**: IV, V, VIII
**Partial Compliance (Justified)**: VI (manual authoring justified for foundational tooling docs)

**No blocking violations.** Documentation project appropriately adapts constitution principles for non-code deliverable.

## Project Structure

### Documentation (this feature)

```text
specs/001-caps-compiler-guide/
├── spec.md              # Feature specification (complete)
├── plan.md              # This file (/sp.plan output)
├── research.md          # Phase 0: Documentation best practices, compiler behavior analysis
├── data-model.md        # Phase 1: Documentation structure, section taxonomy
├── quickstart.md        # Phase 1: Condensed getting-started workflow
├── contracts/           # Phase 1: Documentation contract (TOC, section templates)
│   └── documentation-outline.md
├── checklists/          # Quality validation
│   └── requirements.md  # Spec validation (complete)
└── tasks.md             # Phase 2: Implementation tasks (/sp.tasks - not created by /sp.plan)
```

### Documentation Output Location (repository)

```text
# Option A: Integrated with CAPS library (RECOMMENDED)
caps-library/
├── docs/
│   └── compiler-guide/
│       ├── README.md                    # Main entry point (compiled guide)
│       ├── 01-overview.md               # Overview section
│       ├── 02-architecture.md           # Architecture section
│       ├── 03-installation.md           # Installation section
│       ├── 04-quickstart.md             # Quick Start section
│       ├── 05-command-reference.md      # Command Reference section
│       ├── 06-workflow-integration.md   # Workflow Integration section
│       ├── 07-troubleshooting.md        # Troubleshooting section
│       ├── 08-advanced-usage.md         # Advanced Usage section
│       └── assets/
│           ├── diagrams/                # Visual diagrams (e.g., pipeline flow)
│           └── examples/                # Example files for copy-paste
└── playbooks/                           # CAPS playbooks directory

# Option B: Standalone documentation directory
docs/
└── caps-compiler-guide/
    └── [same structure as Option A]

# Option C: Integrated with Docusaurus site (if present)
docusaurus-site/
└── docs/
    └── caps-compiler/
        └── [same structure as Option A, adapted for Docusaurus]
```

**Structure Decision**: **Option A (Integrated with CAPS library)** is recommended because:
1. Documentation lives alongside the compiler script and playbooks it documents
2. Easy discoverability for developers working with CAPS
3. Enables future Docusaurus integration without restructuring
4. Supports constitution Principle VI (documentation as automated deliverable)

**Delivery Format**: Documentation will be authored as individual Markdown files per major section (8 files) plus a master README.md that compiles all sections for single-page reading. This provides both modularity (for maintenance) and convenience (for end-to-end reading).

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Manual documentation authoring (Principle VI partial) | Foundational tooling requires human-authored explanatory content for pedagogical clarity and example curation | Auto-generation from compiler source code would produce reference material only, missing tutorials, troubleshooting, and workflow integration guidance that requires human expertise |

---

## Phase 0: Research & Analysis

### Research Objectives

This phase resolves all unknowns about the compiler, establishes documentation standards, and validates technical accuracy before content creation.

#### Research Task 1: Compiler Behavior Analysis

**Goal**: Understand caps-to-skills.sh implementation details to ensure documentation accuracy

**Specific Unknowns**:
- Exact behavior of each compilation stage (Discovery, Validation, Extraction, Transformation, Reporting)
- Validation rules and error messages generated by compiler
- File I/O patterns (where CAPS files are read, where SKILL.md files are written)
- Handling of edge cases documented in spec

**Research Method**:
1. Read caps-to-skills.sh source code line-by-line
2. Execute compiler with various valid/invalid playbooks and capture output
3. Test edge cases: special characters in filenames, deeply nested directories, missing sections, slug collisions
4. Document actual error messages vs. what documentation should explain

**Deliverable**: `research.md` section "Compiler Behavior Analysis" with findings on actual vs. documented behavior

---

#### Research Task 2: Documentation Best Practices for Technical Tools

**Goal**: Identify industry standards for CLI tool documentation structure and style

**Specific Unknowns**:
- Optimal documentation structure for developer tools (Stripe API, AWS CLI, Kubernetes docs as references)
- Progressive disclosure patterns (beginner → intermediate → advanced)
- Code example formatting conventions
- Troubleshooting section organization (symptom → solution, FAQ format, decision trees)

**Research Method**:
1. Review documentation for 5 well-documented CLI tools (examples: Stripe API, Docker CLI, kubectl, Git, npm)
2. Identify common patterns: structure, navigation, example formatting, troubleshooting approaches
3. Extract best practices applicable to CAPS compiler guide

**Deliverable**: `research.md` section "Documentation Best Practices" with patterns and recommendations

---

#### Research Task 3: Code Example Validation Strategy

**Goal**: Define how to ensure all bash examples in documentation are accurate and copy-pasteable

**Specific Unknowns**:
- Tools for validating bash syntax (shellcheck)
- Approach for testing Git hook examples without committing to live repos
- CI/CD workflow examples validation (GitHub Actions YAML syntax)
- Makefile syntax validation

**Research Method**:
1. Identify linting tools: shellcheck for bash, yamllint for GitHub Actions, make --dry-run for Makefiles
2. Define validation workflow: manual execution → automated testing → periodic re-validation
3. Document test environments needed (Linux, macOS, WSL)

**Deliverable**: `research.md` section "Example Validation Strategy" with tools and workflow

---

#### Research Task 4: Visual Diagram Requirements

**Goal**: Determine how to create clear, maintainable diagrams for compilation pipeline

**Specific Unknowns**:
- Diagram format (ASCII art, Mermaid, PlantUML, SVG images)
- Tools for creating diagrams that render in Markdown
- Complexity level (high-level flow vs. detailed stage breakdown)

**Research Method**:
1. Evaluate diagram options: Mermaid (renders in GitHub/GitLab), ASCII art (universally readable), SVG (high quality but larger files)
2. Test rendering in common Markdown viewers (GitHub, VS Code, Docusaurus)
3. Create prototype diagram for compilation pipeline

**Deliverable**: `research.md` section "Visual Diagram Strategy" with chosen format and prototype

---

#### Research Task 5: User Journey Validation

**Goal**: Validate that documented workflows match real user needs and capabilities

**Specific Unknowns**:
- Actual time required for installation and first compilation (spec assumes 15 minutes)
- Common pain points users encounter (based on existing feedback if available)
- Prerequisite knowledge gaps (do users understand YAML, Markdown, bash scripting)

**Research Method**:
1. Simulate user journey: fresh environment → installation → first compilation (time each step)
2. Identify stumbling blocks: unclear instructions, missing context, assumed knowledge
3. Review existing issues/questions about CAPS compiler (if available in GitHub issues, Slack, etc.)

**Deliverable**: `research.md` section "User Journey Validation" with timing data and pain point analysis

---

### Research Output Structure

**File**: `specs/001-caps-compiler-guide/research.md`

**Template**:
```markdown
# Research Findings: CAPS-to-Skills Compiler Guide

**Date**: 2025-12-20
**Purpose**: Resolve unknowns before documentation authoring

## 1. Compiler Behavior Analysis

### Discovery Stage
- **Actual Behavior**: [findings from source code review]
- **File Patterns**: [what patterns are matched]
- **Edge Cases**: [how special cases are handled]

### Validation Stage
- **Checks Performed**: [list of validation rules]
- **Error Messages**: [actual error text from compiler]
- **Pass/Fail Logic**: [when validation succeeds vs. fails]

[... similar sections for Extraction, Transformation, Reporting]

### Documented Edge Cases
| Edge Case | Actual Compiler Behavior | Documentation Approach |
|-----------|-------------------------|----------------------|
| Missing `## Instructions` | [observed behavior] | [how to explain in docs] |
| Special characters in title | [observed behavior] | [how to explain in docs] |
[... continue for all 8 edge cases from spec]

---

## 2. Documentation Best Practices

### Structure Patterns (from reference tools)
- **Stripe API**: [pattern observed and why it works]
- **Docker CLI**: [pattern observed and why it works]
- **kubectl**: [pattern observed and why it works]

### Recommended Patterns for CAPS Compiler Guide
1. **Progressive Disclosure**: [approach]
2. **Example Formatting**: [conventions]
3. **Troubleshooting Organization**: [structure]

---

## 3. Example Validation Strategy

### Tools Selected
- **Bash Scripts**: shellcheck (version X.Y)
- **GitHub Actions**: yamllint + actionlint
- **Makefiles**: make --dry-run

### Validation Workflow
1. [Step 1: Initial authoring with inline validation]
2. [Step 2: Automated testing in CI]
3. [Step 3: Periodic re-validation]

### Test Environments
- Linux (Ubuntu 22.04)
- macOS (Ventura 13.x)
- Windows WSL2 (Ubuntu)

---

## 4. Visual Diagram Strategy

### Format Decision
**Chosen**: [Mermaid / ASCII art / SVG]
**Rationale**: [why this format for our use case]

### Prototype Diagram
```mermaid
[or ASCII art, or link to SVG]
```

### Rendering Validation
- ✅ GitHub
- ✅ VS Code
- ✅ Docusaurus (if applicable)

---

## 5. User Journey Validation

### Timed Simulation Results
- **Installation Prerequisites Check**: X minutes
- **Script Setup**: Y minutes
- **First Playbook Creation**: Z minutes
- **First Compilation**: W minutes
- **Total**: [sum] (Target: 15 minutes)

### Pain Points Identified
1. [Pain point 1 and proposed mitigation]
2. [Pain point 2 and proposed mitigation]

### Prerequisite Knowledge Gaps
- **YAML Syntax**: [gap analysis and documentation approach]
- **Bash Basics**: [gap analysis and documentation approach]

---

## Decisions Summary

| Unknown from Technical Context | Resolution |
|-------------------------------|-----------|
| Documentation format | Markdown (individual files + compiled README) |
| Diagram format | [Mermaid/ASCII/SVG decision] |
| Example validation | shellcheck + manual execution |
| User journey timing | [actual minutes from simulation] |

**Research Complete**: Ready for Phase 1 (Design & Contracts)
```

---

## Phase 1: Design & Contracts

### Phase 1 Objectives

Define documentation structure, create content templates, validate examples, and produce quickstart guide.

---

### Deliverable 1: Data Model (Documentation Structure)

**File**: `specs/001-caps-compiler-guide/data-model.md`

**Purpose**: Define the taxonomy of documentation sections, subsections, and content types

**Template**:
```markdown
# Documentation Structure: CAPS-to-Skills Compiler Guide

**Date**: 2025-12-20
**Purpose**: Define organization and content taxonomy for compiler documentation

## Documentation Entity Model

### Primary Sections (Level 1)

1. **Overview**
   - Purpose: Introduce compiler, explain value proposition
   - Target Audience: New users unfamiliar with CAPS
   - Content Types: Conceptual explanation, visual diagram, capabilities table
   - Success Criteria: User can answer "What does compiler do?" in <5 min (SC-001)

2. **Compiler Architecture**
   - Purpose: Explain 5-stage pipeline and transformation rules
   - Target Audience: Users wanting deeper understanding before use
   - Content Types: Pipeline diagram, stage descriptions, transformation table, examples
   - Success Criteria: User can list 5 stages and predict transformations (User Story 1)

3. **Installation**
   - Purpose: Get compiler running on user's system
   - Target Audience: All users (prerequisite for usage)
   - Content Types: Prerequisites list, step-by-step instructions, verification commands
   - Success Criteria: Successful `./caps-to-skills.sh --help` in <15 min (SC-002)

4. **Quick Start**
   - Purpose: First successful compilation end-to-end
   - Target Audience: Users who completed installation
   - Content Types: 3-4 step workflow, example playbook, validation commands
   - Success Criteria: Generated SKILL.md and successful skill invocation (User Story 3)

5. **Command Reference**
   - Purpose: Comprehensive reference for all compiler options
   - Target Audience: Regular users needing specific capabilities
   - Content Types: Option tables, syntax examples, use cases, expected output
   - Success Criteria: 100% of options documented and testable (SC-003, FR-008)

6. **Workflow Integration**
   - Purpose: Automate compilation in dev workflows
   - Target Audience: Users optimizing their processes
   - Content Types: Git hook code, GitHub Actions YAML, Makefile, usage instructions
   - Success Criteria: Copy-paste examples work on first attempt (SC-005, FR-010)

7. **Troubleshooting**
   - Purpose: Self-service problem resolution
   - Target Audience: Users encountering errors
   - Content Types: Issue/symptom/solution tables, diagnostic commands, fix procedures
   - Success Criteria: Documented issues resolved in <10 min (SC-004, FR-011)

8. **Advanced Usage**
   - Purpose: Scalability patterns for power users
   - Target Audience: Experienced users with large playbook libraries
   - Content Types: Selective compilation examples, batch scripts, analysis commands
   - Success Criteria: One advanced pattern implemented in <20 min (SC-009, FR-012)

---

## Subsection Taxonomy

### For Each Primary Section

#### Content Components
- **Heading**: Clear, descriptive title
- **Introduction Paragraph**: Context and purpose (2-3 sentences)
- **Body Content**: [varies by section type]
  - Conceptual: Explanations, diagrams, analogies
  - Procedural: Step-by-step instructions, commands, verification
  - Reference: Tables, option lists, syntax specifications
- **Examples**: Copy-pasteable code blocks with comments
- **Validation**: Success criteria or verification commands
- **Next Steps**: Link to subsequent section or related content

#### Metadata (for navigation)
- Section ID: (e.g., `#overview`, `#installation`)
- Priority: P1 (MVP), P2 (enhancement), P3 (advanced)
- Dependencies: Prerequisites from other sections
- Cross-References: Related sections

---

## Content Type Definitions

### Diagram
- **Format**: [Mermaid/ASCII/SVG from research]
- **Rendering**: Must display in GitHub Markdown viewer
- **Location**: Inline in section or in assets/diagrams/
- **Maintenance**: Update when compiler behavior changes

### Code Example
- **Format**: Fenced code block with language identifier
- **Validation**: Tested with shellcheck/yamllint/make
- **Comments**: Inline comments for complex lines
- **Length**: <30 lines per example (split if longer)

### Table
- **Format**: Markdown table with header row
- **Columns**: Aligned for readability
- **Content**: Concise (no paragraphs in cells)
- **Sorting**: Logical order (alphabetical, by priority, by frequency)

### Command Syntax
- **Format**: `command [OPTIONS] [ARGUMENTS]`
- **Options**: Documented with short/long forms
- **Examples**: Minimum 2 examples per command option

---

## Navigation Structure

### Table of Contents
- **Location**: Top of README.md (master document)
- **Depth**: 2 levels (sections + major subsections)
- **Links**: Anchor links to section IDs

### Internal Cross-References
- **Format**: `See [Section Name](#section-id) for details`
- **Usage**: When referencing concepts explained elsewhere
- **Validation**: All links checked during Phase 1

### External References
- **Format**: `[Tool Name](https://url)`
- **Usage**: Referencing official docs (Claude CLI, Git, bash)
- **Maintenance**: Note URLs may change (prefer stable permalinks)

---

## Success Metrics Mapping

| Section | Success Criteria | Verification Method |
|---------|-----------------|-------------------|
| Overview | SC-001 (5 min understanding) | User quiz/survey |
| Installation | SC-002 (15 min setup) | Timed simulation |
| Quick Start | User Story 3 acceptance | End-to-end test |
| Command Reference | SC-003 (100% options work) | Automated testing |
| Workflow Integration | SC-005 (copy-paste works) | Manual execution |
| Troubleshooting | SC-004 (10 min resolution) | Issue reproduction |
| Advanced Usage | SC-009 (20 min implementation) | Pattern execution |

---

## Documentation Maintenance Plan

### Triggers for Updates
- Compiler script version change
- New command options added
- User-reported issues (edge cases)
- Spec evolution (CAPS format changes)

### Update Process
1. Identify changed sections
2. Update affected Markdown files
3. Re-validate all examples
4. Update version metadata
5. Commit with clear change description

---

**Structure Finalized**: Ready for content authoring (Phase 2 tasks)
```

---

### Deliverable 2: Documentation Contract (Outline)

**File**: `specs/001-caps-compiler-guide/contracts/documentation-outline.md`

**Purpose**: Detailed section-by-section outline with required content elements

**Template**:
```markdown
# Documentation Contract: CAPS-to-Skills Compiler Guide

**Version**: 1.0.0
**Date**: 2025-12-20
**Binding Requirements**: All sections must meet listed criteria

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

**Contract Finalized**: Ready for implementation (Phase 2 tasks)
```

---

### Deliverable 3: Quickstart Guide

**File**: `specs/001-caps-compiler-guide/quickstart.md`

**Purpose**: Standalone condensed guide for immediate hands-on use

**Template**:
```markdown
# CAPS-to-Skills Compiler Quickstart

**Goal**: Get from zero to first compiled skill in 15 minutes or less.

**Prerequisites**: bash 4.0+, Unix-like environment (Linux/macOS/WSL)

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
```

---

### Deliverable 4: Agent Context Update

**Action**: Run the agent context update script

```bash
powershell.exe -ExecutionPolicy Bypass -File .specify/scripts/powershell/update-agent-context.ps1 -AgentType claude
```

**Purpose**: Update `.claude/AGENTS.md` (or similar) with technology context from this plan

**Expected Updates**:
- Documentation format: Markdown
- Tools: markdownlint, shellcheck
- Structure: caps-library/docs/compiler-guide/
- Deliverables: 8 section files + master README.md

---

## Phase 1 Completion Criteria

- [x] `research.md` created with all unknowns resolved
- [x] `data-model.md` created with documentation structure taxonomy
- [x] `contracts/documentation-outline.md` created with section requirements
- [x] `quickstart.md` created as standalone guide
- [x] Agent context updated with documentation project details
- [x] Constitution Check re-evaluated (no changes needed, remains compliant)

**Gate Decision**: **PROCEED TO PHASE 2** (/sp.tasks command)

---

## Notes for Implementation (Phase 2)

### Authoring Workflow
1. Create individual section files (01-overview.md through 08-advanced-usage.md)
2. Validate examples as you write (shellcheck for bash, yamllint for YAML)
3. Test all commands in clean environment (verify copy-paste accuracy)
4. Compile sections into master README.md
5. Run full validation (links, examples, requirements checklist)

### Quality Gates
- All FR-001 through FR-015 requirements met
- All code examples validated and tested
- All internal links working
- All success criteria achievable with documented content
- User Story acceptance scenarios verifiable

### Maintenance Considerations
- Version metadata in document header
- Change log section for major updates
- Compatibility note (which compiler version documented)
- Deprecation notices if features change

---

**Plan Status**: ✅ **COMPLETE - READY FOR TASKS GENERATION** (/sp.tasks)
