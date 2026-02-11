#!/usr/bin/env bash
#
# Test skills by launching opencode with this repo's config
#
# Usage:
#   ./scripts/test-skill.sh              # List all development skills
#   ./scripts/test-skill.sh <skill>      # Validate specific skill
#   ./scripts/test-skill.sh --run        # Launch interactive opencode session
#
# This script creates a temporary XDG_CONFIG_HOME with symlinks to this
# repository's skills/, context/, command/, and prompts/ directories,
# allowing you to test skill changes before deploying via home-manager.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

setup_test_config() {
    local tmp_base="${TMPDIR:-/tmp}/opencode-test-$$"
    local tmp_config="$tmp_base/opencode"

    mkdir -p "$tmp_config"
    ln -sf "$REPO_ROOT/skills" "$tmp_config/skills"
    ln -sf "$REPO_ROOT/context" "$tmp_config/context"
    ln -sf "$REPO_ROOT/commands" "$tmp_config/commands"
    ln -sf "$REPO_ROOT/prompts" "$tmp_config/prompts"

    echo "$tmp_base"
}

cleanup_test_config() {
    local tmp_base="$1"
    rm -rf "$tmp_base"
}

usage() {
    echo "Usage: $0 [OPTIONS] [SKILL_NAME]"
    echo ""
    echo "Test Opencode skills from this repository without deploying."
    echo ""
    echo "Options:"
    echo "  --run       Launch interactive opencode session with dev skills"
    echo "  --list      List all skills (default if no args)"
    echo "  --validate  Validate all skills"
    echo "  --help      Show this help message"
    echo ""
    echo "Arguments:"
    echo "  SKILL_NAME  Validate a specific skill by name"
    echo ""
    echo "Examples:"
    echo "  $0                    # List all development skills"
    echo "  $0 task-management    # Validate task-management skill"
    echo "  $0 --validate         # Validate all skills"
    echo "  $0 --run              # Launch interactive session"
}

list_skills() {
    local tmp_base
    tmp_base=$(setup_test_config)
    trap "cleanup_test_config '$tmp_base'" EXIT

    echo -e "${YELLOW}Skills in development (from $REPO_ROOT):${NC}"
    echo ""
    XDG_CONFIG_HOME="$tmp_base" opencode debug skill
}

validate_skill() {
    local skill_name="$1"
    local skill_path="$REPO_ROOT/skills/$skill_name"

    if [[ ! -d "$skill_path" ]]; then
        echo -e "${RED}❌ Skill not found: $skill_name${NC}"
        echo "Available skills:"
        ls -1 "$REPO_ROOT/skills/"
        exit 1
    fi

    echo -e "${YELLOW}Validating skill: $skill_name${NC}"
    if python3 "$REPO_ROOT/skills/skill-creator/scripts/quick_validate.py" "$skill_path"; then
        echo -e "${GREEN}✅ Skill '$skill_name' is valid${NC}"
    else
        echo -e "${RED}❌ Skill '$skill_name' has validation errors${NC}"
        exit 1
    fi
}

validate_all() {
    echo -e "${YELLOW}Validating all skills...${NC}"
    echo ""

    local failed=0
    for skill_dir in "$REPO_ROOT/skills/"*/; do
        local skill_name=$(basename "$skill_dir")
        echo -n "  $skill_name: "
        if python3 "$REPO_ROOT/skills/skill-creator/scripts/quick_validate.py" "$skill_dir" > /dev/null 2>&1; then
            echo -e "${GREEN}✅${NC}"
        else
            echo -e "${RED}❌${NC}"
            python3 "$REPO_ROOT/skills/skill-creator/scripts/quick_validate.py" "$skill_dir" 2>&1 | sed 's/^/    /'
            ((failed++)) || true
        fi
    done

    echo ""
    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}All skills valid!${NC}"
    else
        echo -e "${RED}$failed skill(s) failed validation${NC}"
        exit 1
    fi
}

run_opencode() {
    local tmp_base
    tmp_base=$(setup_test_config)
    trap "cleanup_test_config '$tmp_base'" EXIT

    echo -e "${YELLOW}Launching opencode with development skills...${NC}"
    echo -e "Config path: ${GREEN}$tmp_base/opencode${NC}"
    echo ""
    XDG_CONFIG_HOME="$tmp_base" opencode
}

# Main
case "${1:-}" in
    --help|-h)
        usage
        exit 0
        ;;
    --run)
        run_opencode
        ;;
    --list)
        list_skills
        ;;
    --validate)
        validate_all
        ;;
    "")
        list_skills
        ;;
    *)
        validate_skill "$1"
        ;;
esac
