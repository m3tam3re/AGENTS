---
name: knowledge-management
description: "Knowledge base and note management with Obsidian. Use when: (1) saving information for later, (2) organizing notes and references, (3) finding past notes, (4) building knowledge connections, (5) managing documentation. Triggers: save this, note, remember, knowledge base, where did I put, find my notes on, documentation."
compatibility: opencode
---

# Knowledge Management

Note capture and knowledge organization using Obsidian as the backend.

## Status: Active

Quick note capture and knowledge organization using Obsidian markdown vault.

## Quick Note Capture

- Minimal friction capture to Obsidian vault (~/CODEX/)
- Auto-tagging based on content
- Link to related notes using WikiLinks
- Use frontmatter for metadata

## Knowledge Retrieval

- Fast search using ripgrep across vault
- Tag-based filtering (#tag syntax)
- WikiLink connections for related notes
- Use Obsidian graph view for visual connections

## Resource Organization

- PARA Resources category management (03-resources/)
- Topic clustering with folders
- Archive maintenance (04-archive/)
- Frontmatter for structured metadata

## Documentation Management

- Technical docs organization
- Version tracking via Git
- Cross-reference linking
- Template-driven structure

## Integration Points

- **Obsidian**: Primary storage (Markdown vault at ~/CODEX/)
- **task-management**: Link notes to projects/areas
- **research**: Save research findings to Resources

## Quick Commands

| Command | Description |
|---------|-------------|
| `note: [content]` | Quick capture to inbox |
| `find notes on [topic]` | Search vault with ripgrep |
| `link [note] to [note]` | Create WikiLink connection |
| `organize [tag/topic]` | Cluster related notes |

## Note Structure

### Quick Note Format
```markdown
---
date: 2026-01-27
created: 2026-01-27T18:30:00Z
type: note
tags: #quick-capture #{{topic_tag}}
---

# {{topic}}

## Content
{{note content}}

## Related
- [[Related Note 1]]
- [[Related Note 2]]
```

### Resource Format
```markdown
---
date: 2026-01-27
created: 2026-01-27T18:30:00Z
type: resource
tags: #{{topic}} #{{category}}
status: active
---

# {{topic}}

## Overview
{{brief description}}

## Key Information
- Point 1
- Point 2
- Point 3

## Resources
- [Link 1](https://...)
- [Link 2](https://...)

## Related Notes
- [[Note 1]]
- [[Note 2]]
```

## Storage Locations

```
~/CODEX/
├── 00-inbox/                # Quick captures
│   ├── quick-capture.md      # Unprocessed notes
│   ├── web-clips.md         # Saved web content
│   └── learnings.md         # New learnings
├── 01-projects/             # Project-specific knowledge
├── 02-areas/               # Ongoing responsibilities
├── 03-resources/            # Reference material
│   ├── programming/
│   ├── tools/
│   ├── documentation/
│   └── brainstorms/
└── 04-archive/             # Stale content
    ├── projects/
    ├── areas/
    └── resources/
```

## Search Patterns

Use ripgrep for fast vault-wide searches:

```bash
# Search by topic
rg "NixOS" ~/CODEX --type md

# Search by tag
rg "#programming" ~/CODEX --type md

# Search for links
rg "\\[\\[" ~/CODEX --type md

# Find recent notes
rg "date: 2026-01-2" ~/CODEX --type md
```

## Best Practices

1. **Capture quickly, organize later** - Don't overthink during capture
2. **Use WikiLinks generously** - Creates network effect
3. **Tag for retrieval** - Tag by how you'll search, not how you think
4. **Maintain PARA structure** - Keep notes in appropriate folders
5. **Archive regularly** - Move inactive content to 04-archive
6. **Use templates** - Consistent structure for same note types
7. **Leverage graph view** - Visual connections reveal patterns

## Templates

### Quick Capture Template
```markdown
---
date: {{date}}
created: {{timestamp}}
type: note
tags: #quick-capture
---

# {{title}}

## Notes
{{content}}

## Related
- [[]]
```

### Learning Template
```markdown
---
date: {{date}}
created: {{timestamp}}
type: learning
tags: #learning #{{topic}}
---

# {{topic}}

## What I Learned
{{key insight}}

## Why It Matters
{{application}}

## References
- [Source](url)
- [[]]
```

## Integration with Other Skills

| From | To knowledge-management | Trigger |
|------|----------------------|---------|
| research | Save findings | "Save this research" |
| task-management | Link to projects/areas | "Note about project X" |
| brainstorming | Save brainstorm | "Save this brainstorm" |
| daily-routines | Process inbox | "Weekly review" |

## Notes

Expand based on actual note-taking patterns. Consider integration with mem0-memory skill for AI-assisted recall.
