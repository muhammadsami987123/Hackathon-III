# Feature Specification: CAPS Format Specification and Compilation Infrastructure

**Feature Branch**: `001-caps-format-spec`
**Created**: 2025-12-19
**Status**: Draft
**Input**: User description: "CAPS (Coding Agent Playbook Specification) format specification and compilation infrastructure for Claude CLI Skills"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Author Reusable Playbooks (Priority: P1)

As a developer or automation engineer, I need to write reusable workflow instructions in a standardized format so that AI agents (Claude Code) can autonomously execute complex tasks without human intervention.

**Why this priority**: Core value proposition - without the ability to author CAPS playbooks, none of the other functionality matters. This is the foundation upon which everything else builds.

**Independent Test**: Can be fully tested by creating a sample CAPS playbook (e.g., "hello-world.md") using the template and verifying it follows the required structure (YAML frontmatter + markdown sections).

**Acceptance Scenarios**:

1. **Given** a developer has a workflow to automate, **When** they create a new playbook.md file using the CAPS template, **Then** the file contains all required sections (frontmatter with title/description/version/allowed_tools/prerequisites, and markdown with Prerequisites/Instructions/Validation/Troubleshooting sections)

2. **Given** a CAPS playbook with steps containing bash commands, **When** the playbook is reviewed by another developer, **Then** each step is unambiguous, executable, and includes expected output and validation criteria

3. **Given** a CAPS playbook is complete, **When** a validator runs validation checks, **Then** all required fields are present, YAML syntax is valid, code blocks are properly formatted, and step numbering is consecutive

---

### User Story 2 - Compile CAPS to Claude Skills (Priority: P1)

As a developer using Claude Code CLI, I need to compile CAPS playbooks into Claude Skills format so that I can invoke them as slash commands in my development workflow.

**Why this priority**: Equal priority to authoring - the compilation bridge from CAPS to Skills is what enables agent execution. Without compilation, playbooks remain unused documentation.

**Independent Test**: Can be fully tested by running the compilation script on a valid CAPS playbook and verifying a properly formatted SKILL.md file is generated in `.claude/skills/<name>/` directory.

**Acceptance Scenarios**:

1. **Given** a valid CAPS playbook exists at `caps-library/playbooks/hello-world/playbook.md`, **When** the compilation script `caps-to-skills.sh hello-world` runs, **Then** a skill.md file is created at `.claude/skills/hello-world/skill.md` with correct YAML frontmatter and all markdown sections preserved

2. **Given** a CAPS playbook with title "Kafka Kubernetes Setup", **When** compilation occurs, **Then** the generated skill has name "kafka-kubernetes-setup" (slugified, lowercase, hyphenated) and the description matches the CAPS description field

3. **Given** a compiled Claude Skill exists, **When** Claude Code CLI is invoked in a project with that skill, **Then** the skill is automatically discovered and can be referenced/executed by Claude during conversations

---

### User Story 3 - Validate Playbook Quality (Priority: P2)

As a playbook author, I need automated validation of my CAPS playbooks before compilation so that I catch errors early and ensure Claude can execute them successfully.

**Why this priority**: Important quality gate but not blocking initial functionality. Authors can manually check playbooks initially, but automated validation significantly improves efficiency and reliability.

**Independent Test**: Can be fully tested by running the validation script on both valid and invalid CAPS playbooks and verifying correct pass/fail results with specific error messages.

**Acceptance Scenarios**:

1. **Given** a CAPS playbook is missing a required field (e.g., no "version" in frontmatter), **When** the validation script runs, **Then** it reports an error "Missing required field: version" and exits with non-zero status

2. **Given** a CAPS playbook has unmatched code block markers (odd number of triple-backticks), **When** validation runs, **Then** it reports "Unmatched code block markers" error

3. **Given** a CAPS playbook passes all validation checks, **When** validation runs, **Then** it reports "Validation passed" and exits with zero status

---

### User Story 4 - Execute Playbooks with Claude (Priority: P2)

As a Claude Code user, I need Claude to autonomously execute compiled Skills by following the playbook instructions so that complex workflows are automated without manual intervention.

**Why this priority**: The end-user experience of agent execution is important, but relies on P1 stories (authoring + compilation) being complete first. This validates the entire workflow but isn't needed for initial playbook creation and compilation testing.

**Independent Test**: Can be fully tested by invoking Claude Code CLI with a compiled skill and verifying Claude follows the playbook steps, executes commands, validates results, and handles errors using the troubleshooting section.

**Acceptance Scenarios**:

1. **Given** a compiled skill "kafka-kubernetes-setup" exists, **When** a user asks Claude "Set up Kafka on Kubernetes", **Then** Claude recognizes the skill, checks prerequisites, executes steps sequentially, runs validation commands, and reports success or failure with specific details

2. **Given** a playbook step execution fails (e.g., helm install returns error), **When** Claude encounters the error, **Then** Claude consults the Troubleshooting section, identifies matching error symptoms, and either auto-fixes or explains the resolution to the user

3. **Given** a playbook has skip_conditions defined (e.g., "kafka_already_deployed"), **When** Claude checks prerequisites, **Then** Claude tests the skip condition and skips execution if condition is met, reporting why the playbook was skipped

---

### User Story 5 - Iterate and Refine Playbooks (Priority: P3)

As a playbook maintainer, I need to track playbook versions and refine instructions based on execution failures so that playbooks become more robust over time with minimal manual fixes.

**Why this priority**: Long-term maintenance concern. While important for production-quality playbooks, initial functionality can work with v1.0.0 playbooks. This enables continuous improvement but isn't blocking for MVP.

**Independent Test**: Can be fully tested by tracking a playbook through multiple versions (1.0.0 → 1.0.1 → 1.1.0), documenting failures in Troubleshooting sections, and measuring reduction in manual intervention rate over versions.

**Acceptance Scenarios**:

1. **Given** a playbook execution fails 3 times with the same error, **When** the author investigates and adds detailed troubleshooting guidance, **Then** subsequent executions either auto-resolve or provide clear fix instructions, and the version increments appropriately (PATCH for clarifications, MINOR for new steps)

2. **Given** a playbook v1.0.0 requires 10% manual fixes on first run, **When** the playbook is refined through 3 iterations based on real execution logs, **Then** v1.3.0 requires less than 5% manual fixes (meeting constitution target)

3. **Given** a playbook is updated, **When** the version increments, **Then** the version history table is updated with date, changes summary, and author information

---

### Edge Cases

- **What happens when a playbook author forgets a required section?** Validation script catches missing sections (Prerequisites, Instructions, Validation) and prevents compilation until fixed

- **How does the system handle playbooks with hardcoded secrets?** Validation script scans for common secret patterns (password|apikey|token|secret) and warns the author; compilation proceeds but with warnings logged

- **What if compilation target directory (.claude/skills/) doesn't exist?** Compilation script creates the directory structure automatically before writing skill.md

- **How are naming collisions handled?** Use playbook directory name instead of slugified title for skill name, guaranteeing uniqueness (directory names must be unique in file system)

- **What happens when Claude CLI version changes and skill.md format evolves?** Playbooks remain stable (CAPS format is versioned independently). A new compilation script version may be needed to target new skill.md format, but existing CAPS playbooks don't need updates.

- **How does a playbook author know what tools are "valid"?** Validation script maintains a whitelist of common tools (bash, kubectl, helm, docker, git, python, npm, curl). Tools not on the list trigger a warning but don't block compilation (allows extensibility).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support CAPS playbook format with YAML frontmatter containing required fields: title, description, version, allowed_tools, prerequisites
- **FR-002**: System MUST support markdown content sections: Prerequisites, Instructions (with numbered Steps), Validation, and Troubleshooting
- **FR-003**: System MUST provide a compilation script (caps-to-skills.sh) that transforms CAPS playbooks into Claude Skills (skill.md format)
- **FR-004**: Compilation script MUST use playbook directory name as skill name (lowercase, hyphenated, 3-50 chars) to avoid naming collisions
- **FR-005**: Compilation script MUST map CAPS fields to Claude Skill frontmatter: allowed_tools → allowed-tools, preserve description and version
- **FR-006**: Compilation script MUST copy Instructions, Prerequisites, Validation, and Troubleshooting sections verbatim to generated skill.md
- **FR-007**: System MUST provide validation script that checks for required fields, valid YAML syntax, required sections, and proper code block formatting (optional validation-only script, can be integrated into compilation workflow)
- **FR-008**: Compilation script MUST verify step numbering is consecutive (Step 1, Step 2, Step 3) and report gaps as warnings (not blocking)
- **FR-009**: Compilation script MUST check code blocks use bash syntax (```bash) and have matched opening/closing markers - warn if mismatched but don't block compilation
- **FR-010**: System MUST organize playbooks in directory structure: `caps-library/playbooks/<playbook-name>/playbook.md`
- **FR-011**: System MUST place generated Claude Skills in: `.claude/skills/<playbook-name>/skill.md`
- **FR-012**: Playbooks MUST support semantic versioning (MAJOR.MINOR.PATCH) in frontmatter version field
- **FR-013**: Playbooks MUST declare allowed tools as array in frontmatter (e.g., [kubectl, helm, bash])
- **FR-014**: Playbooks MUST declare prerequisites as array of testable conditions (e.g., kubernetes_cluster_running)
- **FR-015**: Playbooks MAY declare dependencies as array of other playbook names for execution ordering (documentation only - not auto-executed)
- **FR-016**: Playbooks MAY declare skip_conditions as array of conditions under which playbook can be skipped (documentation only - Claude evaluates)
- **FR-017**: Each playbook step MUST include: objective, bash commands in code blocks, expected output, and validation criteria
- **FR-018**: Troubleshooting section MUST document common errors with: Problem, Symptoms, Root Cause, Check commands, and Fix commands
- **FR-019**: Validation section MUST include measurable success criteria as checklist items
- **FR-020**: System MUST preserve all markdown formatting, code blocks, and content structure during compilation

### Key Entities *(included - feature involves data structures)*

- **CAPS Playbook**: A markdown file with YAML frontmatter representing a reusable workflow. Key attributes: title, description, version, category, tags, difficulty, estimated_time, allowed_tools, prerequisites, dependencies, skip_conditions, markdown content (Prerequisites, Instructions with Steps, Validation, Troubleshooting, Notes, Rollback, Next Steps)

- **Claude Skill**: A compiled artifact in skill.md format that Claude CLI can discover and execute. Key attributes: name (from directory name), description, allowed-tools array, version, markdown content sections (Prerequisites, Instructions, Validation, Troubleshooting). Relationships: One-to-one mapping from CAPS Playbook.

- **Playbook Step**: Individual action within Instructions section. Key attributes: step_number (sequential integer), title (action name), objective (what it accomplishes), commands (bash code block), expected_output (sample output text), success_criteria (checklist of verification items). Relationships: Belongs to one CAPS Playbook, ordered sequentially.

- **Troubleshooting Entry**: Documentation of a known error case. Key attributes: problem_name, symptoms (observable error messages), root_cause (explanation), check_commands (diagnostic bash commands), fix_commands (resolution bash commands). Relationships: Belongs to one CAPS Playbook, multiple entries per playbook.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Developers can author a new CAPS playbook from template to compiled skill in under 30 minutes for a simple workflow (5-10 steps)

- **SC-002**: Compilation script successfully transforms any valid CAPS playbook into a Claude Skill with 100% content preservation (no loss of instructions, commands, or formatting)

- **SC-003**: Compilation script catches common authoring errors (missing required fields, unclosed code blocks) with clear error messages before generating output

- **SC-004**: Claude Code CLI successfully executes compiled skills with less than 5% manual intervention required (measured after 3 iterations of playbook refinement - aligns with constitution Principle VII target)

- **SC-005**: 90% of playbooks compile successfully on first attempt after authors are trained on CAPS format (measured after training session)

- **SC-006**: Compilation process completes in under 5 seconds for playbooks up to 500 lines

- **SC-007**: Zero data loss during compilation - every bash command, expected output, and troubleshooting detail from CAPS appears identically in generated skill.md

- **SC-008**: Playbook authors successfully version and iterate playbooks with clear semantic version progression (e.g., 1.0.0 → 1.0.1 for clarifications, 1.1.0 for new steps)

## Assumptions *(mandatory)*

1. **Target AI Agent**: Primary target is Claude Code CLI with Skills capability (October 2025+). Claude Skills are discovered automatically from `.claude/skills/` directory.

2. **Execution Environment**: Playbooks will be executed in environments where declared tools (kubectl, helm, bash, docker, etc.) are already installed. Playbook authors are responsible for listing correct prerequisites.

3. **User Skill Level**: Playbook authors have intermediate technical skills (can write bash commands, understand Kubernetes concepts, familiar with markdown and YAML). End users (those invoking compiled skills via Claude) may have lower technical skills.

4. **File System Access**: Compilation script has read/write access to project directories (caps-library/, .claude/skills/).

5. **Version Control**: Project uses Git for version control. Playbooks and compiled skills are checked into repository together.

6. **Bash Availability**: Compilation script is written in Bash and requires Bash 4.0+ available on the system.

7. **Claude CLI Installation**: Users have Claude Code CLI installed and configured. Skills discovery works via `.claude/skills/` directory convention.

8. **Single Source of Truth**: CAPS playbook is the authoritative source. Generated skill.md files are artifacts and may be regenerated. Hand-editing skill.md is discouraged.

9. **Playbook Idempotency**: Playbook authors strive for idempotent commands (safe to run multiple times) but this is a guideline, not enforced by validation.

10. **English Language**: All playbook content is in English. Internationalization not in scope for v1.0.

## Scope *(mandatory)*

### In Scope

- CAPS playbook format specification (v1.0.0)
- YAML frontmatter structure with required and optional fields
- Markdown content section definitions (Prerequisites, Instructions, Validation, Troubleshooting)
- Compilation script (caps-to-skills.sh) for Claude Skills generation
- Basic validation integrated into compilation (required fields, YAML syntax, code block matching)
- Playbook template file for easy authoring (caps-playbook-template.md) - already exists
- Directory structure conventions (caps-library/playbooks/, .claude/skills/) - already implemented
- Example playbooks demonstrating best practices (hello-world already exists)
- Documentation of design principles (clarity, structure, tool explicitness, idempotency, validation by default, fail-fast with debugging)
- Best practices guide (writing clear instructions, testable prerequisites, idempotent commands, comprehensive troubleshooting)
- Integration with existing project structure (aligns with .specify/memory/constitution.md Principle I)
- README documentation for CAPS library usage

### Out of Scope

- Goose Recipes compilation (caps-to-recipes.sh) - separate track but same CAPS source format
- Standalone validation script separate from compilation (validation is integrated into compilation workflow)
- Web-based playbook editor or GUI
- Real-time playbook execution monitoring/dashboards
- Automatic playbook generation from code or logs (future AI capability)
- Multi-language support (non-English playbooks)
- Integration with external playbook repositories or package managers
- Playbook dependency resolution and automatic execution ordering (dependencies are declared but not auto-executed)
- Skip condition evaluation engine (skip_conditions are documented but Claude decides whether to skip)
- Automated testing framework for playbooks (compilation checks syntax, not execution correctness)
- Playbook versioning and change management tools (Git is assumed)
- Claude CLI itself or modifications to Claude's skill discovery mechanism
- MCP (Model Context Protocol) server integration for playbook state

### Dependencies

- Project must have `.specify/memory/constitution.md` with Principle I (Agent-Agnostic Playbook Standards) documented - already in place
- Git repository initialized with caps-library/ directory - already in place
- Bash 4.0+ available on development machines
- Claude Code CLI installed for skill execution testing
- Access to create/modify files in `.claude/skills/` directory

## Out of Scope / Future Considerations

- **Goose Recipes Support**: While the constitution mentions bi-directional compilation (Claude Skills AND Goose Recipes), the CAPS source format supports both. The caps-to-recipes.sh compiler is a parallel effort that can share the same CAPS playbook sources.

- **Standalone Validation Tool**: A dedicated validate-caps.sh script is out of scope for this feature. Validation is integrated into the compilation workflow (fail fast on critical errors, warn on quality issues). Future dedicated validation tool could be added for CI/CD integration.

- **Automated Dependency Execution**: Playbooks can declare dependencies (e.g., kafka-setup depends on namespace-setup), but automatic chaining and execution of dependent playbooks is not implemented. This is a manual or future orchestration capability.

- **Skip Condition Evaluation**: Playbooks can declare skip_conditions, but the evaluation logic is left to Claude's reasoning. A dedicated skip condition evaluation engine could be added later.

- **Playbook Marketplace**: Future vision includes shared playbook repositories where teams can publish/discover CAPS playbooks. This requires hosting infrastructure, versioning, and package management out of scope for v1.0.

- **Real-time Execution Telemetry**: Ability to monitor playbook execution in real-time (progress, current step, resource usage) would enhance observability but requires integration with Claude CLI internals not currently exposed.

- **Automated Playbook Testing**: Running playbooks in isolated test environments (Docker containers, ephemeral K8s clusters) to verify correctness before merging to main branch. This requires test infrastructure and CI/CD integration.

- **Playbook Composition/Reuse**: Ability to reference and include common step sequences across multiple playbooks (e.g., "install helm repo" is repeated in many playbooks). Template/include mechanism could reduce duplication.

- **Multi-language Playbooks**: Supporting playbook instructions in languages other than English. Requires translation infrastructure and testing with multilingual Claude models.

## Notes

### Related Documentation

- Project Constitution: `.specify/memory/constitution.md` (Principle I: Agent-Agnostic Playbook Standards)
- Claude Code Rules: `CLAUDE.md` (sections on Skills directory structure and CAPS compilation workflow)
- Source Document: `sp.abc.md` (comprehensive CAPS v1.0.0 specification including examples)
- Existing CAPS Library README: `caps-library/README.md` (already documents structure and usage)

### Technical Considerations

- Compilation script (caps-to-skills.sh) already exists and is working (verified with hello-world playbook)
- Script uses `awk` for section extraction and `sed` for text processing - no dependencies on `yq` or Python
- Generated skill.md files include metadata footer with source playbook path and compilation timestamp
- File paths in error messages use absolute paths for easy navigation
- Color-coded output in compilation script for better UX (INFO/SUCCESS/ERROR/WARNING)

### Security Considerations

- Compilation script scans for hardcoded secrets with basic pattern matching (password|apikey|token|secret) but this is not foolproof
- Playbooks execute arbitrary bash commands when Claude runs them. Trust model assumes playbook authors are trusted team members
- No sandboxing or permission restrictions enforced at CAPS/compilation level. Claude's own execution sandboxing is the security boundary
- Generated skills stored in `.claude/skills/` should not contain secrets (same as source playbooks)

### Performance Considerations

- Compilation is a one-time process per playbook update. Sub-5-second compilation keeps workflow smooth
- Current script completes hello-world playbook in < 1 second
- Validation integrated into compilation (fail fast) rather than separate pass
- Generated skill.md files are compact (minimal metadata) for faster Claude parsing

### Implementation Notes

- Feature already partially implemented: caps-to-skills.sh script exists and works
- This specification formalizes the existing implementation and documents intended behavior
- hello-world playbook already compiled successfully to .claude/skills/hello-world/skill.md
- Remaining work: enhance validation, document best practices, create additional example playbooks
