---
name: /chiron-task
description: "Add task with smart defaults - create task with proper formatting and placement"
---

# Add Task

Create a task with proper Obsidian Tasks formatting.

## Steps

1. **Parse task details** from request:
   - Task description
   - Priority (if specified: critical, high, low)
   - Due date (if specified)
   - Context/project/area (if specified)
   - Owner (if specified: @mention)
2. **Determine location**:
   - Project-specific → `~/CODEX/01-projects/[project]/_index.md` or `tasks.md`
   - Area-specific → `~/CODEX/02-areas/[area].md`
   - General → `~/CODEX/tasks/inbox.md`
3. **Create task in Obsidian format**:
   ```markdown
   - [ ] Task description #tag [priority] 👤 [@owner] 📅 YYYY-MM-DD
   ```
4. **Confirm** with task details and location

## Expected Output

Task created in appropriate location with:
- Proper Obsidian Tasks format
- Priority indicator (⏫/🔼/🔽 or none)
- Due date if specified
- Owner attribution if specified
- Link to project/area if applicable

## Related Skills

- `task-management` - Task creation and placement logic
- `chiron-core` - PARA methodology for task placement
- `obsidian-management` - File operations
- `project-structures` - Project task placement
