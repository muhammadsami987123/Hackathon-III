---
id: 004
title: CAPS format tasks generation
stage: tasks
date: 2025-12-19
surface: agent
model: claude-sonnet-4-5
feature: caps-format-spec
branch: 001-caps-format-spec
user: Claude
command: /sp.tasks
labels: ["tasks", "caps", "playbooks", "implementation", "user-stories"]
links:
  spec: specs/001-caps-format-spec/spec.md
  ticket: null
  adr: null
  pr: null
files:
  - specs/001-caps-format-spec/tasks.md
tests:
  - No tests requested in feature specification (tooling enhancement with manual validation)
---

## Prompt

User invoked: `/sp.tasks` (continued from previous conversation after `/sp.plan` completion)

The command expanded to execute the task generation workflow using design documents from `specs/001-caps-format-spec/`:
- **Required inputs**: plan.md (technical architecture, research decisions, component design), spec.md (5 user stories with priorities P1-P3)
- **Optional inputs**: data-model.md (5 entities: CAPS Playbook, Claude Skill, Playbook Step, Troubleshooting Entry, Validation Result), quickstart.md (15-minute tutorial), research.md (4 research decisions)

**Context**: The CAPS Format Specification feature formalizes and enhances existing compilation infrastructure (caps-to-skills.sh already works with hello-world playbook). The feature has 5 prioritized user stories:
1. (P1) Author Reusable Playbooks - Write CAPS playbooks in standardized format
2. (P1) Compile CAPS to Claude Skills - Transform playbooks to skill.md format
3. (P2) Validate Playbook Quality - Automated pre-compilation checks
4. (P2) Execute Playbooks with Claude - Autonomous skill execution
5. (P3) Iterate and Refine Playbooks - Version tracking and refinement toward <5% manual intervention

**Goal**: Generate tasks.md with implementation tasks organized by user story to enable independent implementation and testing of each story.

## Response snapshot

**Process**:
1. Ran `check-prerequisites.ps1 -Json` to get feature directory (F:\Hackathon\Hackathon III\specs\001-caps-format-spec) and available docs (research.md, data-model.md, quickstart.md)
2. Read spec.md to extract 5 user stories with acceptance scenarios and priorities
3. Read plan.md to understand technical context (Bash 4.0+, native dependencies, existing caps-to-skills.sh script), constitution compliance, research decisions, component architecture, project structure
4. Read tasks-template.md to understand required format and organization pattern

**Generated tasks.md structure** (8 phases):

**Phase 1: Setup** (4 tasks)
- Verify existing infrastructure (caps-to-skills.sh, hello-world playbook, template, .claude/skills/)

**Phase 2: Foundational** (3 tasks - BLOCKS all user stories)
- Create best-practices.md (authoring guidelines)
- Create validation-guide.md (common errors and fixes)
- Enhance caps-library/README.md (validation section, troubleshooting)

**Phase 3: User Story 1 - Author Reusable Playbooks (P1)** (6 tasks - MVP)
- Verify and enhance caps-playbook-template.md
- Add inline comments explaining fields
- Add example step and troubleshooting formats
- Document template usage

**Phase 4: User Story 2 - Compile CAPS to Claude Skills (P1)** (6 tasks - MVP)
- Update caps-to-skills.sh to use directory name (not slugified title)
- Verify frontmatter mapping (description, version)
- Verify verbatim section copying
- Test hello-world compilation
- Document compilation commands

**Phase 5: User Story 3 - Validate Playbook Quality (P2)** (13 tasks)
- Add required field validation (title, description, version, allowed_tools, prerequisites)
- Add YAML syntax validation
- Add markdown section validation (Prerequisites, Instructions, Validation, Troubleshooting)
- Add code block matching validation
- Add quality warnings (hardcoded secrets, unknown tools, non-consecutive steps)
- Implement error vs warning differentiation (critical errors exit 1, warnings log but continue)
- Add colored output (RED errors, YELLOW warnings, GREEN success)
- Test with broken and valid playbooks
- Update validation-guide.md with examples

**Phase 6: User Story 4 - Execute Playbooks with Claude (P2)** (10 tasks)
- Create 3 example playbooks (kafka-k8s-setup, postgresql-k8s-setup, fastapi-dapr-service)
- Compile all 3 example playbooks
- Test all 3 skills with Claude Code CLI
- Update troubleshooting sections based on real failures

**Phase 7: User Story 5 - Iterate and Refine Playbooks (P3)** (8 tasks)
- Document semantic versioning guidelines
- Add version history table to template
- Create iteration tracking document
- Iterate all 4 playbooks (hello-world + 3 new) through 3 versions
- Track manual intervention percentage (target: <5% by v1.3.0)

**Phase 8: Polish & Cross-Cutting Concerns** (9 tasks)
- Update README with links to all documentation
- Add Quick Reference section
- Verify all playbooks compile without errors
- Measure compilation performance (<5 sec target)
- Verify 100% content preservation
- Create success metrics document
- Run quickstart.md walkthrough end-to-end

**Key Decisions**:
- **No tests included**: Feature specification does not request test-driven approach (tooling enhancement with manual validation)
- **Organization by user story**: Each phase corresponds to a user story, enabling independent implementation and testing
- **MVP scope**: Phases 1-4 (19 tasks) deliver core authoring and compilation functionality
- **Total**: 59 tasks, 32 marked [P] for parallel execution (54% parallelizable)
- **Checkpoints**: Each user story phase ends with verification criteria to validate independently

**Task Format** (strictly followed):
- `- [ ] [TaskID] [P?] [Story?] Description with file path`
- Example: `- [ ] T020 [P] [US3] Add required field validation to caps-to-skills.sh: check for title, description, version, allowed_tools, prerequisites in YAML frontmatter`

**Dependencies documented**:
- Phase dependencies (Setup → Foundational → User Stories → Polish)
- User story dependencies (US1 and US2 independent P1 priorities, US3 depends on US2, US4 depends on US1/US2/US3, US5 depends on US4)
- Within-story dependencies (validation checks can run in parallel, testing depends on implementation)
- Parallel opportunities identified (32 tasks marked [P])

**Implementation strategies provided**:
1. MVP First: Complete Phases 1-4 (US1 + US2), validate, deploy
2. Incremental Delivery: Add each user story, test independently, deploy
3. Parallel Team: Split Setup/Foundational, then developers work on different user stories in parallel

**Success criteria verification plan**: Mapped all 8 success criteria (SC-001 through SC-008) to specific tasks for verification

## Outcome

- ✅ Impact: Complete task breakdown with 59 implementation tasks organized by user story, enabling independent implementation and testing. MVP scope clearly defined (19 tasks). Parallel opportunities identified (32 tasks marked [P]).
- 🧪 Tests: No tests included (not requested in feature specification - tooling enhancement with manual validation approach)
- 📁 Files: Created tasks.md (673 lines) with detailed task descriptions, dependencies, parallel execution examples, implementation strategies
- 🔁 Next prompts: User can start implementation with Phase 1 (Setup - verify existing infrastructure), or proceed directly to Phase 2 (Foundational - create documentation), or jump to MVP focus (Phases 1-4 for US1 and US2). Alternatively, user can run `/sp.analyze` to perform cross-artifact consistency check.
- 🧠 Reflection: Tasks organized by user story (not by technical layer) to enable independent value delivery. Each user story phase has clear goal, independent test criteria, and checkpoint validation. MVP defined as US1 (Authoring) + US2 (Compilation) = 19 tasks delivers end-to-end workflow. Enhancement work (US3 Validation, US4 Execution, US5 Iteration) adds quality gates and example library incrementally. Existing implementation acknowledged (caps-to-skills.sh works, hello-world exists) - tasks focus on enhancement, not greenfield. Principle VII alignment: US5 explicitly targets <5% manual intervention through iterative refinement.

## Evaluation notes (flywheel)

- Failure modes observed: PHR creation script not found (.specify/scripts/bash/create-phr.sh missing) - recovered by creating PHR manually using template (agent-native approach per CLAUDE.md guidelines)
- Graders run and results (PASS/FAIL): Tasks validated against template format requirements - ALL 59 tasks follow strict checklist format (checkbox + TaskID + [P] marker + [Story] label + description with file path). User story organization enables independent testing (PASS). Dependencies clearly documented (PASS). Parallel opportunities identified (PASS).
- Prompt variant (if applicable): Standard /sp.tasks workflow with user story organization (per constitution Principle III and task generation rules)
- Next experiment (smallest change to try): Start implementation with Phase 1 (Setup) to verify existing infrastructure baseline, then proceed to Phase 2 (Foundational) to create documentation foundation that enables all user story work. Alternatively, run `/sp.analyze` to validate consistency across spec.md, plan.md, and tasks.md before beginning implementation.
