#!/usr/bin/env bash
# List all collections available in Outline
#
# Usage:
#   list_outline_collections.sh
#
# Environment:
#   OUTLINE_API_KEY - Bearer token for wiki.az-gruppe.com API
#
# Output (JSON):
#   [{"id": "...", "name": "...", "url": "..."}, ...]

set -euo pipefail

# List collections
RESPONSE=$(curl -s -X POST "https://wiki.az-gruppe.com/api/collections.list" \
    -H "Authorization: Bearer $OUTLINE_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{}')

# Check for errors
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.message // "Failed to list collections"')
    echo "{\"success\": false, \"error\": \"$ERROR_MSG\", \"response\": \"$RESPONSE\"}" >&2
    exit 1
fi

# Extract collection list
COLLECTIONS=$(echo "$RESPONSE" | jq -r '.data[] | {id: .id, name: .name, url: .url}')

# Output as JSON array
echo "$COLLECTIONS" | jq -s '.'
