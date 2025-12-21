# MCP Code Execution Pattern

## Overview

The **MCP Code Execution Pattern** is Hackathon 3's core innovation. Instead of loading massive MCP tool definitions into the agent's context, you wrap them in minimal Skills that execute external scripts.

This documentation explains how to build efficient Claude Skills using external script execution, achieving 99.8% token reduction compared to direct MCP usage.

### The Paradigm Shift

**Old Approach (Hackathon 2): Direct MCP**
```
Agent Context: [MCP tools loaded] → [Tool results] → [Processing]
Token Cost: 50,000+ before you start
```

**New Approach (Hackathon 3): Skills + Scripts**
```
Agent Context: [Skill.md ~100 tokens] → [Script executes] → [Result returned]
Token Cost: 110 tokens total (80-98% reduction)
```

### Why This Matters

| Scenario | Direct MCP | Skills + Scripts | Savings |
|----------|-----------|------------------|---------|
| Single deployment | 50,000 tokens | 110 tokens | 99.8% |
| 10 tool calls | 50,000 + 50,000 | 110 + 20 | 99.9% |
| Complex workflow | 50,000 + 100,000 | 110 + 100 | 99.9% |

**Real-world impact:** Same capability, 400-800x fewer tokens = longer conversations, faster responses, lower cost.

---

## 🎯 Learning Path

This guide is organized into three tiers to support your learning journey:

### Foundation (Start Here)

New to the MCP Code Execution Pattern? Start with these foundational concepts:

1. **[The Token Problem](01-token-problem.md)** - Understand why direct MCP consumes 50,000+ tokens
2. **[Solution Architecture](02-solution-architecture.md)** - Learn the 4-part structure that reduces to 110 tokens

**Outcome**: Understand the 3 token problems (Tool Definition Loading, Data Bloat, Transcript Duplication) and how the pattern achieves 99.8% reduction.

### Intermediate (Build Skills)

Ready to create your first efficient skill? Follow these hands-on guides:

3. **[Skill Structure](03-skill-structure.md)** - Master the SKILL.md template and 4-part architecture
4. **[Writing Efficient Scripts](04-writing-scripts.md)** - Learn Python/Bash patterns for minimal token usage
5. **[Complete Kafka Example](05-kafka-example.md)** - Study a production-ready skill (SKILL.md, scripts/, REFERENCE.md)

**Outcome**: Create your first skill in <30 minutes following the proven patterns.

### Advanced (Reference & Optimization)

Optimize your skills and ensure cross-agent compatibility:

6. **[REFERENCE.md Pattern](06-reference-pattern.md)** - Implement on-demand documentation (0 tokens until requested)
7. **[Cross-Agent Testing](07-cross-agent-testing.md)** - Ensure skills work with both Claude Code and Goose
8. **[Performance Benchmarks](08-performance-benchmarks.md)** - Validate 99% token reduction and measure impact
9. **[Best Practices](09-best-practices.md)** - Apply DO/DON'T lists and production-grade patterns

**Outcome**: Build production-ready skills with cross-agent compatibility and optimal token efficiency.

---

## Prerequisites

Before diving into this documentation:

- **Basic Programming**: Familiarity with Python 3.8+ and Bash scripting
- **Kubernetes Knowledge**: Understanding of kubectl, pods, services, namespaces
- **CAPS Fundamentals**: Read the [CAPS-to-Skills Compiler Guide](../compiler-guide/README.md) first
- **Project Constitution**: Review [Constitution Principles I, V, VII](../../../.specify/memory/constitution.md) for context

**No MCP experience required** - this guide assumes you're starting fresh.

---

## Estimated Reading Time

- **Foundation (Sections 1-2)**: 15 minutes
- **Intermediate (Sections 3-5)**: 25 minutes
- **Advanced (Sections 6-9)**: 20 minutes
- **Total**: 45-60 minutes for complete understanding

---

## Quick Navigation

### Core Concepts
- [The Token Problem](01-token-problem.md) - Why 50,000+ tokens?
- [Solution Architecture](02-solution-architecture.md) - How to reduce to 110 tokens
- [Performance Benchmarks](08-performance-benchmarks.md) - Validate 99.8% reduction

### Practical Guides
- [Skill Structure](03-skill-structure.md) - SKILL.md template
- [Writing Scripts](04-writing-scripts.md) - Python/Bash patterns
- [Kafka Example](05-kafka-example.md) - Complete working skill

### Reference & Testing
- [REFERENCE.md Pattern](06-reference-pattern.md) - On-demand documentation
- [Cross-Agent Testing](07-cross-agent-testing.md) - Claude + Goose compatibility
- [Best Practices](09-best-practices.md) - DO/DON'T lists

---

## Related Documentation

- **[CAPS-to-Skills Compiler Guide](../compiler-guide/README.md)** - How CAPS playbooks compile to Skills
- **[Project Constitution](../../../.specify/memory/constitution.md)** - Governance principles (Principles I, V, VII)
- **[Hackathon III Overview](../../../README.md)** - Project context and goals

---

## Next Steps

1. **New to token efficiency?** Start with [The Token Problem](01-token-problem.md)
2. **Ready to build?** Jump to [Kafka Example](05-kafka-example.md)
3. **Need quick reference?** See [Best Practices](09-best-practices.md)

---

**Last Updated**: December 21, 2025
**Version**: 1.0.0
**Maintainer**: Hackathon III Team
