---
name: /chiron-search
description: "Search knowledge base - find notes, tasks, or information in ~/CODEX vault"
---

# Search Knowledge Base

Find information across the Obsidian vault.

## Steps

1. **Parse search intent**:
   - Task search → Search for `- [ ]` patterns
   - Tag search → Search for `#tag` patterns
   - Recent → Search in `~/CODEX/daily/` for recent files
   - Full-text → General term search
2. **Execute search** using `rg`:
   ```bash
   # Tasks
   rg "- \\[ \\]" ~/CODEX --type md

   # Tags
   rg "#work" ~/CODEX --type md

   # Recent
   rg "term" ~/CODEX/daily --type md

   # Full text
   rg "search term" ~/CODEX --type md -C 3
   ```
3. **Group results** by location (Projects/Areas/Resources/Daily)
4. **Present** with context and file paths
5. **Offer follow-up actions** (read note, edit, create task, etc.)

## Expected Output

Search results grouped by:
- Location (Projects, Areas, Resources, Daily, Tasks)
- File paths for easy access
- Context (matching lines with surrounding content)
- Follow-up action suggestions

## Related Skills

- `obsidian-management` - Vault search operations
- `task-management` - Task-specific search
- `chiron-core` - PARA navigation for locating content
