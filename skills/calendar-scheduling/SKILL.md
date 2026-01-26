---
name: calendar-scheduling
description: "Calendar and time management with Proton Calendar integration. Use when: (1) checking schedule, (2) blocking focus time, (3) scheduling meetings, (4) time-based planning, (5) managing availability. Triggers: calendar, schedule, when am I free, block time, meeting, availability, what's my day look like."
compatibility: opencode
---

# Calendar & Scheduling

Time management and calendar integration for Proton Calendar.

## Status: Stub

This skill is a placeholder for future development. Core functionality to be added:

## Planned Features

### Schedule Overview
- Daily/weekly calendar view
- Meeting summaries
- Free time identification

### Time Blocking
- Deep work blocks
- Focus time protection
- Buffer time between meetings

### Meeting Management
- Quick meeting creation
- Availability checking
- Meeting prep reminders

### Time-Based Planning
- Energy-matched scheduling
- Context-based time allocation
- Review time protection

## Integration Points

- **Proton Calendar**: Primary calendar backend
- **task-management**: Align tasks with available time
- **ntfy**: Meeting reminders and alerts

## Quick Commands (Future)

| Command | Description |
|---------|-------------|
| `what's my day` | Today's schedule overview |
| `block [duration] for [activity]` | Create focus block |
| `when am I free [day]` | Check availability |
| `schedule meeting [details]` | Create calendar event |

## Proton Calendar Integration

API integration pending. Requires:
- Proton Bridge or API access
- CalDAV sync configuration
- Authentication setup

## Time Blocking Philosophy

Based on Sascha's preferences:
- **Early mornings**: Deep work (protect fiercely)
- **Mid-day**: Meetings and collaboration
- **Late afternoon**: Admin and email
- **Evening**: Review and planning

## Notes

Proton Calendar API access needs to be configured. Consider CalDAV integration or n8n workflow as bridge.
