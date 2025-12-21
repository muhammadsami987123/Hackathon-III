# Feature Specification: MCP Code Execution Pattern Documentation Integration

**Feature Branch**: `002-mcp-code-execution-guide`
**Created**: 2025-12-21
**Status**: Draft
**Input**: User description: "Integrate and document the MCP Code Execution Pattern as a comprehensive guide for building efficient Skills with external scripts"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Understanding Token Efficiency (Priority: P1)

A developer needs to understand why direct MCP tool integration causes massive context consumption (50,000+ tokens) and how the Skills + Scripts pattern reduces this to ~110 tokens (99.8% reduction).

**Why this priority**: Core value proposition - developers must understand the problem before adopting the solution. This is the fundamental "why" that drives adoption.

**Independent Test**: Developer can read the documentation and explain the three token problems (Tool Definition Loading, Data Bloat, Transcript Duplication) and the 4-part solution architecture.

**Acceptance Scenarios**:

1. **Given** a developer is integrating MCP tools, **When** they read the "Token Problem" section, **Then** they understand the context window consumption issues with concrete token counts
2. **Given** a developer reviews the solution architecture, **When** they compare before/after diagrams, **Then** they can identify which components stay in context vs. execute externally
3. **Given** a developer needs to justify the pattern, **When** they reference performance benchmarks, **Then** they can cite 25-50x productivity improvements

---

### User Story 2 - Building First Skill (Priority: P2)

A developer wants to create their first efficient Skill that wraps MCP tool calls in external scripts, following the 4-part structure (SKILL.md, scripts/, REFERENCE.md, examples/).

**Why this priority**: Practical application - once developers understand the "why," they need hands-on guidance to build their first skill correctly.

**Independent Test**: Developer successfully creates a functional skill with minimal token usage by following the complete Kafka Setup example.

**Acceptance Scenarios**:

1. **Given** a developer has an existing MCP tool, **When** they follow the SKILL.md template, **Then** they create a ~100 token interface file
2. **Given** a developer implements the deployment logic, **When** they follow the Python/Bash script patterns, **Then** scripts return only status messages (not raw data)
3. **Given** a developer tests the skill, **When** they execute it with Claude Code or Goose, **Then** the agent sees only ~110 tokens total per execution
4. **Given** a developer encounters errors, **When** they check the REFERENCE.md pattern, **Then** they find troubleshooting guidance loaded on-demand

---

### User Story 3 - Cross-Agent Compatibility (Priority: P3)

A developer needs to ensure their skill works identically across both Claude Code and Goose agents, following the bi-directional validation principle from the constitution.

**Why this priority**: Essential for LearnFlow feature parity (Principle VIII), but can be validated after basic skill creation works.

**Independent Test**: Developer runs the same skill with both agents and verifies identical output and behavior.

**Acceptance Scenarios**:

1. **Given** a developer has created a skill, **When** they test with Claude Code using `claude --skill name`, **Then** they get the expected minimal output
2. **Given** the same skill, **When** they test with Goose using `goose --skill name`, **Then** they get identical output format and behavior
3. **Given** cross-agent testing requirements, **When** they check the testing checklist, **Then** all 6 validation items pass (recognition, execution, output, reference access, Python 3.8+, Bash 4.0+ compatibility)

---

### User Story 4 - Advanced Patterns and Best Practices (Priority: P4)

An experienced developer wants to optimize their skills further, implement error handling patterns, and follow best practices for production-grade skills.

**Why this priority**: Nice-to-have advanced guidance after basic patterns are established.

**Independent Test**: Developer applies best practices and avoids common anti-patterns listed in the documentation.

**Acceptance Scenarios**:

1. **Given** a developer reviews best practices, **When** they implement their skill, **Then** they follow DO guidelines (keep SKILL.md minimal, move work to scripts, return minimal output, test both agents, use exit codes properly, handle errors gracefully)
2. **Given** a developer reviews anti-patterns, **When** they audit their code, **Then** they avoid DON'T patterns (loading large data, making direct MCP calls, hardcoding values, skipping error handling, forgetting REFERENCE.md)
3. **Given** a developer needs advanced examples, **When** they reference the Example Skills section, **Then** they find categorized examples by difficulty (Foundation, Infrastructure, Application skills)

---

### Edge Cases

- What happens when a script execution times out (>600s)? → Script should return timeout error status; document in REFERENCE.md
- How does the system handle script failures with unclear error messages? → Use meaningful error messages and exit codes (0=success, 1=failure, 2=warning)
- What if REFERENCE.md becomes too large (>10k tokens)? → Split into multiple focused reference files by topic
- How do we version skills when the underlying MCP tools change? → Track playbook versions in git per Principle VII
- What if a skill needs to return structured data (JSON) to the agent? → Return minimal JSON summary only; full data stays in logs/files

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Documentation MUST include complete Kafka K8s Setup example with all 4 parts (SKILL.md, scripts/, REFERENCE.md, examples/)
- **FR-002**: Documentation MUST provide SKILL.md template with standard sections (When to Use, Quick Start, What Happens, Validation, Configuration, Error Handling)
- **FR-003**: Documentation MUST explain the 4-part structure and token costs (100 tokens for SKILL.md, 0 for scripts/REFERENCE.md/examples initially)
- **FR-004**: Documentation MUST include Python and Bash script patterns with error handling
- **FR-005**: Documentation MUST provide verification script patterns that return only status summaries (not raw data)
- **FR-006**: Documentation MUST include cross-agent testing guidance for Claude Code and Goose
- **FR-007**: Documentation MUST include performance benchmarks showing 99.78% token reduction vs direct MCP
- **FR-008**: Documentation MUST provide best practices (DO list) and anti-patterns (DON'T list)
- **FR-009**: Documentation MUST include categorized example skills by difficulty level (Foundation, Infrastructure, Application)
- **FR-010**: Documentation MUST explain REFERENCE.md pattern for on-demand deep documentation

### Key Entities *(documentation structure)*

- **Skill Structure**: 4-part pattern (SKILL.md ~100 tokens, scripts/ 0 tokens initially, REFERENCE.md 0 tokens until requested, examples/ 0 tokens initially)
- **Script Patterns**: Python class-based deployer pattern, Bash orchestration pattern, Verification pattern with status-only returns
- **Token Budget**: Before (50k+ tokens), After (110 tokens), Reduction metrics (99.78%-99.9%)
- **Testing Checklist**: 6-item validation for cross-agent compatibility
- **Example Skills**: Foundation (agents-md-gen, k8s-health-check), Infrastructure (kafka-k8s-setup, postgres-k8s-setup, helm-chart-deploy), Application (fastapi-dapr-agent, mcp-code-execution, nextjs-k8s-deploy)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Developers can explain the 3 token problems (Tool Definition Loading, Data Bloat, Transcript Duplication) after reading the documentation
- **SC-002**: Developers can create a functional skill following the 4-part structure within 30 minutes using the Kafka example
- **SC-003**: Skills built using this pattern consume <200 tokens per execution (target: 110 tokens)
- **SC-004**: Skills pass all 6 cross-agent testing checklist items for Claude Code and Goose compatibility
- **SC-005**: 90% of developers successfully implement error handling patterns from the script examples
- **SC-006**: Documentation reduces the need for clarifying questions about skill structure by 80% (compared to no documentation baseline)
- **SC-007**: Skills demonstrate 99% token reduction vs direct MCP integration (matching documented benchmarks)

### Definition of Done

- [ ] Complete Kafka K8s Setup example is documented with all 4 files (SKILL.md, main.sh, deploy.py, verify.py, REFERENCE.md)
- [ ] All mandatory sections from the `.md` file are integrated into project documentation structure
- [ ] Cross-references to project constitution (Principles I-VIII) are added
- [ ] Performance benchmark tables are validated against actual execution
- [ ] Best practices align with existing constitution requirements
- [ ] Documentation is structured for both linear reading and reference lookup
- [ ] Examples are categorized by difficulty with clear skill names
- [ ] All script patterns include complete error handling examples

## Out of Scope

- Building new MCP servers (documentation only, not implementation)
- Creating the actual example skills (documentation describes existing examples)
- Implementing the CAPS-to-Skills compiler (already covered in feature 001-caps-compiler-guide)
- Goose Recipe generation (focus is on Claude Skills pattern, though cross-compatibility is documented)
- Performance testing infrastructure (benchmarks are documented, not automated testing)

## Assumptions

- The existing `.md` file contains accurate token counts from real-world testing
- The Kafka K8s Setup example files actually exist in `caps-library/playbooks/kafka-k8s-setup/`
- Developers have basic familiarity with Python, Bash, and Kubernetes concepts
- Claude Code and Goose both support the `.claude/skills/` directory structure described
- The 300k token context window mentioned in examples reflects current Claude API limits
- Exit codes (0=success, 1=failure, 2=warning) are standard conventions developers will recognize

## Dependencies

- Feature 001-caps-compiler-guide (CAPS-to-Skills compilation process)
- Project constitution (`.specify/memory/constitution.md`) for principles I-VIII
- Existing playbooks in `caps-library/playbooks/` (kafka-k8s-setup, postgres-k8s-setup, etc.)
- `.claude/skills/` directory structure established by CAPS compiler

## Notes

- This is a **documentation integration feature**, not new code development
- The source material (`.md` file) is comprehensive but needs integration into project structure
- Some content overlaps with 001-caps-compiler-guide; ensure proper cross-referencing without duplication
- The "SP Specify Part 4" title suggests this is part of a larger tutorial series - maintain consistency with Parts 1-3 (if they exist)
- Last updated date in source (December 18, 2025) is actually future-dated - use current date (2025-12-21) for spec
