#!/bin/bash
# Batch compile multiple CAPS playbook libraries
# Usage: bash compile-all-libraries.sh [output-dir]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
OUTPUT_DIR="${1:-.claude/skills}"
COMPILER="caps-library/scripts/caps-to-skills.sh"
PLAYBOOKS_DIR="caps-library/playbooks"

echo -e "${YELLOW}CAPS Batch Compiler${NC}"
echo "=================="
echo "Output directory: $OUTPUT_DIR"
echo ""

# Verify compiler exists
if [[ ! -f "$COMPILER" ]]; then
    echo -e "${RED}Error: Compiler not found at $COMPILER${NC}"
    exit 1
fi

# Find all playbooks
PLAYBOOKS=($(find "$PLAYBOOKS_DIR" -name "playbook.md" -type f))
TOTAL=${#PLAYBOOKS[@]}

if [[ $TOTAL -eq 0 ]]; then
    echo -e "${RED}No playbooks found in $PLAYBOOKS_DIR${NC}"
    exit 1
fi

echo "Found $TOTAL playbooks"
echo ""

# Compile each playbook
SUCCESS_COUNT=0
FAIL_COUNT=0
FAILED_PLAYBOOKS=()

for playbook_path in "${PLAYBOOKS[@]}"; do
    # Extract playbook name from path
    playbook_name=$(dirname "$playbook_path" | xargs basename)

    echo -e "${YELLOW}Processing: $playbook_name${NC}"

    # Compile with validation
    if bash "$COMPILER" "$playbook_name" --validate -o "$OUTPUT_DIR" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Compiled successfully"
        ((SUCCESS_COUNT++))
    else
        echo -e "  ${RED}✗${NC} Compilation failed"
        FAILED_PLAYBOOKS+=("$playbook_name")
        ((FAIL_COUNT++))
    fi
done

echo ""
echo "=================="
echo "Compilation Summary"
echo "=================="
echo -e "Total playbooks: $TOTAL"
echo -e "${GREEN}Successful: $SUCCESS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"

if [[ $FAIL_COUNT -gt 0 ]]; then
    echo ""
    echo "Failed playbooks:"
    for playbook in "${FAILED_PLAYBOOKS[@]}"; do
        echo "  - $playbook"
    done
    exit 1
fi

echo ""
echo -e "${GREEN}All playbooks compiled successfully!${NC}"
exit 0
