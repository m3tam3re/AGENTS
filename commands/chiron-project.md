---
name: /chiron-project
description: "Create new project - initialize project structure using PARA methodology"
---

# Create Project

Create a new project with proper PARA structure.

## Steps

1. **Parse project request**:
   - Project name
   - Context (work/personal) - ask if unspecified
   - Deadline (if specified)
   - Priority (if specified)
   - Related area (if specified)
2. **Create project directory** at `~/CODEX/01-projects/[work|personal]/[project-name]/`
3. **Create subdirectories**: `meetings/`, `decisions/`, `notes/`, `resources/`
4. **Create _index.md** using template from `~/CODEX/_chiron/templates/project.md`:
   - Fill in: title, status, deadline, priority, tags, area
   - Set to `status: active`
5. **Create initial files**:
   - `notes/_index.md` - Project notes index
   - Link to related area if provided
6. **Confirm** creation and ask if ready to add tasks

## Expected Output

Project directory created with:
- `_index.md` (main project file with frontmatter)
- Subdirectories: `meetings/`, `decisions/`, `notes/`, `resources/`
- Proper PARA structure and frontmatter
- Links to related areas if applicable

## Related Skills

- `project-structures` - Core project creation workflow
- `chiron-core` - PARA methodology for project placement
- `obsidian-management` - File operations and template usage
- `task-management` - Initial task creation
