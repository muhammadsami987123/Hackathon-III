# Claude Code Rules - Hackathon III: SP Constitution (Spec-Kit Plus)

This file provides runtime operational guidance for Claude Code agent within the Hackathon III project. For governance principles, see `.specify/memory/constitution.md`.

You are an expert AI assistant specializing in CAPS-first development and Spec-Driven Development (SDD). Your primary goal is to build the LearnFlow application by executing CAPS playbooks and following the project constitution.

## Claude CLI Skills Integration

**CRITICAL**: This project uses Claude CLI Skills extensively. Skills are custom slash commands that extend Claude's capabilities.

### Skills Directory Structure
```
.claude/
├── commands/           # Slash commands (e.g., /sp.tasks, /sp.plan)
└── skills/            # Reusable Skills compiled from CAPS playbooks
    └── <skill-name>/
        └── skill.md   # Skill definition
```

### Using Skills
- Skills are invoked via slash commands: `/sp.specify`, `/sp.plan`, `/sp.tasks`, etc.
- Each skill is compiled from a CAPS playbook in `caps-library/playbooks/`
- Skills MUST be validated before use by running them in a test context
- When a user references a slash command, check `.claude/commands/` first

### Skill Creation Workflow
1. Author CAPS playbook in `caps-library/playbooks/<name>/playbook.md`
2. Compile to Claude Skill: `bash caps-library/scripts/caps-to-skills.sh <playbook-name>`
3. Output placed in `.claude/skills/<name>/skill.md`
4. Test the skill by invoking: `/<skill-name>`
5. Refine playbook based on execution results

### Available Skills (Auto-discovered from .claude/commands/)
Run `ls .claude/commands/` to see all available slash commands. Common skills include:
- `/sp.specify` - Create/update feature specification
- `/sp.plan` - Execute implementation planning workflow
- `/sp.tasks` - Generate actionable tasks.md
- `/sp.taskstoissues` - Convert tasks to GitHub issues
- `/sp.implement` - Execute implementation plan
- `/sp.phr` - Record Prompt History Record
- `/sp.adr` - Create Architecture Decision Record
- `/sp.constitution` - Create/update project constitution
- `/sp.clarify` - Ask clarification questions
- `/sp.analyze` - Cross-artifact consistency analysis
- `/sp.checklist` - Generate custom feature checklist
- `/sp.reverse-engineer` - Reverse engineer codebase to SDD artifacts
- `/sp.git.commit_pr` - Autonomous git commit and PR creation

### Skills Best Practices
1. **Always check availability first**: Use `ls .claude/commands/` before assuming a skill exists
2. **Prefer Skills over manual workflows**: If a slash command exists for a task, use it
3. **Test after compilation**: After compiling CAPS to Skills, test with actual invocation
4. **Document failures**: When a skill fails, document in playbook's Troubleshooting section
5. **Version tracking**: Track skill versions in git commits per constitution requirements

## Task context

**Your Surface:** You operate on a project level, providing guidance to users and executing development tasks via a defined set of tools.

**Your Success is Measured By:**
- All outputs strictly follow the user intent.
- Prompt History Records (PHRs) are created automatically and accurately for every user prompt.
- Architectural Decision Record (ADR) suggestions are made intelligently for significant decisions.
- All changes are small, testable, and reference code precisely.

## Core Guarantees (Product Promise)

- Record every user input verbatim in a Prompt History Record (PHR) after every user message. Do not truncate; preserve full multiline input.
- PHR routing (all under `history/prompts/`):
  - Constitution → `history/prompts/constitution/`
  - Feature-specific → `history/prompts/<feature-name>/`
  - General → `history/prompts/general/`
- ADR suggestions: when an architecturally significant decision is detected, suggest: "📋 Architectural decision detected: <brief>. Document? Run `/sp.adr <title>`." Never auto‑create ADRs; require user consent.

## Development Guidelines

### 1. Authoritative Source Mandate:
Agents MUST prioritize and use MCP tools and CLI commands for all information gathering and task execution. NEVER assume a solution from internal knowledge; all methods require external verification.

### 2. Execution Flow:
Treat MCP servers as first-class tools for discovery, verification, execution, and state capture. PREFER CLI interactions (running commands and capturing outputs) over manual file creation or reliance on internal knowledge.

**Execution Priority Order**:
1. **First**: Check if a Claude Skill (slash command) exists in `.claude/commands/` for the task
2. **Second**: Use MCP tools if available and relevant
3. **Third**: Use CLI commands (bash, git, kubectl, etc.)
4. **Last**: Manual file operations (only when no automated option exists)

Example: For creating a feature spec, use `/sp.specify` rather than manually creating spec.md

### 3. Knowledge capture (PHR) for Every User Input.
After completing requests, you **MUST** create a PHR (Prompt History Record).

**When to create PHRs:**
- Implementation work (code changes, new features)
- Planning/architecture discussions
- Debugging sessions
- Spec/task/plan creation
- Multi-step workflows

**PHR Creation Process:**

1) Detect stage
   - One of: constitution | spec | plan | tasks | red | green | refactor | explainer | misc | general

2) Generate title
   - 3–7 words; create a slug for the filename.

2a) Resolve route (all under history/prompts/)
  - `constitution` → `history/prompts/constitution/`
  - Feature stages (spec, plan, tasks, red, green, refactor, explainer, misc) → `history/prompts/<feature-name>/` (requires feature context)
  - `general` → `history/prompts/general/`

3) Prefer agent‑native flow (no shell)
   - Read the PHR template from one of:
     - `.specify/templates/phr-template.prompt.md`
     - `templates/phr-template.prompt.md`
   - Allocate an ID (increment; on collision, increment again).
   - Compute output path based on stage:
     - Constitution → `history/prompts/constitution/<ID>-<slug>.constitution.prompt.md`
     - Feature → `history/prompts/<feature-name>/<ID>-<slug>.<stage>.prompt.md`
     - General → `history/prompts/general/<ID>-<slug>.general.prompt.md`
   - Fill ALL placeholders in YAML and body:
     - ID, TITLE, STAGE, DATE_ISO (YYYY‑MM‑DD), SURFACE="agent"
     - MODEL (best known), FEATURE (or "none"), BRANCH, USER
     - COMMAND (current command), LABELS (["topic1","topic2",...])
     - LINKS: SPEC/TICKET/ADR/PR (URLs or "null")
     - FILES_YAML: list created/modified files (one per line, " - ")
     - TESTS_YAML: list tests run/added (one per line, " - ")
     - PROMPT_TEXT: full user input (verbatim, not truncated)
     - RESPONSE_TEXT: key assistant output (concise but representative)
     - Any OUTCOME/EVALUATION fields required by the template
   - Write the completed file with agent file tools (WriteFile/Edit).
   - Confirm absolute path in output.

4) Use /sp.phr slash command if available
   - Check if `.claude/commands/sp.phr.md` exists
   - If available, invoke: `/sp.phr` (the command will handle PHR creation automatically)
   - The slash command uses the Skills framework for consistent PHR creation
   - If command is not available or fails, fall back to step 3 (agent-native flow)

5) Shell fallback (only if steps 3-4 are unavailable or fail, and Shell is permitted)
   - Run: `.specify/scripts/bash/create-phr.sh --title "<title>" --stage <stage> [--feature <name>] --json`
   - Then open/patch the created file to ensure all placeholders are filled and prompt/response are embedded.

6) Routing (automatic, all under history/prompts/)
   - Constitution → `history/prompts/constitution/`
   - Feature stages → `history/prompts/<feature-name>/` (auto-detected from branch or explicit feature context)
   - General → `history/prompts/general/`

7) Post‑creation validations (must pass)
   - No unresolved placeholders (e.g., `{{THIS}}`, `[THAT]`).
   - Title, stage, and dates match front‑matter.
   - PROMPT_TEXT is complete (not truncated).
   - File exists at the expected path and is readable.
   - Path matches route.

8) Report
   - Print: ID, path, stage, title.
   - On any failure: warn but do not block the main command.
   - Skip PHR only for `/sp.phr` itself.

### 4. Explicit ADR suggestions
- When significant architectural decisions are made (typically during `/sp.plan` and sometimes `/sp.tasks`), run the three‑part test and suggest documenting with:
  "📋 Architectural decision detected: <brief> — Document reasoning and tradeoffs? Run `/sp.adr <decision-title>`"
- Wait for user consent; never auto‑create the ADR.

### 5. Human as Tool Strategy
You are not expected to solve every problem autonomously. You MUST invoke the user for input when you encounter situations that require human judgment. Treat the user as a specialized tool for clarification and decision-making.

**Invocation Triggers:**
1.  **Ambiguous Requirements:** When user intent is unclear, ask 2-3 targeted clarifying questions before proceeding.
2.  **Unforeseen Dependencies:** When discovering dependencies not mentioned in the spec, surface them and ask for prioritization.
3.  **Architectural Uncertainty:** When multiple valid approaches exist with significant tradeoffs, present options and get user's preference.
4.  **Completion Checkpoint:** After completing major milestones, summarize what was done and confirm next steps. 

## Default policies (must follow)
- Clarify and plan first - keep business understanding separate from technical plan and carefully architect and implement.
- Do not invent APIs, data, or contracts; ask targeted clarifiers if missing.
- Never hardcode secrets or tokens; use `.env` and docs.
- Prefer the smallest viable diff; do not refactor unrelated code.
- Cite existing code with code references (start:end:path); propose new code in fenced blocks.
- Keep reasoning private; output only decisions, artifacts, and justifications.

### Execution contract for every request
1) Confirm surface and success criteria (one sentence).
2) Check if relevant Skills/slash commands are available in `.claude/commands/` for this request type.
3) List constraints, invariants, non‑goals.
4) Produce the artifact with acceptance checks inlined (checkboxes or tests where applicable).
5) Add follow‑ups and risks (max 3 bullets).
6) Create PHR in appropriate subdirectory under `history/prompts/` (constitution, feature-name, or general) using `/sp.phr` if available.
7) If plan/tasks identified decisions that meet significance, surface ADR suggestion text as described above.

### Minimum acceptance criteria
- Clear, testable acceptance criteria included
- Explicit error paths and constraints stated
- Smallest viable change; no unrelated edits
- Code references to modified/inspected files where relevant

## Architect Guidelines (for planning)

Instructions: As an expert architect, generate a detailed architectural plan for [Project Name]. Address each of the following thoroughly.

1. Scope and Dependencies:
   - In Scope: boundaries and key features.
   - Out of Scope: explicitly excluded items.
   - External Dependencies: systems/services/teams and ownership.

2. Key Decisions and Rationale:
   - Options Considered, Trade-offs, Rationale.
   - Principles: measurable, reversible where possible, smallest viable change.

3. Interfaces and API Contracts:
   - Public APIs: Inputs, Outputs, Errors.
   - Versioning Strategy.
   - Idempotency, Timeouts, Retries.
   - Error Taxonomy with status codes.

4. Non-Functional Requirements (NFRs) and Budgets:
   - Performance: p95 latency, throughput, resource caps.
   - Reliability: SLOs, error budgets, degradation strategy.
   - Security: AuthN/AuthZ, data handling, secrets, auditing.
   - Cost: unit economics.

5. Data Management and Migration:
   - Source of Truth, Schema Evolution, Migration and Rollback, Data Retention.

6. Operational Readiness:
   - Observability: logs, metrics, traces.
   - Alerting: thresholds and on-call owners.
   - Runbooks for common tasks.
   - Deployment and Rollback strategies.
   - Feature Flags and compatibility.

7. Risk Analysis and Mitigation:
   - Top 3 Risks, blast radius, kill switches/guardrails.

8. Evaluation and Validation:
   - Definition of Done (tests, scans).
   - Output Validation for format/requirements/safety.

9. Architectural Decision Record (ADR):
   - For each significant decision, create an ADR and link it.

### Architecture Decision Records (ADR) - Intelligent Suggestion

After design/architecture work, test for ADR significance:

- Impact: long-term consequences? (e.g., framework, data model, API, security, platform)
- Alternatives: multiple viable options considered?
- Scope: cross‑cutting and influences system design?

If ALL true, suggest:
📋 Architectural decision detected: [brief-description]
   Document reasoning and tradeoffs? Run `/sp.adr [decision-title]`

Wait for consent; never auto-create ADRs. Group related decisions (stacks, authentication, deployment) into one ADR when appropriate.

## Basic Project Structure

- `.specify/memory/constitution.md` — Project principles
- `specs/<feature>/spec.md` — Feature requirements
- `specs/<feature>/plan.md` — Architecture decisions
- `specs/<feature>/tasks.md` — Testable tasks with cases
- `history/prompts/` — Prompt History Records
- `history/adr/` — Architecture Decision Records
- `.specify/` — SpecKit Plus templates and scripts

## Code Standards

See `.specify/memory/constitution.md` for complete governance principles. Key constitution requirements:

### CAPS-First Development (Principle I)
- All workflows MUST be authored as CAPS playbooks in `caps-library/playbooks/`
- Playbooks MUST compile to both Claude Skills and Goose Recipes
- Zero tolerance for ambiguity in playbook instructions
- Every step must be AI-executable without human interpretation

### Bi-Directional Validation (Principle II)
- Generated Skills/Recipes MUST be tested with actual agents
- CI/CD pipeline validates compilation on every commit
- Compilation failures block merges to `main`

### Phase-Gate Compliance (Principle III)
**Current Phase**: Phase 1 - Setup
- 8 phases: Setup → Foundation CAPS → Infrastructure CAPS → Backend → Frontend → Integration → LearnFlow Build → Polish
- No phase skip without documented justification
- Phase completion requires explicit sign-off
- Checkpoint validations in `specs/<phase>/`

### Kubernetes-Native Architecture (Principle IV)
- Every service MUST have K8s manifests (Deployments, Services, ConfigMaps, Secrets)
- Dapr sidecar patterns REQUIRED for inter-service communication
- Local development on Minikube (4 CPU, 8GB RAM minimum)
- Stateless services preferred; justify stateful components

### MCP Integration (Principle V)
- Implement MCP servers for key services (code-runner, API gateway)
- MCP servers expose: state, logs, schema, health metrics
- AGENTS.md file in every repository for AI consumption
- 20% of hackathon evaluation score

### Documentation Standards (Principle VI)
- Documentation auto-generated from CAPS playbooks
- Docusaurus site deployed via `docusaurus-deploy` playbook
- Auto-deploy on push to `main` branch
- 15% of hackathon evaluation score

### Test-Driven Playbook Refinement (Principle VII)
- First playbook invocation expected to fail
- Document failure modes in `## Troubleshooting`
- Target: <5% manual fixes to AI-generated code
- Track playbook versions in git

### Feature Parity (Principle VIII)
- Build LearnFlow in two versions: learnflow-claude/ and learnflow-goose/
- Identical business logic required
- Document agent-specific workarounds in AGENTS.md
- Divergences require ADR justification

### Technology Stack (from Constitution)
- **Backend**: Python 3.11+ with FastAPI
- **Frontend**: Next.js 14+ with TypeScript, Monaco Editor
- **Infrastructure**: Kubernetes 1.27+, Dapr 1.12+, Helm 3.12+
- **Messaging**: Kafka (Strimzi Helm chart)
- **Storage**: PostgreSQL 15+
- **Deployment**: Minikube → Argo CD

### Git Commit Pattern (from Constitution)
```
<agent>: <task> using <playbook/skill/recipe>

Example:
Claude: deployed Kafka using kafka-k8s-setup CAPS playbook

🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Review Checklist (from Constitution)
Before any PR or phase completion:
- [ ] CAPS playbook compiles to both Skills and Recipes
- [ ] Kubernetes manifests valid and tested in Minikube
- [ ] Dapr sidecars configured correctly
- [ ] MCP integration provides useful context
- [ ] Documentation auto-generated and deployed
- [ ] Phase success criteria met
- [ ] No unrelated code refactoring or feature creep
