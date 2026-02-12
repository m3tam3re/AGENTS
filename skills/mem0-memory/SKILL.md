---
name: mem0-memory
description: "Store and retrieve memories using Mem0 REST API. Use when: (1) storing information for future recall, (2) searching past conversations or facts, (3) managing user/agent memory contexts, (4) building conversational AI with persistent memory. Triggers on keywords like 'remember', 'recall', 'memory', 'store for later', 'what did I say about'."
compatibility: opencode
---

# Mem0 Memory

Store and retrieve memories via Mem0 REST API at `http://localhost:8000`.

## Quick Reference

| Operation         | Method | Endpoint              |
| ----------------- | ------ | --------------------- |
| Store memory      | POST   | `/memories`           |
| Search memories   | POST   | `/search`             |
| Get all memories  | GET    | `/memories?user_id=X` |
| Get single memory | GET    | `/memories/{id}`      |
| Update memory     | PUT    | `/memories/{id}`      |
| Delete memory     | DELETE | `/memories/{id}`      |
| Delete all        | DELETE | `/memories?user_id=X` |

## Core Operations

### Store a Memory

```bash
curl -X POST http://localhost:8000/memories \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "I prefer dark mode in all apps"},
      {"role": "assistant", "content": "Noted, you prefer dark mode."}
    ],
    "user_id": "user123"
  }'
```

**Required**: `messages` array with `role` (user/assistant) and `content`.
**Optional**: `user_id`, `agent_id`, `run_id`, `metadata` object.

### Search Memories

```bash
curl -X POST http://localhost:8000/search \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What are my UI preferences?",
    "user_id": "user123"
  }'
```

**Required**: `query` string.
**Optional**: `user_id`, `agent_id`, `run_id`, `filters` object.

### Retrieve All Memories

```bash
curl "http://localhost:8000/memories?user_id=user123"
```

Filter by `user_id`, `agent_id`, or `run_id`.

### Get Single Memory

```bash
curl http://localhost:8000/memories/{memory_id}
```

### Update Memory

```bash
curl -X PUT http://localhost:8000/memories/{memory_id} \
  -H "Content-Type: application/json" \
  -d '{"content": "Updated preference: light mode"}'
```

### Delete Memory

```bash
curl -X DELETE http://localhost:8000/memories/{memory_id}
```

### Delete All Memories

```bash
curl -X DELETE "http://localhost:8000/memories?user_id=user123"
```

## Identity Scopes

Mem0 supports three identity scopes for organizing memories:

| Scope      | Use Case                                 |
| ---------- | ---------------------------------------- |
| `user_id`  | Per-user memories across sessions        |
| `agent_id` | Per-agent memories (shared across users) |
| `run_id`   | Per-session memories (temporary)         |

Combine scopes for fine-grained control:

```json
{
  "messages": [...],
  "user_id": "alice",
  "agent_id": "support-bot",
  "run_id": "session-456"
}
```

## Memory Categories

Memories are classified into 5 categories for organization:

| Category | Definition | Obsidian Path | Example |
|----------|------------|---------------|---------|
| `preference` | Personal preferences | `80-memory/preferences/` | UI settings, workflow styles |
| `fact` | Objective information | `80-memory/facts/` | Tech stack, role, constraints |
| `decision` | Choices with rationale | `80-memory/decisions/` | Tool selections, architecture |
| `entity` | People, orgs, systems | `80-memory/entities/` | Contacts, APIs, concepts |
| `other` | Everything else | `80-memory/other/` | General learnings |

### Metadata Pattern

Include category in metadata when storing:

```json
{
  "messages": [...],
  "user_id": "user123",
  "metadata": {
    "category": "preference",
    "source": "explicit"
  }
}
```

- `category`: One of preference, fact, decision, entity, other
- `source`: "explicit" (user requested) or "auto-capture" (automatic)

## Workflow Patterns

### Pattern 1: Remember User Preferences

User says "Remember I like X" -> Store with their user_id:

```bash
curl -X POST http://localhost:8000/memories \
  -d '{"messages":[{"role":"user","content":"Remember I like dark mode"}], "user_id":"USER_ID"}'
```

### Pattern 2: Recall Past Context

User asks "What did I tell you about X?" -> Search:

```bash
curl -X POST http://localhost:8000/search \
  -d '{"query":"dark mode preferences", "user_id":"USER_ID"}'
```

### Pattern 3: Session Memory

Store conversation context for current session only:

```bash
curl -X POST http://localhost:8000/memories \
  -d '{"messages":[...], "run_id":"SESSION_ID"}'
```

## Dual-Layer Sync

Memories are stored in BOTH Mem0 AND the Obsidian CODEX vault for redundancy and accessibility.

### Sync Pattern

1. **Store in Mem0 first** - Get `mem0_id` from response
2. **Create Obsidian note** - In `80-memory/<category>/` using memory template
3. **Cross-reference**:
   - Add `mem0_id` to Obsidian note frontmatter
   - Update Mem0 metadata with `obsidian_ref` (file path)

### Example Flow

```bash
# 1. Store in Mem0
RESPONSE=$(curl -s -X POST http://localhost:8000/memories \
  -d '{"messages":[{"role":"user","content":"I prefer dark mode"}],"user_id":"m3tam3re","metadata":{"category":"preference","source":"explicit"}}')

# 2. Extract mem0_id
MEM0_ID=$(echo $RESPONSE | jq -r '.id')

# 3. Create Obsidian note (via REST API or MCP)
# Path: 80-memory/preferences/prefers-dark-mode.md
# Frontmatter includes: mem0_id: $MEM0_ID

# 4. Update Mem0 with Obsidian reference
curl -X PUT http://localhost:8000/memories/$MEM0_ID \
  -d '{"metadata":{"obsidian_ref":"80-memory/preferences/prefers-dark-mode.md"}}'
```

### When Obsidian Unavailable

- Store in Mem0 only
- Log sync failure
- Retry on next access

## Response Format

Memory objects include:

```json
{
  "id": "mem_abc123",
  "memory": "User prefers dark mode",
  "user_id": "user123",
  "created_at": "2025-12-31T12:00:00Z",
  "updated_at": "2025-12-31T12:00:00Z"
}
```

Search returns array of matching memories with relevance scores.

## Health Check

Verify API is running:

```bash
curl http://localhost:8000/health
```

### Pre-Operation Check

Before any memory operation, verify Mem0 is running:

```bash
if ! curl -s http://localhost:8000/health > /dev/null 2>&1; then
  echo "WARNING: Mem0 unavailable. Memory operations skipped."
  # Continue without memory features
fi
```

## Error Handling

### Mem0 Unavailable

When `curl http://localhost:8000/health` fails:
- Skip all memory operations
- Warn user: "Memory system unavailable. Mem0 not running at localhost:8000"
- Continue with degraded functionality

### Obsidian Unavailable

When vault sync fails:
- Store in Mem0 only
- Log: "Obsidian sync failed for memory [id]"
- Do not block user workflow

### API Errors

| Status | Meaning | Action |
|--------|---------|--------|
| 400 | Bad request | Check JSON format, required fields |
| 404 | Memory not found | Memory may have been deleted |
| 500 | Server error | Retry, check Mem0 logs |

### Graceful Degradation

Always continue core functionality even if memory system fails. Memory is enhancement, not requirement.

## API Reference

See [references/api_reference.md](references/api_reference.md) for complete OpenAPI schema.
