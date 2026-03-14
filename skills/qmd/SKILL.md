---
name: qmd
description: "Knowledge retrieval and memory system via qmd (Query Markup Documents). Use when: (1) Searching knowledge vault for relevant context, (2) Storing memories, decisions, preferences from sessions, (3) Auto-recall of relevant context at session start, (4) Writing session summaries, (5) Querying past decisions or project context. Triggers: 'remember', 'recall', 'search vault', 'what did we decide', 'session summary', 'qmd', 'knowledge', 'memory', 'context'."
compatibility: opencode
---

# qmd

Primary retrieval + memory workflow using qmd v2.0.1 over the already-indexed `qmd://CODEX/` vault.

## Prerequisites

- `qmd` installed globally and available in `PATH`
- `CODEX` collection configured and indexed
- Vault at `~/CODEX/` with memory folders under `80-memory/`

Verify runtime state:

```bash
qmd status
```

## Search Workflows

Default to `qmd query` unless a narrower mode is clearly better.

### 1) BM25 Keyword Search (Fast)

Use when exact terms, filenames, tags, or known phrases are likely present.

```bash
qmd search "query"
qmd search "query" --md --full -n 5
qmd search "query" --json -n 10
qmd search "query" -c memory --md -n 5
qmd search "query" --min-score 0.3 --all --files
```

### 2) Vector Semantic Search

Use when the concept is known but wording is uncertain.

```bash
qmd vsearch "query"
qmd vsearch "query" --md --full -n 5
qmd vsearch "query" --json -n 10
qmd vsearch "query" -c memory --md -n 5
qmd vsearch "query" --min-score 0.3 --all --files
```

### 3) Hybrid + Rerank (Best Quality, Default)

Use for high-confidence retrieval, ambiguous queries, and session bootstrap.

```bash
qmd query "query"
qmd query "query" --md --full -n 5
qmd query "query" --json -n 10
qmd query "query" -c memory --md -n 5
qmd query "query" --min-score 0.3 --all --files
```

## Document Retrieval

Use retrieval commands after search to pull exact documents.

```bash
qmd get "path/to/file.md"
qmd get "#docid"
qmd multi-get "80-memory/sessions/*.md"
qmd multi-get "file1.md, file2.md"
```

## Memory Write Workflows

qmd is read-only. Write memory notes directly to filesystem, then re-index.

Memory note file pattern:

```bash
~/CODEX/80-memory/{category}/{slug}.md
```

Required frontmatter:

```yaml
---
type: memory
category: preference  # preference | fact | decision | entity | other
source: opencode      # opencode | manual
importance: medium    # critical | high | medium | low
session:              # opencode session ID for traceability (optional)
project:              # [[Project Name]] if project-specific (optional)
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags:
  - memory
  - preference
---
```

Content template:

- `# {Title}`
- `## Content` → concise factual memory
- `## Context` → when/why captured
- `## Related` → WikiLinks to related notes

Category decision guide:

| Signal | Category | Example |
|--------|----------|---------|
| "I prefer...", "I like...", "Always use..." | preference | Prefers Nix over Docker |
| "We use...", "The stack is...", "My role is..." | fact | Tech stack is NixOS + TypeScript |
| "Let's go with...", "We decided...", reasoning about choices | decision | Chose qmd for memory retrieval |
| Person name, org, system, API | entity | Tobi Lütke - Shopify CEO |
| Doesn't fit above | other | |

## Session Summary Workflow

Write at session end or when explicitly requested.

Session file pattern:

```bash
~/CODEX/80-memory/sessions/YYYY-MM-DD-{slug}.md
```

Frontmatter:

```yaml
---
type: session-summary
created: YYYY-MM-DD
session:           # opencode session ID
project:           # [[Project Name]]
duration:          # approximate
tags:
  - memory
  - session
---
```

Content template:

- `# Session: {Brief Description}`
- `## What Was Done` → completed work bullets
- `## Decisions Made` → decision + short rationale (+ WikiLink if significant)
- `## Open Questions` → unresolved items
- `## Files Changed` → key file list + one-line deltas
- `## Next Steps` → next executable actions

## Auto-Recall Workflow

At session start, proactively retrieve context before deep work.

1. Determine project/task context from working directory, git repo, and user goal.
2. Retrieve general relevant knowledge:

```bash
qmd query "{relevant context}" --md --full -n 3 -c CODEX
```

3. Retrieve project memory context:

```bash
qmd query "{project name}" --md -n 3 -c memory
```

4. Inject only relevant excerpts; cap recall to ~2000 tokens.

This workflow is advisory and should be run proactively by the agent.

## Re-indexing

After creating or editing memory/session files, update index for immediate recall.

```bash
qmd update
```

Indexing also runs periodically; use manual update when immediate searchability is required.

## Integration with Other Skills

| From | To | Pattern |
|------|----|---------|
| qmd search | Any skill | Retrieve relevant context before starting work |
| brainstorming | qmd write | Save brainstorm decisions as memory notes |
| Any session | qmd write | Capture session summaries at session end |
| qmd search | obsidian | Find note to update, then use Obsidian skill for CRUD |
