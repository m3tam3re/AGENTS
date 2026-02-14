---
name: memory
description: "Persistent memory system for Opencode agents. SQLite-based hybrid search over Obsidian vault. Use when: (1) storing user preferences/decisions, (2) recalling past context, (3) searching knowledge base. Triggers: remember, recall, memory, store, preference."
compatibility: opencode
---

## Overview

opencode-memory is a SQLite-based hybrid memory system for Opencode agents. It indexes markdown files from your Obsidian vault (`~/CODEX/80-memory/`) and session transcripts, providing fast hybrid search (vector + keyword BM25).

## Architecture

- **Source of truth**: Markdown files at `~/CODEX/80-memory/`
- **Derived index**: SQLite at `~/.local/share/opencode-memory/index.db`
- **Hybrid search**: FTS5 (BM25) + vec0 (vector similarity)
- **Embeddings**: OpenAI text-embedding-3-small (1536 dimensions)

## Available Tools

### memory_search
Hybrid search over all indexed content (vault + sessions).

```
memory_search(query, maxResults?, source?)
```

- `query`: Search query (natural language)
- `maxResults`: Max results (default 6)
- `source`: Filter by "memory", "sessions", or "all"

### memory_store
Store new memory as markdown file in vault.

```
memory_store(content, title?, category?)
```

- `content`: Memory content to store
- `title`: Optional title (slugified for filename)
- `category`: "preferences", "facts", "decisions", "entities", "other"

### memory_get
Read specific file/lines from vault.

```
memory_get(filePath, startLine?, endLine?)
```

## Auto-Behaviors

- **Auto-recall**: On session.created, relevant memories are searched and injected
- **Auto-capture**: On session.idle, preferences/decisions are extracted and stored
- **Token budget**: Max 2000 tokens injected to respect context limits

## Workflows

### Recall information
Before answering about past work, preferences, or decisions:
1. Call `memory_search` with relevant query
2. Use `memory_get` to retrieve full context if needed

### Store new information
When user expresses preference or decision:
1. Call `memory_store` with content and category

## Vault Structure

```
~/CODEX/80-memory/
├── preferences/   # User preferences
├── facts/         # Factual knowledge
├── decisions/     # Design decisions
├── entities/      # People, projects, concepts
└── other/         # Uncategorized memories
```
