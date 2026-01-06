# Anytype API Workflows

API patterns for task management operations in the Chiron space.

## Setup

### Space Configuration

**Space Name**: Chiron
**Space ID**: Retrieve via `Anytype_API-list-spaces` after creation

```
# List spaces to find Chiron space ID
Anytype_API-list-spaces

# Store space_id for subsequent calls
SPACE_ID="<chiron-space-id>"
```

### Required Types

Create these types if they don't exist:

#### Area Type
```
Anytype_API-create-type
  space_id: SPACE_ID
  name: "Area"
  plural_name: "Areas"
  layout: "basic"
  key: "area"
  properties:
    - name: "Description", key: "description", format: "text"
    - name: "Review Frequency", key: "review_frequency", format: "select"
```

#### Project Type
```
Anytype_API-create-type
  space_id: SPACE_ID
  name: "Project"
  plural_name: "Projects"
  layout: "basic"
  key: "project"
  properties:
    - name: "Status", key: "status", format: "select"
    - name: "Priority", key: "priority", format: "select"
    - name: "Area", key: "area", format: "objects"
    - name: "Due Date", key: "due_date", format: "date"
    - name: "Outcome", key: "outcome", format: "text"
```

#### Task Type
```
Anytype_API-create-type
  space_id: SPACE_ID
  name: "Task"
  plural_name: "Tasks"
  layout: "action"
  key: "task"
  properties:
    - name: "Status", key: "status", format: "select"
    - name: "Priority", key: "priority", format: "select"
    - name: "Area", key: "area", format: "objects"
    - name: "Project", key: "project", format: "objects"
    - name: "Due Date", key: "due_date", format: "date"
    - name: "Energy", key: "energy", format: "select"
    - name: "Context", key: "context", format: "multi_select"
```

### Required Properties with Tags

#### Status Property Tags
```
Anytype_API-create-property
  space_id: SPACE_ID
  name: "Status"
  key: "status"
  format: "select"
  tags:
    - name: "Inbox", color: "grey"
    - name: "Next", color: "blue"
    - name: "Waiting", color: "yellow"
    - name: "Scheduled", color: "purple"
    - name: "Done", color: "lime"
```

#### Priority Property Tags
```
Anytype_API-create-property
  space_id: SPACE_ID
  name: "Priority"
  key: "priority"
  format: "select"
  tags:
    - name: "Critical", color: "red"
    - name: "High", color: "orange"
    - name: "Medium", color: "yellow"
    - name: "Low", color: "grey"
```

#### Energy Property Tags
```
Anytype_API-create-property
  space_id: SPACE_ID
  name: "Energy"
  key: "energy"
  format: "select"
  tags:
    - name: "High", color: "red"
    - name: "Medium", color: "yellow"
    - name: "Low", color: "blue"
```

#### Context Property Tags
```
Anytype_API-create-property
  space_id: SPACE_ID
  name: "Context"
  key: "context"
  format: "multi_select"
  tags:
    - name: "Deep Work", color: "purple"
    - name: "Admin", color: "grey"
    - name: "Calls", color: "blue"
    - name: "Errands", color: "teal"
    - name: "Quick Wins", color: "lime"
```

## CRUD Operations

### Create Task

```
Anytype_API-create-object
  space_id: SPACE_ID
  type_key: "task"
  name: "Task title here"
  body: "Optional task description or notes"
  properties:
    - key: "status", select: "<status_tag_id>"
    - key: "priority", select: "<priority_tag_id>"
    - key: "area", objects: ["<area_object_id>"]
    - key: "due_date", date: "2025-01-10"
  icon:
    format: "icon"
    name: "checkbox"
    color: "blue"
```

### Create Project

```
Anytype_API-create-object
  space_id: SPACE_ID
  type_key: "project"
  name: "Project title"
  body: "Project description and goals"
  properties:
    - key: "status", select: "<active_tag_id>"
    - key: "area", objects: ["<area_object_id>"]
    - key: "outcome", text: "What done looks like"
  icon:
    format: "icon"
    name: "rocket"
    color: "purple"
```

### Create Area

```
Anytype_API-create-object
  space_id: SPACE_ID
  type_key: "area"
  name: "CTO Leadership"
  body: "Team management, technical strategy, architecture decisions"
  properties:
    - key: "description", text: "Standards: Team health, technical excellence, strategic alignment"
    - key: "review_frequency", select: "<weekly_tag_id>"
  icon:
    format: "icon"
    name: "briefcase"
    color: "blue"
```

### Quick Capture (Inbox)

```
Anytype_API-create-object
  space_id: SPACE_ID
  type_key: "note"
  name: "Quick capture content here"
  properties:
    - key: "status", select: "<inbox_tag_id>"
  icon:
    format: "icon"
    name: "mail"
    color: "grey"
```

### Update Task Status

```
Anytype_API-update-object
  space_id: SPACE_ID
  object_id: "<task_object_id>"
  properties:
    - key: "status", select: "<done_tag_id>"
```

## Query Patterns

### Get All Tasks for Today

```
Anytype_API-search-space
  space_id: SPACE_ID
  types: ["task"]
  filters:
    operator: "and"
    conditions:
      - property_key: "status"
        select: "<next_tag_id>"
      - property_key: "due_date"
        date: "2025-01-05"
        condition: "le"
```

### Get Inbox Items

```
Anytype_API-search-space
  space_id: SPACE_ID
  filters:
    operator: "and"
    conditions:
      - property_key: "status"
        select: "<inbox_tag_id>"
  sort:
    property_key: "created_date"
    direction: "desc"
```

### Get Tasks by Area

```
Anytype_API-search-space
  space_id: SPACE_ID
  types: ["task"]
  filters:
    operator: "and"
    conditions:
      - property_key: "area"
        objects: ["<area_object_id>"]
      - property_key: "status"
        condition: "nempty"
```

### Get Active Projects

```
Anytype_API-search-space
  space_id: SPACE_ID
  types: ["project"]
  filters:
    conditions:
      - property_key: "status"
        select: "<active_tag_id>"
```

### Get Overdue Tasks

```
Anytype_API-search-space
  space_id: SPACE_ID
  types: ["task"]
  filters:
    operator: "and"
    conditions:
      - property_key: "due_date"
        date: "<today>"
        condition: "lt"
      - property_key: "status"
        condition: "nempty"
```

### Get Tasks by Context

```
Anytype_API-search-space
  space_id: SPACE_ID
  types: ["task"]
  filters:
    conditions:
      - property_key: "context"
        multi_select: ["<deep_work_tag_id>"]
      - property_key: "status"
        select: "<next_tag_id>"
```

## Batch Operations

### Complete Multiple Tasks

```python
# Pseudocode for batch completion
task_ids = ["id1", "id2", "id3"]
done_tag_id = "<done_tag_id>"

for task_id in task_ids:
    Anytype_API-update-object(
        space_id=SPACE_ID,
        object_id=task_id,
        properties=[{"key": "status", "select": done_tag_id}]
    )
```

### Archive Completed Projects

```
# 1. Find completed projects
Anytype_API-search-space
  space_id: SPACE_ID
  types: ["project"]
  filters:
    conditions:
      - property_key: "status"
        select: "<completed_tag_id>"

# 2. For each, update to archived status or move to archive
```

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Missing/invalid auth | Check API key configuration |
| 404 Not Found | Invalid space/object ID | Verify IDs with list operations |
| 400 Bad Request | Invalid property format | Check property types match expected format |

## Notes

- Always retrieve space_id fresh via `list-spaces` before operations
- Tag IDs must be retrieved via `list-tags` for the specific property
- Object relations require the target object's ID, not name
- Dates use ISO 8601 format: `2025-01-05` or `2025-01-05T18:00:00Z`
