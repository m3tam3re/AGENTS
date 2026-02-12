---
name: memory
description: "Dual-layer memory system (Mem0 + Obsidian CODEX). Use when: (1) storing information for future recall ('remember this'), (2) auto-capturing session insights, (3) recalling past decisions/preferences/facts, (4) injecting relevant context before tasks. Triggers: 'remember', 'recall', 'what do I know about', 'memory', session end."
compatibility: opencode
---

# Memory

Dual-layer memory system for persistent AI agent context. Memories are stored in BOTH Mem0 (semantic search) AND Obsidian CODEX vault (human-readable, versioned).

## Overview

**Architecture:**
- **Mem0 Layer** (`localhost:8000`): Fast semantic search, operational memory
- **Obsidian Layer** (`~/CODEX/80-memory/`): Human-readable notes, version controlled, wiki-linked

**Cross-Reference:**
- `mem0_id` in Obsidian frontmatter links to Mem0
- `obsidian_ref` in Mem0 metadata links to vault file

## Prerequisites

1. **Mem0 running** at `http://localhost:8000` - Verify with `curl http://localhost:8000/health`
2. **Obsidian MCP configured** - See [references/mcp-config.md](references/mcp-config.md)
3. **Vault structure** - `80-memory/` folder with category subfolders

## Memory Categories

| Category | Definition | Examples |
|----------|------------|----------|
| `preference` | Personal preferences (UI, workflow, communication style) | Dark mode, async communication, detailed responses |
| `fact` | Objective information about user/work (role, tech stack, constraints) | Job title, preferred languages, system architecture |
| `decision` | Architectural/tool choices made (with rationale) | Using React over Vue, PostgreSQL over MySQL |
| `entity` | People, organizations, systems, concepts | Key contacts, important APIs, domain concepts |
| `other` | Everything else | General learnings, context notes |

## Workflow 1: Store Memory (Explicit)

When user says "remember this" or "store this":

### Steps

1. **Classify category** - Determine which of the 5 categories applies
2. **Store in Mem0** - POST to `/memories`:
   ```bash
   curl -X POST http://localhost:8000/memories \
     -H "Content-Type: application/json" \
     -d '{
       "messages": [{"role": "user", "content": "[memory content]"}],
       "user_id": "m3tam3re",
       "metadata": {
         "category": "preference",
         "source": "explicit"
       }
     }'
   ```
3. **Create Obsidian note** - Use memory template in `80-memory/<category>/`:
   - Set `mem0_id` from Mem0 response
   - Set `source: explicit`
4. **Update Mem0 with Obsidian ref** - Add `obsidian_ref` to metadata

### Example

```
User: "Remember that I prefer detailed explanations with code examples"

Agent:
1. Category: preference
2. Mem0: Store with category=preference, source=explicit
3. Obsidian: Create 80-memory/preferences/prefers-detailed-explanations.md
4. Cross-reference IDs
```

## Workflow 2: Recall Memory

When user asks "what do I know about X":

### Steps

1. **Search Mem0** - POST to `/search`:
   ```bash
   curl -X POST http://localhost:8000/search \
     -H "Content-Type: application/json" \
     -d '{
       "query": "[search query]",
       "user_id": "m3tam3re"
     }'
   ```
2. **Return results** - Include Obsidian note paths from `obsidian_ref` metadata
3. **Optionally read full note** - Use Obsidian REST API for complete context

### Example

```
User: "What do you know about my UI preferences?"

Agent:
1. Search Mem0 for "UI preferences"
2. Return: "You prefer dark mode (80-memory/preferences/prefers-dark-mode.md)"
```

## Workflow 3: Auto-Capture (Session End)

Automatically extract and store valuable memories at session end.

### Process

1. **Scan conversation** for memory-worthy content:
   - Preferences stated
   - Decisions made
   - Important facts revealed
   - Entities mentioned
2. **Select top 3** highest-value memories
3. **For each**: Store in Mem0 AND create Obsidian note (source: "auto-capture")
4. **Present to user**: "I captured these memories: [list]. Confirm or reject?"

### Memory-Worthy Signals

- "I prefer..." / "I like..." / "I hate..." → preference
- "We decided to use..." / "Chose X because..." → decision
- "My role is..." / "We use..." / "The system is..." → fact
- Names, companies, tools mentioned repeatedly → entity

## Workflow 4: Auto-Recall (Session Start)

Inject relevant memories before starting work.

### Process

1. **On session start**, search Mem0 with user's first message/topic
2. **If relevant memories found** (score > 0.7), inject as context:
   ```markdown
   <relevant-memories>
   - [preference] User prefers dark mode in all apps
   - [fact] User's tech stack: TypeScript, React, Node.js
   </relevant-memories>
   ```
3. **Limit to top 5** most relevant memories

## Error Handling

### Mem0 Unavailable

```bash
# Check health first
curl http://localhost:8000/health
# If fails: Skip all memory operations, warn user
```

Response: "Mem0 is not running. Memory features unavailable. Start with: [instructions]"

### Obsidian Unavailable

- Store in Mem0 only
- Log that Obsidian sync failed
- Continue with degraded functionality

### Both Unavailable

- Skip memory entirely
- Continue without memory features
- Warn user: "Memory system unavailable"

## Integration

### How Other Skills Use Memory

```bash
# Load memory skill to access workflows
# Use mem0-memory skill for direct Mem0 API calls
# Use obsidian skill for direct vault operations
```

### Apollo Agent

Apollo is the primary memory specialist. When complex memory operations needed, delegate to Apollo with memory skill loaded.

### Skill Handoff

| From Skill | Handoff Pattern |
|------------|----------------|
| Any skill | Load `memory` skill, call store/recall workflows |
| mem0-memory | Direct Mem0 API, optionally sync to Obsidian |
| obsidian | Direct vault operations, use memory template |

## Quick Reference

| Operation | Mem0 API | Obsidian Path |
|-----------|----------|---------------|
| Store | POST /memories | 80-memory/<category>/*.md |
| Search | POST /search | Search 80-memory/ |
| Get | GET /memories/{id} | Read note by path |
| Update | PUT /memories/{id} | Update note |
| Health | GET /health | Check REST API |

## See Also

- [references/mcp-config.md](references/mcp-config.md) - Obsidian MCP server configuration
- `~/p/AI/AGENTS/skills/mem0-memory/SKILL.md` - Mem0 REST API details
- `~/p/AI/AGENTS/skills/obsidian/SKILL.md` - Obsidian vault operations
- `~/CODEX/AGENTS.md` - Vault conventions and memory folder docs
