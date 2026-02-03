#!/usr/bin/env bash
#
# Validate agents.json structure and prompt files
#
# Usage:
#   ./scripts/validate-agents.sh              # Validate agents.json
#   ./scripts/validate-agents.sh --help       # Show help
#
# Checks:
#   - agents.json is valid JSON
#   - Each agent has required fields (description, mode, model, prompt, permission)
#   - All referenced prompt files exist
#   - All prompt files are non-empty

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Validate agents.json structure and prompt files."
    echo ""
    echo "Options:"
    echo "  --help      Show this help message"
    echo ""
    echo "Validates:"
    echo "  - agents.json is valid JSON"
    echo "  - Each agent has required fields"
    echo "  - All referenced prompt files exist"
    echo "  - All prompt files are non-empty"
}

check_json_valid() {
    local agents_file="$1"

    if ! python3 -m json.tool "$agents_file" > /dev/null 2>&1; then
        echo -e "${RED}❌ agents.json is not valid JSON${NC}"
        return 1
    fi

    echo -e "${GREEN}✅ agents.json is valid JSON${NC}"
    return 0
}

check_required_fields() {
    local agents_file="$1"
    local agent_name="$2"
    local agent_data="$3"

    local required_fields=("description" "mode" "model" "prompt" "permission")
    local missing_fields=()

    for field in "${required_fields[@]}"; do
        if ! echo "$agent_data" | python3 -c "import sys, json; data = json.load(sys.stdin); exit(0 if '$field' in data else 1)" 2>/dev/null; then
            missing_fields+=("$field")
        fi
    done

    if [[ ${#missing_fields[@]} -gt 0 ]]; then
        echo -e "  ${RED}❌ Missing required fields for '$agent_name': ${missing_fields[*]}${NC}"
        return 1
    fi

    echo -e "  ${GREEN}✅ '$agent_name' has all required fields${NC}"
    return 0
}

check_prompt_file() {
    local agent_name="$1"
    local prompt_ref="$2"

    # Extract filename from {file:./prompts/filename}
    if [[ ! $prompt_ref =~ \{file:./prompts/([^}]+)\} ]]; then
        echo -e "  ${RED}❌ '$agent_name': Invalid prompt reference format: $prompt_ref${NC}"
        return 1
    fi

    local prompt_file="prompts/${BASH_REMATCH[1]}"

    if [[ ! -f "$REPO_ROOT/$prompt_file" ]]; then
        echo -e "  ${RED}❌ '$agent_name': Prompt file not found: $prompt_file${NC}"
        return 1
    fi

    if [[ ! -s "$REPO_ROOT/$prompt_file" ]]; then
        echo -e "  ${RED}❌ '$agent_name': Prompt file is empty: $prompt_file${NC}"
        return 1
    fi

    echo -e "  ${GREEN}✅ '$agent_name': Prompt file exists and is non-empty ($prompt_file)${NC}"
    return 0
}

validate_agents() {
    local agents_file="$REPO_ROOT/agents/agents.json"

    echo -e "${YELLOW}Validating agents.json...${NC}"
    echo ""

    if [[ ! -f "$agents_file" ]]; then
        echo -e "${RED}❌ agents.json not found at $agents_file${NC}"
        exit 1
    fi

    check_json_valid "$agents_file" || exit 1

    local agent_names
    agent_names=$(python3 -c "import json; data = json.load(open('$agents_file')); print('\n'.join(data.keys()))")

    local failed=0

    while IFS= read -r agent_name; do
        [[ -z "$agent_name" ]] && continue

        echo -n "  Checking '$agent_name': "

        local agent_data
        agent_data=$(python3 -c "import json; data = json.load(open('$agents_file')); print(json.dumps(data['$agent_name']))")

        if ! check_required_fields "$agents_file" "$agent_name" "$agent_data"; then
            ((failed++)) || true
            continue
        fi

        local prompt_ref
        prompt_ref=$(python3 -c "import json, sys; data = json.load(open('$agents_file')); print(data['$agent_name'].get('prompt', ''))")

        if ! check_prompt_file "$agent_name" "$prompt_ref"; then
            ((failed++)) || true
        fi

    done <<< "$agent_names"

    echo ""

    if [[ $failed -eq 0 ]]; then
        echo -e "${GREEN}✅ All agents validated successfully!${NC}"
        exit 0
    else
        echo -e "${RED}❌ $failed agent(s) failed validation${NC}"
        exit 1
    fi
}

# Main
case "${1:-}" in
    --help|-h)
        usage
        exit 0
        ;;
    "")
        validate_agents
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo ""
        usage
        exit 1
        ;;
esac
