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

## API Reference

See [references/api_reference.md](references/api_reference.md) for complete OpenAPI schema.
