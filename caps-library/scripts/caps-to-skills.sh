#!/bin/bash
# CAPS to Claude Skills Compiler
# Converts CAPS playbook format to Claude CLI Skills format
# Version: 2.0.0 - Enhanced with comprehensive validation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Known tools whitelist
KNOWN_TOOLS="bash kubectl helm docker git python npm curl jq yq terraform ansible minikube kind make cargo rustc go node ruby pip apt yum dnf brew"

# Usage information
usage() {
    echo "Usage: $0 <playbook-name> [options]"
    echo ""
    echo "Compiles a CAPS playbook to Claude CLI Skill format"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -o, --output DIR     Output directory (default: .claude/skills)"
    echo "  -v, --validate       Run validation checks (recommended)"
    echo "  --dry-run            Show what would be done without doing it"
    echo ""
    echo "Examples:"
    echo "  $0 hello-world"
    echo "  $0 deploy-k8s --validate"
    echo "  $0 fastapi-service -o .claude/skills --validate"
    exit 1
}

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Validation error (blocks compilation)
validation_error() {
    log_error "$1"
    exit 1
}

# Validation warning (continues compilation)
validation_warning() {
    log_warning "$1"
}

# Parse arguments
PLAYBOOK_NAME=""
OUTPUT_DIR="$PROJECT_ROOT/.claude/skills"
VALIDATE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -v|--validate)
            VALIDATE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            if [[ -z "$PLAYBOOK_NAME" ]]; then
                PLAYBOOK_NAME="$1"
            else
                log_error "Unknown argument: $1"
                usage
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "$PLAYBOOK_NAME" ]]; then
    log_error "Playbook name is required"
    usage
fi

# Paths
PLAYBOOK_DIR="$PROJECT_ROOT/caps-library/playbooks/$PLAYBOOK_NAME"
PLAYBOOK_FILE="$PLAYBOOK_DIR/playbook.md"
SKILL_OUTPUT_DIR="$OUTPUT_DIR/$PLAYBOOK_NAME"
SKILL_OUTPUT_FILE="$SKILL_OUTPUT_DIR/skill.md"

log_info "CAPS to Claude Skills Compiler v2.0.0"
log_info "======================================"
log_info "Playbook: $PLAYBOOK_NAME"
log_info "Source: $PLAYBOOK_FILE"
log_info "Output: $SKILL_OUTPUT_FILE"
echo ""

# Check if playbook exists
if [[ ! -f "$PLAYBOOK_FILE" ]]; then
    log_error "Playbook file not found: $PLAYBOOK_FILE"
    log_info "Expected structure: caps-library/playbooks/$PLAYBOOK_NAME/playbook.md"
    exit 1
fi

# Dry run check
if [[ "$DRY_RUN" == true ]]; then
    log_info "DRY RUN - No files will be created"
    log_info "Would create: $SKILL_OUTPUT_FILE"
    exit 0
fi

# Validation function
validate_playbook() {
    local errors=0
    local warnings=0

    log_info "Running validation checks..."
    echo ""

    # Extract YAML frontmatter
    YAML_START=$(grep -n "^---$" "$PLAYBOOK_FILE" | head -1 | cut -d: -f1)
    YAML_END=$(grep -n "^---$" "$PLAYBOOK_FILE" | tail -1 | cut -d: -f1)

    if [[ -z "$YAML_START" ]] || [[ -z "$YAML_END" ]] || [[ "$YAML_START" == "$YAML_END" ]]; then
        validation_error "Invalid YAML frontmatter: Missing --- markers"
    fi

    YAML_CONTENT=$(sed -n "${YAML_START},${YAML_END}p" "$PLAYBOOK_FILE")

    # Check required fields
    log_info "Validating required fields..."
    REQUIRED_FIELDS=("title" "description" "version" "allowed_tools" "prerequisites")

    for field in "${REQUIRED_FIELDS[@]}"; do
        if ! echo "$YAML_CONTENT" | grep -q "^$field:"; then
            validation_error "Missing required field: $field"
        else
            log_info "  ✓ Field '$field' present"
        fi
    done

    # Validate version format (basic semver check)
    VERSION=$(echo "$YAML_CONTENT" | grep "^version:" | sed 's/version: *//' | tr -d ' ')
    if ! echo "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        validation_error "Invalid version format: $VERSION (expected MAJOR.MINOR.PATCH)"
    else
        log_info "  ✓ Version format valid: $VERSION"
    fi

    # Check required sections
    log_info "Validating required sections..."
    REQUIRED_SECTIONS=("## Prerequisites" "## Instructions" "## Validation" "## Troubleshooting")

    for section in "${REQUIRED_SECTIONS[@]}"; do
        if ! grep -q "^$section" "$PLAYBOOK_FILE"; then
            validation_error "Missing required section: $section"
        else
            log_info "  ✓ Section '$section' present"
        fi
    done

    # Validate code blocks (must be matched)
    log_info "Validating code blocks..."
    CODE_BLOCK_COUNT=$(grep -c '^```' "$PLAYBOOK_FILE" || true)
    if [ $((CODE_BLOCK_COUNT % 2)) -ne 0 ]; then
        validation_error "Unmatched code block markers (found $CODE_BLOCK_COUNT, must be even)"
    else
        log_info "  ✓ Code blocks matched ($CODE_BLOCK_COUNT markers)"
    fi

    # Quality warnings (non-blocking)
    log_info "Checking quality warnings..."

    # Check for hardcoded secrets
    if grep -Eiq "password|apikey|token|secret" "$PLAYBOOK_FILE"; then
        LINES=$(grep -Ein "password|apikey|token|secret" "$PLAYBOOK_FILE" | head -3 | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
        validation_warning "Potential hardcoded secret detected (lines: $LINES)"
        ((warnings++))
    fi

    # Check for non-consecutive step numbering
    STEPS=$(grep "^### Step [0-9]" "$PLAYBOOK_FILE" | sed 's/.*Step \([0-9]*\).*/\1/' | tr '\n' ' ')
    if [[ -n "$STEPS" ]]; then
        PREV=0
        for step in $STEPS; do
            if [[ $PREV -ne 0 ]] && [[ $((step - PREV)) -ne 1 ]]; then
                validation_warning "Non-consecutive step numbering detected (Step $PREV → Step $step)"
                ((warnings++))
                break
            fi
            PREV=$step
        done
    fi

    # Check for unknown tools
    TOOLS=$(echo "$YAML_CONTENT" | sed -n '/^allowed_tools:/,/^[a-z_]*:/p' | grep "^  - " | sed 's/^  - //' | tr '\n' ' ')
    for tool in $TOOLS; do
        if ! echo "$KNOWN_TOOLS" | grep -qw "$tool"; then
            validation_warning "Unknown tool in allowed_tools: $tool (not in whitelist)"
            ((warnings++))
        fi
    done

    echo ""
    if [[ $errors -eq 0 ]]; then
        log_success "Validation passed! (0 errors, $warnings warnings)"
        return 0
    else
        log_error "Validation failed with $errors errors"
        return 1
    fi
}

# Run validation if requested
if [[ "$VALIDATE" == true ]]; then
    if ! validate_playbook; then
        exit 1
    fi
    echo ""
fi

# Create output directory
mkdir -p "$SKILL_OUTPUT_DIR"
log_info "Created output directory: $SKILL_OUTPUT_DIR"

# Read playbook content
log_info "Reading CAPS playbook..."

# Extract YAML frontmatter fields
YAML_START=$(grep -n "^---$" "$PLAYBOOK_FILE" | head -1 | cut -d: -f1)
YAML_END=$(grep -n "^---$" "$PLAYBOOK_FILE" | tail -1 | cut -d: -f1)
YAML_CONTENT=$(sed -n "${YAML_START},${YAML_END}p" "$PLAYBOOK_FILE")

# Extract metadata (using directory name for skill name per research.md)
SKILL_NAME="$PLAYBOOK_NAME"
TITLE=$(echo "$YAML_CONTENT" | grep "^title:" | sed 's/title: *//')
DESCRIPTION=$(echo "$YAML_CONTENT" | grep "^description:" | sed 's/description: *//')
VERSION=$(echo "$YAML_CONTENT" | grep "^version:" | sed 's/version: *//' | tr -d ' ')

# Fallbacks
if [[ -z "$TITLE" ]]; then
    TITLE="$PLAYBOOK_NAME"
fi

if [[ -z "$DESCRIPTION" ]]; then
    DESCRIPTION="CAPS playbook: $PLAYBOOK_NAME"
fi

if [[ -z "$VERSION" ]]; then
    VERSION="1.0.0"
fi

log_info "Skill Name: $SKILL_NAME (from directory)"
log_info "Title: $TITLE"
log_info "Description: $DESCRIPTION"
log_info "Version: $VERSION"

# Generate Claude Skill format
log_info "Generating Claude Skill..."

# Write YAML frontmatter
cat > "$SKILL_OUTPUT_FILE" <<EOF
---
description: $DESCRIPTION
version: $VERSION
---

# $TITLE

$DESCRIPTION

EOF

# Extract and append markdown sections (verbatim content preservation)
# Copy everything after second --- (end of YAML frontmatter)
CONTENT_START=$((YAML_END + 1))
sed -n "${CONTENT_START},\$p" "$PLAYBOOK_FILE" | sed '/^# /d' >> "$SKILL_OUTPUT_FILE"

# Add metadata footer
cat >> "$SKILL_OUTPUT_FILE" <<EOF

---

**Source Playbook:** \`caps-library/playbooks/$PLAYBOOK_NAME/playbook.md\`
**Compiled:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**CAPS Version:** $VERSION
**Skill Name:** $SKILL_NAME
EOF

log_success "Skill compiled successfully!"
log_success "Output: $SKILL_OUTPUT_FILE"

# Post-compilation validation
if [[ "$VALIDATE" == true ]]; then
    log_info ""
    log_info "Validating generated skill..."

    # Check if file exists and is readable
    if [[ ! -r "$SKILL_OUTPUT_FILE" ]]; then
        log_error "Validation failed: Output file not readable"
        exit 1
    fi

    # Check if file has content
    if [[ ! -s "$SKILL_OUTPUT_FILE" ]]; then
        log_error "Validation failed: Output file is empty"
        exit 1
    fi

    # Check for YAML frontmatter
    if ! grep -q "^---" "$SKILL_OUTPUT_FILE"; then
        validation_warning "No YAML frontmatter found in output"
    fi

    # Check for title
    if ! grep -q "^# " "$SKILL_OUTPUT_FILE"; then
        validation_warning "No title heading found in output"
    fi

    log_success "Output validation passed!"
fi

echo ""
log_info "Next steps:"
log_info "1. Review the generated skill: cat $SKILL_OUTPUT_FILE"
log_info "2. Test with Claude Code CLI"
log_info "3. Refine CAPS playbook if needed"
log_info "4. Commit both playbook and skill to git"

exit 0
