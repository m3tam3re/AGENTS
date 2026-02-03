---
name: obsidian
description: "Obsidian Local REST API integration for knowledge management. Use when: (1) Creating, reading, updating, or deleting notes in Obsidian vault, (2) Searching vault content by title, content, or tags, (3) Managing daily notes and journaling, (4) Working with WikiLinks and vault metadata. Triggers: 'Obsidian', 'note', 'vault', 'WikiLink', 'daily note', 'journal', 'create note'."
compatibility: opencode
---

# Obsidian

Knowledge management integration via Obsidian Local REST API for vault operations, note CRUD, search, and daily notes.

## Prerequisites

- **Obsidian Local REST API plugin** installed and enabled in Obsidian
- **API server running** on default port `27124` (or configured custom port)
- **Vault path** configured in plugin settings
- **API key** set (optional, if authentication enabled)

API endpoints available at `http://127.0.0.1:27124` by default.

## Core Workflows

### List Vault Files

Get list of all files in vault:

```bash
curl -X GET "http://127.0.0.1:27124/list"
```

Returns array of file objects with `path`, `mtime`, `ctime`, `size`.

### Get File Metadata

Retrieve metadata for a specific file:

```bash
curl -X GET "http://127.0.0.1:27124/get-file-info?path=Note%20Title.md"
```

Returns file metadata including tags, links, frontmatter.

### Create Note

Create a new note in the vault:

```bash
curl -X POST "http://127.0.0.1:27124/create-note" \
  -H "Content-Type: application/json" \
  -d '{"content": "# Note Title\n\nNote content..."}'
```

Use `path` parameter for specific location:
```json
{
  "content": "# Note Title\n\nNote content...",
  "path": "subdirectory/Note Title.md"
}
```

### Read Note

Read note content by path:

```bash
curl -X GET "http://127.0.0.1:27124/read-note?path=Note%20Title.md"
```

Returns note content as plain text or structured JSON with frontmatter parsing.

### Update Note

Modify existing note:

```bash
curl -X PUT "http://127.0.0.1:27124/update-note" \
  -H "Content-Type: application/json" \
  -d '{"path": "Note Title.md", "content": "# Updated Title\n\nNew content..."}'
```

### Delete Note

Remove note from vault:

```bash
curl -X DELETE "http://127.0.0.1:27124/delete-note?path=Note%20Title.md"
```

**Warning**: This operation is irreversible. Confirm with user before executing.

### Search Notes

Find notes by content, title, or tags:

```bash
# Content search
curl -X GET "http://127.0.0.1:27124/search?q=search%20term"

# Search with parameters
curl -X GET "http://127.0.0.1:27124/search?q=search%20term&path=subdirectory&context-length=100"
```

Returns array of matches with file path and context snippets.

### Daily Notes

#### Get Daily Note

Retrieve or create daily note for specific date:

```bash
# Today
curl -X GET "http://127.0.0.1:27124/daily-note"

# Specific date (YYYY-MM-DD)
curl -X GET "http://127.0.0.1:27124/daily-note?date=2026-02-03"
```

Returns daily note content or creates using Obsidian's Daily Notes template.

#### Update Daily Note

Modify today's daily note:

```bash
curl -X PUT "http://127.0.0.1:27124/daily-note" \
  -H "Content-Type: application/json" \
  -d '{"content": "## Journal\n\nToday I learned..."}'
```

### Get Vault Info

Retrieve vault metadata:

```bash
curl -X GET "http://127.0.0.1:27124/vault-info"
```

Returns vault path, file count, and configuration details.

## Note Structure Patterns

### Frontmatter Conventions

Use consistent frontmatter for note types:

```yaml
---
date: 2026-02-03
created: 2026-02-03T10:30:00Z
type: note
tags: #tag1 #tag2
status: active
---
```

### WikiLinks

Reference other notes using Obsidian WikiLinks:
- `[[Note Title]]` - Link to note by title
- `[[Note Title|Alias]]` - Link with custom display text
- `[[Note Title#Heading]]` - Link to specific heading
- `![[Image.png]]` - Embed images or media

### Tagging

Use tags for categorization:
- `#tag` - Single-word tag
- `#nested/tag` - Hierarchical tags
- Tags in frontmatter for metadata
- Tags in content for inline categorization

## Workflow Examples

### Create Brainstorm Note

```bash
curl -X POST "http://127.0.0.1:27124/create-note" \
  -H "Content-Type: application/json" \
  -d '{
    "path": "03-resources/brainstorms/2026-02-03-Topic.md",
    "content": "---\ndate: 2026-02-03\ncreated: 2026-02-03T10:30:00Z\ntype: brainstorm\nframework: pros-cons\nstatus: draft\ntags: #brainstorm #pros-cons\n---\n\n# Topic\n\n## Context\n\n## Options\n\n## Decision\n"
  }'
```

### Append to Daily Journal

```bash
# Get current daily note
NOTE=$(curl -s "http://127.0.0.1:27124/daily-note")

# Append content
curl -X PUT "http://127.0.0.1:27124/daily-note" \
  -H "Content-Type: application/json" \
  -d "{\"content\": \"${NOTE}\n\n## Journal Entry\n\nLearned about Obsidian API integration.\"}"
```

### Search and Link Notes

```bash
# Search for related notes
curl -s "http://127.0.0.1:27124/search?q=Obsidian"

# Create note with WikiLinks to found notes
curl -X POST "http://127.0.0.1:27124/create-note" \
  -H "Content-Type: application/json" \
  -d '{
    "path": "02-areas/Obsidian API Guide.md",
    "content": "# Obsidian API Guide\n\nSee [[API Endpoints]] and [[Workflows]] for details."
  }'
```

## Integration with Other Skills

| From Obsidian | To skill | Handoff pattern |
|--------------|----------|----------------|
| Note created | brainstorming | Create brainstorm note with frontmatter |
| Daily note updated | reflection | Append conversation analysis to journal |
| Research note | research | Save research findings with tags |
| Project note | task-management | Link tasks to project notes |
| Plan document | plan-writing | Save generated plan to vault |

## Best Practices

1. **Use paths consistently** - Follow PARA structure or vault conventions
2. **Include frontmatter** - Enables search and metadata queries
3. **Use WikiLinks** - Creates knowledge graph connections
4. **Validate paths** - Check file existence before operations
5. **Handle errors** - API may return 404 for non-existent files
6. **Escape special characters** - URL-encode paths with spaces or symbols
7. **Backup vault** - REST API operations modify files directly

## Error Handling

Common HTTP status codes:
- `200 OK` - Success
- `404 Not Found` - File or resource doesn't exist
- `400 Bad Request` - Invalid parameters or malformed JSON
- `500 Internal Server Error` - Plugin or vault error

Check API response body for error details before retrying operations.
