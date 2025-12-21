# Advanced Usage

Advanced patterns and techniques for power users managing large CAPS playbook collections.

---

## Selective Compilation

Compile specific subsets of playbooks based on directory structure, naming patterns, or modification time.

**Token Optimization Note**: When compiling multiple skills, ensure each skill follows the MCP Code Execution Pattern to minimize token consumption. See [MCP Pattern Library](../mcp-code-execution/09-best-practices.md) for optimization strategies.

### Compile by Directory Pattern

```bash
# Compile all playbooks in specific subdirectory
for dir in caps-library/playbooks/kubernetes-*/; do
    playbook=$(basename "$dir")
    bash caps-library/scripts/caps-to-skills.sh "$playbook" --validate
done
```

**Example**: Compile only Kubernetes-related playbooks (`kubernetes-*`)

```bash
# Output:
# Compiling: kubernetes-deploy
# Compiling: kubernetes-rollback
# Compiling: kubernetes-scale
```

### Compile by Name Pattern

```bash
# Compile playbooks matching pattern (e.g., all "setup" playbooks)
for dir in caps-library/playbooks/*-setup/; do
    playbook=$(basename "$dir")
    bash caps-library/scripts/caps-to-skills.sh "$playbook" --validate
done
```

**Example**: Compile `kafka-k8s-setup`, `postgresql-k8s-setup`, `minikube-setup`

### Compile Recently Modified

```bash
# Compile playbooks modified in last 24 hours
find caps-library/playbooks/ -name "playbook.md" -mtime -1 -type f | while read playbook_path; do
    playbook_name=$(dirname "$playbook_path" | xargs basename)
    echo "Compiling recently modified: $playbook_name"
    bash caps-library/scripts/caps-to-skills.sh "$playbook_name" --validate
done
```

**Use Case**: Recompile only changed playbooks after editing session

---

## Batch Processing

Compile multiple playbook libraries efficiently with error handling and reporting.

**MCP Pattern Integration**: When batch compiling skills, follow the [MCP Code Execution Pattern](../mcp-code-execution/README.md) to ensure all generated skills maintain <120 token budgets. See [Writing Efficient Scripts](../mcp-code-execution/04-writing-scripts.md) for implementation guidance.

### Batch Compilation Script

See complete script: [compile-all-libraries.sh](assets/examples/compile-all-libraries.sh)

**Features**:
- Auto-discovers all playbooks
- Validates before compiling
- Tracks success/failure counts
- Reports failed playbooks
- Color-coded output

**Usage**:
```bash
# Compile all playbooks to default location
bash caps-library/docs/compiler-guide/assets/examples/compile-all-libraries.sh

# Compile to custom directory
bash caps-library/docs/compiler-guide/assets/examples/compile-all-libraries.sh /opt/skills
```

**Example Output**:
```
CAPS Batch Compiler
==================
Output directory: .claude/skills

Found 8 playbooks

Processing: hello-world
  ✓ Compiled successfully
Processing: kafka-k8s-setup
  ✓ Compiled successfully
Processing: postgresql-k8s-setup
  ✗ Compilation failed
...

==================
Compilation Summary
==================
Total playbooks: 8
Successful: 7
Failed: 1

Failed playbooks:
  - postgresql-k8s-setup
```

### Parallel Compilation

Use GNU Parallel for faster batch compilation:

```bash
# Install GNU Parallel (if not present)
# Ubuntu/Debian:
sudo apt install parallel

# macOS:
brew install parallel

# Compile playbooks in parallel (4 jobs)
ls caps-library/playbooks/ | parallel -j4 'bash caps-library/scripts/caps-to-skills.sh {} --validate'
```

**Performance**: ~4x faster on multi-core systems for large playbook collections

**Warning**: Parallel compilation produces interleaved output. Use for speed, not readability.

---

## Output Analysis

Analyze compiled skills for metadata, statistics, and quality checks.

### List All Skills

See complete script: [list-skills.sh](assets/examples/list-skills.sh)

**Usage**:
```bash
# List all skills in default directory
bash caps-library/docs/compiler-guide/assets/examples/list-skills.sh

# List skills in custom directory
bash caps-library/docs/compiler-guide/assets/examples/list-skills.sh /opt/skills
```

**Example Output**:
```
Compiled Claude Skills
=====================

Found 3 skills:

hello-world
  Description: Simple example playbook
  Version: 1.0.0
  Compiled: 2025-12-20 14:23:45 UTC
  Path: .claude/skills/hello-world/skill.md

kafka-k8s-setup
  Description: Deploy Apache Kafka on Kubernetes
  Version: 1.0.0
  Compiled: 2025-12-20 14:25:12 UTC
  Path: .claude/skills/kafka-k8s-setup/skill.md

=====================
Total: 2 skills
```

### Count Skills

```bash
# Count total skills
ls .claude/skills/*/skill.md 2>/dev/null | wc -l

# Count by directory pattern
ls .claude/skills/kubernetes-*/skill.md 2>/dev/null | wc -l
```

### Find Skills by Version

```bash
# Find all v1.0.0 skills
grep -l "^version: 1.0.0" .claude/skills/*/skill.md

# Find skills needing updates (version < 2.0.0)
for skill in .claude/skills/*/skill.md; do
    version=$(grep "^version:" "$skill" | sed 's/version: *//')
    if [[ "$version" < "2.0.0" ]]; then
        echo "$(dirname $skill): $version"
    fi
done
```

### Analyze Skill Sizes

```bash
# List skills by size
du -sh .claude/skills/*/skill.md | sort -h

# Find largest skills
du -sh .claude/skills/*/skill.md | sort -hr | head -5
```

**Use Case**: Identify complex playbooks that may need refactoring

---

## Version Control Integration

Manage playbooks and skills together in version control.

### Track Generated Skills

**Option 1**: Commit skills to repository (recommended)
```bash
# Add skills directory to git
git add .claude/skills/

# Commit both playbook and skill
git add caps-library/playbooks/my-feature/
git commit -m "feat: add my-feature playbook and skill"
```

**Benefits**:
- Skills available immediately after checkout
- No compilation required for users
- Full history of skill changes

**Option 2**: Ignore skills, generate on demand
```bash
# Add to .gitignore
echo ".claude/skills/" >> .gitignore

# Users compile after checkout
make compile  # or bash compile-all-libraries.sh
```

**Benefits**:
- Smaller repository size
- No merge conflicts in generated files
- Always uses latest compiler version

### Pre-Commit Hook Integration

Automate compilation in pre-commit hook (see [Workflow Integration](06-workflow-integration.md#git-pre-commit-hook))

```bash
# Hook automatically:
# 1. Detects modified playbooks
# 2. Validates changes
# 3. Compiles to skills
# 4. Stages skills for commit
# 5. Blocks commit if validation fails
```

### Diff Generated Skills

```bash
# Compare skill changes
git diff .claude/skills/my-feature/skill.md

# Show skill changes in last commit
git show HEAD:.claude/skills/my-feature/skill.md
```

---

## Multi-Environment Management

Manage separate skill collections for different environments.

### Environment-Specific Compilation

```bash
# Development environment
bash caps-library/scripts/caps-to-skills.sh my-feature --validate -o .claude/skills-dev

# Staging environment
bash caps-library/scripts/caps-to-skills.sh my-feature --validate -o .claude/skills-staging

# Production environment
bash caps-library/scripts/caps-to-skills.sh my-feature --validate -o .claude/skills-prod
```

### Environment Directory Structure

```
.claude/
├── skills-dev/        # Development skills
├── skills-staging/    # Staging skills
└── skills-prod/       # Production skills
```

### Environment-Specific Git Branches

```bash
# Development branch
git checkout develop
bash compile-all-libraries.sh .claude/skills-dev

# Production branch
git checkout main
bash compile-all-libraries.sh .claude/skills-prod
```

---

## Custom Output Locations

Advanced output directory patterns for complex projects.

### User-Specific Skills

```bash
# Compile to user's home directory
bash caps-library/scripts/caps-to-skills.sh my-feature -o ~/.claude/skills/
```

### Temporary Testing

```bash
# Compile to /tmp for testing
bash caps-library/scripts/caps-to-skills.sh my-feature -o /tmp/test-skills/

# Clean up after testing
rm -rf /tmp/test-skills/
```

### Shared Network Location

```bash
# Compile to network share
bash caps-library/scripts/caps-to-skills.sh my-feature -o /mnt/shared/skills/

# Multiple team members access same skills
```

---

## Automation Patterns

Advanced automation techniques for large-scale deployments.

**Cross-Agent Testing**: When automating skill deployment, ensure cross-agent compatibility. See [Cross-Agent Testing Guide](../mcp-code-execution/07-cross-agent-testing.md) for the 6-item validation checklist.

### Cron Job Automation

```bash
# Add to crontab: compile all playbooks nightly
0 2 * * * cd /path/to/project && bash caps-library/docs/compiler-guide/assets/examples/compile-all-libraries.sh > /var/log/caps-compile.log 2>&1
```

### Watch for Changes

```bash
# Install inotify-tools (Linux)
sudo apt install inotify-tools

# Watch playbooks directory and recompile on changes
while inotifywait -e modify,create,delete -r caps-library/playbooks/; do
    echo "Playbook changed, recompiling..."
    bash compile-all-libraries.sh
done
```

### Continuous Deployment Pipeline

```yaml
# Jenkins/GitLab CI example
stages:
  - validate
  - compile
  - deploy

validate:
  script:
    - bash compile-all-libraries.sh --validate-only

compile:
  script:
    - bash compile-all-libraries.sh .claude/skills-prod/

deploy:
  script:
    - rsync -av .claude/skills-prod/ production-server:/opt/claude/skills/
```

---

## Quality Assurance

Advanced validation and quality checks for playbook collections.

### Validate All Playbooks

```bash
# Dry-run validation without compilation
for dir in caps-library/playbooks/*/; do
    playbook=$(basename "$dir")
    echo "Validating: $playbook"
    bash caps-library/scripts/caps-to-skills.sh "$playbook" --validate --dry-run
done
```

### Check for Common Issues

```bash
# Find playbooks with hardcoded secrets
grep -r "password\|apikey\|token\|secret" caps-library/playbooks/ --include="playbook.md"

# Find playbooks with old versions
for dir in caps-library/playbooks/*/; do
    version=$(grep "^version:" "$dir/playbook.md" | sed 's/version: *//')
    if [[ "$version" < "1.0.0" ]]; then
        echo "$(basename $dir): $version (needs update)"
    fi
done
```

### Lint All Playbooks

```bash
# Check YAML syntax (requires yq)
for dir in caps-library/playbooks/*/; do
    playbook="$dir/playbook.md"
    echo "Checking: $(basename $dir)"

    # Extract and validate YAML
    sed -n '/^---$/,/^---$/p' "$playbook" | yq eval - > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "  ✗ Invalid YAML"
    else
        echo "  ✓ Valid YAML"
    fi
done
```

---

## Performance Optimization

Tips for optimizing compilation performance.

### Skip Validation (Not Recommended)

```bash
# Compile without validation (faster but risky)
bash caps-library/scripts/caps-to-skills.sh my-feature  # No --validate flag

# Use only for known-good playbooks
# Or when validation already done separately
```

**Speed Improvement**: ~30% faster (no validation overhead)
**Risk**: Errors caught at runtime instead of compile-time

### Incremental Compilation

```bash
# Only compile if playbook newer than skill
playbook_file="caps-library/playbooks/my-feature/playbook.md"
skill_file=".claude/skills/my-feature/skill.md"

if [[ ! -f "$skill_file" ]] || [[ "$playbook_file" -nt "$skill_file" ]]; then
    echo "Compiling (playbook modified)"
    bash caps-library/scripts/caps-to-skills.sh my-feature --validate
else
    echo "Skipping (skill up-to-date)"
fi
```

### Batch Validation

```bash
# Validate all first, then compile (fail fast)
echo "Phase 1: Validation"
for dir in caps-library/playbooks/*/; do
    playbook=$(basename "$dir")
    bash caps-library/scripts/caps-to-skills.sh "$playbook" --validate --dry-run || exit 1
done

echo "Phase 2: Compilation"
for dir in caps-library/playbooks/*/; do
    playbook=$(basename "$dir")
    bash caps-library/scripts/caps-to-skills.sh "$playbook"
done
```

---

## Advanced Troubleshooting

### Debug Compilation Issues

```bash
# Enable bash debug mode
bash -x caps-library/scripts/caps-to-skills.sh my-feature --validate

# Show only errors
bash caps-library/scripts/caps-to-skills.sh my-feature --validate 2>&1 | grep "\[ERROR\]"

# Capture full output for analysis
bash caps-library/scripts/caps-to-skills.sh my-feature --validate &> debug.log
```

### Compare Playbook and Skill

```bash
# Side-by-side diff
diff -y caps-library/playbooks/my-feature/playbook.md .claude/skills/my-feature/skill.md | less

# Show only differences
diff caps-library/playbooks/my-feature/playbook.md .claude/skills/my-feature/skill.md
```

---

## Advanced Pattern References

### MCP Code Execution Pattern Library

For production-grade skill patterns beyond basic compilation, explore the MCP Code Execution Pattern documentation:

#### Selective Compilation Patterns
- **[Skill Structure](../mcp-code-execution/03-skill-structure.md)** - Learn the 4-part structure (SKILL.md, scripts/, REFERENCE.md, examples/) for minimal token consumption
- **[Writing Efficient Scripts](../mcp-code-execution/04-writing-scripts.md)** - Python/Bash patterns for external execution (0 tokens in context)
- **[REFERENCE.md Pattern](../mcp-code-execution/06-reference-pattern.md)** - On-demand documentation strategy

**Use Case**: When compiling skills that wrap MCP tools, follow these patterns to achieve 99.8% token reduction.

#### Batch Processing Patterns
- **[Complete Kafka Example](../mcp-code-execution/05-kafka-example.md)** - Full working skill with all 4 parts
- **[Best Practices](../mcp-code-execution/09-best-practices.md)** - DO/DON'T lists for production skills
- **[Example Skills by Difficulty](../mcp-code-execution/09-best-practices.md#example-skills-to-build)** - Foundation, Infrastructure, Application tiers

**Use Case**: When batch-compiling multiple playbooks, use these examples as templates to maintain consistency.

#### Automation Patterns
- **[Cross-Agent Testing](../mcp-code-execution/07-cross-agent-testing.md)** - 6-item checklist for Claude Code + Goose compatibility
- **[Performance Benchmarks](../mcp-code-execution/08-performance-benchmarks.md)** - Token metrics and validation criteria

**Use Case**: Automate validation of compiled skills with cross-agent testing scripts.

### Integration Example: Selective MCP Skill Compilation

```bash
#!/bin/bash
# Compile only MCP-wrapping skills with token optimization validation

MCP_SKILLS=("kafka-k8s-setup" "postgresql-k8s-setup" "fastapi-dapr-service")

for skill in "${MCP_SKILLS[@]}"; do
    echo "Compiling MCP skill: $skill"

    # Compile with validation
    bash caps-library/scripts/caps-to-skills.sh "$skill" --validate || continue

    # Check token budget (<120 tokens target)
    skill_file=".claude/skills/$skill/skill.md"
    token_count=$(wc -w < "$skill_file")

    if (( token_count > 200 )); then
        echo "[WARNING] $skill exceeds 200 tokens ($token_count)"
        echo "Consider moving content to REFERENCE.md"
    else
        echo "[SUCCESS] $skill: $token_count tokens ✓"
    fi
done
```

---

## Next Steps

- **Solve Issues**: [Troubleshooting Guide](07-troubleshooting.md)
- **Automate Workflow**: [Workflow Integration](06-workflow-integration.md)
- **Command Options**: [Command Reference](05-command-reference.md)
- **Token Optimization**: [MCP Code Execution Pattern](../mcp-code-execution/README.md)

---

**Version**: 1.0.0 | **Compiler Version**: 2.0.0 | **Last Updated**: 2025-12-21
