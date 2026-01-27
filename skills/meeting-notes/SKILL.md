---
name: meeting-notes
description: "Structured meeting note capture and action item extraction. Use when: (1) taking meeting notes, (2) starting a meeting, (3) processing raw meeting notes, (4) extracting action items. Triggers: meeting, notes, attendies, action items, follow up."
compatibility: opencode
---

# Meeting Notes

Structured meeting note creation with action item tracking for Chiron system.

## Meeting Creation

**When user says**: "Start meeting: X", "Meeting about X", "Take meeting notes for X"

**Steps:**

1. **Determine meeting type**
   - Standup (daily/weekly sync)
   - 1:1 meeting
   - Workshop/brainstorm
   - Decision meeting

2. **Create meeting note using template**
   - Template: `_chiron/templates/meeting.md`
   - Location: Depends on context
     - Project-specific: `01-projects/[work|personal]/[project]/meetings/[topic]-YYYYMMDD.md`
     - Area-related: `02-areas/[area]/meetings/[topic]-YYYYMMDD.md`
     - General: `00-inbox/meetings/[topic]-YYYYMMDD.md`

3. **Fill in sections:**
   - Title, date, time, duration
   - Attendees (names and roles)
   - Agenda (if known in advance)
   - Notes (during or after)
   - Decisions made
   - Action items

4. **Create action item tasks**
   - Extract each action item
   - Create as tasks in note (Obsidian Tasks format)
   - Assign owners and due dates
   - Link to related projects/areas

5. **Link to context**
   - Link to project if meeting was about project
   - Link to area if about area
   - Link to related resources

**Output format:**
```markdown
---
title: "Meeting Title"
date: 2026-01-27
time: "14:00-15:00"
duration: "1 hour"
location: [Zoom/Office/etc.]
attendees: [Person 1, Person 2]
type: [standup|1:1|workshop|decision]
project: [[Project Name]]
tags: [meeting, work]
---

## Attendees
- [Name] - [Role] - [Organization]
- [Name] - [Role] - [Organization]

## Agenda
1. [Item 1]
2. [Item 2]
3. [Item 3]

## Notes

### [Item 1]
- [Key point 1]
- [Key point 2]

### [Item 2]
- [Key point 1]
- [Key point 2]

## Decisions Made
1. [Decision 1] - [reasoning]
2. [Decision 2] - [reasoning]

## Action Items

- [ ] [Action description] #meeting #todo 🔼 👤 @name 📅 YYYY-MM-DD
- [ ] [Action description] #meeting #todo 🔼 👤 @self 📅 YYYY-MM-DD
- [ ] [Action description] #meeting #todo 🔽 👤 @name 📅 YYYY-MM-DD

## Next Steps
- [ ] Schedule follow-up meeting
- [ ] Share notes with team
```

## Processing Raw Notes

**When user says**: "Process these meeting notes", "Clean up meeting notes", [provides raw text]

**Steps:**

1. **Parse raw text for:**
   - Attendees (people mentioned)
   - Action items (next steps, to-dos, action points)
   - Decisions (agreed, decided, resolved)
   - Key topics/themes

2. **Structure into template**
   - Create meeting note with proper sections
   - Extract action items as tasks
   - Identify decisions made

3. **Link to context**
   - Detect mentions of projects/areas
   - Create wiki-links automatically
   - Add appropriate tags

4. **Confirm with user**
   - Show extracted structure
   - Ask for corrections
   - Finalize note

**Example:**
```
User provides raw notes:
"Met with John and Sarah about Q1 roadmap. Decided to prioritize feature A over B. John to talk to engineering. Sarah to create PRD. Next meeting next Tuesday."

Action:
Create meeting note:
---
title: "Q1 Roadmap Discussion"
attendees: [John, Sarah]
type: decision
---

## Decisions Made
1. Prioritize feature A over B - Resource constraints

## Action Items
- [ ] Talk to engineering about timeline #meeting #todo 🔼 👤 @john 📅 2026-02-03
- [ ] Create PRD for feature A #meeting #todo 🔼 👤 @sarah 📅 2026-02-05

## Next Steps
- [ ] Schedule follow-up next Tuesday

Confirm: "Created meeting note with 2 action items assigned to John and Sarah."
```

## Action Item Extraction

**When user says**: "Extract action items", "What are the action items?", [shows meeting note]

**Steps:**

1. **Read meeting note**
2. **Extract action items section**
3. **Parse each action item:**
   - Task description
   - Owner (@mention)
   - Due date (📅 date)
   - Priority (⏫/🔼/🔽)
   - Tags

4. **Present summary:**
   - Total action items
   - Grouped by owner
   - Highlight overdue items

**Output format:**
```markdown
## Action Items Summary

Total: 5 items

### Assigned to @john
- [ ] Task 1 🔼 📅 2026-01-30
- [ ] Task 2 ⏫ 📅 2026-01-28

### Assigned to @sarah
- [ ] Task 3 🔼 📅 2026-02-05

### Unassigned
- [ ] Task 4 🔽

### Overdue
- [ ] Task 2 ⏫ 📅 2026-01-27 (DUE TODAY)
```

## Meeting Follow-Up

**When user says**: "Follow up on meeting", "Check action items", "What's outstanding from X meeting?"

**Steps:**

1. **Find meeting note** (by title, date, or attendee)
2. **Check action items status**
3. **Generate follow-up note**:
   - Completed items
   - Incomplete items
   - Blockers or delays
   - Next actions

**Output format:**
```markdown
# Follow-Up: [Meeting Title]

## Completed Items ✅
- [x] Task 1 - Completed on 2026-01-26
- [x] Task 2 - Completed on 2026-01-27

## Incomplete Items ⏭️
- [ ] Task 3 - Blocked: Waiting for approval
- [ ] Task 4 - In progress

## Recommended Next Actions
- [ ] Follow up with @john on Task 3
- [ ] Check Task 4 progress on Wednesday
- [ ] Schedule next meeting
```

## Meeting Types

### Standup
**Duration**: 15-30 minutes
**Purpose**: Sync, blockers, quick updates
**Template variation**: Minimal notes, focus on blockers and today's plan

### 1:1 Meeting
**Duration**: 30-60 minutes
**Purpose**: In-depth discussion, problem-solving
**Template variation**: Detailed notes, multiple action items

### Workshop/Brainstorm
**Duration**: 1-3 hours
**Purpose**: Idea generation, collaboration
**Template variation**: Focus on ideas, themes, next steps (few action items)

### Decision Meeting
**Duration**: 30-60 minutes
**Purpose**: Make decisions on specific topics
**Template variation**: Emphasize decisions, reasoning, action items

## Integration with Other Skills

**Delegates to:**
- `obsidian-management` - Create/update meeting notes
- `task-management` - Extract action items as tasks
- `chiron-core` - Link to projects/areas
- `calendar-scheduling` - Schedule follow-up meetings
- `quick-capture` - Quick capture mode during meetings

**Delegation rules:**
- File operations → `obsidian-management`
- Task operations → `task-management`
- PARA linkage → `chiron-core`
- Calendar actions → `calendar-scheduling`

## Best Practices

### During Meeting
- Focus on decisions and action items
- Capture attendees and roles
- Note dates/times for reference
- Link to relevant projects immediately

### After Meeting
- Extract action items within 24 hours
- Share notes with attendees
- Schedule follow-ups if needed
- Link note to daily note (tagged with #meeting)

### Action Items
- Be specific (not vague like "follow up")
- Assign owners clearly (@mention)
- Set realistic due dates
- Set appropriate priorities
- Link to related work

## File Naming

**Pattern:** `[topic]-YYYYMMDD.md`

**Examples:**
- `product-roadmap-20260127.md`
- `standup-team-20260127.md`
- `feature-planning-20260127.md`
- `decision-budget-20260127.md`

## Template Variables

**Replace in `_chiron/templates/meeting.md`:**

| Variable | Replacement |
|----------|-------------|
| `{{title}}` | Meeting title |
| `{{date}}` | Meeting date (YYYY-MM-DD) |
| `{{time}}` | Meeting time (HH:mm) |
| `{{attendees}}` | Attendee list |
| `{{type}}` | Meeting type |
| `{{project}}` | Linked project |

## Error Handling

### Ambiguous Attendees
1. Ask for clarification
2. Offer to use generic names (e.g., "Team", "Design Team")
3. Note that owner is unclear

### No Action Items
1. Confirm with user
2. Ask: "Any action items from this meeting?"
3. If no, note as informational only

### Duplicate Meeting Notes
1. Search for similar meetings
2. Ask user: "Merge or create new?"
3. If merge, combine information appropriately

## Quick Reference

| Action | Command Pattern |
|--------|-----------------|
| Start meeting | "Meeting: [topic]" or "Start meeting: [title]" |
| Process notes | "Process meeting notes: [raw text]" |
| Extract actions | "Extract action items from meeting" |
| Follow up | "Follow up on meeting: [title]" or "Check action items" |
| Find meeting | "Find meeting about [topic]" |

## Resources

- `references/meeting-formats.md` - Different meeting type templates
- `references/action-item-extraction.md` - Patterns for detecting action items

**Load references when:**
- Customizing meeting templates
- Processing raw meeting notes
- Troubleshooting extraction issues
