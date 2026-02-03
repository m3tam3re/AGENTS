---
name: msteams
description: "Microsoft Teams Graph API integration for team communication and collaboration. Use when Opencode needs to interact with Teams for: (1) Managing channels and teams, (2) Sending and retrieving channel messages, (3) Creating and managing meetings, (4) Handling chat conversations, (5) Building automated team communication workflows. Triggers: 'Teams', 'channel', 'meeting', 'chat', 'team message', 'Microsoft Teams'."
compatibility: opencode
---

# Microsoft Teams Graph API Integration

Integrate with Microsoft Teams via Graph API for team communication, meeting management, and collaboration workflows.

## Quick Start

Teams Graph API provides comprehensive access to Teams functionality for automation workflows. Use this skill when building workflows that involve:
- Automated channel message posting
- Meeting scheduling and management
- Chat interaction and conversation handling
- Team and channel organization

## Core API Capabilities

### Teams & Channels

**List teams**
- Get all teams the user has access to
- Filter teams by display name or group ID
- Retrieve team membership and role information

**Access channels**
- Get all channels within a team
- Access standard channels, private channels, and shared channels
- Retrieve channel membership and settings

**Manage channels**
- Create new channels in teams
- Update channel properties (name, description)
- Archive or delete channels
- Manage channel members and permissions

### Channel Messages

**Send messages**
- Post new messages to channels
- Send rich text and formatted content
- Attach files and images to messages
- Mention users or teams with @mentions
- Create adaptive cards for interactive messages

**Retrieve messages**
- Get channel message history
- Filter messages by date range or sender
- Load message replies and threads
- Access message attachments and reactions

**Manage messages**
- Edit existing channel messages
- Delete messages
- Pin important messages
- Add reactions and reactions management

### Meetings

**Create meetings**
- Schedule online meetings via Teams
- Set meeting title, description, and duration
- Add participants and attendees
- Configure meeting options (recording, lobby, etc.)

**Manage meetings**
- Update meeting details
- Cancel meetings
- Get meeting recordings and transcripts
- Access meeting attendance reports

**Meeting participation**
- Join meetings via API (where supported)
- Get meeting links and join URLs
- Manage meeting chat during calls

### Chat Conversations

**List chats**
- Get all chats the user participates in
- Filter by chat type (1:1, group, meeting)
- Access chat metadata and participant info

**Send chat messages**
- Send messages to 1:1 or group chats
- Send rich text and formatted content
- Attach files to chat messages

**Retrieve chat messages**
- Get chat message history
- Load message threads and replies
- Access message attachments and metadata

**Manage chats**
- Create new group chats
- Add or remove participants
- Update chat settings
- Archive or delete conversations

## Common Workflows

### Automated Channel Announcements

Broadcast information to team channels:
1. Identify target team and channel via Graph API
2. Prepare message content with rich text formatting
3. Post message to channel using message endpoint
4. Include attachments if needed
5. Log or track message delivery

### Meeting Scheduling Automation

Schedule recurring or one-off meetings:
1. Create meeting object with required details
2. Add attendees and configure options
3. Use Graph API to create meeting in calendar
4. Generate and share meeting link
5. Send confirmation to participants

### Chat-Based Notifications

Send notifications to users or groups via chat:
1. Identify target chat (1:1 or group)
2. Compose notification message
3. Send via chat message endpoint
4. Handle delivery confirmations
5. Track response if needed

### Content Retrieval & Reporting

Gather information from Teams conversations:
1. Query channel or chat message history
2. Filter by date, sender, or keywords
3. Extract relevant content and attachments
4. Compile report or summary
5. Format for user consumption

### Meeting Follow-up Workflows

Automate post-meeting actions:
1. Retrieve meeting transcripts or recordings
2. Extract action items or decisions
3. Create follow-up tasks or messages
4. Share summary with participants
5. Schedule next meeting if needed

## API Endpoint Reference

**Teams & Channels**
- `GET /teams` - List all teams
- `GET /teams/{team-id}` - Get specific team
- `GET /teams/{team-id}/channels` - List team channels
- `GET /teams/{team-id}/channels/{channel-id}` - Get channel details
- `POST /teams/{team-id}/channels` - Create new channel
- `PATCH /teams/{team-id}/channels/{channel-id}` - Update channel

**Channel Messages**
- `GET /teams/{team-id}/channels/{channel-id}/messages` - List messages
- `GET /teams/{team-id}/channels/{channel-id}/messages/{message-id}` - Get message
- `POST /teams/{team-id}/channels/{channel-id}/messages` - Send message
- `PATCH /teams/{team-id}/channels/{channel-id}/messages/{message-id}` - Edit message
- `DELETE /teams/{team-id}/channels/{channel-id}/messages/{message-id}` - Delete message

**Meetings**
- `POST /me/onlineMeetings` - Create online meeting
- `GET /me/onlineMeetings` - List my meetings
- `GET /me/onlineMeetings/{meeting-id}` - Get meeting details
- `PATCH /me/onlineMeetings/{meeting-id}` - Update meeting
- `DELETE /me/onlineMeetings/{meeting-id}` - Cancel meeting
- `GET /me/onlineMeetings/{meeting-id}/transcripts` - Get transcripts

**Chat**
- `GET /chats` - List all chats
- `GET /chats/{chat-id}` - Get chat details
- `POST /chats` - Create new chat
- `GET /chats/{chat-id}/messages` - List chat messages
- `POST /chats/{chat-id}/messages` - Send chat message

## Best Practices

**Message Formatting**
- Use Markdown or HTML for rich text when supported
- Handle @mentions correctly (user or team references)
- Validate message length limits (typically 28KB)
- Test adaptive cards for compatibility

**Rate Limiting**
- Respect Microsoft Graph API rate limits
- Implement exponential backoff for throttling
- Batch operations where possible
- Monitor API usage and adjust accordingly

**Error Handling**
- Handle 404 errors (resource not found)
- Manage permission errors (403) gracefully
- Implement retry logic for transient failures
- Log errors with sufficient context for debugging

**Meeting Management**
- Check participant limits for meeting type
- Validate meeting options before creation
- Handle time zone conversions correctly
- Confirm meeting creation before sharing links

**Content Safety**
- Validate content for sensitive information
- Follow organizational communication policies
- Respect privacy when accessing chat history
- Obtain consent where required for automation

## Integration Examples

**Post a daily status update to channel**
1. Identify target channel ID via teams/channels endpoints
2. Compose status message with relevant data
3. Use `POST /teams/{team-id}/channels/{channel-id}/messages`
4. Include attachments or adaptive cards if needed
5. Confirm successful posting

**Schedule a weekly team meeting**
1. Create meeting object with recurring schedule
2. Add team members as attendees
3. Call `POST /me/onlineMeetings`
4. Extract meeting link and share with team
5. Send confirmation via channel or chat

**Send notification to multiple users via group chat**
1. Create group chat with participants
2. Compose notification message
3. Send via `POST /chats/{chat-id}/messages`
4. Track delivery and responses
5. Archive or update chat as needed

**Retrieve meeting action items**
1. Get meeting transcript via `/transcripts` endpoint
2. Parse transcript for action items
3. Create follow-up tasks or messages
4. Share summary with participants
5. Update project tracking systems if integrated
