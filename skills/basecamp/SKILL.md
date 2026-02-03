---
name: basecamp
description: "Use when: (1) Managing Basecamp projects, (2) Working with Basecamp todos and tasks, (3) Reading/updating message boards and campfire, (4) Managing card tables (kanban), (5) Handling email forwards/inbox, (6) Setting up webhooks for automation. Triggers: 'Basecamp', 'project', 'todo', 'card table', 'campfire', 'message board', 'webhook', 'inbox', 'email forwards'."
compatibility: opencode
---

# Basecamp

Basecamp 3 project management integration via MCP server. Provides comprehensive access to projects, todos, messages, card tables (kanban), campfire, inbox, documents, and webhooks.

## Core Workflows

### Finding Projects and Todos

**List all projects:**
```bash
# Get all accessible Basecamp projects
get_projects
```

**Get project details:**
```bash
# Get specific project information including status, tools, and access level
get_project --project_id <id>
```

**Explore todos:**
```bash
# Get all todo lists in a project
get_todolists --project_id <id>

# Get all todos from a specific todo list (handles pagination automatically)
get_todos --recording_id <todo_list_id>

# Search across projects for todos/messages containing keywords
search_basecamp --query <search_term>
```

### Managing Card Tables (Kanban)

**Card tables** are Basecamp's kanban-style workflow management tool.

**Explore card table:**
```bash
# Get card table for a project
get_card_table --project_id <id>

# Get all columns in a card table
get_columns --card_table_id <id>

# Get all cards in a specific column
get_cards --column_id <id>
```

**Manage columns:**
```bash
# Create new column (e.g., "In Progress", "Done")
create_column --card_table_id <id> --title "Column Name"

# Update column title
update_column --column_id <id> --title "New Title"

# Move column to different position
move_column --column_id <id> --position 3

# Update column color
update_column_color --column_id <id> --color "red"

# Put column on hold (freeze work)
put_column_on_hold --column_id <id>

# Remove hold from column (unfreeze work)
remove_column_hold --column_id <id>
```

**Manage cards:**
```bash
# Create new card in a column
create_card --column_id <id> --title "Task Name" --content "Description"

# Update card details
update_card --card_id <id> --title "Updated Title" --content "New content"

# Move card to different column
move_card --card_id <id> --to_column_id <new_column_id>

# Mark card as complete
complete_card --card_id <id>

# Mark card as incomplete
uncomplete_card --card_id <id>
```

**Manage card steps (sub-tasks):**
```bash
# Get all steps for a card
get_card_steps --card_id <id>

# Create new step
create_card_step --card_id <id> --content "Sub-task description"

# Update step
update_card_step --step_id <id> --content "Updated description"

# Delete step
delete_card_step --step_id <id>

# Mark step as complete
complete_card_step --step_id <id>

# Mark step as incomplete
uncomplete_card_step --step_id <id>
```

### Working with Messages and Campfire

**Message board:**
```bash
# Get message board for a project
get_message_board --project_id <id>

# Get all messages from a project
get_messages --project_id <id>

# Get specific message
get_message --message_id <id>
```

**Campfire (team chat):**
```bash
# Get recent campfire lines (messages)
get_campfire_lines --campfire_id <id>
```

**Comments:**
```bash
# Get comments for any Basecamp item (message, todo, card, etc.)
get_comments --recording_id <id>

# Create a comment
create_comment --recording_id <id> --content "Your comment"
```

### Managing Inbox (Email Forwards)

**Inbox** handles email forwarding to Basecamp projects.

**Explore inbox:**
```bash
# Get inbox for a project (email forwards container)
get_inbox --project_id <id>

# Get all forwarded emails from a project's inbox
get_forwards --project_id <id>

# Get specific forwarded email
get_forward --forward_id <id>

# Get all replies to a forwarded email
get_inbox_replies --forward_id <id>

# Get specific reply
get_inbox_reply --reply_id <id>
```

**Manage forwards:**
```bash
# Move forwarded email to trash
trash_forward --forward_id <id>
```

### Documents

**Manage documents:**
```bash
# List documents in a vault
get_documents --vault_id <id>

# Get specific document
get_document --document_id <id>

# Create new document
create_document --vault_id <id> --title "Document Title" --content "Document content"

# Update document
update_document --document_id <id> --title "Updated Title" --content "New content"

# Move document to trash
trash_document --document_id <id>
```

### Webhooks and Automation

**Webhooks** enable automation by triggering external services on Basecamp events.

**Manage webhooks:**
```bash
# List webhooks for a project
get_webhooks --project_id <id>

# Create webhook
create_webhook --project_id <id> --callback_url "https://your-service.com/webhook" --types "TodoCreated,TodoCompleted"

# Delete webhook
delete_webhook --webhook_id <id>
```

### Daily Check-ins

**Project check-ins:**
```bash
# Get daily check-in questions for a project
get_daily_check_ins --project_id <id>

# Get answers to daily check-in questions
get_question_answers --question_id <id>
```

### Attachments and Events

**Upload and track:**
```bash
# Upload file as attachment
create_attachment --recording_id <id> --file_path "/path/to/file"

# Get events for a recording
get_events --recording_id <id>
```

## Integration with Other Skills

### Hermes (Work Communication)

Hermes loads this skill when working with Basecamp projects. Common workflows:

| User Request | Hermes Action | Basecamp Tools Used |
|--------------|---------------|---------------------|
| "Create a task in Marketing project" | Create card/todo | `create_card`, `get_columns`, `create_column` |
| "Check project updates" | Read messages/campfire | `get_messages`, `get_campfire_lines`, `get_comments` |
| "Update my tasks" | Move cards, update status | `move_card`, `complete_card`, `update_card` |
| "Add comment to discussion" | Post comment | `create_comment`, `get_comments` |
| "Review project inbox" | Check email forwards | `get_inbox`, `get_forwards`, `get_inbox_replies` |

### Workflow Patterns

**Project setup:**
1. Use `get_projects` to find existing projects
2. Use `get_project` to verify project details
3. Use `get_todolists` or `get_card_table` to understand project structure

**Task management:**
1. Use `get_todolists` or `get_columns` to find appropriate location
2. Use `create_card` or todo creation to add work
3. Use `move_card`, `complete_card` to update status
4. Use `get_card_steps` and `create_card_step` for sub-task breakdown

**Communication:**
1. Use `get_messages` or `get_campfire_lines` to read discussions
2. Use `create_comment` to contribute to existing items
3. Use `search_basecamp` to find relevant content

**Automation:**
1. Use `get_webhooks` to check existing integrations
2. Use `create_webhook` to set up external notifications

## Tool Organization by Category

**Projects & Lists:**
- `get_projects`, `get_project`, `get_todolists`, `get_todos`, `search_basecamp`

**Card Table (Kanban):**
- `get_card_table`, `get_columns`, `get_column`, `create_column`, `update_column`, `move_column`, `update_column_color`, `put_column_on_hold`, `remove_column_hold`, `watch_column`, `unwatch_column`, `get_cards`, `get_card`, `create_card`, `update_card`, `move_card`, `complete_card`, `uncomplete_card`, `get_card_steps`, `create_card_step`, `get_card_step`, `update_card_step`, `delete_card_step`, `complete_card_step`, `uncomplete_card_step`

**Messages & Communication:**
- `get_message_board`, `get_messages`, `get_message`, `get_campfire_lines`, `get_comments`, `create_comment`

**Inbox (Email Forwards):**
- `get_inbox`, `get_forwards`, `get_forward`, `get_inbox_replies`, `get_inbox_reply`, `trash_forward`

**Documents:**
- `get_documents`, `get_document`, `create_document`, `update_document`, `trash_document`

**Webhooks:**
- `get_webhooks`, `create_webhook`, `delete_webhook`

**Other:**
- `get_daily_check_ins`, `get_question_answers`, `create_attachment`, `get_events`

## Common Queries

**Finding the right project:**
```bash
# Use search to find projects by keyword
search_basecamp --query "marketing"
# Then inspect specific project
get_project --project_id <id>
```

**Understanding project structure:**
```bash
# Check which tools are available in a project
get_project --project_id <id>
# Project response includes tools: message_board, campfire, card_table, todolists, etc.
```

**Bulk operations:**
```bash
# Get all todos across a project (pagination handled automatically)
get_todos --recording_id <todo_list_id>
# Returns all pages of results

# Get all cards across all columns
get_columns --card_table_id <id>
get_cards --column_id <id>  # Repeat for each column
```
