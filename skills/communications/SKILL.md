---
name: communications
description: "Email and communication management with Proton Mail integration. Use when: (1) drafting emails, (2) managing follow-ups, (3) communication tracking, (4) message templates, (5) inbox management. Triggers: email, draft, reply, follow up, message, inbox, communication, respond to."
compatibility: opencode
---

# Communications

Email and communication management for Proton Mail.

## Status: Stub

This skill is a placeholder for future development. Core functionality to be added:

## Planned Features

### Email Drafting
- Context-aware draft generation
- Tone matching (formal/casual)
- Template-based responses

### Follow-up Tracking
- Waiting-for list management
- Follow-up reminders
- Response tracking

### Inbox Management
- Priority sorting
- Quick triage assistance
- Archive recommendations

### Communication Templates
- Common response patterns
- Meeting request templates
- Status update formats

## Integration Points

- **Proton Mail**: Primary email backend
- **task-management**: Convert emails to tasks
- **ntfy**: Important email alerts
- **n8n**: Automation workflows

## Quick Commands (Future)

| Command | Description |
|---------|-------------|
| `draft reply to [context]` | Generate email draft |
| `follow up on [topic]` | Check follow-up status |
| `email template [type]` | Use saved template |
| `inbox summary` | Overview of pending emails |

## Proton Mail Integration

API integration pending. Options:
- Proton Bridge (local IMAP/SMTP)
- n8n with email triggers
- Manual copy/paste workflow initially

## Communication Style Guide

Based on Sascha's profile:
- **Tone**: Professional but approachable
- **Length**: Concise, get to the point
- **Structure**: Clear ask/action at the top
- **Follow-up**: Set clear expectations

## Email Templates (Future)

- Meeting request
- Status update
- Delegation request
- Follow-up reminder
- Thank you / acknowledgment

## Notes

Start with manual draft assistance. Proton Mail API integration can be added via n8n workflow when ready.
