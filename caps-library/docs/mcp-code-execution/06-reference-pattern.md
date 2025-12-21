---
description: Create on-demand documentation that loads only when needed, maintaining 0 token cost until requested
readingTime: 6 minutes
---

# REFERENCE.md Pattern

## Overview

The REFERENCE.md file is the fourth component of the MCP Code Execution Pattern. It contains deep documentation that is loaded on-demand only, keeping initial token costs at zero.

## Key Principle

**REFERENCE.md is NOT loaded by default**

The agent only sees REFERENCE.md if:
- Agent explicitly asks: "Show me the reference"
- Agent needs help with "advanced configuration"
- Agent searches documentation for specific topics
- User requests: "Check the reference documentation"

**Token cost:** 0 tokens until requested

This is crucial for maintaining the 99% token reduction. Without this pattern, documentation would consume thousands of tokens whether needed or not.

## Structure

Every REFERENCE.md file should follow this structure:

```markdown
# {Skill Name} - Reference Documentation

## Overview
[Architecture, how it works, design decisions]

## Configuration Options
[All customizable settings with examples]

## Advanced Usage
[Complex scenarios, edge cases]

## API Reference
[If applicable: Functions, parameters, return values]

## Troubleshooting
[Common issues and solutions]

## Examples
[Real-world usage patterns]

## References & Links
[External documentation, related skills]
```

## Example: Kafka REFERENCE.md

A complete example is available:

**File**: [assets/examples/reference/kafka-reference.md](assets/examples/reference/kafka-reference.md)

This file demonstrates:
- **Architecture Overview**: Visual representation of deployed components
- **Configuration Options**: Every Helm chart parameter explained
- **Topic Management**: Complete kubectl commands
- **Troubleshooting**: Common issues with diagnostic commands
- **Performance Tuning**: Settings for high throughput vs. low latency
- **Monitoring**: Health check commands
- **Upgrade/Uninstall**: Helm operations

**Size**: 200+ lines, ~1000 tokens

**When it loads**: Only when agent asks for it

## When to Create REFERENCE.md

Create a REFERENCE.md file when your skill has:

1. **Multiple configuration options** (>5 parameters)
2. **Complex troubleshooting** (common errors with solutions)
3. **Advanced usage patterns** (beyond basic deployment)
4. **External dependencies** (requires explaining integrations)
5. **Performance tuning** (optimization settings)

## When to Skip REFERENCE.md

Skip REFERENCE.md for simple skills:

- Single-purpose utilities (e.g., agents-md-gen)
- No configuration options
- Trivial troubleshooting
- Self-explanatory operation

Example: A skill that generates a single file doesn't need a REFERENCE.md

## Token Cost Comparison

### Without REFERENCE.md Pattern

```
Scenario: Agent needs to deploy Kafka

Agent Context:
├── SKILL.md with all configuration: 1,200 tokens
├── Troubleshooting embedded: 500 tokens
├── Examples embedded: 300 tokens
└── API docs embedded: 400 tokens
────────────────────────────────────────────
Total: 2,400 tokens loaded upfront
```

### With REFERENCE.md Pattern

```
Scenario: Agent needs to deploy Kafka (basic deployment)

Agent Context:
├── SKILL.md (minimal): 100 tokens
└── REFERENCE.md: 0 tokens (not loaded)
────────────────────────────────────────────
Total: 100 tokens

Later: Agent encounters error and needs troubleshooting
├── SKILL.md already loaded: 0 additional
├── Agent asks "show reference": +1,000 tokens
────────────────────────────────────────────
Total: 1,100 tokens (only when needed)
```

**Benefit**: 54% reduction even when reference is loaded, 96% reduction when not needed

## Best Practices

### DO:

1. **Keep SKILL.md minimal** - Move all details to REFERENCE.md
2. **Link from SKILL.md** - Use `See [REFERENCE.md](./REFERENCE.md)` for more info
3. **Structure consistently** - Follow the standard sections
4. **Provide examples** - Real commands users can copy-paste
5. **Include troubleshooting** - Common errors with solutions

### DON'T:

1. **Don't duplicate** - Don't repeat SKILL.md content in REFERENCE.md
2. **Don't load automatically** - Never have scripts that output REFERENCE.md content
3. **Don't skip organization** - Use headings and sections
4. **Don't forget updates** - Keep REFERENCE.md in sync with scripts

## Integration with SKILL.md

In your SKILL.md, reference the REFERENCE.md file like this:

```markdown
## Configuration

For custom deployments, see [REFERENCE.md](./REFERENCE.md):
- Number of replicas
- Storage configuration
- Topic creation settings
- Resource limits
- Security policies
```

This tells the agent:
1. More information is available
2. Where to find it (REFERENCE.md)
3. What topics are covered

## Cross-References

- **Complete Example**: See [05-kafka-example.md](05-kafka-example.md#file-5-referencemd) for Kafka's REFERENCE.md usage
- **Token Optimization**: See [02-solution-architecture.md](02-solution-architecture.md) for the 4-part structure

## Next Steps

- Test your skill across agents: [07-cross-agent-testing.md](07-cross-agent-testing.md)
- Learn verification benchmarks: [08-performance-benchmarks.md](08-performance-benchmarks.md)
- Apply best practices: [09-best-practices.md](09-best-practices.md)
