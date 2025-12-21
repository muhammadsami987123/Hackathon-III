# Data Model: MCP Code Execution Pattern Documentation

**Feature**: 002-mcp-code-execution-guide
**Date**: 2025-12-21
**Phase**: 1 (Design)

## Overview

This data model defines the entities and relationships for the MCP Code Execution Pattern documentation structure. These are **documentation entities** (not code objects), representing how content is organized, referenced, and validated.

---

## Entity Definitions

### 1. Documentation Section

**Purpose**: Represents a single documentation page or major section

**Attributes**:
- `title` (string, required): Section title (e.g., "The Token Problem")
- `file_name` (string, required): Target filename (e.g., "01-token-problem.md")
- `order` (integer, required): Sequential order for navigation (1-10)
- `source_lines` (string, required): Line range from source `.md` file (e.g., "52-136")
- `target_lines` (integer, estimated): Expected lines after migration (e.g., 200)
- `word_count` (integer, estimated): Approximate word count for reading time
- `learning_level` (enum, required): One of: `foundation | intermediate | advanced | reference`
- `cross_references` (array of strings): Links to other sections or external docs
- `success_criteria_ids` (array of strings): Which SC items this section validates (e.g., ["SC-001", "SC-003"])

**Relationships**:
- `has_many` subsections (self-referential, optional)
- `belongs_to` parent_section (self-referential, optional)
- `contains` code_examples (0..*)
- `validates` success_criteria (0..*)

**Validation Rules**:
- `title` must be unique across all sections
- `order` must be sequential (no gaps, no duplicates)
- `file_name` must match pattern `\d{2}-[a-z-]+\.md` or `README.md`
- `source_lines` must be valid range (start < end, within 1-1500)
- `learning_level` must progress logically (foundation → intermediate → advanced)

**Example Instance**:
```yaml
title: "The Token Problem"
file_name: "01-token-problem.md"
order: 2
source_lines: "52-136"
target_lines: 200
word_count: 1800
learning_level: foundation
cross_references:
  - "compiler-guide/02-architecture.md#validation"
  - "02-solution-architecture.md"
success_criteria_ids: ["SC-001"]
```

---

### 2. Code Example

**Purpose**: Represents a code snippet or script extracted from source material

**Attributes**:
- `name` (string, required): Descriptive name (e.g., "Kafka Deploy Script")
- `language` (enum, required): One of: `python | bash | yaml | json | markdown`
- `file_path` (string, required): Location in assets/ (e.g., "assets/examples/scripts/kafka-deploy.py")
- `source_lines` (string, required): Line range from source `.md` (e.g., "1005-1151")
- `line_count` (integer, required): Number of lines in example
- `token_count` (integer, estimated): Token budget for this example
- `demonstrates_pattern` (string, required): What pattern this shows (e.g., "Python class-based deployer with error handling")
- `inline_or_extracted` (enum, required): One of: `inline | extracted`
- `syntax_validated` (boolean, required): Whether example has been syntax-checked

**Relationships**:
- `belongs_to` documentation_section
- `references` skill_template (optional, if example shows template usage)
- `demonstrates` best_practice (optional, links to best practices section)

**Validation Rules**:
- `line_count` must match actual file lines (if extracted)
- `inline_or_extracted` = `inline` if `line_count` < 20, else `extracted`
- `syntax_validated` must be `true` before documentation publication
- `file_path` must exist in filesystem (for extracted examples)
- `language` must have syntax highlighter in Docusaurus

**Example Instance**:
```yaml
name: "Kafka Deploy Script"
language: python
file_path: "assets/examples/scripts/kafka-deploy.py"
source_lines: "1005-1151"
line_count: 147
token_count: 1200
demonstrates_pattern: "Python class-based deployer with error handling"
inline_or_extracted: extracted
syntax_validated: true
references_skill_template: "kafka-skill-template"
```

---

### 3. Skill Template

**Purpose**: Represents a reusable skill structure template (SKILL.md, REFERENCE.md, scripts)

**Attributes**:
- `name` (string, required): Template name (e.g., "Kafka K8s Setup Skill")
- `template_type` (enum, required): One of: `SKILL.md | REFERENCE.md | main-script | deploy-script | verify-script`
- `token_budget` (integer, required): Target token count (e.g., 100 for SKILL.md, 0 for scripts)
- `file_path` (string, required): Location in assets/ (e.g., "assets/examples/skill-templates/kafka-skill.md")
- `source_lines` (string, required): Line range from source `.md`
- `validates_pattern` (string, required): Which 4-part structure component (e.g., "SKILL.md interface pattern")

**Relationships**:
- `has_many` code_examples (script examples that implement the template)
- `belongs_to` skill_structure (4-part structure entity)
- `demonstrates` best_practices (links to DO/DON'T sections)

**Validation Rules**:
- `SKILL.md` templates must have `token_budget` ≤ 120 (target 100)
- `REFERENCE.md` templates must have `token_budget` = 0 (on-demand loading)
- Script templates (`*-script`) must have `token_budget` = 0 (execute externally)
- All templates must follow 4-part structure guidelines

**Example Instance**:
```yaml
name: "Kafka K8s Setup Skill"
template_type: "SKILL.md"
token_budget: 100
file_path: "assets/examples/skill-templates/kafka-skill.md"
source_lines: "638-728"
validates_pattern: "SKILL.md interface pattern"
demonstrates_best_practices: ["keep-skill-md-minimal", "link-to-reference"]
```

---

### 4. Cross-Reference Link

**Purpose**: Represents a hyperlink between documentation sections or to external resources

**Attributes**:
- `source_section` (string, required): Section that contains the link (e.g., "03-skill-structure.md")
- `target_section` (string, required): Section or external doc being referenced (e.g., "compiler-guide/02-architecture.md")
- `link_type` (enum, required): One of: `see_also | prerequisite | example | deep_dive`
- `anchor` (string, optional): Specific heading anchor (e.g., "#validation-rules")
- `link_text` (string, required): Display text for the link
- `bidirectional` (boolean, required): Whether target should link back

**Relationships**:
- `connects` documentation_sections (source to target)
- `may_create` reverse_link (if bidirectional)

**Validation Rules**:
- `target_section` must exist (either in this documentation set or verified external URL)
- No circular references (section cannot link to itself through chain)
- `prerequisite` links must point to lower `order` sections (earlier in learning path)
- `bidirectional` links must create reverse link with appropriate `link_type`

**Example Instance**:
```yaml
source_section: "03-skill-structure.md"
target_section: "compiler-guide/02-architecture.md"
link_type: "see_also"
anchor: "#stage-4-transformation"
link_text: "See CAPS-to-Skills Compiler Guide for transformation rules"
bidirectional: true
```

---

### 5. Success Criterion

**Purpose**: Represents one of the 7 measurable success criteria (SC-001 through SC-007)

**Attributes**:
- `id` (string, required): Identifier (e.g., "SC-001")
- `description` (string, required): What developers should achieve (e.g., "Explain 3 token problems")
- `metric` (string, required): Measurable aspect (e.g., "Comprehension")
- `target_value` (string, required): Expected outcome (e.g., "Can identify Tool Definition Loading, Data Bloat, Transcript Duplication")
- `validation_method` (enum, required): One of: `comprehension_test | timed_walkthrough | token_counting | checklist_execution | pattern_adoption | historical_comparison | benchmark_validation`
- `validation_approach` (string, required): Detailed validation steps
- `acceptable_proxy` (string, optional): Alternative if direct measurement unavailable

**Relationships**:
- `validated_by` documentation_section (which section(s) enable this criterion)
- `has_many` validation_checklist_items

**Validation Rules**:
- All 7 `id` values must be present (SC-001 through SC-007)
- Each criterion must have at least one validating section
- `validation_method` must match one of defined approaches
- If `acceptable_proxy` is used, justification required

**Example Instance**:
```yaml
id: "SC-001"
description: "Developers can explain the 3 token problems after reading the documentation"
metric: "Comprehension"
target_value: "Can identify Tool Definition Loading, Data Bloat, Transcript Duplication"
validation_method: "comprehension_test"
validation_approach: "Self-assessment quiz at end of Token Problem section"
acceptable_proxy: "Documentation completeness check (all 3 problems explained with examples)"
validated_by_sections: ["01-token-problem.md", "02-solution-architecture.md"]
```

---

### 6. Diagram Asset

**Purpose**: Represents a visual diagram (Mermaid, ASCII, SVG)

**Attributes**:
- `name` (string, required): Diagram name (e.g., "Before/After Token Comparison")
- `format` (enum, required): One of: `mermaid | ascii | svg`
- `file_path` (string, required): Location in assets/diagrams/ (e.g., "assets/diagrams/before-after-tokens.mermaid")
- `source_lines` (string, required): Line range from source `.md` where ASCII original exists
- `diagram_type` (enum, required): One of: `flowchart | sequence | graph | architecture | comparison`
- `renders_in_docusaurus` (boolean, required): Whether diagram has been tested

**Relationships**:
- `belongs_to` documentation_section
- `illustrates` concept (which pattern or problem the diagram clarifies)

**Validation Rules**:
- `mermaid` format must render in Docusaurus preview
- `ascii` format only allowed for directory trees (better as code blocks)
- `file_path` must exist and contain valid diagram syntax

**Example Instance**:
```yaml
name: "Before/After Token Comparison"
format: mermaid
file_path: "assets/diagrams/before-after-tokens.mermaid"
source_lines: "147-157"
diagram_type: comparison
renders_in_docusaurus: true
illustrates: "Context window consumption: Direct MCP vs Skills+Scripts"
```

---

## Entity Relationships Diagram

```
Documentation Section (1)
  |-- has_many (0..*) --> Subsections (Documentation Section)
  |-- belongs_to (0..1) --> Parent Section (Documentation Section)
  |-- contains (0..*) --> Code Examples
  |-- validates (0..*) --> Success Criteria
  |-- referenced_by (0..*) --> Cross-Reference Links (as target)
  |-- references_via (0..*) --> Cross-Reference Links (as source)
  |-- includes (0..*) --> Diagram Assets

Code Example (1)
  |-- belongs_to (1) --> Documentation Section
  |-- references (0..1) --> Skill Template
  |-- demonstrates (0..*) --> Best Practice

Skill Template (1)
  |-- has_many (0..*) --> Code Examples
  |-- belongs_to (1) --> Skill Structure (4-part)
  |-- demonstrates (0..*) --> Best Practices

Cross-Reference Link (1)
  |-- connects (1) --> Source Section (Documentation Section)
  |-- connects (1) --> Target Section (Documentation Section or External)
  |-- may_create (0..1) --> Reverse Link (if bidirectional)

Success Criterion (1)
  |-- validated_by (1..*) --> Documentation Sections
  |-- has_many (0..*) --> Validation Checklist Items

Diagram Asset (1)
  |-- belongs_to (1) --> Documentation Section
  |-- illustrates (1) --> Concept/Pattern
```

---

## Data Constraints

### Section Ordering
- Sections must be ordered 1-10 (no gaps)
- Learning progression: foundation → intermediate → advanced → reference
- `order` 1 is always README.md (overview)

### Token Budgets
- SKILL.md templates: 80-120 tokens (target 100)
- REFERENCE.md templates: 0 tokens (loaded on-demand)
- Scripts: 0 tokens (execute externally)
- Status messages: <20 tokens (minimal output)

### Cross-Reference Validity
- Internal links: Must point to existing section file_name
- External links: Must point to verified documentation (compiler-guide, constitution)
- No circular references: Section A → B → C cannot → A

### Success Criteria Coverage
- Each SC-00X must have at least 1 validating section
- All sections should contribute to at least 1 success criterion
- Validation methods must be documented in research.md

---

## Migration Validation Rules

Before marking a section as "migrated":
- [ ] All code examples extracted/inline per size rules
- [ ] All cross-references added and validated
- [ ] All diagrams converted to Mermaid (if applicable)
- [ ] Section contributes to at least 1 success criterion
- [ ] Token budget validated for templates
- [ ] Syntax validation passed for all code examples

---

**Data Model Status**: ✅ Complete | Ready for Contract Definition
