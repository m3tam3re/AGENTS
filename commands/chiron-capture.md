---
name: /chiron-capture
description: "Quick capture to inbox - minimal friction capture for tasks, notes, meetings, learnings"
---

# Quick Capture

Instant capture to inbox for later processing.

## Steps

1. **Parse capture type** from request:
   - Task → Create in `~/CODEX/tasks/inbox.md`
   - Note → Create in `~/CODEX/00-inbox/quick-capture-*.md`
   - Meeting → Create in `~/CODEX/00-inbox/meetings/meeting-*.md`
   - Learning → Create in `~/CODEX/00-inbox/learnings/learning-*.md`
   - Reference → Create in `~/CODEX/00-inbox/web-clips/*.md`
2. **Use appropriate format** (Obsidian Tasks format for tasks, markdown with frontmatter for notes)
3. **Add minimal metadata** (creation date, tags from context)
4. **Confirm capture**

## Expected Output

Appropriate file created in inbox with:
- Tasks in Obsidian Tasks format: `- [ ] Task #tag ⏫ 📅 date`
- Notes with frontmatter and timestamped content
- Quick confirmation: "Captured to inbox. Process during weekly review."

## Related Skills

- `quick-capture` - Core capture workflows for all types
- `obsidian-management` - File creation in inbox structure
- `task-management` - Task format and placement
- `meeting-notes` - Meeting note templates
