#!/bin/bash
# test-cross-agent-compat.sh
# Validates skill compatibility across Claude Code and Goose
# Usage: ./test-cross-agent-compat.sh <skill-name>

set -euo pipefail

SKILL_NAME="${1:-}"

if [ -z "$SKILL_NAME" ]; then
    echo "Usage: $0 <skill-name>"
    echo "Example: $0 kafka-k8s-setup"
    exit 1
fi

echo "========================================="
echo "Cross-Agent Compatibility Test"
echo "Skill: $SKILL_NAME"
echo "========================================="
echo ""

# Test 1: Agent Recognition
echo "Test 1: Agent Recognition"
echo "-----------------------------------------"
if command -v claude &> /dev/null; then
    if claude list skills 2>/dev/null | grep -q "$SKILL_NAME"; then
        echo "  ✓ Claude recognizes skill"
        CLAUDE_RECOGNIZES=true
    else
        echo "  ✗ Claude does not recognize skill"
        CLAUDE_RECOGNIZES=false
    fi
else
    echo "  ⚠ Claude CLI not found (skipping)"
    CLAUDE_RECOGNIZES=false
fi

if command -v goose &> /dev/null; then
    if goose list skills 2>/dev/null | grep -q "$SKILL_NAME"; then
        echo "  ✓ Goose recognizes skill"
        GOOSE_RECOGNIZES=true
    else
        echo "  ✗ Goose does not recognize skill"
        GOOSE_RECOGNIZES=false
    fi
else
    echo "  ⚠ Goose CLI not found (skipping)"
    GOOSE_RECOGNIZES=false
fi
echo ""

# Test 2: Execution
echo "Test 2: Script Execution"
echo "-----------------------------------------"
SKILL_DIR=".claude/skills/$SKILL_NAME"
if [ ! -d "$SKILL_DIR" ]; then
    echo "  ✗ Skill directory not found: $SKILL_DIR"
    exit 1
fi

MAIN_SCRIPT="$SKILL_DIR/scripts/main.sh"
if [ ! -f "$MAIN_SCRIPT" ]; then
    echo "  ✗ Main script not found: $MAIN_SCRIPT"
    exit 1
fi

if [ ! -x "$MAIN_SCRIPT" ]; then
    echo "  ⚠ Main script not executable, fixing permissions..."
    chmod +x "$MAIN_SCRIPT"
fi

# Test execution (dry-run or actual based on skill requirements)
echo "  Testing script execution..."
if bash -n "$MAIN_SCRIPT"; then
    echo "  ✓ Script syntax valid (bash -n)"
else
    echo "  ✗ Script syntax errors detected"
    exit 1
fi
echo ""

# Test 3: Python Compatibility
echo "Test 3: Python 3.8+ Compatibility"
echo "-----------------------------------------"
PYTHON_VERSION=$(python3 --version 2>&1 | grep -oP '\d+\.\d+' || echo "0.0")
PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)

if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 8 ]; then
    echo "  ✓ Python $PYTHON_VERSION >= 3.8"
else
    echo "  ✗ Python $PYTHON_VERSION < 3.8 (required: 3.8+)"
fi

# Check Python scripts syntax
PYTHON_SCRIPTS=$(find "$SKILL_DIR/scripts" -name "*.py" 2>/dev/null || true)
if [ -n "$PYTHON_SCRIPTS" ]; then
    for script in $PYTHON_SCRIPTS; do
        if python3 -m py_compile "$script" 2>/dev/null; then
            echo "  ✓ $(basename "$script") syntax valid"
        else
            echo "  ✗ $(basename "$script") syntax errors"
        fi
    done
else
    echo "  ⚠ No Python scripts found"
fi
echo ""

# Test 4: Bash Compatibility
echo "Test 4: Bash 4.0+ Compatibility"
echo "-----------------------------------------"
BASH_VERSION=$(bash --version | head -n1 | grep -oP '\d+\.\d+' || echo "0.0")
BASH_MAJOR=$(echo "$BASH_VERSION" | cut -d. -f1)

if [ "$BASH_MAJOR" -ge 4 ]; then
    echo "  ✓ Bash $BASH_VERSION >= 4.0"
else
    echo "  ✗ Bash $BASH_VERSION < 4.0 (required: 4.0+)"
fi

# Check Bash scripts syntax
BASH_SCRIPTS=$(find "$SKILL_DIR/scripts" -name "*.sh" 2>/dev/null || true)
if [ -n "$BASH_SCRIPTS" ]; then
    for script in $BASH_SCRIPTS; do
        if bash -n "$script" 2>/dev/null; then
            echo "  ✓ $(basename "$script") syntax valid"
        else
            echo "  ✗ $(basename "$script") syntax errors"
        fi
    done
else
    echo "  ⚠ No Bash scripts found"
fi
echo ""

# Test 5: REFERENCE.md Access
echo "Test 5: REFERENCE.md Accessibility"
echo "-----------------------------------------"
REFERENCE_FILE="$SKILL_DIR/REFERENCE.md"
if [ -f "$REFERENCE_FILE" ]; then
    echo "  ✓ REFERENCE.md exists"
    echo "  ✓ Size: $(wc -l < "$REFERENCE_FILE") lines"
else
    echo "  ⚠ REFERENCE.md not found (optional)"
fi
echo ""

# Test 6: File Structure
echo "Test 6: File Structure Validation"
echo "-----------------------------------------"
if [ -f "$SKILL_DIR/SKILL.md" ]; then
    echo "  ✓ SKILL.md exists"
else
    echo "  ✗ SKILL.md missing"
fi

if [ -d "$SKILL_DIR/scripts" ]; then
    echo "  ✓ scripts/ directory exists"
else
    echo "  ✗ scripts/ directory missing"
fi
echo ""

# Summary
echo "========================================="
echo "Test Summary"
echo "========================================="
echo "Agent Recognition:"
echo "  Claude: $($CLAUDE_RECOGNIZES && echo '✓' || echo '✗')"
echo "  Goose:  $($GOOSE_RECOGNIZES && echo '✓' || echo '✗')"
echo ""
echo "Compatibility:"
echo "  Python 3.8+: $([ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 8 ] && echo '✓' || echo '✗')"
echo "  Bash 4.0+:   $([ "$BASH_MAJOR" -ge 4 ] && echo '✓' || echo '✗')"
echo ""
echo "File Structure:"
echo "  SKILL.md:      $([ -f "$SKILL_DIR/SKILL.md" ] && echo '✓' || echo '✗')"
echo "  scripts/:      $([ -d "$SKILL_DIR/scripts" ] && echo '✓' || echo '✗')"
echo "  REFERENCE.md:  $([ -f "$REFERENCE_FILE" ] && echo '✓' || echo '⚠')"
echo ""
echo "========================================="
echo "Compatibility test complete"
echo "========================================="
