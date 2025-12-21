# Research: MCP Code Execution Pattern Documentation Integration

**Feature**: 002-mcp-code-execution-guide
**Date**: 2025-12-21
**Phase**: 0 (Research & Analysis)

## Research Questions Answered

### 1. Documentation Structure Organization

**Question**: How to integrate 1500-line source into project structure without duplication with 001-caps-compiler-guide?

**Decision**: **Split into 10 topic-focused sections + cross-reference compiler-guide for tooling details**

**Rationale**:
- Compiler-guide focuses on CAPS → Skills compilation process (tooling, validation, automation)
- MCP pattern docs focus on Skills execution patterns (token optimization, script patterns, MCP integration)
- Natural separation: compiler-guide = "HOW to compile," MCP docs = "WHAT to compile and WHY"
- Overlap areas identified: Skills structure (02-architecture.md), batch processing (08-advanced-usage.md)

**Alternatives Considered**:
1. **Single merged document** - Rejected: 3000+ lines too large, conflates compilation with execution
2. **MCP as sub-section of compiler-guide** - Rejected: Gives token optimization insufficient prominence
3. **Separate docs with cross-refs** - **CHOSEN**: Maintains separation of concerns, enables deep-dive in both areas

**Cross-Reference Strategy**:
- In compiler-guide `02-architecture.md`: Add "Token Optimization Considerations" subsection pointing to MCP docs
- In compiler-guide `08-advanced-usage.md`: Link "Advanced Script Patterns" to MCP pattern library
- In MCP docs `03-skill-structure.md`: Reference compiler-guide for validation rules
- In MCP docs `04-writing-scripts.md`: Reference compiler-guide for batch processing automation

---

### 2. Content Chunking Strategy

**Question**: Optimal way to split 1500-line monolithic document into navigable sections?

**Decision**: **10 sections, target 150-300 lines each, organized by learning progression**

**Rationale**:
- Docusaurus best practice: 200-400 lines per page for readability
- Learning progression: Problem → Solution → Structure → Patterns → Examples → Advanced
- Preserves narrative flow while enabling reference lookups
- Section 6 (Kafka Example) is 631 lines - acceptable as complete working example (users need full context)

**Section Breakdown**:

| Section | Title | Source Lines | Target Lines | Rationale |
|---------|-------|--------------|--------------|-----------|
| README.md | Overview | 1-50 | 150 | Add navigation, learning path |
| 01 | Token Problem | 52-136 | 200 | Problem statement, motivation |
| 02 | Solution Architecture | 140-168 | 180 | Core insight, 4-part structure |
| 03 | Skill Structure | 172-280 | 250 | Templates, directory layout |
| 04 | Writing Scripts | 284-629 | 400 | Python/Bash patterns, error handling |
| 05 | Kafka Example | 633-1264 | 631 | Complete example (keep intact) |
| 06 | REFERENCE.md Pattern | 1268-1306 | 150 | On-demand documentation |
| 07 | Cross-Agent Testing | 1310-1351 | 180 | Claude Code + Goose compatibility |
| 08 | Performance Benchmarks | 1353-1378 | 150 | Token metrics, real-world impact |
| 09 | Best Practices | 1380-1493 | 250 | DO/DON'T, example skills catalog |

**Total**: ~2400 lines across 10 files (includes added navigation, cross-refs, examples)

**Alternatives Considered**:
1. **5 large sections** - Rejected: Pages too long (300-500 lines), poor navigation
2. **15 micro-sections** - Rejected: Too fragmented, loses narrative flow
3. **10 sections** - **CHOSEN**: Balances depth with navigability

---

### 3. Cross-Agent Testing Documentation Patterns

**Question**: Best format for documenting cross-agent compatibility (User Story 3, FR-006)?

**Decision**: **6-item checklist format + example test scripts for both agents**

**Rationale**:
- Constitution Principle VIII requires explicit feature parity validation
- Checklist provides clear pass/fail criteria
- Example scripts demonstrate testing in practice
- Aligns with existing project pattern (see `checklists/requirements.md`)

**Testing Checklist Format**:

```markdown
## Cross-Agent Compatibility Checklist

**Purpose**: Validate skill works identically across Claude Code and Goose agents

**Prerequisites**:
- Skill compiled from CAPS playbook
- Both agents installed and configured

**Validation Items**:

- [ ] **Agent Recognition**: Both agents recognize skill in `.claude/skills/` directory
  - Test: `claude list skills | grep skill-name`
  - Test: `goose list skills | grep skill-name`

- [ ] **Script Execution**: Both agents execute main script successfully
  - Test: `claude --skill skill-name` (observe exit code 0)
  - Test: `goose --skill skill-name` (observe exit code 0)

- [ ] **Output Consistency**: Both agents display identical output format
  - Compare: stdout from both agents (status messages, formatting)

- [ ] **REFERENCE.md Access**: Both agents can load on-demand documentation
  - Test: Ask "show reference" in follow-up (verify load from REFERENCE.md)

- [ ] **Python Compatibility**: Scripts work with Python 3.8+ (lowest common version)
  - Test: `python3 --version` (verify ≥3.8)
  - Test: Run deploy/verify scripts in isolated Python 3.8 environment

- [ ] **Bash Compatibility**: Scripts work with Bash 4.0+ (macOS default)
  - Test: `bash --version` (verify ≥4.0)
  - Test: Run main.sh script with Bash 4.0
```

**Example Test Script** (to be included in `07-cross-agent-testing.md`):

```bash
#!/bin/bash
# test-cross-agent-compat.sh
# Validates skill compatibility across Claude Code and Goose

SKILL_NAME="$1"

echo "Testing skill: $SKILL_NAME"
echo "---"

# Test 1: Agent Recognition
echo "Test 1: Agent Recognition"
claude list skills | grep -q "$SKILL_NAME" && echo "  ✓ Claude recognizes skill" || echo "  ✗ Claude missing"
goose list skills | grep -q "$SKILL_NAME" && echo "  ✓ Goose recognizes skill" || echo "  ✗ Goose missing"

# Test 2: Execution
echo "Test 2: Execution"
claude --skill "$SKILL_NAME" > /tmp/claude-output.txt 2>&1
[ $? -eq 0 ] && echo "  ✓ Claude execution successful" || echo "  ✗ Claude failed"

goose --skill "$SKILL_NAME" > /tmp/goose-output.txt 2>&1
[ $? -eq 0 ] && echo "  ✓ Goose execution successful" || echo "  ✗ Goose failed"

# Test 3: Output Comparison
echo "Test 3: Output Consistency"
diff /tmp/claude-output.txt /tmp/goose-output.txt > /dev/null
[ $? -eq 0 ] && echo "  ✓ Outputs identical" || echo "  ⚠ Outputs differ (review manually)"

echo "---"
echo "Compatibility test complete"
```

**Alternatives Considered**:
1. **Narrative testing guide** - Rejected: No clear pass/fail criteria
2. **Automated test suite** - Rejected: Too complex for documentation feature, better for implementation
3. **Checklist + examples** - **CHOSEN**: Clear criteria, practical guidance

---

### 4. Asset Management (Diagrams, Examples)

**Question**: How to handle ASCII diagrams and code examples from source material?

**Decision**: **Convert ASCII diagrams to Mermaid, extract large code examples to separate files, keep small examples inline**

**Rationale**:
- Mermaid is Docusaurus-native, renders better than ASCII in web docs
- Large code examples (>50 lines) benefit from syntax highlighting in separate files
- Small examples (<20 lines) stay inline for readability
- Preserves source material's instructional value while improving presentation

**Asset Organization Strategy**:

```
caps-library/docs/mcp-code-execution/assets/
├── diagrams/
│   ├── before-after-tokens.mermaid       # Convert from source lines 147-157
│   ├── 4-part-structure.mermaid          # Convert from source lines 172-182
│   └── kafka-architecture.mermaid        # Convert from source lines 737-744
├── examples/
│   ├── skill-templates/
│   │   ├── kafka-skill.md                # Extract from source lines 638-728
│   │   └── generic-skill-template.md     # Extract from source lines 336-383
│   ├── scripts/
│   │   ├── kafka-main.sh                 # Extract from source lines 952-1000
│   │   ├── kafka-deploy.py               # Extract from source lines 1005-1151
│   │   ├── kafka-verify.py               # Extract from source lines 1156-1263
│   │   ├── python-pattern.py             # Extract from source lines 401-498
│   │   └── bash-pattern.sh               # Extract from source lines 510-549
│   └── reference/
│       └── kafka-reference.md            # Extract from source lines 733-947
```

**Diagram Conversion Rules**:
- ASCII box diagrams → Mermaid flowchart or graph
- Before/After comparisons → Mermaid sequence diagrams
- Directory trees → Keep as code blocks (tree format is clearest)

**Code Example Rules**:
- **Inline** (keep in markdown): <20 lines, demonstrates single concept
- **Separate file** (extract to assets/): >50 lines, complete working example
- **Syntax highlighting**: All code blocks get language specifiers (python, bash, yaml, etc.)

**Alternatives Considered**:
1. **Keep ASCII diagrams** - Rejected: Poor rendering in web docs
2. **Convert to SVG** - Rejected: Requires manual design, harder to maintain
3. **Mermaid diagrams** - **CHOSEN**: Source-controlled, easy to update, renders well
4. **All examples inline** - Rejected: Makes pages too long
5. **All examples extracted** - Rejected: Breaks reading flow for small examples
6. **Selective extraction** - **CHOSEN**: Balances readability with maintainability

---

### 5. Success Criteria Validation Approach

**Question**: How to validate 7 success criteria (especially SC-006: 80% question reduction)?

**Decision**: **Create validation checklist per criterion, combine quantitative and qualitative measures**

**Validation Checklist**:

#### SC-001: Developers explain 3 token problems after reading

**Validation Method**: **Comprehension test**
- **Approach**: Quiz-style questions in documentation
- **Pass Criteria**: Reader can identify Tool Definition Loading, Data Bloat, Transcript Duplication
- **Measurement**: Self-assessment quiz at end of "Token Problem" section
- **Acceptable Proxy**: Documentation completeness check (all 3 problems explained with examples)

#### SC-002: Skill creation in <30 minutes using Kafka example

**Validation Method**: **Timed walkthrough**
- **Approach**: Follow complete Kafka example step-by-step
- **Pass Criteria**: New skill compiles and executes successfully in ≤30 minutes
- **Measurement**: Time from "read example" to "skill runs" for new user
- **Acceptable Proxy**: Example completeness (all steps documented, no missing prerequisites)

#### SC-003: Skills consume <200 tokens per execution (target: 110)

**Validation Method**: **Token counting**
- **Approach**: Measure actual token usage during skill execution
- **Pass Criteria**: SKILL.md + status output ≤ 200 tokens
- **Measurement**: Claude API token counter on skill invocation
- **Acceptable Proxy**: Line count validation (SKILL.md <100 lines ≈ 100 tokens)

#### SC-004: Pass all 6 cross-agent testing checklist items

**Validation Method**: **Checklist execution**
- **Approach**: Run cross-agent compatibility tests (see Research Question 3)
- **Pass Criteria**: All 6 items checked (recognition, execution, output, reference, Python 3.8+, Bash 4.0+)
- **Measurement**: Test script results (automated)
- **Acceptable Proxy**: Manual testing with both agents + documented results

#### SC-005: 90% implement error handling correctly

**Validation Method**: **Pattern adoption rate**
- **Approach**: Review skills created after documentation release
- **Pass Criteria**: 9/10 new skills include try/except (Python) or set -euo pipefail (Bash)
- **Measurement**: Code review of new skills in `.claude/skills/`
- **Acceptable Proxy**: Documentation includes 5+ error handling examples

#### SC-006: 80% reduction in clarifying questions about skill structure

**Validation Method**: **Historical comparison**
- **Approach**: Compare /sp.clarify sessions before and after documentation
- **Pass Criteria**: Skills-related clarifications reduced by ≥80%
- **Measurement**: Track /sp.clarify PHRs tagged "skills" over time
- **Acceptable Proxy**: Qualitative assessment (documentation answers common questions)
- **Baseline**: Define as "number of questions in feature 001 clarification session" or "typical skills-related clarifications"

#### SC-007: 99% token reduction vs direct MCP

**Validation Method**: **Benchmark validation**
- **Approach**: Measure token usage with and without MCP pattern
- **Pass Criteria**: Skills + Scripts ≤ 110 tokens vs. Direct MCP ≥ 50,000 tokens
- **Measurement**: Compare token counts for same task (e.g., Kafka deployment)
- **Acceptable Proxy**: Performance benchmark tables in docs match real execution

**Summary Validation Checklist** (for Definition of Done):

```markdown
## Success Criteria Validation

- [ ] **SC-001**: Comprehension quiz included in "Token Problem" section
- [ ] **SC-002**: Complete Kafka example documented with time estimates
- [ ] **SC-003**: Token counts validated for example skills (<200)
- [ ] **SC-004**: Cross-agent test script provided and tested
- [ ] **SC-005**: 5+ error handling examples included in scripts section
- [ ] **SC-006**: Common clarification questions answered in docs (baseline: feature 001)
- [ ] **SC-007**: Performance benchmark table validated against real execution
```

**Alternatives Considered**:
1. **All quantitative** - Rejected: SC-006 lacks clear baseline
2. **All qualitative** - Rejected: Insufficient rigor for measurable outcomes
3. **Mixed approach** - **CHOSEN**: Uses quantitative where possible, qualitative proxies where needed

---

## Implementation Recommendations

### Content Migration Order

**Phase 1: Foundation (Week 1)**
1. Create directory structure (`caps-library/docs/mcp-code-execution/`)
2. Convert diagrams to Mermaid
3. Extract code examples to `assets/examples/`

**Phase 2: Core Content (Week 1-2)**
4. Migrate sections 1-4 (Overview, Problem, Solution, Structure)
5. Add cross-references to compiler-guide
6. Create navigation/sidebar updates

**Phase 3: Examples & Patterns (Week 2)**
7. Migrate Section 5 (Writing Scripts) with inline examples
8. Migrate Section 6 (Complete Kafka Example)
9. Create quickstart.md guide

**Phase 4: Advanced & Validation (Week 2-3)**
10. Migrate sections 7-10 (REFERENCE pattern, Testing, Benchmarks, Best Practices)
11. Create validation checklists for all SC items
12. Test all cross-references and examples

### Quality Gates

**Before migration**:
- [ ] All 5 research questions answered
- [ ] Asset organization strategy defined
- [ ] Cross-reference locations identified

**After migration**:
- [ ] All sections have cross-references
- [ ] All code examples syntax-validated
- [ ] All Mermaid diagrams render correctly
- [ ] All 7 success criteria validation methods implemented
- [ ] Cross-agent testing checklist completed

### Risk Mitigation

**Duplication with compiler-guide**:
- Action: Create cross-reference map (done in Research Question 1)
- Validation: Each overlap area has explicit cross-ref link

**Section length**:
- Action: Section 6 (Kafka Example) stays 631 lines (justified as complete example)
- Validation: All other sections <400 lines

**Asset complexity**:
- Action: Use Mermaid for diagrams, extract large examples
- Validation: All assets render in Docusaurus preview

**SC-006 baseline**:
- Action: Define baseline as feature 001 clarification count
- Validation: Track /sp.clarify sessions tagged "skills" over 3 months

---

## Next Steps

1. ✅ Research complete (this document)
2. ⏳ Create `data-model.md` (Phase 1 artifact)
3. ⏳ Create `contracts/documentation-outline.md` (Phase 1 artifact)
4. ⏳ Create `quickstart.md` (Phase 1 artifact)
5. ⏳ Run agent context update script
6. ⏳ Generate tasks with `/sp.tasks`

---

**Research Status**: ✅ Complete | Ready for Phase 1 Design
