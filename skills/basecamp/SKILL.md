---
name: basecamp
description: "Manage work projects in Basecamp via MCP. Use when: (1) creating or viewing Basecamp projects, (2) managing todos or todo lists, (3) working with card tables (kanban boards), (4) searching Basecamp content, (5) syncing project plans to Basecamp. Triggers: basecamp, create todos, show my projects, card table, move card, basecamp search, sync to basecamp, what's in basecamp."
compatibility: opencode
---

# Basecamp

Manage work projects in Basecamp via MCP server. Provides workflows for project overview, todo management, kanban boards, and syncing from plan-writing skill.

## Quick Reference

| Action          | Command Pattern                        |
| --------------- | -------------------------------------- |
| List projects   | "Show my Basecamp projects"            |
| View project    | "What's in [project name]?"            |
| Create todos    | "Add todos to [project]"               |
| View card table | "Show kanban for [project]"            |
| Move card       | "Move [card] to [column]"              |
| Search          | "Search Basecamp for [query]"          |
| Sync plan       | "Create Basecamp todos from this plan" |

## Core Workflows

### 1. Project Overview

List and explore projects:

```
1. get_projects → list all projects
2. Present summary: name, last activity
3. User selects project
4. get_project(id) → show dock items (todosets, card tables, message boards)
```

**Example output:**

```
Your Basecamp Projects:
1. Q2 Training Program (last activity: 2 hours ago)
2. Website Redesign (last activity: yesterday)
3. Product Launch (last activity: 3 days ago)

Which project would you like to explore?
```

### 2. Todo Management

**View todos:**

```
1. get_project(id) → find todoset from dock
2. get_todolists(project_id) → list all todo lists
3. get_todos(project_id, todolist_id) → show todos with status
```

**Create todos:**

```
1. Identify target project and todo list
2. For each todo:
   create_todo(
     project_id,
     todolist_id,
     content,
     due_on?,        # YYYY-MM-DD format
     assignee_ids?,  # array of person IDs
     notify?         # boolean
   )
3. Confirm creation with links
```

**Complete/update todos:**

```
- complete_todo(project_id, todo_id) → mark done
- uncomplete_todo(project_id, todo_id) → reopen
- update_todo(project_id, todo_id, content?, due_on?, assignee_ids?)
- delete_todo(project_id, todo_id) → remove
```

### 3. Card Table (Kanban) Management

**View board:**

```
1. get_card_table(project_id) → get card table details
2. get_columns(project_id, card_table_id) → list columns
3. For each column: get_cards(project_id, column_id)
4. Present as kanban view
```

**Example output:**

```
Card Table: Development Pipeline

| Backlog (3) | In Progress (2) | Review (1) | Done (5) |
|-------------|-----------------|------------|----------|
| Feature A   | Feature B       | Bug fix    | ...      |
| Feature C   | Feature D       |            |          |
| Refactor    |                 |            |          |
```

**Manage columns:**

```
- create_column(project_id, card_table_id, title)
- update_column(project_id, column_id, title) → rename
- move_column(project_id, card_table_id, column_id, position)
- update_column_color(project_id, column_id, color)
- put_column_on_hold(project_id, column_id) → freeze work
- remove_column_hold(project_id, column_id) → unfreeze
```

**Manage cards:**

```
- create_card(project_id, column_id, title, content?, due_on?, notify?)
- update_card(project_id, card_id, title?, content?, due_on?, assignee_ids?)
- move_card(project_id, card_id, column_id) → move to different column
- complete_card(project_id, card_id)
- uncomplete_card(project_id, card_id)
```

**Card steps (subtasks):**

```
- get_card_steps(project_id, card_id) → list subtasks
- create_card_step(project_id, card_id, title, due_on?, assignee_ids?)
- complete_card_step(project_id, step_id)
- update_card_step(project_id, step_id, title?, due_on?, assignee_ids?)
- delete_card_step(project_id, step_id)
```

### 4. Search

```
search_basecamp(query, project_id?)
- Omit project_id → search all projects
- Include project_id → scope to specific project
```

Results include todos, messages, and other content matching the query.

### 5. Sync from Plan-Writing

When user has a project plan from plan-writing skill:

```
1. Parse todo-structure.md or tasks.md for task hierarchy
2. Ask: "Which Basecamp project should I add these to?"
   - List existing projects via get_projects
   - Note: New projects must be created manually in Basecamp
3. Ask: "Use todo lists or card table?"
4. If todo lists:
   - Create todo list per phase/milestone if needed
   - Create todos with due dates and assignees
5. If card table:
   - Create columns for phases/statuses
   - Create cards from tasks
   - Add card steps for subtasks
6. Confirm: "Created X todos/cards in [project]. View in Basecamp."
```

### 6. Status Check

```
User: "What's the status of [project]?"

1. get_project(id)
2. For each todo list: get_todos, count complete/incomplete
3. If card table exists: get columns and card counts
4. Calculate summary:
   - X todos complete, Y incomplete, Z overdue
   - Card distribution across columns
5. Highlight: overdue items, blocked items
```

**Example output:**

```
Project: Q2 Training Program

Todos: 12/20 complete (60%)
- 3 overdue items
- 5 due this week

Card Table: Development
| Backlog | In Progress | Review | Done |
|    3    |      2      |   1    |  8   |

Attention needed:
- "Create training materials" (overdue by 2 days)
- "Review curriculum" (due tomorrow)
```

## Tool Categories

For complete tool reference with parameters, see [references/mcp-tools.md](references/mcp-tools.md).

| Category   | Key Tools                                                      |
| ---------- | -------------------------------------------------------------- |
| Projects   | get_projects, get_project                                      |
| Todos      | get_todolists, get_todos, create_todo, complete_todo           |
| Cards      | get_card_table, get_columns, get_cards, create_card, move_card |
| Card Steps | get_card_steps, create_card_step, complete_card_step           |
| Search     | search_basecamp                                                |
| Comments   | get_comments, create_comment                                   |
| Documents  | get_documents, create_document, update_document                |

## Limitations

- **No create_project tool**: Projects must be created manually in Basecamp UI
- **Work projects only**: This skill is for professional/team projects
- **Pagination handled**: MCP server handles pagination transparently

## Integration with Other Skills

| From Skill      | To Basecamp                                       |
| --------------- | ------------------------------------------------- |
| brainstorming   | Save decision → reference in project docs         |
| plan-writing    | todo-structure.md → Basecamp todos or cards       |
| task-management | Obsidian tasks ↔ Basecamp todos (manual reference) |

## Common Patterns

### Create todos from a list

```
User provides list:
- Task 1 (due Friday)
- Task 2 (due next week)
- Task 3

1. Identify or confirm project and todo list
2. Parse due dates (Friday → YYYY-MM-DD)
3. Create each todo via create_todo
4. Report: "Created 3 todos in [list name]"
```

### Move cards through workflow

```
User: "Move Feature A to In Progress"

1. search_basecamp("Feature A") or get_cards to find card_id
2. get_columns to find target column_id
3. move_card(project_id, card_id, column_id)
4. Confirm: "Moved 'Feature A' to 'In Progress'"
```

### Add subtasks to a card

```
User: "Add subtasks to the Feature B card"

1. Find card via search or get_cards
2. For each subtask:
   create_card_step(project_id, card_id, title)
3. Report: "Added X steps to 'Feature B'"
```
