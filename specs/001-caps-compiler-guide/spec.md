# Feature Specification: CAPS-to-Skills Compiler Guide

**Feature Branch**: `001-caps-compiler-guide`
**Created**: 2025-12-20
**Status**: Draft
**Input**: User description: "SP Specify Part 2: CAPS-to-Skills Compiler Guide - Implementation & Usage Documentation"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Learning About CAPS Compiler (Priority: P1)

As a developer new to the CAPS ecosystem, I want to understand what the CAPS-to-Skills compiler does, how it works, and why I should use it, so that I can decide if it fits my workflow and understand the value it provides.

**Why this priority**: This is the entry point for all users. Without understanding the "what" and "why", users won't proceed to use the tool. This establishes the foundation for adoption.

**Independent Test**: Can be fully tested by a new user reading the Overview and Compiler Architecture sections and successfully answering questions like "What does the compiler do?", "What are the 5 stages of compilation?", and "What transformations occur?". Delivers immediate understanding of the tool's purpose and value.

**Acceptance Scenarios**:

1. **Given** a developer unfamiliar with CAPS, **When** they read the Overview section, **Then** they can explain what the compiler transforms (CAPS playbooks → Claude Skills) and identify at least 3 key capabilities
2. **Given** a developer reviewing the architecture, **When** they study the Processing Pipeline, **Then** they can list all 5 stages in order and describe what each stage does
3. **Given** a developer examining transformation rules, **When** they review the table and examples, **Then** they can predict how a given CAPS element will be transformed to a SKILL.md element

---

### User Story 2 - Installing and Setting Up Compiler (Priority: P1)

As a developer who wants to use the CAPS compiler, I need clear installation instructions with prerequisites and verification steps, so that I can get the compiler running on my system without errors.

**Why this priority**: Installation is a critical blocker - users cannot proceed without a working installation. This must be rock-solid to prevent early abandonment.

**Independent Test**: Can be fully tested by following the Installation section steps on a clean system and successfully running `./caps-to-skills.sh --help` without errors. Delivers a working compiler environment ready for use.

**Acceptance Scenarios**:

1. **Given** a system with bash 4.0+, **When** a developer follows prerequisite verification steps, **Then** all required tools are confirmed present (bash, find, grep, sed, awk)
2. **Given** the compiler script exists, **When** a developer makes it executable and runs `--help`, **Then** the help message displays without errors
3. **Given** directory structure requirements, **When** a developer creates `playbooks/` and `.claude/skills/` directories, **Then** the compiler can locate both directories successfully
4. **Given** the optional test playbook is created, **When** a developer runs `--validate`, **Then** the validation passes with "✓ Valid playbook" message

---

### User Story 3 - First Successful Compilation (Priority: P1)

As a developer with the compiler installed, I want to validate and compile my first CAPS playbook following a quick start guide, so that I can see the complete workflow from playbook to executable Claude Skill.

**Why this priority**: The "aha moment" - seeing the full cycle work builds confidence and confirms understanding. This is the MVP for compiler usage.

**Independent Test**: Can be fully tested by following the Quick Start section and successfully generating a SKILL.md file from a CAPS playbook, then invoking it with Claude CLI. Delivers tangible proof that the system works end-to-end.

**Acceptance Scenarios**:

1. **Given** one or more CAPS playbooks exist in `playbooks/` directory, **When** a developer runs `./caps-to-skills.sh --validate`, **Then** all playbooks pass validation or specific errors are reported
2. **Given** validated playbooks, **When** a developer runs `./caps-to-skills.sh`, **Then** corresponding SKILL.md files are generated in `.claude/skills/` subdirectories
3. **Given** generated skills exist, **When** a developer runs `claude --skill <name>`, **Then** Claude CLI executes the skill successfully
4. **Given** compilation completes, **When** a developer checks the output, **Then** they see a summary of successful compilations and any failures with details

---

### User Story 4 - Understanding All Command Options (Priority: P2)

As a developer using the compiler regularly, I need comprehensive documentation of all command options with examples and use cases, so that I can choose the right options for different scenarios (validation-only, dry-run, verbose debugging, etc.).

**Why this priority**: Once users have basic compilation working, they need to understand all available options for different workflows. This enables advanced usage but isn't required for initial success.

**Independent Test**: Can be fully tested by running each documented command option and verifying it produces the expected behavior described in the Command Reference section. Delivers mastery of compiler capabilities.

**Acceptance Scenarios**:

1. **Given** the compiler is installed, **When** a developer runs each option (`--validate`, `--compile`, `--clean`, `--dry-run`, `--verbose`, `--log-file`), **Then** each option produces the documented behavior
2. **Given** multiple options can be combined, **When** a developer runs combined options like `--dry-run --verbose`, **Then** both behaviors are active simultaneously
3. **Given** a developer wants to preview changes, **When** they run `--dry-run`, **Then** no actual files are created but expected output is shown
4. **Given** a developer encounters issues, **When** they run `--verbose --log-file`, **Then** detailed debug output is captured for analysis

---

### User Story 5 - Integrating into Development Workflow (Priority: P2)

As a developer maintaining CAPS playbooks in a project, I want to integrate compilation into my workflow (Git hooks, CI/CD, Make commands), so that playbooks are automatically validated and compiled without manual intervention.

**Why this priority**: Automation improves productivity and prevents errors, but users can still work effectively with manual compilation. This is an optimization after basic workflow is established.

**Independent Test**: Can be fully tested by implementing one integration method (e.g., Git pre-commit hook) and verifying that commits with invalid playbooks are blocked while valid playbooks are automatically compiled. Delivers workflow efficiency gains.

**Acceptance Scenarios**:

1. **Given** a Git pre-commit hook is installed, **When** a developer commits changes with invalid CAPS, **Then** the commit is blocked with validation errors displayed
2. **Given** a Git pre-commit hook is installed, **When** a developer commits valid CAPS playbooks, **Then** compilation occurs automatically and generated skills are added to the commit
3. **Given** a GitHub Actions workflow is configured, **When** playbooks are pushed to the repository, **Then** validation and compilation run in CI and results are reported
4. **Given** a Makefile is created, **When** a developer runs `make test`, **Then** both validation and compilation execute and pass/fail status is clear

---

### User Story 6 - Troubleshooting Compilation Issues (Priority: P3)

As a developer encountering compilation errors, I need clear troubleshooting guidance with common issues, symptoms, and solutions, so that I can quickly diagnose and fix problems without external help.

**Why this priority**: Troubleshooting is important for user success but only needed when problems occur. Most users won't need this immediately. Good error messages reduce the need for extensive troubleshooting docs.

**Independent Test**: Can be fully tested by intentionally creating each documented error scenario and verifying that the Troubleshooting section provides an accurate solution. Delivers self-service problem resolution.

**Acceptance Scenarios**:

1. **Given** a playbook with missing YAML closing `---`, **When** validation fails with "Missing required field" error, **Then** the troubleshooting guide explains YAML format requirements and shows correct examples
2. **Given** a playbook with unmatched code block markers, **When** validation fails with "Unmatched code block markers", **Then** the troubleshooting guide shows how to identify and fix the issue
3. **Given** a playbook with incorrect title format, **When** the generated skill has wrong name, **Then** the troubleshooting guide explains slugification rules and how to control skill naming
4. **Given** compilation produces incomplete SKILL.md, **When** sections are missing, **Then** the troubleshooting guide lists required sections and how to verify they exist in CAPS

---

### User Story 7 - Advanced Usage Patterns (Priority: P3)

As an experienced developer with multiple playbook libraries, I need advanced usage patterns like selective compilation, batch processing, and output analysis, so that I can efficiently manage large-scale CAPS playbook collections.

**Why this priority**: Advanced patterns are valuable for power users but not needed by beginners or most standard workflows. This serves a smaller audience with specific needs.

**Independent Test**: Can be fully tested by implementing one advanced pattern (e.g., selective compilation of a specific directory) and verifying it works as documented. Delivers scalability for advanced use cases.

**Acceptance Scenarios**:

1. **Given** playbooks in multiple subdirectories, **When** a developer compiles only `playbooks/infra/`, **Then** only infrastructure playbooks are compiled, others are skipped
2. **Given** multiple playbook libraries exist, **When** a developer runs batch processing script, **Then** all libraries are compiled in sequence with status reported for each
3. **Given** compiled skills exist, **When** a developer runs output analysis commands, **Then** accurate counts, modification times, and file sizes are displayed
4. **Given** a developer wants to track skills in git, **When** they follow version control integration guidance, **Then** generated skills are properly committed or ignored per project preferences

---

### Edge Cases

- What happens when a CAPS playbook has valid YAML but missing required sections (e.g., no `## Instructions`)?
- How does the compiler handle playbooks with special characters or spaces in directory names?
- What occurs when `.claude/skills/` directory doesn't have write permissions?
- How are errors handled when multiple playbooks have the same title (slug collision)?
- What happens if compilation is interrupted mid-process (partial file writes)?
- How does the system behave when a CAPS playbook references non-existent tools in `allowed_tools`?
- What occurs when a playbook has deeply nested directory structure (e.g., `playbooks/a/b/c/d/playbook.md`)?
- How are heredocs and nested code blocks handled during transformation?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Documentation MUST provide a clear visual diagram showing CAPS Playbooks → Compiler → Claude Skills → Claude CLI execution flow
- **FR-002**: Documentation MUST describe all 5 stages of the compilation pipeline (Discovery, Validation, Extraction, Transformation, Reporting) with specific actions for each stage
- **FR-003**: Documentation MUST include a transformation rules table mapping each CAPS element to its Claude Skill output format
- **FR-004**: Documentation MUST provide concrete examples showing input CAPS playbook and resulting SKILL.md side-by-side
- **FR-005**: Installation section MUST list all prerequisites (bash 4.0+, Unix tools, directory structure) with verification commands
- **FR-006**: Installation section MUST include step-by-step setup with verification after each step
- **FR-007**: Quick Start section MUST provide a complete workflow from installation verification to first compiled skill in 4 steps or less
- **FR-008**: Command Reference section MUST document all command-line options (`--help`, `--validate`, `--compile`, `--clean`, `--dry-run`, `--verbose`, `--log-file`)
- **FR-009**: Each command option MUST include syntax, description, use case, and expected output
- **FR-010**: Workflow Integration section MUST provide ready-to-use code examples for Git pre-commit hooks, GitHub Actions CI/CD, and Makefile integration
- **FR-011**: Troubleshooting section MUST document at least 5 common issues with symptom, root cause, and solution for each
- **FR-012**: Advanced Usage section MUST cover selective compilation, batch processing, output analysis, and version control integration patterns
- **FR-013**: All code examples MUST be copy-pasteable and include comments explaining key lines
- **FR-014**: Documentation MUST use consistent formatting with clear section hierarchy and navigation aids (table of contents, section links)
- **FR-015**: Documentation MUST include "Next Steps" guidance pointing users to related resources after completing each major section

### Key Entities

- **CAPS Playbook**: Source document containing workflow instructions in CAPS format with YAML frontmatter and Markdown sections (Prerequisites, Instructions, Validation, Troubleshooting)
- **Claude Skill**: Generated executable definition in SKILL.md format that Claude CLI can invoke, containing transformed playbook content
- **Compiler Script**: The `caps-to-skills.sh` bash script that performs validation and transformation
- **Compilation Pipeline Stage**: One of five phases (Discovery, Validation, Extraction, Transformation, Reporting) that processes playbooks
- **Transformation Rule**: A mapping that defines how a CAPS element converts to a SKILL.md element (e.g., `title` → slugified `name`)
- **Command Option**: A flag passed to the compiler script that modifies its behavior (e.g., `--validate`, `--dry-run`)
- **Workflow Integration**: Automation setup that embeds compilation into development processes (Git hooks, CI/CD, build tools)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A developer with no prior CAPS knowledge can read the Overview section and correctly answer "What does the compiler do?" in under 5 minutes
- **SC-002**: A developer can complete installation and run their first successful compilation within 15 minutes following the Quick Start guide
- **SC-003**: 100% of documented command options can be executed and produce the described behavior when tested
- **SC-004**: A developer encountering one of the documented troubleshooting scenarios can resolve it without external help in under 10 minutes
- **SC-005**: All code examples (Git hooks, GitHub Actions, Makefile) can be copied and used without modification and work on first attempt
- **SC-006**: The documentation table of contents allows a developer to locate any specific topic within 30 seconds
- **SC-007**: After reading the documentation, developers report understanding the complete compilation workflow with 90% confidence (measured by survey or quiz)
- **SC-008**: Documentation reduces compiler-related support requests by 75% compared to having no documentation
- **SC-009**: Advanced users can implement at least one workflow integration (hook/CI/Make) within 20 minutes using provided examples
- **SC-010**: 95% of edge cases encountered in real-world usage are covered in either Troubleshooting or Edge Cases sections

### Assumptions

- **Assumption 1**: Users have basic command-line proficiency and understand concepts like file paths, bash scripts, and directory structures
- **Assumption 2**: Users have read or are familiar with CAPS format basics (YAML frontmatter, Markdown sections) before attempting compilation
- **Assumption 3**: Users have access to a Unix-like environment (Linux, macOS, WSL, Git Bash) with bash 4.0 or later
- **Assumption 4**: Users have Claude CLI installed and configured before attempting to use generated skills
- **Assumption 5**: The compiler script (`caps-to-skills.sh`) exists and is maintained separately from this documentation
- **Assumption 6**: Error messages from the compiler script are sufficiently descriptive to help users identify issues when combined with this documentation
- **Assumption 7**: Users understand Git basics (branches, commits, hooks) when implementing Git-based workflow integrations
- **Assumption 8**: The CAPS playbook format specification is stable and documented elsewhere (this guide focuses on compilation, not playbook authoring)

### Dependencies

- **Dependency 1**: Requires the `caps-to-skills.sh` compiler script to exist and be functional (external to this documentation)
- **Dependency 2**: Requires Claude CLI to be installed for users to test generated skills (external tool)
- **Dependency 3**: Git pre-commit hook examples depend on Git being installed and repository being initialized
- **Dependency 4**: GitHub Actions workflow depends on repository being hosted on GitHub
- **Dependency 5**: Make integration depends on `make` utility being installed
- **Dependency 6**: Assumes existence of CAPS playbook format specification (referenced but not defined in this guide)
- **Dependency 7**: Relies on standard Unix tools (find, grep, sed, awk) being available in the environment

### Out of Scope

- **Out of Scope 1**: Teaching CAPS playbook authoring - this guide assumes playbooks already exist or users know how to write them
- **Out of Scope 2**: Detailed Claude CLI usage beyond basic skill invocation - refers to Claude CLI documentation
- **Out of Scope 3**: Implementing the compiler script itself - this documents usage, not implementation
- **Out of Scope 4**: Debugging CAPS playbook logic or content issues - focuses only on compilation process issues
- **Out of Scope 5**: Performance tuning for compiling extremely large playbook libraries (1000+ playbooks)
- **Out of Scope 6**: Supporting non-bash shell environments (PowerShell native, cmd.exe) - bash 4.0+ is required
- **Out of Scope 7**: Goose Recipe compilation - this Part 2 focuses exclusively on Claude Skills; Goose Recipes are covered separately
- **Out of Scope 8**: Advanced bash scripting techniques or extending the compiler with custom transformations
