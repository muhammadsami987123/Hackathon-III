---
description: "Implementation tasks for CAPS Format Specification and Compilation Infrastructure"
---

# Tasks: CAPS Format Specification and Compilation Infrastructure

**Feature Branch**: `001-caps-format-spec`
**Input**: Design documents from `/specs/001-caps-format-spec/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Organization**: Tasks are organized by user story to enable independent implementation and testing of each story.

**Tests**: Tests are NOT requested in the feature specification. This feature focuses on tooling enhancement and documentation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: Bash scripts in `caps-library/scripts/`, playbooks in `caps-library/playbooks/`, docs in `caps-library/docs/`
- **Compiled output**: `.claude/skills/<playbook-name>/skill.md`

---

## Phase 1: Setup (Project Verification)

**Purpose**: Verify existing infrastructure and document baseline

- [ ] T001 Verify existing caps-to-skills.sh script at caps-library/scripts/caps-to-skills.sh is functional
- [ ] T002 Verify hello-world playbook at caps-library/playbooks/hello-world/playbook.md compiles successfully
- [ ] T003 [P] Verify caps-playbook-template.md exists at caps-library/docs/caps-playbook-template.md
- [ ] T004 [P] Verify .claude/skills/ directory structure exists and hello-world skill.md is present

---

## Phase 2: Foundational (Documentation Foundation)

**Purpose**: Create core documentation that guides all playbook authoring work

**⚠️ CRITICAL**: These documents are referenced by all user stories

- [ ] T005 Create best-practices.md at caps-library/docs/best-practices.md with CAPS authoring guidelines (required fields, step structure, validation criteria, idempotency, troubleshooting patterns)
- [ ] T006 Create validation-guide.md at caps-library/docs/validation-guide.md documenting common errors (missing required fields, unmatched code blocks, invalid YAML, hardcoded secrets) and fixes
- [ ] T007 Enhance caps-library/README.md with validation section, troubleshooting reference link, compilation examples with --validate flag

**Checkpoint**: Documentation foundation ready - authoring and validation work can now begin in parallel

---

## Phase 3: User Story 1 - Author Reusable Playbooks (Priority: P1) 🎯 MVP

**Goal**: Enable developers to write reusable workflow instructions in standardized CAPS format

**Independent Test**: Create a sample CAPS playbook using the template and verify it follows required structure (YAML frontmatter with all required fields + markdown sections: Prerequisites, Instructions, Validation, Troubleshooting)

**Acceptance Criteria** (from spec):
- Developer can create playbook.md using template with all required sections
- Steps are unambiguous and executable with bash commands
- Each step includes expected output and validation criteria
- Validator confirms all required fields present, YAML valid, code blocks properly formatted

### Implementation for User Story 1

- [ ] T008 [P] [US1] Verify caps-playbook-template.md at caps-library/docs/caps-playbook-template.md has all required frontmatter fields (title, description, version, allowed_tools, prerequisites)
- [ ] T009 [P] [US1] Verify caps-playbook-template.md has all required sections (## Prerequisites, ## Instructions with ### Step N, ## Validation, ## Troubleshooting)
- [ ] T010 [US1] Enhance caps-playbook-template.md with inline comments explaining each field purpose and validation rules
- [ ] T011 [US1] Add example step structure to template showing Objective, Commands, Expected Output, Success Criteria format
- [ ] T012 [US1] Add example troubleshooting entry to template showing Problem/Symptoms/Root Cause/Check/Fix format
- [ ] T013 [US1] Document template usage in caps-library/README.md with quickstart reference link

**Checkpoint**: Template is complete and documented. Developers can now author new playbooks following the template.

**Test Manually**: Create a test playbook (e.g., "test-playbook") using the template, fill in all sections, verify it's clear and unambiguous.

---

## Phase 4: User Story 2 - Compile CAPS to Claude Skills (Priority: P1)

**Goal**: Transform CAPS playbooks into Claude Skills format for agent execution

**Independent Test**: Run compilation script on valid CAPS playbook and verify skill.md generated in `.claude/skills/<name>/` with correct YAML frontmatter and all markdown sections preserved verbatim

**Acceptance Criteria** (from spec):
- caps-to-skills.sh compiles playbook to .claude/skills/<playbook-name>/skill.md
- Generated skill uses directory name (not slugified title) as skill name
- Description and version match CAPS frontmatter
- All markdown sections preserved (100% content preservation)
- Claude CLI discovers and can reference the skill

### Implementation for User Story 2

- [ ] T014 [P] [US2] Update caps-to-skills.sh to use playbook directory name instead of slugified title for skill name (basename of parent directory)
- [ ] T015 [P] [US2] Verify caps-to-skills.sh maps CAPS frontmatter fields correctly to skill.md (description, version)
- [ ] T016 [P] [US2] Verify caps-to-skills.sh copies all markdown sections verbatim (Prerequisites, Instructions with all steps, Validation, Troubleshooting)
- [ ] T017 [US2] Verify caps-to-skills.sh adds metadata footer with source playbook path, compilation timestamp, CAPS version
- [ ] T018 [US2] Test compilation with hello-world playbook and verify .claude/skills/hello-world/skill.md is correct
- [ ] T019 [US2] Document compilation command in caps-library/README.md with examples (basic compile, compile with validation, dry-run, custom output)

**Checkpoint**: Compilation script correctly transforms CAPS to Skills with 100% content preservation. hello-world compilation still works.

**Test Manually**: Compile hello-world, inspect skill.md, verify no data loss, verify Claude CLI discovers the skill.

---

## Phase 5: User Story 3 - Validate Playbook Quality (Priority: P2)

**Goal**: Automated validation of CAPS playbooks before compilation to catch errors early

**Independent Test**: Run validation on both valid and invalid CAPS playbooks, verify correct pass/fail results with specific error messages

**Acceptance Criteria** (from spec):
- Missing required field reports error with field name and exits non-zero
- Unmatched code block markers reports error
- Valid playbook reports "Validation passed" and exits zero
- Hardcoded secrets trigger warnings (not blocking)
- Unknown tools trigger warnings (not blocking)

### Implementation for User Story 3

- [ ] T020 [P] [US3] Add required field validation to caps-to-skills.sh: check for title, description, version, allowed_tools, prerequisites in YAML frontmatter
- [ ] T021 [P] [US3] Add YAML syntax validation to caps-to-skills.sh: verify frontmatter is between --- markers and fields follow key: value format
- [ ] T022 [P] [US3] Add markdown section validation to caps-to-skills.sh: check for ## Prerequisites, ## Instructions, ## Validation, ## Troubleshooting sections
- [ ] T023 [P] [US3] Add code block validation to caps-to-skills.sh: count ``` markers and verify even number (matched pairs)
- [ ] T024 [P] [US3] Add quality warning for hardcoded secrets: scan for patterns (password|apikey|token|secret) and log warning with line number
- [ ] T025 [P] [US3] Add quality warning for unknown tools: check allowed_tools against whitelist (bash, kubectl, helm, docker, git, python, npm, curl, etc.), warn if not recognized
- [ ] T026 [P] [US3] Add quality warning for non-consecutive step numbering: check ## Step 1, ## Step 2, ## Step 3 sequence, warn if gaps found
- [ ] T027 [US3] Implement error vs warning differentiation: critical errors exit 1 immediately, warnings log but continue compilation
- [ ] T028 [US3] Add colored output for validation messages: RED for errors, YELLOW for warnings, GREEN for success, BLUE for info
- [ ] T029 [US3] Add --validate flag handling to caps-to-skills.sh (already exists, verify it triggers validation checks)
- [ ] T030 [US3] Test validation with intentionally broken playbooks: missing title, unmatched code blocks, invalid YAML, and verify errors caught
- [ ] T031 [US3] Test validation with valid playbook and verify "Validation passed" message
- [ ] T032 [US3] Update caps-library/docs/validation-guide.md with examples of each validation error and how to fix

**Checkpoint**: Validation integrated into compilation workflow. Critical errors block compilation, quality issues warn but allow compilation.

**Test Manually**: Create broken playbooks (missing fields, unmatched code blocks), run compilation, verify errors block and messages are clear. Create valid playbook, verify it passes.

---

## Phase 6: User Story 4 - Execute Playbooks with Claude (Priority: P2)

**Goal**: Enable Claude Code CLI to autonomously execute compiled Skills by following playbook instructions

**Independent Test**: Invoke Claude Code CLI with compiled skill and verify Claude follows steps, executes commands, validates results, handles errors using troubleshooting section

**Acceptance Criteria** (from spec):
- Claude recognizes compiled skill and checks prerequisites
- Claude executes steps sequentially and runs validation commands
- Claude consults Troubleshooting section on errors and auto-fixes or explains resolution
- Claude tests skip_conditions and skips execution if condition met

### Implementation for User Story 4

- [ ] T033 [P] [US4] Create kafka-k8s-setup playbook at caps-library/playbooks/kafka-k8s-setup/playbook.md (Intermediate complexity: Helm installation, topic creation, producer/consumer testing, troubleshooting pod pending and version incompatibility)
- [ ] T034 [P] [US4] Create postgresql-k8s-setup playbook at caps-library/playbooks/postgresql-k8s-setup/playbook.md (Intermediate complexity: secrets, StatefulSet, persistent storage, connection testing, authentication troubleshooting)
- [ ] T035 [P] [US4] Create fastapi-dapr-service playbook at caps-library/playbooks/fastapi-dapr-service/playbook.md (Advanced complexity: project structure, FastAPI app, Dockerfile, K8s manifests, Dapr sidecar, deployment, service testing)
- [ ] T036 [US4] Compile kafka-k8s-setup playbook using caps-to-skills.sh --validate and verify .claude/skills/kafka-k8s-setup/skill.md created
- [ ] T037 [US4] Compile postgresql-k8s-setup playbook using caps-to-skills.sh --validate and verify .claude/skills/postgresql-k8s-setup/skill.md created
- [ ] T038 [US4] Compile fastapi-dapr-service playbook using caps-to-skills.sh --validate and verify .claude/skills/fastapi-dapr-service/skill.md created
- [ ] T039 [US4] Test kafka-k8s-setup skill with Claude Code CLI: ask Claude to "Set up Kafka on Kubernetes", verify Claude follows playbook steps, documents any failures
- [ ] T040 [US4] Test postgresql-k8s-setup skill with Claude Code CLI: ask Claude to "Set up PostgreSQL on Kubernetes", verify Claude follows playbook steps, documents any failures
- [ ] T041 [US4] Test fastapi-dapr-service skill with Claude Code CLI: ask Claude to "Create FastAPI service with Dapr", verify Claude follows playbook steps, documents any failures
- [ ] T042 [US4] Update troubleshooting sections in playbooks based on actual execution failures (iterate playbooks per Principle VII)

**Checkpoint**: Multiple example playbooks created, compiled, and tested with Claude CLI. Troubleshooting sections updated based on real failures.

**Test Manually**: Open Claude Code CLI, ask for Kafka/PostgreSQL/FastAPI setup, observe Claude execution, note any manual interventions required, update playbooks.

---

## Phase 7: User Story 5 - Iterate and Refine Playbooks (Priority: P3)

**Goal**: Track playbook versions and refine instructions based on execution failures to achieve <5% manual intervention target

**Independent Test**: Track a playbook through multiple versions (1.0.0 → 1.0.1 → 1.1.0), document failures in Troubleshooting, measure reduction in manual intervention rate

**Acceptance Criteria** (from spec):
- Playbook author adds troubleshooting guidance after 3 failures of same error
- Version increments appropriately (PATCH for clarifications, MINOR for new steps)
- After 3 iterations, playbook requires <5% manual fixes (constitution target)

### Implementation for User Story 5

- [ ] T043 [P] [US5] Document semantic versioning guidelines in caps-library/docs/best-practices.md (PATCH: clarifications/fixes, MINOR: new steps/features, MAJOR: breaking changes)
- [ ] T044 [P] [US5] Add version history table template to caps-playbook-template.md (Date, Version, Changes, Author columns)
- [ ] T045 [US5] Create iteration tracking document at caps-library/docs/iteration-tracking.md with template for recording execution failures, manual intervention percentage, version progression
- [ ] T046 [US5] Iterate hello-world playbook: execute 3 times, document any failures in Troubleshooting, update version if needed (1.0.0 → 1.0.1 if clarifications needed)
- [ ] T047 [US5] Iterate kafka-k8s-setup playbook: execute 3 times, document failures in Troubleshooting, refine instructions, increment version (target: <5% manual intervention by v1.3.0)
- [ ] T048 [US5] Iterate postgresql-k8s-setup playbook: execute 3 times, document failures in Troubleshooting, refine instructions, increment version (target: <5% manual intervention by v1.3.0)
- [ ] T049 [US5] Iterate fastapi-dapr-service playbook: execute 3 times, document failures in Troubleshooting, refine instructions, increment version (target: <5% manual intervention by v1.3.0)
- [ ] T050 [US5] Update caps-library/docs/iteration-tracking.md with results from all playbook iterations (version progression, manual intervention percentages, common failure patterns)

**Checkpoint**: All playbooks iterated through at least 3 versions. Troubleshooting sections comprehensive. Manual intervention reduced toward <5% target.

**Test Manually**: Execute each playbook 3 times, track manual fixes needed, calculate percentage, refine instructions, update troubleshooting, increment versions.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final documentation enhancements and verification

- [ ] T051 [P] Update caps-library/README.md with links to all new documentation (best-practices.md, validation-guide.md, quickstart.md, iteration-tracking.md)
- [ ] T052 [P] Add "Quick Reference" section to caps-library/README.md with common compilation commands, validation checks, troubleshooting tips
- [ ] T053 [P] Verify all example playbooks (hello-world, kafka-k8s-setup, postgresql-k8s-setup, fastapi-dapr-service) compile without errors
- [ ] T054 [P] Verify all generated skills in .claude/skills/ have correct structure (YAML frontmatter, markdown sections, metadata footer)
- [ ] T055 Run full validation suite: compile all 4 example playbooks with --validate flag, verify all pass
- [ ] T056 Measure compilation performance: compile 500-line playbook, verify completes in <5 seconds (success criterion SC-006)
- [ ] T057 Verify 100% content preservation: compare CAPS playbook sections to compiled skill.md sections, confirm verbatim copying (success criterion SC-002 and SC-007)
- [ ] T058 Create compilation success metrics document at specs/001-caps-format-spec/success-metrics.md documenting: authoring time (<30 min), compilation time (<5 sec), content preservation (100%), manual intervention rate (<5% after 3 iterations)
- [ ] T059 Run quickstart.md walkthrough end-to-end: follow all steps, verify developer can author first playbook in 15 minutes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational (documentation foundation)
- **User Story 2 (Phase 4)**: Depends on Foundational (documentation) - Can run in parallel with US1
- **User Story 3 (Phase 5)**: Depends on US2 (validation enhances compilation script)
- **User Story 4 (Phase 6)**: Depends on US1 (authoring), US2 (compilation), US3 (validation) - Creates example playbooks
- **User Story 5 (Phase 7)**: Depends on US4 (needs example playbooks to iterate) - Refinement phase
- **Polish (Phase 8)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1 - Authoring)**: Can start after Foundational - Independent
- **User Story 2 (P1 - Compilation)**: Can start after Foundational - Independent (parallel with US1)
- **User Story 3 (P2 - Validation)**: Depends on US2 (enhances compilation script) - Can run in parallel with US1
- **User Story 4 (P2 - Execution)**: Depends on US1, US2, US3 - Needs authoring template, compilation script, validation
- **User Story 5 (P3 - Iteration)**: Depends on US4 - Needs example playbooks created and tested

### Within Each User Story

**User Story 1 (Authoring)**:
- All template enhancement tasks (T008-T012) can run in parallel [P]
- Documentation task (T013) depends on template enhancements

**User Story 2 (Compilation)**:
- All caps-to-skills.sh enhancements (T014-T017) can run in parallel [P]
- Testing (T018) depends on enhancements complete
- Documentation (T019) can run in parallel with testing

**User Story 3 (Validation)**:
- All validation check additions (T020-T027) can run in parallel [P]
- Error differentiation (T028), colored output (T029) can run in parallel [P]
- Testing (T030-T031) depends on validation checks implemented
- Documentation (T032) can run in parallel with testing

**User Story 4 (Execution)**:
- All playbook creation tasks (T033-T035) can run in parallel [P]
- Compilation tasks (T036-T038) depend on playbook creation
- Testing tasks (T039-T041) depend on compilation
- Troubleshooting updates (T042) depend on testing results

**User Story 5 (Iteration)**:
- Documentation tasks (T043-T045) can run in parallel [P]
- Iteration tasks (T046-T049) can run in parallel [P] (different playbooks)
- Tracking document update (T050) depends on all iterations complete

**Polish Phase**:
- All documentation tasks (T051-T054) can run in parallel [P]
- Validation suite (T055) depends on all playbooks existing
- Performance testing (T056-T057) can run in parallel [P]
- Metrics document (T058) depends on all measurements complete
- Quickstart walkthrough (T059) is final verification

### Parallel Opportunities

**Phase 1 (Setup)**: All 4 tasks can run in parallel [P]

**Phase 2 (Foundational)**: T005 and T006 can run in parallel [P] (different files)

**Phase 3 (US1)**: Tasks T008, T009 can run in parallel [P] (both verify template)

**Phase 4 (US2)**: Tasks T014, T015, T016 can run in parallel [P] (different script sections)

**Phase 5 (US3)**: Tasks T020-T027 can run in parallel [P] (independent validation checks)

**Phase 6 (US4)**: Tasks T033-T035 can run in parallel [P] (different playbooks)

**Phase 7 (US5)**: Tasks T043-T045 can run in parallel [P] (different docs), Tasks T046-T049 can run in parallel [P] (different playbooks)

**Phase 8 (Polish)**: Tasks T051-T054 can run in parallel [P] (different files)

---

## Parallel Example: User Story 3 (Validation)

```bash
# Launch all validation check additions together:
Task T020: "Add required field validation to caps-to-skills.sh"
Task T021: "Add YAML syntax validation to caps-to-skills.sh"
Task T022: "Add markdown section validation to caps-to-skills.sh"
Task T023: "Add code block validation to caps-to-skills.sh"
Task T024: "Add quality warning for hardcoded secrets"
Task T025: "Add quality warning for unknown tools"
Task T026: "Add quality warning for non-consecutive step numbering"

# Then sequential:
Task T027: "Implement error vs warning differentiation" (depends on T020-T026)
Task T028: "Add colored output for validation messages"
Task T029: "Verify --validate flag handling"

# Then parallel testing:
Task T030: "Test validation with broken playbooks"
Task T031: "Test validation with valid playbook"
Task T032: "Update validation-guide.md with examples"
```

---

## Parallel Example: User Story 4 (Execution)

```bash
# Launch all playbook creation together:
Task T033: "Create kafka-k8s-setup playbook"
Task T034: "Create postgresql-k8s-setup playbook"
Task T035: "Create fastapi-dapr-service playbook"

# Then compile all:
Task T036: "Compile kafka-k8s-setup"
Task T037: "Compile postgresql-k8s-setup"
Task T038: "Compile fastapi-dapr-service"

# Then test all:
Task T039: "Test kafka-k8s-setup with Claude CLI"
Task T040: "Test postgresql-k8s-setup with Claude CLI"
Task T041: "Test fastapi-dapr-service with Claude CLI"

# Then update based on results:
Task T042: "Update troubleshooting sections"
```

---

## Implementation Strategy

### MVP First (User Stories 1 & 2 Only)

1. Complete Phase 1: Setup (verify existing infrastructure)
2. Complete Phase 2: Foundational (create documentation foundation)
3. Complete Phase 3: User Story 1 (authoring template enhancements)
4. Complete Phase 4: User Story 2 (compilation with directory naming)
5. **STOP and VALIDATE**: Verify hello-world still compiles, test authoring a new simple playbook using enhanced template
6. **MVP READY**: Developers can author CAPS playbooks and compile to Claude Skills

### Incremental Delivery

1. **Foundation** (Setup + Foundational) → Documentation baseline ready
2. **MVP** (US1 + US2) → Authoring and compilation work end-to-end
3. **Quality Gate** (US3) → Validation catches errors before compilation
4. **Example Library** (US4) → Multiple reference playbooks demonstrating complexity range
5. **Refinement** (US5) → Iterate playbooks toward <5% manual intervention target
6. **Polish** → All documentation complete, success criteria verified

### Parallel Team Strategy

With multiple developers:

1. **Together**: Complete Setup (Phase 1) and Foundational (Phase 2)
2. **Parallel Track 1**: Developer A works on User Story 1 (Authoring)
3. **Parallel Track 2**: Developer B works on User Story 2 (Compilation)
4. **Parallel Track 3**: Developer C works on User Story 3 (Validation) - depends on US2, can start when US2 script enhancements begin
5. **Together**: Complete User Story 4 (Execution) - create 3 playbooks in parallel
6. **Parallel**: Each developer iterates one playbook for User Story 5
7. **Together**: Polish phase

---

## Success Criteria Verification Plan

### SC-001: Author new playbook in <30 minutes
**Verification**: Run quickstart.md walkthrough (Task T059), time from start to compiled skill, target <30 min

### SC-002: 100% content preservation
**Verification**: Compare CAPS playbook sections to compiled skill.md (Task T057), verify verbatim copying

### SC-003: Catch common errors
**Verification**: Test validation with broken playbooks (Task T030), verify missing fields, unmatched code blocks, invalid YAML caught

### SC-004: <5% manual intervention after 3 iterations
**Verification**: Track playbook iterations (Tasks T046-T049), measure manual fixes percentage, target <5% by v1.3.0

### SC-005: 90% first-attempt compilation
**Verification**: After training (quickstart.md), test developers compile first playbook successfully (informal observation)

### SC-006: <5 seconds compilation
**Verification**: Compile 500-line playbook (Task T056), measure time, verify <5 sec

### SC-007: Zero data loss
**Verification**: Same as SC-002, compare source to output (Task T057)

### SC-008: Clear version progression
**Verification**: Review version history in iterated playbooks (Tasks T046-T049), verify semantic versioning followed

---

## Notes

- **No Tests**: Tests are NOT included because feature specification does not request test-driven approach. This is tooling/infrastructure enhancement with manual validation.
- **[P] tasks**: Different files, no dependencies, can run in parallel
- **[Story] labels**: Map tasks to user stories for traceability (US1=Authoring, US2=Compilation, US3=Validation, US4=Execution, US5=Iteration)
- **Each user story independently testable**: US1 verified by authoring test playbook, US2 by compilation, US3 by validation testing, US4 by Claude CLI execution, US5 by iteration tracking
- **Commit frequently**: After each task or logical group
- **Stop at checkpoints**: Validate each user story independently before proceeding
- **Principle VII alignment**: User Story 5 explicitly implements Test-Driven Playbook Refinement (<5% manual intervention target)
- **Existing implementation**: Many components already exist (caps-to-skills.sh, hello-world, template) - tasks focus on enhancement and expansion, not greenfield development

---

## Task Count Summary

- **Phase 1 (Setup)**: 4 tasks
- **Phase 2 (Foundational)**: 3 tasks
- **Phase 3 (US1 - Authoring)**: 6 tasks
- **Phase 4 (US2 - Compilation)**: 6 tasks
- **Phase 5 (US3 - Validation)**: 13 tasks
- **Phase 6 (US4 - Execution)**: 10 tasks
- **Phase 7 (US5 - Iteration)**: 8 tasks
- **Phase 8 (Polish)**: 9 tasks

**Total**: 59 tasks

**Parallel Opportunities**: 32 tasks marked [P] (54% of tasks can run in parallel when prerequisites met)

**MVP Scope**: Phases 1-4 (19 tasks) delivers core authoring and compilation functionality

**Full Delivery**: All 59 tasks completes feature with comprehensive validation, multiple example playbooks, and iterative refinement
