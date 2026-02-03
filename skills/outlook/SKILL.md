---
name: outlook
description: "Outlook Graph API integration for email, calendar, and contact management. Use when: (1) Reading or sending emails, (2) Managing inbox and folders, (3) Working with calendar events and appointments, (4) Managing contacts, (5) Organizing email messages. Triggers: 'email', 'Outlook', 'inbox', 'calendar', 'contact', 'message', 'folder', 'appointment', 'meeting'."
compatibility: opencode
---

# Outlook

Outlook Graph API integration for mail, calendar, and contact management via MCP. Enables comprehensive email workflows, calendar coordination, and contact organization.

## Overview

Outlook is Microsoft 365's messaging and communication hub. This skill provides access to:

- **Mail**: Send, receive, search, organize, and categorize messages
- **Calendar**: Create and manage events, appointments, and meetings
- **Contacts**: Manage contact information and relationships
- **Folders**: Organize messages into custom folder structures

## Core Workflows

### 1. Reading Emails

Retrieve messages from mailbox:

```
User: "Check my inbox for new messages from John"

AI: Use Outlook MCP to:
1. List messages in Inbox folder
2. Filter by sender = "John"
3. Display summary (subject, date, importance)
```

**Use search and sort** to efficiently find messages:
- Filter by folder (Inbox, Sent, Drafts, etc.)
- Sort by date, importance, or subject
- Search by sender, subject, or content

### 2. Sending Emails

Compose and send new messages:

```
User: "Send an email to sarah@company.com about the project update"

AI: Use Outlook MCP to:
1. Create message draft with recipient and subject
2. Add body content
3. Send the message
```

**Key options**:
- Add attachments
- Set importance (low, normal, high)
- Add recipients (to, cc, bcc)
- Use categories for organization

### 3. Replying and Forwarding

Respond to existing messages:

```
User: "Reply to the last email from Mike with thanks"

AI: Use Outlook MCP to:
1. Retrieve the most recent message from Mike
2. Create reply with appropriate body
3. Send the reply
```

**Supports**:
- Reply (to sender)
- Reply All (to all recipients)
- Forward (to new recipients)

### 4. Managing Folders

Organize messages into folder structure:

```
User: "Move all emails from vendor@supplier.com to Vendors folder"

AI: Use Outlook MCP to:
1. Search for messages from vendor@supplier.com
2. Move matching messages to Vendors folder
3. Confirm move operation
```

**Folder operations**:
- List folders
- Create new folders
- Move messages between folders
- Delete folders (careful!)

### 5. Calendar Events

Manage calendar and schedule meetings:

```
User: "Schedule a team meeting for Friday at 2pm"

AI: Use Outlook MCP to:
1. Create calendar event
2. Set date/time (Friday 2:00 PM)
3. Add attendees
4. Send meeting invitation
```

**Event details**:
- Subject and location
- Start/end times
- Attendees and required/optional status
- Meeting body/agenda
- Recurrence (for recurring meetings)

### 6. Managing Contacts

Create and maintain contact information:

```
User: "Add Jane Smith to contacts: jane@company.com, 555-1234"

AI: Use Outlook MCP to:
1. Create contact object
2. Add email address and phone number
3. Save to contacts
```

**Contact fields**:
- Name (first, last, display name)
- Email addresses (multiple)
- Phone numbers (multiple types)
- Company, job title
- Notes

## Advanced Features

### Message Organization

**Categories**: Tag messages with color-coded categories for enhanced organization
```
User: "Tag these project emails as 'Urgent' category"

AI: Use Outlook MCP to:
1. Retrieve specified messages
2. Assign category (e.g., "Urgent")
3. Confirm categorization
```

**Importance**: Mark messages as high, normal, or low importance
```
User: "Mark this message as high priority"

AI: Use Outlook MCP to update message importance flag
```

**Search**: Find messages by sender, subject, content, or date range
```
User: "Find all emails about Q4 budget from October"

AI: Use Outlook MCP to search with filters:
- Subject contains "budget"
- Date range: October
- Optionally filter by sender
```

### Email Intelligence

**Focused Inbox**: Access messages categorized as focused vs other
**Mail Tips**: Check recipient status before sending (auto-reply, full mailbox)
**MIME Support**: Handle email in MIME format for interoperability

## Integration with Other Skills

This skill focuses on Outlook-specific operations. For related functionality:

| Need | Skill | When to Use |
|------|-------|-------------|
| **Team project updates** | basecamp | "Update the Basecamp todo" |
| **Team channel messages** | msteams | "Post this in the Teams channel" |
| **Private notes about emails** | obsidian | "Save this to Obsidian" |
| **Drafting long-form emails** | calliope | "Help me write a professional email" |
| **Short quick messages** | hermes (this skill) | "Send a quick update" |

## Common Patterns

### Email Triage Workflow

1. **Scan inbox**: List messages sorted by date
2. **Categorize**: Assign categories based on content/urgency
3. **Action**: Reply, forward, or move to appropriate folder
4. **Track**: Flag for follow-up if needed

### Meeting Coordination

1. **Check availability**: Query calendar for conflicts
2. **Propose time**: Suggest multiple time options
3. **Create event**: Set up meeting with attendees
4. **Follow up**: Send reminder or agenda

### Project Communication

1. **Search thread**: Find all messages related to project
2. **Organize**: Move to project folder
3. **Categorize**: Tag with project category
4. **Summarize**: Extract key points if needed

## Quality Standards

- **Accurate recipient addressing**: Verify email addresses before sending
- **Clear subject lines**: Ensure subjects accurately reflect content
- **Appropriate categorization**: Use categories consistently
- **Folder hygiene**: Maintain organized folder structure
- **Respect privacy**: Do not share sensitive content indiscriminately

## Edge Cases

**Multiple mailboxes**: This skill supports primary and shared mailboxes, not archive mailboxes
**Large attachments**: Use appropriate attachment handling for large files
**Meeting conflicts**: Check calendar availability before scheduling
**Email limits**: Respect rate limits and sending quotas
**Deleted items**: Use caution with delete operations (consider archiving instead)

## Boundaries

- **Do NOT handle Teams-specific messaging** (Teams's domain)
- **Do NOT handle Basecamp communication** (basecamp's domain)
- **Do NOT manage wiki documentation** (Athena's domain)
- **Do NOT access private Obsidian vaults** (Apollo's domain)
- **Do NOT write creative email content** (delegate to calliope for drafts)
