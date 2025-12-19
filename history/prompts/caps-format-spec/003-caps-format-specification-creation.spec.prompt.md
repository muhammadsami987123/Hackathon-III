---
id: 003
title: CAPS format specification creation
stage: spec
date: 2025-12-19
surface: agent
model: claude-sonnet-4-5
feature: caps-format-spec
branch: 001-caps-format-spec
user: Claude
command: /sp.specify
labels: ["specification", "caps", "playbooks", "claude-skills", "compilation"]
links:
  spec: specs/001-caps-format-spec/spec.md
  ticket: null
  adr: null
  pr: null
files:
  - specs/001-caps-format-spec/spec.md
  - specs/001-caps-format-spec/checklists/requirements.md
tests:
  - Specification validation checklist - all checks passed
---

## Prompt

User invoked: `/sp.specify @sp.abc.md`

The feature description referenced sp.abc.md which contains the comprehensive CAPS (Coding Agent Playbook Specification) v1.0.0 format specification including:
- CAPS format structure (YAML frontmatter + markdown sections)
- Design principles (clarity, structure, tool explicitness, idempotency, validation by default, fail-fast with debugging)
- Field reference for all frontmatter fields (title, description, version, category, tags, difficulty, estimated_time, allowed_tools, prerequisites, dependencies, skip_conditions)
- Execution model for Claude CLI
- Claude Skills compilation mapping rules
- Validation rules
- Best practices for authoring playbooks
- Complete examples (PostgreSQL, FastAPI, AGENTS.md generation)

The goal was to create a feature specification that formalizes the CAPS format and compilation infrastructure already partially implemented in the project (caps-to-skills.sh script exists and works with hello-world playbook).

## Response snapshot

Created comprehensive feature specification with:

**Branch**: 001-caps-format-spec (created and checked out)

**5 Prioritized User Stories**:
1. (P1) Author Reusable Playbooks - Write CAPS playbooks in standardized format
2. (P1) Compile CAPS to Claude Skills - Transform playbooks to skill.md format
3. (P2) Validate Playbook Quality - Automated pre-compilation checks
4. (P2) Execute Playbooks with Claude - Autonomous skill execution
5. (P3) Iterate and Refine Playbooks - Version tracking and refinement

**20 Functional Requirements** (FR-001 through FR-020):
- CAPS format structure (YAML + markdown)
- Compilation script requirements (mapping, naming, content preservation)
- Validation requirements (required fields, YAML syntax, code blocks)
- Directory structure conventions
- Semantic versioning support
- Tool declarations, prerequisites, dependencies, skip conditions
- Step structure with objectives, commands, validation
- Troubleshooting documentation requirements

**8 Success Criteria** (SC-001 through SC-008):
- Time-based: 30 min authoring, 5 sec compilation
- Quality-based: 100% content preservation, zero data loss
- Success rate: 90% compile on first attempt, <5% manual intervention after 3 iterations
- Aligns with constitution Principle VII target

**Key Entities**:
- CAPS Playbook (source format)
- Claude Skill (compiled artifact)
- Playbook Step (instruction unit)
- Troubleshooting Entry (error documentation)

**Scope clearly bounded**:
- In scope: Format spec, compilation script, validation, templates, examples, docs
- Out of scope: Goose recipes (parallel track), standalone validation tool, GUI, monitoring, marketplace, automated testing

**10 Assumptions documented**:
- Target: Claude Code CLI (October 2025+)
- Bash 4.0+ required
- Single source of truth (CAPS playbook)
- English language only
- Git version control
- Authors have intermediate technical skills

**Edge Cases covered**:
- Missing sections (caught by validation)
- Hardcoded secrets (warning)
- Directory creation (auto-created)
- Naming collisions (use directory name)
- CLI version changes (CAPS stable, compiler may update)
- Unknown tools (warning, not blocking)

**Specification Quality Checklist**: Created at `specs/001-caps-format-spec/checklists/requirements.md` with all checks passing:
- ✅ No implementation details in user stories
- ✅ Technology-agnostic success criteria
- ✅ All requirements testable and unambiguous
- ✅ No [NEEDS CLARIFICATION] markers (made informed guesses with documented assumptions)
- ✅ Feature ready for planning phase

## Outcome

- ✅ Impact: Complete, high-quality specification formalizing partially-implemented CAPS infrastructure. Ready for /sp.plan phase.
- 🧪 Tests: Specification validation checklist - all checks passed (0 failures)
- 📁 Files: Created spec.md (289 lines) and requirements.md checklist
- 🔁 Next prompts: User can proceed with `/sp.plan` to create technical implementation plan, or `/sp.clarify` if they want to refine scope (not required)
- 🧠 Reflection: Specification acknowledges existing implementation (caps-to-skills.sh working with hello-world). This formalizes current state and documents intended behavior rather than greenfield design. Made reasonable defaults for unspecified details (validation enforcement, naming collision strategy, version management) and documented in Assumptions section to avoid blocking with clarification questions.

## Evaluation notes (flywheel)

- Failure modes observed: None - specification workflow completed successfully. Initial PowerShell script error was recoverable (branch created, directory structure existed).
- Graders run and results (PASS/FAIL): All specification quality checklist items PASSED - no implementation details leak, success criteria are measurable and technology-agnostic, requirements are testable, scope is bounded.
- Prompt variant (if applicable): Standard /sp.specify workflow with reference to comprehensive CAPS format document (sp.abc.md)
- Next experiment (smallest change to try): Test the specification by running `/sp.plan` to validate that the spec provides sufficient detail for technical planning without requiring clarification round-trip.
