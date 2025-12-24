---
id: 001
title: Research Technical Decisions for LearnFlow
stage: plan
date: 2025-12-22
surface: agent
model: claude-sonnet-4-5-20250929
feature: 004-learnflow-application
branch: 004-learnflow-application
user: muhammadsami987123
command: Create comprehensive research.md file
labels: ["research", "architecture", "technical-decisions", "learnflow"]
links:
  spec: specs/004-learnflow-application/spec.md
  ticket: null
  adr: null
  pr: null
files:
 - specs/004-learnflow-application/research.md
tests:
 - Validated all 10 research tasks addressed
 - Verified technical decisions align with Constitution principles
 - Confirmed implementation notes are concrete and actionable
---

## Prompt

Create comprehensive research.md file at F:\Hackathon\Hackathon III\specs\004-learnflow-application\research.md

This file should address all 10 research tasks listed in the plan.md file:

1. AI Agent Architecture Patterns - Evaluate monolithic vs. 6 microservices tradeoff
2. Code Sandbox Security Implementation - Docker seccomp profiles, AppArmor, resource limits
3. OpenAI API Fallback Strategy - Pre-scripted response schema and caching
4. Mastery Calculation Formula Validation - Confirm formula weights and edge cases
5. Real-Time Struggle Detection Algorithm - Event stream processing with Kafka
6. Data Retention and Cleanup Strategy - Automated cleanup job implementation
7. MCP Server Integration Patterns - Required endpoints and data formats
8. Monaco Editor Integration with Next.js 14 - SSR considerations and dynamic imports
9. Classroom State Machine - Active/Archived transitions and permissions
10. Curriculum Data Structure - JSON schema for 8 modules

For each research task, provide:
- **Decision**: What was chosen
- **Rationale**: Why it was chosen
- **Alternatives Considered**: What else was evaluated
- **Implementation Notes**: Specific technical details

Focus on best practices for:
- Python 3.11+ with FastAPI
- Kubernetes + Dapr architecture
- Docker security for code sandboxes
- Next.js 14 App Router
- OpenAI SDK integration
- Kafka event streaming

The research should resolve all "NEEDS CLARIFICATION" items and provide concrete technical decisions ready for implementation.

## Response snapshot

Created comprehensive research.md file addressing all 10 research tasks with the following key technical decisions:

**1. AI Agent Architecture**: 6 specialized microservices (Triage, Concepts, Code Review, Debug, Exercise, Progress) deployed on Kubernetes with Dapr sidecars. Rationale: Independent scaling, failure isolation, leverages K8s strengths. Shared base class and utilities prevent code duplication.

**2. Code Sandbox Security**: Multi-layer security with Docker seccomp profiles, no-new-privileges flag, read-only root filesystem, network isolation, and resource limits (50MB memory, 5s timeout). Whitelisted Python libraries only (numpy, matplotlib, pandas). Kubernetes NetworkPolicy blocks all egress.

**3. OpenAI API Fallback**: Two-tier system with Redis caching (24-hour TTL) and pre-scripted fallback responses by topic. Cache hit target >70%, cost savings 60-80%. Fallback disclaimer: "AI unavailable - showing general guidance."

**4. Mastery Calculation**: Formula: (Exercises×0.40) + (Quizzes×0.30) + (Code Quality×0.20) + (Streak×0.10). Uses latest quiz score (not average) to reflect current understanding. Mastery levels: Beginner (0-40%), Learning (41-70%), Proficient (71-90%), Mastered (91-100%).

**5. Struggle Detection**: Kafka consumer processes code.executed, quiz.submitted, chat.message events. Five pattern-matching rules: same error 3x, stuck >10min, quiz <50%, help requests 3x, 5 consecutive failures. Alert deduplication with 1-hour TTL. Real-time notification <30s.

**6. Data Retention**: Kubernetes CronJob runs daily at 2 AM UTC. Deletes code submissions, quiz responses, struggle alerts after enrollment + 1 year. Progress records (mastery levels) retained indefinitely for academic transcripts.

**7. MCP Integration**: Code Runner and API Gateway expose /mcp/state, /mcp/logs, /mcp/schema, /mcp/metrics endpoints. JSON responses provide runtime context for AI agent debugging. AGENTS.md documents MCP endpoints and common debugging workflows.

**8. Monaco Editor**: Next.js dynamic() with ssr: false for client-side-only rendering. Monaco requires DOM APIs incompatible with SSR. Python-specific configuration: tab size 4, custom snippets, auto-save every 30s, keyboard shortcuts (Ctrl+Enter to run, Ctrl+S to save).

**9. Classroom State Machine**: Two states - Active (default) and Archived (read-only). Teacher-initiated transition via "Archive Classroom" button. Irreversible in MVP. Archived classrooms prevent new enrollments/submissions but preserve historical data for review.

**10. Curriculum Data Structure**: JSON files in data/modules/ with hierarchical structure: 8 modules → 40 topics → 160 exercises + 40 quizzes. JSON schema validation in CI/CD pipeline. Loaded once at startup and cached in memory. Version controlled in git.

**Summary Table** provided with all 10 decisions and key rationale for quick reference.

## Outcome

- ✅ Impact: Complete Phase 0 research artifact. All 10 research tasks addressed with concrete technical decisions. Ready to proceed to Phase 1 Design (data-model.md, contracts, quickstart.md).
- 🧪 Tests: All technical decisions validated against Constitution principles. Architecture patterns align with Kubernetes-native requirement (Principle IV), MCP integration satisfies Principle V (20% evaluation score), event-driven design supports scalability goals.
- 📁 Files: Created specs/004-learnflow-application/research.md (12,000+ words, comprehensive implementation guidance)
- 🔁 Next prompts: 1) Create data-model.md with PostgreSQL schemas and Kafka event formats, 2) Create API contracts in contracts/ directory (YAML), 3) Create quickstart.md for local dev environment setup, 4) Run /sp.tasks to generate implementation tasks
- 🧠 Reflection: Research phase provided clarity on architecture tradeoffs and resolved all "NEEDS CLARIFICATION" items from plan.md. Each research task includes implementation notes with code examples (Python, YAML, TypeScript) to accelerate development. Decision summary table enables quick reference during task generation.

## Evaluation notes (flywheel)

- Failure modes observed: None. All research tasks successfully addressed with concrete decisions.
- Graders run and results (PASS/FAIL): PASS - Constitution Check alignment verified, all 8 principles satisfied (Principle VIII feature parity addressed with shared codebase strategy)
- Prompt variant (if applicable): N/A (direct request for research artifact)
- Next experiment (smallest change to try): Proceed to Phase 1 Design artifacts (data-model.md, contracts, quickstart.md) to validate research decisions in concrete design specifications
