# Documentation Structure: CAPS-to-Skills Compiler Guide

**Date**: 2025-12-20
**Purpose**: Define organization and content taxonomy for compiler documentation
**Status**: Complete - Ready for content authoring

---

## Documentation Entity Model

### Primary Sections (Level 1)

#### 1. Overview
- **Purpose**: Introduce compiler, explain value proposition
- **Target Audience**: New users unfamiliar with CAPS
- **Content Types**: Conceptual explanation, visual diagram, capabilities table
- **Success Criteria**: User can answer "What does compiler do?" in <5 min (SC-001)
- **File**: `01-overview.md`
- **Priority**: P1 (MVP)

#### 2. Compiler Architecture
- **Purpose**: Explain 5-stage pipeline and transformation rules
- **Target Audience**: Users wanting deeper understanding before use
- **Content Types**: Pipeline diagram, stage descriptions, transformation table, examples
- **Success Criteria**: User can list 5 stages and predict transformations (User Story 1)
- **File**: `02-architecture.md`
- **Priority**: P1 (MVP)

#### 3. Installation
- **Purpose**: Get compiler running on user's system
- **Target Audience**: All users (prerequisite for usage)
- **Content Types**: Prerequisites list, step-by-step instructions, verification commands
- **Success Criteria**: Successful `./caps-to-skills.sh --help` in <15 min (SC-002)
- **File**: `03-installation.md`
- **Priority**: P1 (MVP)

#### 4. Quick Start
- **Purpose**: First successful compilation end-to-end
- **Target Audience**: Users who completed installation
- **Content Types**: 3-4 step workflow, example playbook, validation commands
- **Success Criteria**: Generated SKILL.md and successful skill invocation (User Story 3)
- **File**: `04-quickstart.md`
- **Priority**: P1 (MVP)

#### 5. Command Reference
- **Purpose**: Comprehensive reference for all compiler options
- **Target Audience**: Regular users needing specific capabilities
- **Content Types**: Option tables, syntax examples, use cases, expected output
- **Success Criteria**: 100% of options documented and testable (SC-003, FR-008)
- **File**: `05-command-reference.md`
- **Priority**: P2 (Enhancement)

#### 6. Workflow Integration
- **Purpose**: Automate compilation in dev workflows
- **Target Audience**: Users optimizing their processes
- **Content Types**: Git hook code, GitHub Actions YAML, Makefile, usage instructions
- **Success Criteria**: Copy-paste examples work on first attempt (SC-005, FR-010)
- **File**: `06-workflow-integration.md`
- **Priority**: P2 (Enhancement)

#### 7. Troubleshooting
- **Purpose**: Self-service problem resolution
- **Target Audience**: Users encountering errors
- **Content Types**: Issue/symptom/solution tables, diagnostic commands, fix procedures
- **Success Criteria**: Documented issues resolved in <10 min (SC-004, FR-011)
- **File**: `07-troubleshooting.md`
- **Priority**: P3 (Advanced)

#### 8. Advanced Usage
- **Purpose**: Scalability patterns for power users
- **Target Audience**: Experienced users with large playbook libraries
- **Content Types**: Selective compilation examples, batch scripts, analysis commands
- **Success Criteria**: One advanced pattern implemented in <20 min (SC-009, FR-012)
- **File**: `08-advanced-usage.md`
- **Priority**: P3 (Advanced)

---

## Subsection Taxonomy

### For Each Primary Section

#### Content Components
- **Heading**: Clear, descriptive title (H1 for section, H2 for major subsections)
- **Introduction Paragraph**: Context and purpose (2-3 sentences)
- **Body Content**: [varies by section type]
  - **Conceptual**: Explanations, diagrams, analogies
  - **Procedural**: Step-by-step instructions, commands, verification
  - **Reference**: Tables, option lists, syntax specifications
- **Examples**: Copy-pasteable code blocks with comments (FR-013)
- **Validation**: Success criteria or verification commands
- **Next Steps**: Link to subsequent section or related content (FR-015)

#### Metadata (for navigation)
- **Section ID**: Anchor links (e.g., `#overview`, `#installation`)
- **Priority**: P1 (MVP), P2 (enhancement), P3 (advanced)
- **Dependencies**: Prerequisites from other sections
- **Cross-References**: Related sections for "See also" guidance

---

## Content Type Definitions

### Diagram
- **Format**: Mermaid (decided in research phase - renders in GitHub, VS Code, Docusaurus)
- **Rendering**: Must display in GitHub Markdown viewer
- **Location**: Inline in section or in `assets/diagrams/`
- **Maintenance**: Update when compiler behavior changes
- **Required Diagrams**:
  1. Compilation flow (CAPS → Compiler → Skills → Claude CLI) in Overview
  2. 5-stage pipeline flow in Architecture
  3. Optional: Workflow integration flowcharts

### Code Example
- **Format**: Fenced code block with language identifier (```bash, ```yaml, etc.)
- **Validation**: Tested with shellcheck (bash) / yamllint (YAML) / make --dry-run (Makefile)
- **Comments**: Inline comments for complex lines (FR-013)
- **Length**: <30 lines per example (split if longer for readability)
- **Copy-Paste Ready**: No placeholders like `<YOUR_VALUE>` (FR-013)
- **Standards**: All examples must follow FR-013 requirements

### Table
- **Format**: Markdown table with header row
- **Columns**: Aligned for readability (use consistent spacing)
- **Content**: Concise (no paragraphs in cells - use bullet lists if needed)
- **Sorting**: Logical order (alphabetical, by priority, by frequency of use)
- **Examples**:
  - Key Capabilities table (6 rows minimum)
  - Transformation Rules table (7+ rows)
  - Command options table

### Command Syntax
- **Format**: `command [OPTIONS] [ARGUMENTS]`
- **Options**: Documented with short/long forms where applicable
- **Examples**: Minimum 2 examples per command option (FR-009)
- **Output**: Show expected output for each example

---

## Navigation Structure

### Table of Contents
- **Location**: Top of README.md (master document)
- **Depth**: 2 levels (sections + major subsections)
- **Links**: Anchor links to section IDs (#section-name format)
- **Format**: Numbered list matching section numbers (1-8)
- **Requirement**: FR-014 (clear section hierarchy and navigation aids)

### Internal Cross-References
- **Format**: `See [Section Name](#section-id) for details`
- **Usage**: When referencing concepts explained elsewhere
- **Validation**: All links checked during Phase 10 (Polish) - Task T116
- **Best Practice**: Use descriptive link text (not "click here")

### External References
- **Format**: `[Tool Name](https://url)` as markdown links
- **Usage**: Referencing official docs (Claude CLI, Git, bash, make, etc.)
- **Maintenance**: Note URLs may change (prefer stable permalinks when available)
- **Examples**: Links to Claude CLI docs, GitHub Actions docs, shellcheck docs

---

## Success Metrics Mapping

| Section | Success Criteria | Verification Method | User Story |
|---------|-----------------|-------------------|------------|
| Overview | SC-001 (5 min understanding) | User quiz/survey | US1 |
| Architecture | User Story 1 acceptance | Comprehension test | US1 |
| Installation | SC-002 (15 min setup) | Timed simulation | US2 |
| Quick Start | User Story 3 acceptance | End-to-end test | US3 |
| Command Reference | SC-003 (100% options work) | Automated testing | US4 |
| Workflow Integration | SC-005 (copy-paste works) | Manual execution | US5 |
| Troubleshooting | SC-004 (10 min resolution) | Issue reproduction | US6 |
| Advanced Usage | SC-009 (20 min implementation) | Pattern execution | US7 |

---

## Documentation Maintenance Plan

### Triggers for Updates
- Compiler script version change (new features, changed behavior)
- New command options added to caps-to-skills.sh
- User-reported issues (edge cases not documented)
- Spec evolution (CAPS format changes)
- Error message changes in compiler

### Update Process
1. Identify changed sections based on trigger
2. Update affected Markdown files (individual section files)
3. Re-validate all examples with shellcheck/yamllint
4. Test updated commands/workflows in clean environment
5. Update master README.md if section structure changes
6. Update version metadata in README.md header
7. Commit with clear change description following git commit pattern

### Version Tracking
- **Document Version**: Semantic versioning (MAJOR.MINOR.PATCH)
- **Compiler Version Compatibility**: Note which compiler version documented
- **Change Log**: Maintain in README.md or separate CHANGELOG.md
- **Last Updated Date**: Update on every change

---

## File Organization

### Directory Structure
```
caps-library/docs/compiler-guide/
├── README.md                    # Master document (all sections compiled)
├── 01-overview.md               # Section 1
├── 02-architecture.md           # Section 2
├── 03-installation.md           # Section 3
├── 04-quickstart.md             # Section 4
├── 05-command-reference.md      # Section 5
├── 06-workflow-integration.md   # Section 6
├── 07-troubleshooting.md        # Section 7
├── 08-advanced-usage.md         # Section 8
└── assets/
    ├── diagrams/                # Visual diagrams
    │   ├── compilation-flow.mermaid
    │   └── pipeline-stages.mermaid
    └── examples/                # Example files for copy-paste
        ├── sample-playbook.md
        ├── sample-skill.md
        ├── test-playbook.md
        ├── pre-commit            # Git hook
        ├── caps-compile.yml      # GitHub Actions
        ├── Makefile
        ├── compile-all-libraries.sh
        └── list-skills.sh
```

### Naming Conventions
- **Section files**: Numbered prefix (01-08) for ordered reading
- **Diagram files**: Descriptive names with .mermaid extension
- **Example files**: Descriptive names matching usage context
- **All files**: Lowercase with hyphens (kebab-case)

---

## Content Delivery Formats

### Individual Section Files
- **Purpose**: Modular maintenance - update one section without touching others
- **Target**: Developers maintaining documentation
- **Benefit**: Clear separation of concerns, easier version control

### Master README.md
- **Purpose**: Single-page reading experience - complete guide in one file
- **Target**: End users reading documentation
- **Benefit**: No navigation required, easy to search (Ctrl+F)
- **Generation**: Compile all 8 sections with TOC at top

### Future Formats (Out of Scope for Phase 2)
- **Docusaurus Integration**: Adapt structure for Docusaurus site
- **PDF Export**: For offline reading or printing
- **Interactive Tutorial**: Embedded exercises and validation

---

**Structure Finalized**: Ready for content authoring (Phase 3: User Story 1)

All sections, content types, navigation, and maintenance procedures defined. This structure ensures:
- ✅ All FR-001 to FR-015 requirements can be met
- ✅ All SC-001 to SC-010 success criteria are achievable
- ✅ All 7 user stories have clear deliverable sections
- ✅ Progressive disclosure: concept → hands-on → reference → advanced
- ✅ Independent user story implementation possible
