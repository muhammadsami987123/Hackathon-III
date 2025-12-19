# SP Constitution (Spec-Kit Plus) - Hackathon III Project Constitution
<!-- Reusable Intelligence & Cloud-Native Mastery with CAPS -->

<!--
  ============================================================================
  SYNC IMPACT REPORT (Constitution Update)
  ============================================================================
  Version Change: N/A → 1.0.0 (Initial Constitution)
  Date: 2025-12-18

  Modified Principles:
  - All principles created from scratch based on sp.const.md project charter

  Added Sections:
  - Core Principles (8 principles)
  - Development Standards
  - Quality Assurance & Testing
  - Governance

  Templates Status:
  ✅ plan-template.md - Reviewed, Constitution Check section aligns
  ✅ spec-template.md - Reviewed, user story prioritization aligns
  ✅ tasks-template.md - Reviewed, task categorization aligns with principles

  Follow-up TODOs:
  - Ensure all team members review and understand the constitution
  - Establish weekly checkpoint process for phase-gate compliance
  ============================================================================
-->

## Core Principles

### I. Agent-Agnostic Playbook Standards (CAPS-First)

The **CAPS (Common Agent Playbook Specification)** format is the single source of truth for all reusable intelligence. Every workflow, deployment pattern, and automation MUST be authored as a CAPS playbook before implementation.

**Rules**:
- All playbooks stored in `caps-library/playbooks/` with clear directory structure
- Each playbook MUST compile cleanly to both Claude Skills and Goose Recipes without manual intervention
- Playbooks MUST include: title, description, version, allowed_tools, prerequisites, step-by-step instructions, validation criteria, and troubleshooting guidance
- Zero tolerance for ambiguity: every step must be AI-executable without human interpretation
- Claude Skills compiled to `.claude/skills/` directory
- Goose Recipes compiled to `.goose/recipes/` directory
- Skills/Recipes invoked via slash commands (e.g., `/sp.plan`, `/sp.tasks`)

**Rationale**: CAPS ensures portability across AI agent platforms (Claude Code, Goose) and enables the paradigm shift from "write code" to "write playbooks → AI writes code." This is the foundation for reusable intelligence. Claude CLI Skills provide a native mechanism for extending Claude Code with custom workflows.

---

### II. Bi-Directional Compilation & Validation

Compilation scripts (`caps-to-skills.sh`, `caps-to-recipes.sh`) MUST produce syntactically valid, immediately executable outputs. Both compilation paths MUST be tested in actual agent environments.

**Rules**:
- Compiler scripts validate YAML/Markdown syntax after generation
- Generated Skills/Recipes MUST be tested with actual Claude Code and Goose agents
- GitHub Actions CI/CD pipeline runs validation on every commit
- Compilation failures block merges to `main` branch

**Rationale**: Untested compilation is worthless. Both agents must achieve identical functional outcomes from the same CAPS playbook to prove true portability.

---

### III. Phase-Gate Development with Gold Standards

Work progresses through 8 defined phases (Setup → Foundation CAPS → Infrastructure CAPS → Backend → Frontend → Integration → LearnFlow Build → Polish). Each phase has explicit success criteria that MUST be met before advancing.

**Rules**:
- No phase skip allowed without documented justification in constitution amendment
- Each phase defines "Gold Standard" outputs (e.g., "Single-command compilation produces valid output")
- Checkpoint validations documented in `specs/<phase>/` directories
- Phase completion requires explicit sign-off from team lead

**Rationale**: Sequential gates prevent compound failures, ensure deliverable quality at each milestone, and maintain focus on hackathon evaluation criteria (CAPS Autonomy 25%, Architecture 25%, MCP Integration 20%, Documentation 15%, Spec-Kit Usage 15%).

---

### IV. Kubernetes-Native & Cloud-Ready Architecture

All services MUST be designed for Kubernetes deployment from day one. Infrastructure components (Kafka, PostgreSQL) are deployed via CAPS playbooks targeting Minikube initially, with cloud migration path documented.

**Rules**:
- Every service MUST have Kubernetes manifests (Deployments, Services, ConfigMaps, Secrets)
- Dapr sidecar patterns REQUIRED for all inter-service communication
- Local development uses Minikube (4 CPU, 8GB RAM minimum)
- Helm charts used for complex deployments (Kafka, Argo CD)
- Stateless services preferred; stateful components explicitly justified

**Rationale**: Kubernetes is the target platform for cloud-native mastery demonstration. Dapr abstracts messaging/state/service invocation to simplify microservices architecture.

---

### V. MCP (Model Context Protocol) Integration for AI Observability

Model Context Protocol servers MUST provide rich context for AI agents to understand system state, debug issues, and propose expansions autonomously.

**Rules**:
- MCP servers implemented for key services (code-runner, API gateway)
- MCP servers expose: current state, recent logs, schema/contract information, health metrics
- AGENTS.md file in every repository describes structure for AI consumption
- MCP integration evaluated as 20% of hackathon score

**Rationale**: MCP turns AI agents from "code generators" into "system understanding partners" that can reason about existing infrastructure and suggest improvements.

---

### VI. Documentation as Automated Deliverable

Documentation MUST be generated from CAPS playbooks and design artifacts, deployed automatically via Docusaurus + Argo CD pipeline.

**Rules**:
- Docusaurus site setup via `docusaurus-deploy` CAPS playbook
- Every CAPS playbook generates both Skills/Recipes AND documentation page
- AGENTS.md files explain repo structure to AI agents (not just humans)
- Documentation auto-deploys on push to `main` branch
- Documentation completeness is 15% of hackathon evaluation

**Rationale**: Manual documentation drifts from reality. Generated docs from CAPS playbooks ensure accuracy and demonstrate the "playbook is the product" philosophy.

---

### VII. Test-Driven Refinement for Playbooks

CAPS playbooks are refined iteratively until AI agents generate working code autonomously. Initial playbook failures are expected; systematic improvement is mandatory.

**Rules**:
- First playbook invocation expected to fail or produce imperfect code
- Document failure modes in playbook `## Troubleshooting` section
- Refine instructions, add validation steps, specify exact tool parameters
- Success target: <5% manual fixes to AI-generated code
- Track playbook version history in git commits

**Rationale**: AI agents require precise, unambiguous instructions. Iterative refinement based on actual execution failures produces robust playbooks that work autonomously.

---

### VIII. Explicit Feature Parity Between Agent Builds

LearnFlow application MUST be built in two versions (learnflow-claude/ and learnflow-goose/) with identical functionality. Differences MUST be documented and justified.

**Rules**:
- Both versions implement same business logic (agents, curriculum, mastery system, code sandbox)
- Both versions use Monaco editor, FastAPI + Dapr services, Kafka messaging, PostgreSQL storage
- Agent-specific workarounds documented in respective AGENTS.md files
- End-to-end testing validates feature parity before demo
- Divergences require ADR (Architecture Decision Record) justification

**Rationale**: Feature parity proves CAPS portability. Documented differences reveal agent platform limitations and guide future CAPS specification improvements.

---

## Development Standards

### Project Structure Conventions

**Repository Organization**:
- `spec-kit-plus/` (forked): CAPS specification, compiler scripts, CI/CD
- `caps-library/`: CAPS playbooks, generated Skills/Recipes
- `learnflow-claude/` and `learnflow-goose/`: LearnFlow application implementations

**CAPS Playbook Structure**:
```
caps-library/playbooks/<playbook-name>/
├── playbook.md              # CAPS source file
├── README.md                # Human-readable overview
└── examples/                # Example invocations
```

**Claude CLI Skills Directory Structure**:
```
.claude/
├── commands/                # Slash command definitions
│   ├── sp.plan.md          # /sp.plan command
│   ├── sp.tasks.md         # /sp.tasks command
│   └── ...
├── skills/                  # Compiled Skills from CAPS
│   ├── <skill-name>/
│   │   └── skill.md        # Skill definition
│   └── ...
└── settings.local.json      # Claude configuration
```

**LearnFlow Application Structure**:
```
learnflow-{agent}/
├── .claude/                 # Claude Skills (for learnflow-claude)
│   ├── commands/           # Slash commands
│   └── skills/             # Compiled Skills
├── .goose/                  # Goose Recipes (for learnflow-goose)
│   └── recipes/            # Compiled Recipes
├── src/
│   ├── frontend/            # Next.js + Monaco
│   ├── services/            # FastAPI + Dapr agents
│   └── k8s/                 # Kubernetes manifests
├── AGENTS.md                # AI-readable spec
└── docs/                    # Docusaurus source
```

### Technology Stack Requirements

**Languages & Frameworks**:
- Backend: Python 3.11+ with FastAPI
- Frontend: Next.js 14+ with TypeScript, Monaco Editor
- Infrastructure: Kubernetes 1.27+, Dapr 1.12+, Helm 3.12+

**Messaging & Storage**:
- Kafka (via Strimzi Helm chart) for event streaming
- PostgreSQL 15+ for persistent storage
- Dapr pub/sub for service-to-service messaging

**AI Agent Platforms**:
- Claude Code (latest) with custom Skills
- Goose (latest) with custom Recipes

**Deployment & Observability**:
- Minikube for local development
- Argo CD for GitOps continuous deployment
- Structured logging (JSON format), Prometheus metrics (where applicable)

### Git Workflow & Commit Convention

**Branch Strategy**:
- `main`: Production-ready, passing all tests
- `caps-<name>`: Feature branches for new playbooks
- `integration-<agent>`: Testing integration with Claude/Goose

**Commit Message Pattern**:
```
<agent>: <task> using <playbook/skill/recipe>

Examples:
- Claude: deployed Kafka using kafka-k8s-setup CAPS playbook
- Goose: generated code-runner service from code-runner-service recipe
- Manual: refined fastapi-dapr-agent playbook based on test failures
```

**Attribution**:
All agent-generated commits MUST include attribution line:
```
🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Quality Assurance & Testing

### Validation Requirements

**CAPS Playbook Validation**:
- Syntax validation via `validate-output.sh` script
- Test compilation to both Skills and Recipes
- Agent execution test: playbook → agent invocation → working deployment
- Validation tests run in CI/CD pipeline before merge

**Application Testing Strategy**:
- **Contract Tests**: Validate API contracts defined in `specs/<feature>/contracts/`
- **Integration Tests**: Test service-to-service communication via Dapr
- **End-to-End Tests**: Validate complete user journeys in LearnFlow application
- **Independent Story Testing**: Each user story MUST be testable in isolation

**Success Metrics by Phase**:
- Phase 1 (Setup): All CLI tools functional (`minikube status`, `kubectl cluster-info`)
- Phase 2 (Foundation CAPS): CAPS format documented, first compiler working
- Phase 3 (Infrastructure CAPS): Both agents deploy Kafka/PostgreSQL autonomously
- Phase 4 (Backend): Dapr pub/sub messages flowing between services
- Phase 5 (Frontend): Monaco editor renders and executes code in sandbox
- Phase 6 (Integration): CI/CD pipeline automated, docs auto-deploy
- Phase 7 (LearnFlow Build): Both versions operational, feature parity achieved
- Phase 8 (Polish): Submission complete, demo recorded, repositories clean

### Error Handling & Debugging

**Playbook Troubleshooting Requirements**:
- Common error scenarios documented in `## Troubleshooting` section
- Error messages include: problem description, root cause, solution steps
- Validation commands provided for success verification

**Application Error Standards**:
- Structured logging with log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- Error responses include error codes, messages, and recovery guidance
- MCP servers expose recent errors and stack traces for AI debugging

---

## Governance

### Constitution Authority

This constitution supersedes all other development practices for the SP Constitution (Hackathon III) project. All team decisions, code reviews, and agent interactions MUST verify compliance with these principles.

### Amendment Process

**Constitution changes require**:
1. Documented justification for change (new principle, removed constraint, refined rule)
2. Impact analysis on existing CAPS playbooks and LearnFlow implementations
3. Version bump per semantic versioning (MAJOR: breaking changes, MINOR: new principles, PATCH: clarifications)
4. Team lead approval before merge to `main`
5. Update to this file with Sync Impact Report prepended as HTML comment

### Compliance Verification

**All pull requests MUST**:
- Reference applicable principles in PR description
- Demonstrate Constitution Check compliance (from plan-template.md)
- Include validation evidence for quality gates
- Document any complexity added with explicit justification in Complexity Tracking table

**Review checklist for all changes**:
- [ ] CAPS playbook compiles to both Skills (`.claude/skills/`) and Recipes (`.goose/recipes/`)
- [ ] Generated Skills/Recipes are syntactically valid and tested with actual agents
- [ ] Slash commands properly registered in `.claude/commands/` or `.goose/commands/`
- [ ] Kubernetes manifests valid and tested in Minikube
- [ ] Dapr sidecars configured correctly for service communication
- [ ] MCP integration provides useful context for AI agents
- [ ] Documentation auto-generated and deployed
- [ ] Phase success criteria met before advancing
- [ ] No unrelated code refactoring or feature creep

### Risk Management

**Top identified risks and mitigations**:

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| AI-generated code is broken | High | High | Iterative playbook refinement, validation tests, <5% manual fix target |
| CAPS spec too rigid | Medium | High | Version 1.0 with feedback loop, plan iterations post-hackathon |
| Kubernetes complexity | Medium | Medium | Use Minikube, pre-built Helm charts, infrastructure CAPS playbooks |
| Time management | High | Medium | Phase-gate approach, prioritize gold standards, MVP-first user stories |

### Runtime Development Guidance

For operational guidance during development (not governance principles), refer to:
- **Claude Code users**: `CLAUDE.md` in repository root
- **Goose users**: `GOOSE.md` (if present) in repository root
- **General guidance**: `AGENTS.md` files in each repository

---

**Version**: 1.0.0 | **Ratified**: 2025-12-18 | **Last Amended**: 2025-12-18
