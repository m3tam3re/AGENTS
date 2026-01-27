---
name: obsidian-management
description: "Obsidian vault operations and file management for ~/CODEX. Use when: (1) creating/editing notes in Obsidian vault, (2) using templates from _chiron/templates/, (3) managing vault structure, (4) reading vault files, (5) organizing files within PARA structure. Triggers: obsidian, vault, note, template, create note, read note, organize files."
compatibility: opencode
---

# Obsidian Management

File operations and template usage for Obsidian vault at `~/CODEX/`.

## Vault Structure

```
~/CODEX/
├── _chiron/              # System files
│   ├── context.md        # Primary context
│   └── templates/       # Note templates
├── 00-inbox/            # Quick captures
├── 01-projects/         # Active projects
├── 02-areas/            # Ongoing responsibilities
├── 03-resources/        # Reference material
├── 04-archive/          # Completed items
├── daily/               # Daily notes
└── tasks/               # Task management
```

## Core Operations

### Create Note

**When user says**: "Create a note called X", "Make a new note for X", "Add a note"

**Steps:**
1. Determine location (ask if unclear):
   - `00-inbox/` for quick captures
   - `01-projects/[work|personal]/[project]/` for project notes
   - `02-areas/` for area notes
   - `03-resources/` for reference material
2. Create file with proper filename (kebab-case, .md extension)
3. Add frontmatter if using template
4. Confirm creation

**Example:**
```
User: "Create a note about Obsidian plugins in resources"

Action:
1. Locate: ~/CODEX/03-resources/tools/obsidian-plugins.md
2. Create file with template or basic frontmatter
3. Confirm: "Created obsidian-plugins.md in 03-resources/tools/"
```

### Read Note

**When user says**: "Read the note X", "Show me X note", "What's in X?"

**Steps:**
1. Find note by:
   - Exact path if provided
   - Fuzzy search across vault
   - Dataview query if complex
2. Read full note content
3. Summarize key points if long
4. Offer follow-up actions

**Example:**
```
User: "Read my learning-python note"

Action:
1. Search: rg "learning-python" ~/CODEX --type md
2. Read matching file
3. Present content
4. Offer: "Want to edit this? Add tasks? Link to other notes?"
```

### Edit Note

**When user says**: "Update X", "Change X to Y", "Add to X"

**Steps:**
1. Read existing note
2. Locate section to modify
3. Apply changes preserving formatting
4. Maintain frontmatter structure
5. Confirm changes

**Preserve:**
- Wiki-links `[[Note Name]]`
- Frontmatter YAML
- Task formatting
- Tags
- Dataview queries

### Use Template

**When user says**: "Create using template", "Use the X template"

**Available templates:**

| Template | Location | Purpose |
|----------|----------|---------|
| `daily-note.md` | `_chiron/templates/` | Daily planning/reflection |
| `weekly-review.md` | `_chiron/templates/` | Weekly review |
| `project.md` | `_chiron/templates/` | Project initialization |
| `meeting.md` | `_chiron/templates/` | Meeting notes |
| `resource.md` | `_chiron/templates/` | Reference material |
| `area.md` | `_chiron/templates/` | Area definition |

**Steps:**
1. Read template from `_chiron/templates/[template-name].md`
2. Replace template variables ({{date}}, {{project}}, etc.)
3. Create new file in appropriate location
4. Fill in placeholder sections

**Example:**
```
User: "Create a new project using the project template for 'Learn Rust'"

Action:
1. Read _chiron/templates/project.md
2. Replace {{project}} with "learn-rust", {{date}} with today
3. Create: ~/CODEX/01-projects/personal/learn-rust/_index.md
4. Fill in: deadline, priority, goals, etc.
```

### Search Vault

**When user says**: "Search for X", "Find notes about X", "Where's X?"

**Search methods:**

1. **Simple search**: `rg "term" ~/CODEX --type md`
2. **Tag search**: `rg "#tag" ~/CODEX --type md`
3. **Task search**: `rg "- \\[ \\]" ~/CODEX --type md`
4. **Wiki-link search**: `rg "\\[\\[.*\\]\\]" ~/CODEX --type md`

**Present results grouped by:**
- Location (Projects/Areas/Resources)
- Relevance
- Date modified

### Organize Files

**When user says**: "Organize inbox", "Move X to Y", "File this note"

**Steps:**
1. Read file to determine content
2. Consult chiron-core PARA guidance for proper placement
3. Create proper directory structure if needed
4. Move file maintaining links
5. Update wiki-links if file moved

**Example:**
```
User: "Organize my inbox"

Action:
1. List files in 00-inbox/
2. For each file:
   - Read content
   - Determine PARA category
   - Move to appropriate location
3. Update broken links
4. Confirm: "Moved 5 files from inbox to Projects (2), Resources (2), Archive (1)"
```

## File Operations

### Paths

**Always use absolute paths:**
- `~/CODEX/` → `/home/username/knowledge/`
- Expand `~` before file operations

### Filenames

**Naming conventions:**
- Notes: `kebab-case.md` (all lowercase, hyphens)
- Projects: `project-name/` (directory with `_index.md`)
- Daily notes: `YYYY-MM-DD.md` (ISO date)
- Templates: `template-name.md` (kebab-case)

**Do NOT use:**
- Spaces in filenames
- CamelCase (use kebab-case)
- Special characters (except hyphens and underscores)

### Frontmatter

**Required fields:**
```yaml
---
title: "Note Title"
tags: [tag1, tag2]
created: YYYY-MM-DD
modified: YYYY-MM-DD
---
```

**Project frontmatter:**
```yaml
---
title: "Project Name"
status: active | on-hold | completed
deadline: YYYY-MM-DD
priority: critical | high | medium | low
tags: [work, personal]
---
```

**Task file frontmatter:**
```yaml
---
title: "Task List"
context: daily | project | area
tags: [tasks]
---
```

### Wiki-Links

**Format:** `[[Note Name]]` or `[[Note Name|Display Text]]`

**Best practices:**
- Use exact note titles
- Include display text for clarity
- Link to related concepts
- Back-link from destination notes

### Tags

**Format:** `#tagname` or `#tag/subtag`

**Common tags:**
- `#work`, `#personal`
- `#critical`, `#high`, `#low`
- `#project`, `#area`, `#resource`
- `#todo`, `#done`, `#waiting`

## Template System

### Template Variables

Replace these when using templates:

| Variable | Replacement |
|----------|-------------|
| `{{date}}` | Current date (YYYY-MM-DD) |
| `{{datetime}}` | Current datetime (YYYY-MM-DD HH:mm) |
| `{{project}}` | Project name |
| `{{area}}` | Area name |
| `{{title}}` | Note title |
| `{{week}}` | Week number (e.g., W04) |

### Template Locations

**Core templates** in `_chiron/templates/`:
- `daily-note.md` - Daily planning and reflection
- `weekly-review.md` - Weekly review structure
- `project.md` - Project initialization
- `meeting.md` - Meeting notes template
- `resource.md` - Reference material
- `area.md` - Area definition
- `learning.md` - Learning capture

### Custom Templates

**User can add** templates to `_chiron/templates/`:
1. Create new template file
2. Use variable syntax: `{{variable}}`
3. Document in `_chiron/templates/README.md`
4. Reference in obsidian-management skill

## Integration with Other Skills

**Calls to other skills:**
- `chiron-core` - PARA methodology guidance for organization
- `task-management` - Extract/update tasks from notes
- `quick-capture` - Process inbox items
- `meeting-notes` - Apply meeting template

**Delegation rules:**
- User asks about PARA → `chiron-core`
- User wants task operations → `task-management`
- User wants quick capture → `quick-capture`
- User wants meeting structure → `meeting-notes`

## File Format Standards

### Task Format (Obsidian Tasks plugin)

```markdown
- [ ] Task description #tag ⏫ 📅 YYYY-MM-DD
```

**Priority indicators:**
- ⏫ = Critical (urgent AND important)
- 🔼 = High (important, not urgent)
- 🔽 = Low (nice to have)

**Date indicators:**
- 📅 = Due date
- ⏳ = Start date
- 🛫 = Scheduled date

### Dataview Queries

```dataview
LIST WHERE status = "active"
FROM "01-projects"
SORT deadline ASC
```

```dataview
TABLE deadline, status, priority
FROM "-04-archive"
WHERE contains(tags, "#work")
SORT deadline ASC
```

### Callouts

```markdown
> [!INFO] Information
> Helpful note

> [!WARNING] Warning
> Important alert

> [!TIP] Tip
> Suggestion

> [!QUESTION] Question
> To explore
```

## Error Handling

### File Not Found
1. Search for similar filenames
2. Ask user to confirm
3. Offer to create new file

### Directory Not Found
1. Create directory structure
2. Confirm with user
3. Create parent directories as needed

### Template Not Found
1. List available templates
2. Offer to create template
3. Use basic note structure if needed

### Link Breaks After Move
1. Find all notes linking to moved file
2. Update links to new path
3. Confirm updated links count

## Best Practices

### When Creating Notes
1. Use descriptive titles
2. Add relevant tags
3. Link to related notes immediately
4. Use appropriate frontmatter

### When Editing Notes
1. Preserve existing formatting
2. Update `modified` date in frontmatter
3. Maintain wiki-link structure
4. Check for broken links

### When Organizing
1. Ask user before moving files
2. Update all links
3. Confirm final locations
4. Document changes in daily note

## Quick Reference

| Action | Command Pattern |
|--------|-----------------|
| Create note | "Create note [title] in [location]" |
| Read note | "Read [note-name]" or "Show me [note-name]" |
| Edit note | "Update [note-name] with [content]" |
| Search | "Search vault for [term]" or "Find notes about [topic]" |
| Use template | "Create [note-type] using template" |
| Organize inbox | "Organize inbox" or "Process inbox items" |
| Move file | "Move [file] to [location]" |

## Resources

- `references/file-formats.md` - Detailed format specifications
- `references/dataview-guide.md` - Dataview query patterns
- `references/link-management.md` - Wiki-link best practices
- `assets/templates/` - All template files

**Load references when:**
- User asks about format details
- Creating complex queries
- Troubleshooting link issues
- Template customization needed
