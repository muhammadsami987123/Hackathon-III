---
description: Learn the 4-part skill structure with SKILL.md, scripts, REFERENCE.md, and examples that reduces token usage by 99%
readingTime: 8 minutes
---

# Skill Structure

## Complete Directory Layout

Every efficient skill follows a standard 4-part structure that minimizes token consumption while maximizing functionality.

```
.claude/skills/
├── agents-md-gen/
│   ├── SKILL.md                    # 50 lines
│   ├── REFERENCE.md                # 20 lines
│   └── scripts/
│       └── generate.sh             # 30 lines
│
├── kafka-k8s-setup/
│   ├── SKILL.md                    # 60 lines
│   ├── REFERENCE.md                # 100 lines
│   └── scripts/
│       ├── main.sh                 # Entry point
│       ├── deploy.py               # 50 lines
│       └── verify.py               # 40 lines
│
├── postgres-k8s-setup/
│   ├── SKILL.md
│   ├── REFERENCE.md
│   └── scripts/
│       ├── main.sh
│       ├── deploy.py
│       ├── migrate.py
│       └── verify.py
│
├── fastapi-dapr-agent/
│   ├── SKILL.md
│   ├── REFERENCE.md
│   └── scripts/
│       └── generate_service.py
│
├── mcp-code-execution/
│   ├── SKILL.md
│   ├── REFERENCE.md
│   └── scripts/
│       ├── execute_code.py
│       └── mcp_wrapper.py
│
└── nextjs-k8s-deploy/
    ├── SKILL.md
    ├── REFERENCE.md
    └── scripts/
        ├── build.sh
        └── deploy.py
```

## SKILL.md Template

Every skill follows this structure to maintain consistency and minimize token usage (target: <120 tokens):

```markdown
---
name: {skill-name}
description: {what it does}
---

# {Title}

{One paragraph explaining purpose}

## When to Use

- Scenario 1: ...
- Scenario 2: ...

## Quick Start

Run the main script:
\`\`\`bash
./scripts/main.sh [ARGS]
\`\`\`

## What Happens

Step-by-step explanation of what the script does.

## Validation

How to confirm success:
\`\`\`bash
./scripts/verify.sh
\`\`\`

## Configuration

See [REFERENCE.md](./REFERENCE.md) for:
- All configuration options
- Advanced usage
- Troubleshooting
- Examples

## Error Handling

Common issues:
- Issue 1: [handled in scripts/]
- Issue 2: [handled in scripts/]

Scripts handle errors and return appropriate exit codes.
```

**Key principle:** SKILL.md tells agent WHAT to do. Scripts handle HOW and WHAT to return.

## Token Budget Enforcement

To maintain the 99% token reduction:

- **SKILL.md**: Maximum 120 tokens (target: 80-100)
- **REFERENCE.md**: Not loaded unless requested (0 tokens initially)
- **scripts/**: Execute outside context (0 tokens for processing)
- **examples/**: Only loaded if referenced (0 tokens initially)

### Token Budget Breakdown

```
Agent Context Window Usage:
├── SKILL.md frontmatter (name, description): ~20 tokens
├── Title and purpose paragraph: ~30 tokens
├── When to Use section: ~15 tokens
├── Quick Start section: ~15 tokens
├── What Happens section: ~20 tokens
├── Validation section: ~10 tokens
└── Configuration/Error Handling: ~10 tokens
────────────────────────────────────────────────
Total: ~100 tokens (vs. 50,000 for direct MCP)
```

## Generic SKILL.md Template

A complete, reusable template is available:

**Template File**: [assets/examples/skill-templates/generic-skill-template.md](assets/examples/skill-templates/generic-skill-template.md)

Use this template as a starting point for new skills. It includes:
- Frontmatter structure
- All standard sections
- Placeholder guidance
- Token optimization notes

## Cross-References

- **Architecture**: See [02-solution-architecture.md](02-solution-architecture.md) for the 4-part structure design
- **Transformation**: See [../compiler-guide/02-architecture.md](../compiler-guide/02-architecture.md#stage-4-skill-generation) for CAPS-to-Skills compilation
- **Writing Scripts**: See [04-writing-scripts.md](04-writing-scripts.md) for implementation patterns
- **Assets**: See [assets/](assets/) for example templates and scripts

## Next Steps

- Learn to write efficient scripts: [04-writing-scripts.md](04-writing-scripts.md)
- See a complete working example: [05-kafka-example.md](05-kafka-example.md)
- Understand on-demand documentation: [06-reference-pattern.md](06-reference-pattern.md)
