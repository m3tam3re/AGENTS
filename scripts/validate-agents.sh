#!/usr/bin/env bash
#
# Validate agents.json structure and referenced prompt files
#
# Usage:
#   ./scripts/validate-agents.sh
#
# This script validates the agent configuration by:
# - Parsing agents.json as valid JSON
# - Checking all 6 required agents are present
# - Verifying each agent has required fields
# - Validating agent modes (primary vs subagent)
# - Verifying all referenced prompt files exist and are non-empty

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

AGENTS_FILE="$REPO_ROOT/agents/agents.json"
PROMPTS_DIR="$REPO_ROOT/prompts"

# Expected agent list
EXPECTED_AGENTS=("chiron" "chiron-forge" "hermes" "athena" "apollo" "calliope")
# Expected primary agents
PRIMARY_AGENTS=("chiron" "chiron-forge")
# Expected subagents
SUBAGENTS=("hermes" "athena" "apollo" "calliope")
# Required fields for each agent
REQUIRED_FIELDS=("description" "mode" "model" "prompt")

echo -e "${YELLOW}Validating agent configuration...${NC}"
echo ""

# Track errors
error_count=0
warning_count=0

# Function to print error
error() {
    echo -e "${RED}❌ $1${NC}" >&2
    ((error_count++)) || true
}

# Function to print warning
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((warning_count++)) || true
}

# Function to print success
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Check if agents.json exists
if [[ ! -f "$AGENTS_FILE" ]]; then
    error "agents.json not found at $AGENTS_FILE"
    exit 1
fi

# Validate JSON syntax
if ! python3 -c "import json; json.load(open('$AGENTS_FILE'))" 2>/dev/null; then
    error "agents.json is not valid JSON"
    exit 1
fi

success "agents.json is valid JSON"
echo ""

# Parse agents.json
AGENT_COUNT=$(python3 -c "import json; print(len(json.load(open('$AGENTS_FILE'))))")
success "Found $AGENT_COUNT agents in agents.json"

# Check agent count
if [[ $AGENT_COUNT -ne ${#EXPECTED_AGENTS[@]} ]]; then
    error "Expected ${#EXPECTED_AGENTS[@]} agents, found $AGENT_COUNT"
fi

# Get list of agent names
AGENT_NAMES=$(python3 -c "import json; print(' '.join(sorted(json.load(open('$AGENTS_FILE')).keys())))")

echo ""
echo "Checking agent list..."

# Check for missing agents
for expected_agent in "${EXPECTED_AGENTS[@]}"; do
    if echo "$AGENT_NAMES" | grep -qw "$expected_agent"; then
        success "Agent '$expected_agent' found"
    else
        error "Required agent '$expected_agent' not found"
    fi
done

# Check for unexpected agents
for agent_name in $AGENT_NAMES; do
    if [[ ! " ${EXPECTED_AGENTS[@]} " =~ " ${agent_name} " ]]; then
        warning "Unexpected agent '$agent_name' found (not in expected list)"
    fi
done

echo ""
echo "Checking agent fields and modes..."

# Validate each agent
for agent_name in "${EXPECTED_AGENTS[@]}"; do
    echo -n "  $agent_name: "

    # Check required fields
    missing_fields=()
    for field in "${REQUIRED_FIELDS[@]}"; do
        if ! python3 -c "import json; data=json.load(open('$AGENTS_FILE')); print(data.get('$agent_name').get('$field', ''))" 2>/dev/null | grep -q .; then
            missing_fields+=("$field")
        fi
    done

    if [[ ${#missing_fields[@]} -gt 0 ]]; then
        error "Missing required fields: ${missing_fields[*]}"
        continue
    fi

    # Get mode value
    mode=$(python3 -c "import json; print(json.load(open('$AGENTS_FILE'))['$agent_name']['mode'])")

    # Validate mode
    if [[ " ${PRIMARY_AGENTS[@]} " =~ " ${agent_name} " ]]; then
        if [[ "$mode" == "primary" ]]; then
            success "Mode: $mode (valid)"
        else
            error "Expected mode 'primary' for agent '$agent_name', found '$mode'"
        fi
    elif [[ " ${SUBAGENTS[@]} " =~ " ${agent_name} " ]]; then
        if [[ "$mode" == "subagent" ]]; then
            success "Mode: $mode (valid)"
        else
            error "Expected mode 'subagent' for agent '$agent_name', found '$mode'"
        fi
    fi
done

echo ""
echo "Checking prompt files..."

# Validate prompt file references
for agent_name in "${EXPECTED_AGENTS[@]}"; do
    # Extract prompt file path from agent config
    prompt_ref=$(python3 -c "import json; print(json.load(open('$AGENTS_FILE'))['$agent_name']['prompt'])")

    # Parse prompt reference: {file:./prompts/<name>.txt}
    if [[ "$prompt_ref" =~ \{file:(\./prompts/[^}]+)\} ]]; then
        prompt_file="${BASH_REMATCH[1]}"
        prompt_path="$REPO_ROOT/${prompt_file#./}"

        # Check if prompt file exists
        if [[ -f "$prompt_path" ]]; then
            # Check if prompt file is non-empty
            if [[ -s "$prompt_path" ]]; then
                success "Prompt file exists and non-empty: $prompt_file"
            else
                error "Prompt file is empty: $prompt_file"
            fi
        else
            error "Prompt file not found: $prompt_file"
        fi
    else
        error "Invalid prompt reference format for agent '$agent_name': $prompt_ref"
    fi
done

echo ""
if [[ $error_count -eq 0 ]]; then
    echo -e "${GREEN}All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}$error_count validation error(s) found${NC}"
    exit 1
fi
