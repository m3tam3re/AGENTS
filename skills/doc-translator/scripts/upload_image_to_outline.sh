#!/usr/bin/env bash
# Upload an image to Outline via presigned POST (two-step flow)
#
# Usage:
#   upload_image_to_outline.sh <image_path> [document_id]
#
# Environment:
#   OUTLINE_API_KEY - Bearer token for wiki.az-gruppe.com API
#                     Auto-loaded from /run/agenix/outline-key if not set
#
# Output (JSON to stdout):
#   {"success": true, "attachment_url": "https://..."}
# Error (JSON to stderr):
#   {"success": false, "error": "error message"}

set -euo pipefail

MAX_RETRIES=3
RETRY_DELAY=2

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo '{"success": false, "error": "Usage: upload_image_to_outline.sh <image_path> [document_id]"}' >&2
    exit 1
fi

IMAGE_PATH="$1"
DOCUMENT_ID="${2:-}"

if [ -z "${OUTLINE_API_KEY:-}" ]; then
    if [ -f /run/agenix/outline-key ]; then
        OUTLINE_API_KEY=$(cat /run/agenix/outline-key)
        export OUTLINE_API_KEY
    else
        echo '{"success": false, "error": "OUTLINE_API_KEY not set and /run/agenix/outline-key not found"}' >&2
        exit 1
    fi
fi

# Check if file exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "{\"success\": false, \"error\": \"Image file not found: $IMAGE_PATH\"}" >&2
    exit 1
fi

# Extract image name and extension
IMAGE_NAME="$(basename "$IMAGE_PATH")"
EXTENSION="${IMAGE_NAME##*.}"

# Detect content type by extension
case "${EXTENSION,,}" in
    png)       CONTENT_TYPE="image/png" ;;
    jpg|jpeg)  CONTENT_TYPE="image/jpeg" ;;
    gif)       CONTENT_TYPE="image/gif" ;;
    svg)       CONTENT_TYPE="image/svg+xml" ;;
    webp)      CONTENT_TYPE="image/webp" ;;
    *)         CONTENT_TYPE="application/octet-stream" ;;
esac

FILESIZE=$(stat -c%s "$IMAGE_PATH" 2>/dev/null || stat -f%z "$IMAGE_PATH" 2>/dev/null)

if [ -z "$FILESIZE" ]; then
    echo "{\"success\": false, \"error\": \"Failed to get file size for: $IMAGE_PATH\"}" >&2
    exit 1
fi

REQUEST_BODY=$(jq -n \
    --arg name "$IMAGE_NAME" \
    --arg contentType "$CONTENT_TYPE" \
    --argjson size "$FILESIZE" \
    --arg documentId "$DOCUMENT_ID" \
    'if $documentId == "" then
        {name: $name, contentType: $contentType, size: $size}
    else
        {name: $name, contentType: $contentType, size: $size, documentId: $documentId}
    end')

# Step 1: Create attachment record
RESPONSE=$(curl -s -X POST "https://wiki.az-gruppe.com/api/attachments.create" \
    -H "Authorization: Bearer $OUTLINE_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$REQUEST_BODY")

UPLOAD_URL=$(echo "$RESPONSE" | jq -r '.data.uploadUrl // empty')
ATTACHMENT_URL=$(echo "$RESPONSE" | jq -r '.data.attachment.url // empty')

if [ -z "$UPLOAD_URL" ]; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.message // "Failed to create attachment"')
    echo "{\"success\": false, \"error\": \"$ERROR_MSG\", \"response\": $(echo "$RESPONSE" | jq -c .)}" >&2
    exit 1
fi

FORM_ARGS=()
while IFS= read -r line; do
    key=$(echo "$line" | jq -r '.key')
    value=$(echo "$line" | jq -r '.value')
    FORM_ARGS+=(-F "$key=$value")
done < <(echo "$RESPONSE" | jq -c '.data.form | to_entries[]')

# Step 2: Upload binary to presigned URL with retry
for attempt in $(seq 1 "$MAX_RETRIES"); do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$UPLOAD_URL" \
        "${FORM_ARGS[@]}" \
        -F "file=@$IMAGE_PATH")

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "204" ]; then
        echo "{\"success\": true, \"attachment_url\": \"$ATTACHMENT_URL\"}"
        exit 0
    fi

    if [ "$attempt" -lt "$MAX_RETRIES" ]; then
        sleep "$((RETRY_DELAY * attempt))"
    fi
done

echo "{\"success\": false, \"error\": \"Upload failed after $MAX_RETRIES attempts (last HTTP $HTTP_CODE)\"}" >&2
exit 1
