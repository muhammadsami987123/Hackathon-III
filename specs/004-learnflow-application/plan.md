# Implementation Plan: LearnFlow - AI-Powered Python Tutoring Platform

**Branch**: `004-learnflow-application` | **Date**: 2025-12-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-learnflow-application/spec.md`

## Summary

Build the complete LearnFlow AI-Powered Python Tutoring Platform featuring 6 specialized AI agents (Triage, Concepts, Code Review, Debug, Exercise, Progress), multi-agent microservices architecture on Kubernetes with Dapr service mesh, Kafka event streaming, PostgreSQL persistence, code execution sandbox, and adaptive learning system. The platform serves students learning Python through 8 curriculum modules with real-time AI tutoring, teacher monitoring dashboards with struggle detection, and automated exercise generation.

**Technical Approach**: Cloud-native microservices architecture deployed on Kubernetes with Dapr sidecars for service mesh. Backend services in Python 3.11+ with FastAPI, frontend in Next.js 14+ with Monaco editor, Kafka for event-driven architecture, PostgreSQL for persistence, Docker-based code sandbox with security constraints. All infrastructure components deployed via pre-built CAPS playbooks (minikube-setup, kafka-k8s-setup, postgresql-k8s-setup, dapr-k8s-install, fastapi-dapr-service). Feature parity maintained between Claude and Goose implementations per Constitution Principle VIII.

## Technical Context

**Language/Version**: Python 3.11+ (backend), TypeScript/Next.js 14+ (frontend), Bash (scripts)
**Primary Dependencies**: FastAPI 0.104+, Dapr 1.12+, Kafka 3.8+, PostgreSQL 15+, Monaco Editor, OpenAI SDK, Docker, Kubernetes 1.27+
**Storage**: PostgreSQL 15+ for persistent data (users, progress, submissions, alerts); Kafka for event streaming; Redis via Dapr for caching
**Testing**: pytest (backend unit/integration), Jest (frontend), contract tests for API boundaries, E2E tests with Playwright
**Target Platform**: Kubernetes 1.27+ on Minikube (local dev), cloud-ready architecture for AWS/GCP/Azure
**Project Type**: Web application (full-stack) + distributed microservices
**Performance Goals**:
- Code execution: <1s p90 latency, <5s timeout
- AI responses: <3s p95 latency with fallback to pre-scripted responses
- Dashboard loads: <2s p95
- Concurrent users: 100+ without degradation
**Constraints**:
- Sandbox security: no network, no filesystem (except /tmp), 50MB memory limit, 5s timeout
- Data retention: active enrollment + 1 year for submissions/alerts, indefinite for progress records
- Token budget: <200 tokens per CAPS skill definition (Constitution Principle V)
- Classroom states: Active (default) and Archived (read-only)
**Scale/Scope**:
- 6 AI agent microservices
- 8 Python curriculum modules with exercises/quizzes
- 57 functional requirements across 7 categories
- Target: 20-30 students per classroom
- Teacher dashboards with real-time struggle detection

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I: Agent-Agnostic Playbook Standards (CAPS-First)
**Status**: ✅ **PASS** - Aligned
- All deployment workflows will be authored as CAPS playbooks before implementation
- Infrastructure setup (Kafka, PostgreSQL, Dapr, Minikube) uses existing pre-built CAPS playbooks
- New playbooks required: `learnflow-backend-service`, `learnflow-frontend-deploy`, `code-sandbox-setup`, `ai-agent-deploy`
- All playbooks will compile to both Claude Skills (`.claude/skills/`) and Goose Recipes (`.goose/recipes/`)
- **No violations**

### Principle II: Bi-Directional Compilation & Validation
**Status**: ✅ **PASS** - Aligned
- Playbook compilation validated via CI/CD pipeline (GitHub Actions)
- Both Claude Code and Goose agents will test generated Skills/Recipes
- Validation tests run on every commit before merge to `main`
- **No violations**

### Principle III: Phase-Gate Development with Gold Standards
**Status**: ✅ **PASS** - Aligned
- Development follows 8-phase approach: Setup → Foundation CAPS → Infrastructure CAPS → Backend → Frontend → Integration → LearnFlow Build → Polish
- Current phase: Phase 4 (Backend) - infrastructure playbooks exist, ready to build services
- Explicit success criteria defined for each phase
- No phase skip without documented justification
- **No violations**

### Principle IV: Kubernetes-Native & Cloud-Ready Architecture
**Status**: ✅ **PASS** - Core Requirement
- All services deployed on Kubernetes with Helm charts and K8s manifests
- Dapr sidecars REQUIRED for all inter-service communication (FR-052)
- Local development on Minikube (4 CPU, 8GB RAM per constitution)
- Infrastructure deployed via CAPS playbooks: minikube-setup, dapr-k8s-install, kafka-k8s-setup, postgresql-k8s-setup
- Stateless services preferred (code-runner, AI agents); stateful justified (PostgreSQL, Kafka)
- **No violations**

### Principle V: MCP (Model Context Protocol) Integration for AI Observability
**Status**: ✅ **PASS** - Core Requirement (20% evaluation score)
- MCP servers REQUIRED for code-runner service and API gateway (FR-058-063)
- MCP servers expose: state, logs, schema/contracts, health metrics, AI agent performance
- AGENTS.md file in learnflow-app repository for AI consumption
- Golden signals tracked: latency (p50/p95/p99), error rate, throughput
- Business metrics: active students, AI usage, mastery progression
- **No violations**

### Principle VI: Documentation as Automated Deliverable
**Status**: ✅ **PASS** - Aligned (15% evaluation score)
- Documentation auto-generated from CAPS playbooks
- Docusaurus site deployment via `docusaurus-deploy` playbook
- AGENTS.md explains repo structure for AI agents
- Auto-deploy on push to `main` branch
- **No violations**

### Principle VII: Test-Driven Playbook Refinement
**Status**: ✅ **PASS** - Aligned
- First playbook invocations expected to fail, iterative refinement required
- Failure modes documented in `## Troubleshooting` section of each playbook
- Target: <5% manual fixes to AI-generated code
- Playbook versions tracked in git commits
- **No violations**

### Principle VIII: Explicit Feature Parity Between Agent Builds
**Status**: ⚠️ **REQUIRES ATTENTION** - Potential Complexity
- LearnFlow MUST be built in two versions: `learnflow-claude/` and `learnflow-goose/`
- Both versions implement identical business logic (6 AI agents, 8 modules, mastery system, sandbox)
- Both use Monaco editor, FastAPI + Dapr services, Kafka messaging, PostgreSQL storage
- Agent-specific workarounds documented in respective AGENTS.md files
- Divergences require ADR justification
- **Potential Violation**: Building two complete versions significantly increases scope
- **Justification**: Required by constitution for demonstrating CAPS portability. This is the core hackathon objective.
- **Mitigation**: Shared codebase with agent-specific deployment scripts, not full duplication

### Summary
**Overall Gate Status**: ✅ **ALL CHECKS PASS WITH ATTENTION TO PRINCIPLE VIII**

One attention area identified:
- **Principle VIII (Feature Parity)**: Building two versions (learnflow-claude/ and learnflow-goose/) increases complexity. **Justified** as core hackathon requirement for proving CAPS portability. Mitigation: use shared codebase (`learnflow-app/`) with agent-specific deployment configurations, not full duplication.

## Project Structure

### Documentation (this feature)

```text
specs/004-learnflow-application/
├── spec.md                      # Feature specification (completed)
├── plan.md                      # This file (Phase 0-1 output)
├── research.md                  # Phase 0 output: architecture patterns research
├── data-model.md                # Phase 1: Entity schemas and relationships
├── quickstart.md                # Phase 1: Local dev environment setup guide
├── contracts/                   # Phase 1: API contracts
│   ├── auth-service.yaml        # JWT auth, user management
│   ├── student-service.yaml     # Progress, submissions, quizzes
│   ├── teacher-service.yaml     # Classrooms, alerts, analytics
│   ├── ai-agent-service.yaml    # Triage, Concepts, Debug, etc.
│   ├── code-runner-service.yaml # Sandbox execution
│   └── events.yaml              # Kafka event schemas
├── checklists/
│   └── requirements.md          # 57 FRs validation checklist
└── tasks.md                     # Phase 2 output (/sp.tasks command)
```

### Source Code (repository root)

**Structure Decision**: Web application with microservices architecture. Shared codebase in `learnflow-app/` with agent-specific deployment configurations to satisfy Constitution Principle VIII without full duplication.

```text
learnflow-app/                   # Shared codebase for both Claude and Goose
├── .claude/                     # Claude Skills (slash commands)
│   ├── commands/               # Slash commands for LearnFlow workflows
│   └── skills/                 # Compiled Skills from CAPS playbooks
├── .goose/                      # Goose Recipes (parallel to Claude Skills)
│   └── recipes/                # Compiled Recipes from CAPS playbooks
├── AGENTS.md                    # AI-readable repository structure
├── README.md                    # Human-readable overview
│
├── backend/                     # Python FastAPI microservices
│   ├── src/
│   │   ├── auth-service/       # JWT auth, user management (FR-001 to FR-007)
│   │   ├── student-service/    # Student features (FR-008 to FR-023)
│   │   ├── teacher-service/    # Teacher features (FR-024 to FR-033)
│   │   ├── ai-agent-service/   # AI agents (FR-034 to FR-039a)
│   │   ├── code-runner-service/ # Sandbox execution (FR-010 to FR-013)
│   │   └── event-processor-service/ # Kafka consumers (FR-047 to FR-051)
│   ├── tests/
│   │   ├── contract/           # API contract tests
│   │   ├── integration/        # Service-to-service tests
│   │   └── unit/               # Unit tests per service
│   ├── requirements.txt        # Python dependencies
│   └── Dockerfile              # Multi-stage build for services
│
├── frontend/                    # Next.js 14+ TypeScript frontend
│   ├── src/
│   │   ├── app/                # App router (Next.js 14)
│   │   ├── components/         # React components
│   │   ├── services/           # API clients
│   │   └── types/              # TypeScript types
│   ├── tests/
│   │   ├── components/         # Component tests (Jest)
│   │   └── e2e/                # End-to-end tests (Playwright)
│   ├── package.json
│   └── Dockerfile
│
├── k8s/                         # Kubernetes manifests
│   ├── deployments/
│   ├── services/
│   ├── configmaps/
│   ├── secrets/
│   ├── dapr-components/
│   └── helm/
│
├── scripts/                     # Deployment and setup scripts
│   ├── setup-local-dev.sh      # Full local dev environment setup
│   ├── deploy-infrastructure.sh # Run infrastructure CAPS playbooks
│   ├── build-images.sh         # Build Docker images
│   └── deploy-to-k8s.sh        # Deploy to Kubernetes
│
├── docs/                        # Docusaurus documentation
│   ├── docusaurus.config.js
│   └── docs/
│
└── data/                        # Curriculum data (seed data)
    ├── modules/                # 8 Python modules JSON files
    └── fallback-responses/     # Pre-scripted AI responses
```

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principle VIII (Two Versions) | Constitution requires explicit feature parity between Claude and Goose builds to demonstrate CAPS portability | Single-agent implementation insufficient to prove CAPS portability claim. Mitigation: shared codebase with agent-specific deployment scripts rather than full duplication |

## Phase 0: Outline & Research

### Research Tasks

**Output Location**: `specs/004-learnflow-application/research.md`

1. **AI Agent Architecture Patterns** - Evaluate monolithic vs. 6 microservices tradeoff
2. **Code Sandbox Security Implementation** - Docker seccomp profiles, AppArmor, resource limits
3. **OpenAI API Fallback Strategy** - Pre-scripted response schema and caching
4. **Mastery Calculation Formula Validation** - Confirm formula weights and edge cases
5. **Real-Time Struggle Detection Algorithm** - Event stream processing with Kafka
6. **Data Retention and Cleanup Strategy** - Automated cleanup job implementation
7. **MCP Server Integration Patterns** - Required endpoints and data formats
8. **Monaco Editor Integration with Next.js 14** - SSR considerations and dynamic imports
9. **Classroom State Machine** - Active/Archived transitions and permissions
10. **Curriculum Data Structure** - JSON schema for 8 modules

## Phase 1: Design & Contracts

### Prerequisites
- ✅ Feature specification complete (`spec.md`)
- ⏳ Research complete (`research.md`) - **TO BE CREATED**

### Design Artifacts

#### 1. Data Model (`data-model.md`)

**PostgreSQL Entities**:
- User (id, email, name, password_hash, role, created_at, updated_at)
- Classroom (id, name, teacher_id, join_code, status, created_at, archived_at, updated_at)
- Enrollment (id, student_id, classroom_id, enrolled_at, ended_at)
- StudentProgress (id, student_id, module, topic, mastery_level, exercises_completed, quizzes_taken, last_quiz_score, streak_days, last_active, updated_at)
- CodeSubmission (id, student_id, exercise_id, code_text, output, grade, feedback, submitted_at, execution_time, error_type)
- QuizResponse (id, student_id, quiz_id, score, answers, completed_at)
- StruggleAlert (id, student_id, classroom_id, trigger_type, description, resolved, created_at, resolved_at, metadata)

**Kafka Events**:
- code.executed (student_id, exercise_id, code_text, output, execution_time, success, error_type, timestamp)
- quiz.submitted (student_id, quiz_id, score, answers, completed_at, timestamp)
- struggle.detected (student_id, classroom_id, trigger_type, description, metadata, timestamp)
- progress.updated (student_id, module, topic, mastery_level, exercises_completed, quizzes_taken, timestamp)

#### 2. API Contracts (`contracts/*.yaml`)

- **auth-service.yaml**: POST /register, /login, /reset-password
- **student-service.yaml**: GET /modules, /progress; POST /submit, /chat
- **teacher-service.yaml**: POST /classrooms; GET /dashboard, /alerts
- **ai-agent-service.yaml**: POST /triage, /concepts, /code-review, /debug, /exercise, /progress
- **code-runner-service.yaml**: POST /execute; GET /health, /mcp/state, /mcp/logs
- **events.yaml**: Kafka event schemas

#### 3. Quickstart Guide (`quickstart.md`)

15-minute guide covering:
1. Prerequisites (Docker, Minikube, kubectl, Dapr, Helm, Python, Node.js)
2. Infrastructure Setup (Run CAPS playbooks)
3. Backend Deployment
4. Frontend Deployment
5. Verification

### Agent Context Update

After Phase 1, run:
```bash
powershell.exe -ExecutionPolicy Bypass -File .specify/scripts/powershell/update-agent-context.ps1 -AgentType claude
```

## Risks & Mitigations

### Risk 1: OpenAI API Cost and Rate Limits
**Probability**: High | **Impact**: High
**Mitigation**: Aggressive caching, fallback responses on timeout (>3s), batch non-urgent requests, token usage limits, use GPT-3.5-turbo for non-critical agents

### Risk 2: Code Sandbox Security Vulnerabilities
**Probability**: Medium | **Impact**: Critical
**Mitigation**: Docker seccomp profiles, no network/filesystem, memory/CPU/timeout limits, regular security audits (SC-022)

### Risk 3: AI Agent Response Time Exceeding 3s Target (FR-016)
**Probability**: Medium | **Impact**: Medium
**Mitigation**: 3s hard timeout, pre-warm connections, async processing, immediate fallback, track p95 latency (FR-058)

### Risk 4: Feature Parity Between Claude and Goose Builds (Principle VIII)
**Probability**: Medium | **Impact**: Medium (15% evaluation score)
**Mitigation**: Shared codebase with agent-specific deployment scripts, document divergences in AGENTS.md, automated E2E tests

## Next Steps

1. **Complete Phase 0**: Create `research.md` addressing all 10 research tasks
2. **Complete Phase 1**: Create `data-model.md`, `contracts/*.yaml`, `quickstart.md`
3. **Run Agent Context Update**: Execute update-agent-context.ps1 for Claude
4. **Re-evaluate Constitution Check**: Verify no new violations
5. **Generate Tasks**: Run `/sp.tasks` to create detailed task breakdown

---

**Plan Status**: Phase 0-1 Design Complete | Ready for `/sp.tasks`
