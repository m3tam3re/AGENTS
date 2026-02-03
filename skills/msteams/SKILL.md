---
name: msteams
description: "Microsoft Teams Graph API integration for team communication. Use when: (1) Managing teams and channels, (2) Sending/receiving channel messages, (3) Scheduling or managing meetings, (4) Handling chat conversations. Triggers: 'Teams', 'meeting', 'channel', 'team message', 'chat', 'Teams message'."
compatibility: opencode
---

# Microsoft Teams Integration

Microsoft Teams Graph API integration for managing team communication, channels, messages, meetings, and chat conversations via MCP tools.

## Core Capabilities

### Teams & Channels
- **List joined teams**: Retrieve all teams the user is a member of
- **Manage channels**: Create, list, and manage channels within teams
- **Team membership**: Add, remove, and update team members

### Channel Messages
- **Send messages**: Post messages to channels with rich text support
- **Retrieve messages**: List channel messages with filtering by date range
- **Message management**: Read and respond to channel communications

### Online Meetings
- **Schedule meetings**: Create online meetings with participants
- **Manage meetings**: Update meeting details and coordinates
- **Meeting access**: Retrieve join links and meeting information
- **Presence**: Check user presence and activity status

### Chat
- **Direct messages**: 1:1 chat conversations with users
- **Group chats**: Multi-person chat conversations
- **Chat messages**: Send and receive chat messages

## Common Workflows

### Send Channel Message

1. Identify target team and channel
2. Compose message content
3. Use MCP tool to send message to channel

Example:
```
"Post a message to the 'General' channel in 'Engineering' team about the deployment status"
```

### Schedule Meeting

1. Determine meeting participants
2. Set meeting time and duration
3. Create meeting title and description
4. Use MCP tool to create online meeting

Example:
```
"Schedule a meeting with @alice and @bob for Friday 2pm to discuss the project roadmap"
```

### List Channel Messages

1. Specify team and channel
2. Define date range (required for polling)
3. Retrieve and display messages

Example:
```
"Show me all messages in #general from the last week"
```

### Send Direct Message

1. Identify recipient user
2. Compose message
3. Use MCP chat tool to send message

Example:
```
"Send a message to @john asking if the PR review is complete"
```

## MCP Tool Categories

The MS Teams MCP server provides tool categories for:

- **Channels**: Team and channel management operations
- **Messages**: Channel message operations
- **Meetings**: Online meeting scheduling and management
- **Chat**: Direct and group chat operations

## Important Constraints

**Authentication**: Do NOT include Graph API authentication flows. The MCP server handles authentication configuration.

**Polling limits**: When retrieving messages, always specify a date range. Polling the same resource more than once per day is a violation of Microsoft APIs Terms of Use.

**Email overlap**: Do NOT overlap with Outlook email functionality. This skill focuses on Teams-specific communication (channels, chat, meetings), not email operations.

**File storage**: Files in channels are stored in SharePoint. Use SharePoint-specific operations for file management.

## Domain Boundaries

This skill integrates with **Hermes** (work communication agent). Hermes loads this skill when user requests:
- Teams-related operations
- Meeting scheduling or management
- Channel communication
- Teams chat conversations

For email operations, Hermes uses the **outlook** skill instead.
