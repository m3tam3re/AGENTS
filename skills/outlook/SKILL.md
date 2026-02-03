---
name: outlook
description: "Outlook Graph API email integration via MCP. Use when: (1) Reading or sending emails, (2) Managing inbox folders and organization, (3) Working with calendar events, (4) Managing contacts, (5) Searching mail content, (6) Managing email rules and filters. Triggers: 'email', 'Outlook', 'inbox', 'calendar', 'contacts', 'folder', 'mail', 'message'."
compatibility: opencode
---

# Outlook Graph API Integration

Integration with Microsoft Outlook via Graph API through MCP. Provides comprehensive access to email, calendar, contacts, and folder management.

## Core Operations

### Mail Access

**List messages**: `list_messages(folder_id=None, top=25, skip=0)` - Returns messages from a folder. Use `folder_id` to target specific folders (defaults to Inbox).

**Get message**: `get_message(message_id)` - Full message details including body, headers, and attachments.

**Get message content**: `get_message_content(message_id)` - Retrieve message body (HTML/Text).

**List attachments**: `list_attachments(message_id)` - All attachments for a message.

**Get attachment**: `get_attachment(message_id, attachment_id)` - Download attachment content.

### Mail CRUD

**Create draft**: `create_draft(subject, body, to_recipients, cc_recipients=None, bcc_recipients=None, importance=None, is_html=True)` - Create email draft.

**Send email**: `send_email(subject, body, to_recipients, cc_recipients=None, bcc_recipients=None, importance=None, is_html=True)` - Send email directly.

**Send draft**: `send_draft(message_id)` - Send an existing draft.

**Reply to email**: `reply_to_message(message_id, body, is_html=True)` - Reply to sender.

**Reply all**: `reply_all_message(message_id, body, is_html=True)` - Reply to sender and all recipients.

**Forward email**: `forward_message(message_id, to_recipients, body=None, is_html=True)` - Forward message to new recipients.

**Update message**: `update_message(message_id, subject=None, body=None, importance=None, is_read=None)` - Update message properties.

**Delete message**: `delete_message(message_id)` - Move to deleted items.

**Delete permanently**: `delete_message_permanently(message_id)` - Permanently remove message.

### Folder Management

**List folders**: `list_folders()` - All accessible folders including custom ones.

**Get folder**: `get_folder(folder_id)` - Folder details and metadata.

**Create folder**: `create_folder(name, parent_folder_id=None)` - Create new folder.

**Update folder**: `update_folder(folder_id, name=None)` - Rename folder.

**Delete folder**: `delete_folder(folder_id)` - Remove folder and all contents.

**Move messages**: `move_messages(message_ids, destination_folder_id)` - Move messages between folders.

**Copy messages**: `copy_messages(message_ids, destination_folder_id)` - Copy messages to another folder.

### Calendar Events

**List events**: `list_events(calendar_id=None, top=25, skip=0)` - Events from calendar (defaults to primary calendar).

**Get event**: `get_event(event_id)` - Full event details including attendees and location.

**Create event**: `create_event(subject, start_time, end_time, body=None, location=None, attendees=None, is_all_day=False)` - Create calendar event.

**Update event**: `update_event(event_id, subject=None, start_time=None, end_time=None, body=None, location=None, attendees=None)` - Modify event.

**Delete event**: `delete_event(event_id)` - Remove event.

**Accept event**: `accept_event(event_id, response_comment=None, send_response=True)` - Accept meeting invitation.

**Decline event**: `decline_event(event_id, response_comment=None, send_response=True)` - Decline meeting invitation.

**Tentatively accept**: `tentatively_accept_event(event_id, response_comment=None, send_response=True)` - Tentatively accept invitation.

**List calendars**: `list_calendars()` - All user calendars.

### Contacts

**List contacts**: `list_contacts(folder_id=None, top=25, skip=0)` - Contacts from folder (defaults to default contacts folder).

**Get contact**: `get_contact(contact_id)` - Full contact details.

**Create contact**: `create_contact(given_name, surname, email_addresses, phone_numbers=None, business_address=None)` - Create new contact.

**Update contact**: `update_contact(contact_id, given_name=None, surname=None, email_addresses=None, phone_numbers=None, business_address=None)` - Modify contact.

**Delete contact**: `delete_contact(contact_id)` - Remove contact.

**List contact folders**: `list_contact_folders()` - All contact folders.

**Create contact folder**: `create_contact_folder(name)` - Create new contact folder.

### Search

**Search mail**: `search_mail(query, folder_id=None, top=25)` - Search emails by content across folders.

**Search contacts**: `search_contacts(query)` - Search contacts by name, email, or other properties.

**Search events**: `search_events(query)` - Search calendar events by subject or location.

## Common Workflows

### Send an email

1. Compose email: `send_email("Subject", "Body content", ["recipient@example.com"])`
2. For complex emails with attachments, use `create_draft()` first, then `send_draft()`

### Organize inbox

1. List folders: `list_folders()` to see available folders
2. Create new folder: `create_folder("Project Alpha")`
3. Move messages: `move_messages(["msg-id-1", "msg-id-2"], "new-folder-id")`

### Process meeting invitation

1. Check invitation: `get_message(message_id)` to view details
2. Accept: `accept_event(event_id, response_comment="I'll attend")`
3. Or decline: `decline_event(event_id, response_comment="Cannot make it")`

### Search for old emails

1. Use `search_mail("project deadline", top=50)` for broad search
2. Use `list_messages(folder_id="sent-items")` to check sent folder
3. Combine with filters: `search_mail("report", folder_id="archive")`

### Create recurring meeting

1. Use `create_event()` with appropriate `start_time` and `end_time`
2. Set up multiple events or use calendar-specific recurrence features

### Manage project correspondence

1. Create project folder: `create_folder("Q4 Project")`
2. Search for related emails: `search_mail("Q4 Project")`
3. Move relevant emails: `move_messages(message_ids, "project-folder-id")`
4. Track contacts: `create_contact("John", "Doe", ["john@partner.com"])`

## IDs and Discovery

Outlook Graph API uses resource IDs. When operations require IDs:

1. **Messages**: Start with `list_messages()` to get message IDs
2. **Folders**: Use `list_folders()` to discover folder IDs
3. **Events**: Use `list_events()` to get event IDs
4. **Contacts**: Use `list_contacts()` to get contact IDs

Most IDs are returned in list operations and can be used directly in CRUD operations.

## Important Notes

**Email body format**: The `is_html` parameter controls whether email body is HTML (default) or plain text. HTML provides rich formatting but plain text is more universal.

**Recipients format**: Email addresses should be provided as arrays of strings: `["user1@example.com", "user2@example.com"]`.

**Date/time format**: All datetime values should be in ISO 8601 format (e.g., `2024-12-25T14:30:00`).

**Batch operations**: Some operations like `move_messages()` and `copy_messages()` accept arrays of IDs for batch processing.

**Pagination**: List operations support `top` (max results) and `skip` (offset) parameters for handling large datasets.

**Folder IDs**: Common folder IDs include:
- Inbox (default for most operations)
- Sent Items
- Drafts
- Deleted Items
- Archive

Use `list_folders()` to get exact IDs and discover custom folders.
