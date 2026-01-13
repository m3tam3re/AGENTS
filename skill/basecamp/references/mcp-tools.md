# Basecamp MCP Tools Reference

Complete reference for all 46 available Basecamp MCP tools.

## Projects

| Tool | Parameters | Returns |
|------|------------|---------|
| `get_projects` | none | List of all projects with id, name, description |
| `get_project` | project_id | Project details including dock (todosets, card tables, etc.) |

## Todo Lists

| Tool | Parameters | Returns |
|------|------------|---------|
| `get_todolists` | project_id | All todo lists in project |

## Todos

| Tool | Parameters | Returns |
|------|------------|---------|
| `get_todos` | project_id, todolist_id | All todos (pagination handled) |
| `create_todo` | project_id, todolist_id, content, due_on?, assignee_ids?, notify? | Created todo |
| `update_todo` | project_id, todo_id, content?, due_on?, assignee_ids? | Updated todo |
| `delete_todo` | project_id, todo_id | Success confirmation |
| `complete_todo` | project_id, todo_id | Completed todo |
| `uncomplete_todo` | project_id, todo_id | Reopened todo |

### Todo Parameters

- `content`: String - The todo text
- `due_on`: String - Date in YYYY-MM-DD format
- `assignee_ids`: Array of integers - Person IDs to assign
- `notify`: Boolean - Whether to notify assignees

## Card Tables

| Tool | Parameters | Returns |
|------|------------|---------|
| `get_card_tables` | project_id | All card tables in project |
| `get_card_table` | project_id | Primary card table details |

## Columns

| Tool | Parameters | Returns |
|------|------------|---------|
| `get_columns` | project_id, card_table_id | All columns in card table |
| `get_column` | project_id, column_id | Column details |
| `create_column` | project_id, card_table_id, title | New column |
| `update_column` | project_id, column_id, title | Updated column |
| `move_column` | project_id, card_table_id, column_id, position | Moved column |
| `update_column_color` | project_id, column_id, color | Updated color |
| `put_column_on_hold` | project_id, column_id | Column frozen |
| `remove_column_hold` | project_id, column_id | Column unfrozen |
| `watch_column` | project_id, column_id | Subscribed to notifications |
| `unwatch_column` | project_id, column_id | Unsubscribed |

### Column Colors

Available colors for `update_column_color`:
- white, grey, pink, red, orange, yellow, green, teal, blue, purple

## Cards

| Tool | Parameters | Returns |
|------|------------|---------|
| `get_cards` | project_id, column_id | All cards in column |
| `get_card` | project_id, card_id | Card details |
| `create_card` | project_id, column_id, title, content?, due_on?, notify? | New card |
| `update_card` | project_id, card_id, title?, content?, due_on?, assignee_ids? | Updated card |
| `move_card` | project_id, card_id, column_id | Card moved to column |
| `complete_card` | project_id, card_id | Card marked complete |
| `uncomplete_card` | project_id, card_id | Card reopened |

### Card Parameters

- `title`: String - Card title
- `content`: String - Card description/body (supports HTML)
- `due_on`: String - Date in YYYY-MM-DD format
- `assignee_ids`: Array of integers - Person IDs
- `notify`: Boolean - Notify assignees on creation

## Card Steps (Subtasks)

| Tool | Parameters | Returns |
|------|------------|---------|
| `get_card_steps` | project_id, card_id | All steps on card |
| `create_card_step` | project_id, card_id, title, due_on?, assignee_ids? | New step |
| `get_card_step` | project_id, step_id | Step details |
| `update_card_step` | project_id, step_id, title?, due_on?, assignee_ids? | Updated step |
| `delete_card_step` | project_id, step_id | Step deleted |
| `complete_card_step` | project_id, step_id | Step completed |
| `uncomplete_card_step` | project_id, step_id | Step reopened |

## Search

| Tool | Parameters | Returns |
|------|------------|---------|
| `search_basecamp` | query, project_id? | Matching todos, messages, etc. |

- Omit `project_id` for global search across all projects
- Include `project_id` to scope search to specific project

## Communication

| Tool | Parameters | Returns |
|------|------------|---------|
| `get_campfire_lines` | project_id, campfire_id | Recent chat messages |
| `get_comments` | project_id, recording_id | Comments on any item |
| `create_comment` | project_id, recording_id, content | New comment |

### Comment Parameters

- `recording_id`: The ID of the item (todo, card, document, etc.)
- `content`: String - Comment text (supports HTML)

## Daily Check-ins

| Tool | Parameters | Returns |
|------|------------|---------|
| `get_daily_check_ins` | project_id, page? | Check-in questions |
| `get_question_answers` | project_id, question_id, page? | Answers to question |

## Documents

| Tool | Parameters | Returns |
|------|------------|---------|
| `get_documents` | project_id, vault_id | Documents in vault |
| `get_document` | project_id, document_id | Document content |
| `create_document` | project_id, vault_id, title, content, status? | New document |
| `update_document` | project_id, document_id, title?, content? | Updated document |
| `trash_document` | project_id, document_id | Document trashed |

### Document Parameters

- `vault_id`: Found in project dock as the docs/files container
- `content`: String - Document body (supports HTML)
- `status`: "active" or "archived"

## Attachments

| Tool | Parameters | Returns |
|------|------------|---------|
| `create_attachment` | file_path, name, content_type? | Uploaded attachment |

## Events

| Tool | Parameters | Returns |
|------|------------|---------|
| `get_events` | project_id, recording_id | Activity events on item |

## Webhooks

| Tool | Parameters | Returns |
|------|------------|---------|
| `get_webhooks` | project_id | Project webhooks |
| `create_webhook` | project_id, payload_url, types? | New webhook |
| `delete_webhook` | project_id, webhook_id | Webhook deleted |

### Webhook Types

Available types for `create_webhook`:
- Comment, Document, GoogleDocument, Message, Question::Answer
- Schedule::Entry, Todo, Todolist, Upload, Vault, Card, CardTable::Column

## Common Patterns

### Find project by name

```
1. get_projects → list all
2. Match name (case-insensitive partial match)
3. Return project_id
```

### Find todoset ID for a project

```
1. get_project(project_id)
2. Look in dock array for item with name "todoset"
3. Extract id from dock item URL
```

### Find card table ID

```
1. get_project(project_id)
2. Look in dock for "kanban_board" or use get_card_tables
3. Extract card_table_id
```

### Get all todos across all lists

```
1. get_todolists(project_id)
2. For each todolist: get_todos(project_id, todolist_id)
3. Aggregate results
```
