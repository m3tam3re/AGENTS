---
name: /chiron-meeting
description: "Meeting notes - structured capture of meetings with action items"
---

# Meeting Notes

Take structured meeting notes with action item extraction.

## Steps

1. **Parse meeting request**:
   - Meeting title (if provided)
   - Attendees (if mentioned)
   - Meeting type (standup, 1:1, workshop, decision)
2. **Create meeting note** using template from `~/CODEX/_chiron/templates/meeting.md`:
   - Location: `~/CODEX/01-projects/[project]/meetings/[topic]-YYYYMMDD.md` (if project-specific)
   - Or `~/CODEX/00-inbox/meetings/[topic]-YYYYMMDD.md` (if general)
3. **Fill in sections**:
   - Title, date, time, location
   - Attendees and roles
   - Notes (if user provides or if meeting in progress)
   - Decisions made
   - Action items (extract from notes or user-provided)
4. **Create action item tasks** in Obsidian Tasks format with owners and due dates
5. **Link to context** (project or area)

## Expected Output

Meeting note created with:
- Proper frontmatter (date, attendees, tags)
- Attendees list
- Notes section
- Decisions section
- Action items in Obsidian Tasks format with @mentions and due dates
- Links to related projects/areas

## Related Skills

- `meeting-notes` - Core meeting workflow and templates
- `task-management` - Action item extraction and task creation
- `obsidian-management` - File operations and template usage
- `project-structures` - Project meeting placement
