#!/bin/bash
# CAPS to Goose Recipes Compiler
# Converts CAPS playbook format to Goose Recipes format

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

# Usage information
usage() {
    echo "Usage: $0 <playbook-name> [options]"
    echo ""
    echo "Compiles a CAPS playbook to Goose Recipe format"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -o, --output DIR     Output directory (default: .goose/recipes)"
    echo "  -v, --validate       Validate output after compilation"
    echo "  --dry-run            Show what would be done without doing it"
    echo ""
    echo "Examples:"
    echo "  $0 hello-world"
    echo "  $0 deploy-k8s --validate"
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

# Parse arguments
PLAYBOOK_NAME=""
OUTPUT_DIR="$PROJECT_ROOT/.goose/recipes"
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
RECIPE_OUTPUT_FILE="$OUTPUT_DIR/$PLAYBOOK_NAME.md"

log_info "CAPS to Goose Recipes Compiler"
log_info "==============================="
log_info "Playbook: $PLAYBOOK_NAME"
log_info "Source: $PLAYBOOK_FILE"
log_info "Output: $RECIPE_OUTPUT_FILE"
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
    log_info "Would create: $RECIPE_OUTPUT_FILE"
    exit 0
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
log_info "Created output directory: $OUTPUT_DIR"

# Read playbook content
log_info "Reading CAPS playbook..."

# Extract metadata from playbook
TITLE=$(grep -m 1 "^# " "$PLAYBOOK_FILE" | sed 's/^# //')
DESCRIPTION=$(grep -A 1 "^## Description" "$PLAYBOOK_FILE" | tail -n 1)
VERSION=$(grep "^Version:" "$PLAYBOOK_FILE" | sed 's/Version: //')

if [[ -z "$TITLE" ]]; then
    TITLE="$PLAYBOOK_NAME"
fi

if [[ -z "$DESCRIPTION" ]]; then
    DESCRIPTION="CAPS playbook: $PLAYBOOK_NAME"
fi

if [[ -z "$VERSION" ]]; then
    VERSION="1.0.0"
fi

log_info "Title: $TITLE"
log_info "Description: $DESCRIPTION"
log_info "Version: $VERSION"

# Generate Goose Recipe format
log_info "Generating Goose Recipe..."

cat > "$RECIPE_OUTPUT_FILE" <<EOF
# $TITLE

**Description:** $DESCRIPTION
**Version:** $VERSION
**Source:** CAPS playbook \`$PLAYBOOK_NAME\`

---

## Recipe Instructions

EOF

# Extract and convert playbook sections for Goose
awk '
    /^## Prerequisites/ { in_prereq=1; print "### Prerequisites"; next }
    /^## Steps/ { in_prereq=0; in_steps=1; print ""; print "### Steps to Execute"; next }
    /^## Validation/ { in_steps=0; in_validation=1; print ""; print "### Validation"; next }
    /^## Troubleshooting/ { in_validation=0; in_troubleshooting=1; print ""; print "### Troubleshooting"; next }
    in_prereq || in_steps || in_validation || in_troubleshooting { print }
' "$PLAYBOOK_FILE" >> "$RECIPE_OUTPUT_FILE"

# Add metadata footer
cat >> "$RECIPE_OUTPUT_FILE" <<EOF

---

**Compiled from CAPS:** \`caps-library/playbooks/$PLAYBOOK_NAME/playbook.md\`
**Compilation Date:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**CAPS Version:** $VERSION
EOF

log_success "Recipe compiled successfully!"
log_success "Output: $RECIPE_OUTPUT_FILE"

# Validation
if [[ "$VALIDATE" == true ]]; then
    log_info ""
    log_info "Validating generated recipe..."

    if [[ ! -r "$RECIPE_OUTPUT_FILE" ]]; then
        log_error "Validation failed: Output file not readable"
        exit 1
    fi

    if [[ ! -s "$RECIPE_OUTPUT_FILE" ]]; then
        log_error "Validation failed: Output file is empty"
        exit 1
    fi

    if ! grep -q "^# " "$RECIPE_OUTPUT_FILE"; then
        log_warning "Validation warning: No title found"
    fi

    log_success "Validation passed!"
fi

echo ""
log_info "Next steps:"
log_info "1. Review the generated recipe: cat $RECIPE_OUTPUT_FILE"
log_info "2. Test with Goose agent"
log_info "3. Refine the CAPS playbook if needed"

exit 0
