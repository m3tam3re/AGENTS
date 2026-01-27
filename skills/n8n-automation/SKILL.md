---
name: n8n-automation
description: "n8n workflow design and configuration for Chiron system automation. Use when: (1) designing automated workflows, (2) setting up Cron triggers, (3) configuring webhooks, (4) integrating Obsidian with n8n, (5) setting up ntfy notifications. Triggers: n8n, workflow, automation, webhook, cron, schedule."
compatibility: opencode
---

# n8n Automation

Design and configure n8n workflows for Chiron productivity system automation.

## Chiron n8n Workflows

### Workflow 1: Daily Morning Briefing

**Trigger:** Cron 07:00 (Mon-Fri)

**Purpose:** Generate morning briefing with calendar events, Basecamp todos, and tasks.

**Steps:**
1. Get calendar events (Proton Calendar or Google Calendar)
2. Get Basecamp todos (HTTP Request to Basecamp API)
3. Read today's tasks from Obsidian vault
4. Format morning briefing
5. Write daily note at `~/CODEX/daily/YYYY/MM/DD/YYYY-MM-DD.md`
6. Send ntfy notification: "Morning briefing ready"

**n8n Nodes:**
- Schedule Trigger (Cron `0 7 * * 1-5`)
- HTTP Request (Google Calendar API)
- HTTP Request (Basecamp API)
- Read/Write File (Obsidian vault)
- Code (formatting)
- HTTP Request (ntfy)

**Output:** Daily note created, ntfy notification sent

### Workflow 2: Basecamp to Obsidian Sync

**Trigger:** Webhook from Basecamp

**Events:** `todo_created`, `todo_completed`, `comment_created`, `message_created`

**Purpose:** Log Basecamp activity to Obsidian for reference.

**Steps:**
1. Receive webhook payload
2. Extract event type, project, content
3. Format activity log entry
4. Append to `~/CODEX/01-projects/work/_basecamp-activity.md`

**n8n Nodes:**
- Webhook (triggered by Basecamp)
- Code (extract and format)
- Read/Write File (append to Basecamp activity log)

**Output:** Activity logged to Obsidian

### Workflow 3: Outline Wiki Mirror

**Trigger:** Cron 22:00 daily

**Purpose:** Export updated Outline documents to Markdown and save to vault.

**Steps:**
1. Get recently updated documents from Outline API
2. For each document:
   - Export as Markdown
   - Save to `~/CODEX/03-resources/work-wiki/[doc-name].md`
3. Document sync in daily note

**n8n Nodes:**
- Schedule Trigger (Cron `0 22 * *`)
- HTTP Request (Outline API)
- Read/Write File (Obsidian vault)
- Code (loop and format)

**Output:** Outline docs synced to vault as Markdown

### Workflow 4: Claude Code Webhook Handler

**Trigger:** Webhook at `/webhook/chiron`

**Actions:**
- `notify` → Send ntfy notification
- `create_task` → Create task in Obsidian vault
- `log_learning` → Create learning note in vault
- `sync_basecamp` → Trigger Basecamp sync workflow

**Purpose:** Allow external systems to trigger Chiron workflows.

**Steps:**
1. Receive webhook payload with action parameter
2. Switch on action:
   - `notify`: Send ntfy notification with message
   - `create_task`: Create task in `tasks/inbox.md`
   - `log_learning`: Create learning in `00-inbox/learnings/`
   - `sync_basecamp`: Trigger Basecamp sync workflow
3. Return success response

**n8n Nodes:**
- Webhook (manual trigger)
- Code (action routing)
- Read/Write File (Obsidian vault)
- HTTP Request (ntfy)

**Output:** Action executed, confirmation returned

### Workflow 5: Weekly Review Generator

**Trigger:** Cron Sunday 18:00

**Purpose:** Generate weekly review from daily notes and send notification.

**Steps:**
1. Read daily notes for the week (Monday-Sunday)
2. Collect completed tasks, wins, challenges
3. Generate weekly review using template
4. Write to `~/CODEX/daily/weekly-reviews/YYYY-W##.md`
5. Send ntfy notification: "Weekly review ready"

**n8n Nodes:**
- Schedule Trigger (Cron `0 18 * * 0`)
- Read File (multiple daily notes)
- Code (aggregation)
- Write File (weekly review)
- HTTP Request (ntfy)

**Output:** Weekly review generated, ntfy notification sent

### Workflow 6: Mobile Task Reminders

**Trigger:** Cron every hour

**Purpose:** Send due tasks to mobile device via ntfy.

**Steps:**
1. Search Obsidian vault for tasks due today
2. Format task list
3. Send ntfy notification with task summary

**n8n Nodes:**
- Schedule Trigger (Cron `0 * * *`)
- Read File (search tasks)
- Code (format and search)
- HTTP Request (ntfy)

**Output:** ntfy notification with today's tasks

## Workflow Design Guidelines

### General Principles

1. **Minimal dependencies** - Each workflow should work independently
2. **Error handling** - Graceful degradation if external services fail
3. **Logging** - Log all actions for debugging
4. **Idempotency** - Workflows should be safe to run multiple times
5. **Testing** - Test manually before enabling Cron triggers

### File Operations

**Always use absolute paths:**
- `~/CODEX/` → `/home/username/knowledge/`
- Expand `~` before file operations

**File permissions:**
- Write operations: Ensure write access to vault
- Read operations: Files should exist or handle gracefully
- Directory creation: Create parent directories if needed

### API Integrations

**Basecamp API:**
- Endpoint: `https://3.basecampapi.com/[account]/projects.json`
- Authentication: OAuth2 or API token
- Rate limiting: Respect API limits (check headers)
- Error handling: Retry with exponential backoff

**Outline API:**
- Endpoint: Outline API base URL
- Authentication: API key
- Export format: Markdown
- Filtering: Updated in last 24 hours

**Proton Calendar:**
- Endpoint: Proton Calendar API
- Authentication: API token
- Time range: Today's events only
- Timezone: Use user's timezone (Europe/Berlin)

**ntfy:**
- Endpoint: `https://ntfy.sh/[topic]`
- Authentication: Token or basic auth
- Message format: Plain text or Markdown
- Priority: Default, urgent for time-sensitive notifications

### Webhook Configuration

**Setup steps:**

1. **Expose n8n webhook** (if self-hosted):
   - Domain: `n8n.example.com`
   - Path: `/webhook/chiron`
   - SSL: HTTPS required

2. **Configure Basecamp webhooks**:
   - URL: `https://n8n.example.com/webhook/chiron`
   - Events: todo_created, todo_completed, comment_created, message_created
   - Secret: Shared secret for validation

3. **Security:**
   - Validate webhook secret
   - Rate limit webhook endpoints
   - Log all webhook calls

### Cron Triggers

**Syntax:** `minute hour day month weekday`

**Examples:**
```
# Daily at 7 AM, Mon-Fri
0 7 * * 1-5

# Daily at 10 PM
0 22 * * *

# Weekly Sunday at 6 PM
0 18 * * 0

# Hourly
0 * * * *
```

**n8n Cron Node settings:**
- Enable: Toggle on/off for testing
- Timezone: Europe/Berlin
- Test run: Manual trigger button

## Integration with Chiron Skills

**Delegates to:**
- `obsidian-management` - File operations for reading/writing vault
- `task-management` - Task extraction and format
- `quick-capture` - Quick capture for webhook-created tasks
- `daily-routines` - Daily note creation for morning briefings

**Delegation rules:**
- File operations → `obsidian-management`
- Task creation → `task-management`
- Quick capture → `quick-capture`
- Daily note creation → `daily-routines`

## Quick Reference

| Action | Workflow | Trigger | Frequency |
|--------|----------|----------|-----------|
| Morning briefing | Workflow 1 | Cron 07:00 Mon-Fri |
| Basecamp sync | Workflow 2 | Webhook (on change) |
| Outline mirror | Workflow 3 | Cron 22:00 daily |
| Webhook handler | Workflow 4 | Manual (API calls) |
| Weekly review | Workflow 5 | Cron Sunday 18:00 |
| Task reminders | Workflow 6 | Cron hourly |

## File Paths

**Obsidian vault:**
```
~/CODEX/
├── daily/
│   ├── YYYY/
│   │   └── MM/
│   │       └── DD/
│   │           └── YYYY-MM-DD.md      # Morning briefings
│   └── weekly-reviews/
│       └── YYYY-W##.md                # Weekly reviews
├── 01-projects/work/
│   └── _basecamp-activity.md           # Basecamp activity log
├── tasks/
│   └── inbox.md                         # Webhook-created tasks
└── 00-inbox/learnings/                    # Webhook-created learnings
```

## Error Handling

### API Failure
1. Log error with timestamp
2. Use cached data if available
3. Send ntfy notification: "API failed, using cache"
4. Retry with exponential backoff

### File Write Failure
1. Log error
2. Check disk space
3. Check file permissions
4. Send ntfy notification: "Failed to write to vault"

### Webhook Authentication Failure
1. Reject invalid requests (401)
2. Log suspicious attempts
3. Rate limit source IP
4. Send alert notification

## Testing

### Manual Testing

Before enabling Cron triggers:

1. **Test each workflow**:
   - Manual trigger in n8n UI
   - Verify file creation
   - Verify API calls
   - Check ntfy notifications

2. **Integration testing:**
   - Trigger Basecamp webhook (create todo)
   - Verify appears in Obsidian
   - Test morning briefing workflow
   - Verify daily note created

3. **Load testing:**
   - Test with multiple daily notes
   - Verify weekly review aggregation
   - Test webhook with concurrent requests

### Monitoring

**Add monitoring workflows:**

1. **Health check** - Verify n8n is running (Cron every 5 min)
2. **Success rate** - Track workflow success/failure (daily summary)
3. **Error alerts** - Send ntfy on critical failures
4. **Performance** - Track workflow execution time

## Best Practices

### Workflow Design
- Keep workflows simple and focused
- Use environment variables for configuration
- Document dependencies and requirements
- Version control workflow JSON files

### API Integration
- Respect rate limits and backoff
- Cache responses when appropriate
- Handle pagination for large datasets
- Use appropriate authentication (OAuth2 vs API keys)

### Notifications
- Don't spam with ntfy
- Use appropriate priority (urgent vs default)
- Include actionable information
- Test notification delivery

### Security
- Never hardcode API keys in workflow JSON
- Use environment variables or n8n credentials
- Validate webhook secrets
- Rate limit public endpoints
- Log all external access

## Example Workflow JSON

```json
{
  "name": "Daily Morning Briefing",
  "nodes": [
    {
      "type": "n8n-nodes-base.schedule-trigger",
      "parameters": {
        "rule": {
          "interval": [
            {
              "field": "cronExpression",
              "expression": "0 7 * * 1-5"
            }
          ]
        }
      }
    },
    {
      "type": "n8n-nodes-base.httprequest",
      "parameters": {
        "method": "GET",
        "url": "https://calendar.googleapis.com/v3/calendars/primary/events",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": {
          "id": "proton-calendar-token"
        }
      }
    },
    {
      "type": "code",
      "parameters": {
        "jsCode": "// Format calendar events\nreturn events.map(e => e.summary);\n"
      }
    },
    {
      "type": "n8n-nodes-base.writefile",
      "parameters": {
        "fileName": "/home/username/knowledge/daily/2026/01/27/2026-01-27.md",
        "data": "={{ $json.events }}",
        "mode": "overwrite"
      }
    },
    {
      "type": "n8n-nodes-base.httprequest",
      "parameters": {
        "method": "POST",
        "url": "https://ntfy.sh/chiron-tasks",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": {
          "id": "ntfy-token"
        }
      }
    }
  ]
}
```

## Troubleshooting

### Workflow Not Triggering
1. Check Cron expression syntax
2. Verify timezone settings
3. Check n8n execution logs
4. Test manual trigger

### API Rate Limits
1. Reduce polling frequency
2. Implement caching
3. Use batch operations
4. Contact provider for higher limits

### File Sync Issues
1. Check vault directory exists
2. Verify file permissions
3. Check available disk space
4. Verify path format (absolute vs relative)

## Resources

- `references/n8n-workflow-guide.md` - Detailed n8n workflow design patterns
- `references/api-integration.md` - Basecamp, Outline, Proton Calendar API docs
- `references/webhook-security.md` - Webhook security best practices

**Load references when:**
- Designing new workflows
- Troubleshooting integration issues
- Setting up monitoring
