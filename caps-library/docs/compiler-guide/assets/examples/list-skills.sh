#!/bin/bash
# List all compiled skills with metadata
# Usage: bash list-skills.sh [skills-dir]

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SKILLS_DIR="${1:-.claude/skills}"

echo -e "${YELLOW}Compiled Claude Skills${NC}"
echo "====================="
echo ""

if [[ ! -d "$SKILLS_DIR" ]]; then
    echo "Skills directory not found: $SKILLS_DIR"
    exit 1
fi

# Find all skill.md files
SKILLS=($(find "$SKILLS_DIR" -name "skill.md" -type f | sort))
TOTAL=${#SKILLS[@]}

if [[ $TOTAL -eq 0 ]]; then
    echo "No compiled skills found in $SKILLS_DIR"
    exit 0
fi

echo "Found $TOTAL skills:"
echo ""

# List each skill with metadata
for skill_path in "${SKILLS[@]}"; do
    skill_dir=$(dirname "$skill_path")
    skill_name=$(basename "$skill_dir")

    # Extract metadata from skill file
    description=$(sed -n '/^description:/p' "$skill_path" | head -1 | sed 's/description: *//')
    version=$(sed -n '/^version:/p' "$skill_path" | head -1 | sed 's/version: *//')
    compiled=$(sed -n '/\*\*Compiled:\*\*/p' "$skill_path" | sed 's/.*Compiled:\*\* *//')

    # Print skill info
    echo -e "${GREEN}$skill_name${NC}"
    echo "  Description: $description"
    echo "  Version: $version"
    echo "  Compiled: $compiled"
    echo "  Path: $skill_path"
    echo ""
done

echo "====================="
echo "Total: $TOTAL skills"
