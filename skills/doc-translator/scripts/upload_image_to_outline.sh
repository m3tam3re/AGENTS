#!/usr/bin/env bash
# Upload an image to an Outline document via signed URL
#
# Usage:
#   upload_image_to_outline.sh <image_path> <document_id>
#
# Environment:
#   OUTLINE_API_KEY - Bearer token for wiki.az-gruppe.com API
#
# Output (JSON):
#   {"success": true, "attachment_url": "https://...", "document_id": "..."}
#   OR
#   {"success": false, "error": "error message"}

set -euo pipefail

if [ $# -ne 2 ]; then
    echo '{"success": false, "error": "Usage: upload_image_to_outline.sh <image_path> <document_id>"}' >&2
    exit 1
fi

IMAGE_PATH="$1"
DOCUMENT_ID="$2"

# Check if file exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "{\"success\": false, \"error\": \"Image file not found: $IMAGE_PATH\"}" >&2
    exit 1
fi

# Extract image name and extension
IMAGE_NAME="$(basename "$IMAGE_PATH")"
EXTENSION="${IMAGE_NAME##*.}"
IMAGE_NAME_BASE="${IMAGE_NAME%.*}"

# Detect content type by extension
case "$EXTENSION" in
    png)   CONTENT_TYPE="image/png" ;;
    jpg|jpeg) CONTENT_TYPE="image/jpeg" ;;
    gif)   CONTENT_TYPE="image/gif" ;;
    svg)   CONTENT_TYPE="image/svg+xml" ;;
    webp)  CONTENT_TYPE="image/webp" ;;
    *)     CONTENT_TYPE="application/octet-stream" ;;
esac

# Get file size (cross-platform: macOS uses stat -f%z, Linux uses stat -c%s)
FILESIZE=$(stat -f%z "$IMAGE_PATH" 2>/dev/null || stat -c%s "$IMAGE_PATH" 2>/dev/null)

if [ -z "$FILESIZE" ]; then
    echo "{\"success\": false, \"error\": \"Failed to get file size for: $IMAGE_PATH\"}" >&2
    exit 1
fi

# Create attachment record
RESPONSE=$(curl -s -X POST "https://wiki.az-gruppe.com/api/attachments.create" \
    -H "Authorization: Bearer $OUTLINE_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"$IMAGE_NAME\",
        \"contentType\": \"$CONTENT_TYPE\",
        \"size\": $FILESIZE,
        \"documentId\": \"$DOCUMENT_ID\"
    }")

# Extract URLs from response
UPLOAD_URL=$(echo "$RESPONSE" | jq -r '.data.uploadUrl // empty')
ATTACHMENT_URL=$(echo "$RESPONSE" | jq -r '.data.attachment.url // empty')

# Check for errors
if [ -z "$UPLOAD_URL" ] || [ "$UPLOAD_URL" = "null" ]; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.message // "Failed to create attachment"')
    echo "{\"success\": false, \"error\": \"$ERROR_MSG\", \"response\": \"$RESPONSE\"}" >&2
    exit 1
fi

# Upload binary to signed URL
UPLOAD_RESPONSE=$(curl -s -w "%{http_code}" -X POST "$UPLOAD_URL" \
    -H "Content-Type: $CONTENT_TYPE" \
    --data-binary "@$IMAGE_PATH")

# Extract HTTP status code (last 3 characters)
HTTP_CODE="${UPLOAD_RESPONSE: -3}"

if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "201" ]; then
    echo "{\"success\": false, \"error\": \"Upload failed with HTTP $HTTP_CODE\", \"upload_url\": \"$UPLOAD_URL\"}" >&2
    exit 1
fi

# Output success result
echo "{\"success\": true, \"attachment_url\": \"$ATTACHMENT_URL\", \"document_id\": \"$DOCUMENT_ID\"}"
