---
name: quick-capture
description: "Minimal friction inbox capture for Chiron system. Use when: (1) capturing quick thoughts, (2) adding tasks, (3) saving meeting notes, (4) recording learnings, (5) storing ideas. Triggers: capture, quick note, remember, save this, todo, inbox."
compatibility: opencode
---

# Quick Capture

Minimal friction capture to `00-inbox/` for later processing.

## Philosophy

**Capture everything now, organize later.**

The inbox is a temporary holding area. Speed is prioritized over structure. Processing happens during weekly review.

## Capture Types

### Task Capture

**When user says**: "Add task: X", "Remember to X", "Todo: X"

**Steps:**
1. Parse task from request:
   - Task description
   - Priority (if specified)
   - Due date (if specified)
   - Tags (if specified)
2. Create task in `tasks/inbox.md`:
   ```markdown
   - [ ] [Task description] #inbox ⏫ 📅 [date if specified]
   ```
3. Confirm capture

**Examples:**
```
User: "Capture: Review Q1 budget proposal"

Action:
Create task in tasks/inbox.md:
- [ ] Review Q1 budget proposal #inbox ⏫

Confirm: "Captured to inbox. Process during weekly review."
```

```
User: "Add task: Email John about project deadline, due Friday"

Action:
Create task in tasks/inbox.md:
- [ ] Email John about project deadline #inbox 🔼 📅 2026-01-31

Confirm: "Captured to inbox. Process during weekly review."
```

### Note Capture

**When user says**: "Note: X", "Capture this: X", "Remember: X"

**Steps:**
1. Create note in `00-inbox/` with timestamp:
   - Filename: `quick-capture-YYYYMMDD-HHMM.md`
   - Content: Captured text with tags
2. Add frontmatter with creation date
3. Confirm capture

**Examples:**
```
User: "Capture this: Obsidian plugin that syncs with Notion would be amazing. Need to research this."

Action:
Create 00-inbox/quick-capture-20260127-1730.md:
---
title: "Obsidian-Notion sync plugin idea"
tags: [idea, obsidian]
created: 2026-01-27
---

Obsidian plugin that syncs with Notion would be amazing. Need to research this.

Confirm: "Captured to inbox."
```

### Meeting Capture

**When user says**: "Meeting notes: X", "Just finished meeting with X", "Capture meeting about X"

**Steps:**
1. Create meeting note in `00-inbox/meetings/`:
   - Filename: `meeting-[topic]-YYYYMMDD.md`
   - Use meeting template if available
2. Fill in: attendees, key points, action items
3. Link to project if mentioned

**Examples:**
```
User: "Meeting notes: Product roadmap discussion with team"

Action:
Create 00-inbox/meetings/product-roadmap-20260127.md:
---
title: "Product Roadmap Discussion"
date: 2026-01-27
attendees: [Team]
tags: [meeting, work]
---

## Attendees
- [Person 1]
- [Person 2]

## Agenda
- Review Q1 roadmap
- Discuss feature prioritization

## Key Points
- ...

## Action Items
- [ ] Create JIRA tickets for Q1 features
- [ ] Schedule follow-up with design team
- [ ] Update stakeholders

Confirm: "Captured meeting notes to inbox."
```

### Learning Capture

**When user says**: "Learned X", "Discovery: X", "Insight: X"

**Steps:**
1. Create learning note in `00-inbox/`:
   - Filename: `learning-[topic]-YYYYMMDD.md`
   - Content: What was learned, context, applications
2. Add tags: `#learning`, `#[domain]`
3. Confirm capture

**Examples:**
```
User: "Learned: Git rebase vs merge - use rebase for local history, merge for shared branches"

Action:
Create 00-inbox/learning-git-rebase-merge-20260127.md:
---
title: "Git: Rebase vs Merge"
tags: [learning, git, programming]
created: 2026-01-27
---

## Learning
Use rebase for local history cleanup, merge for shared branches.

## Context
Reading about Git workflows. Confusion about when to use each.

## Applications
- Local feature branch before push: Rebase
- Updating shared branch: Merge
- Cleaning up history: Rebase -i

Confirm: "Captured learning to inbox."
```

### Web Clip / Reference Capture

**When user says**: "Save this article: URL", "Clip this: X", "Reference: X"

**Steps:**
1. Create reference in `00-inbox/web-clips/`:
   - Filename: `[source]-[topic].md`
   - Content: Title, URL, summary, key takeaways
2. Add tags for topic and source
3. Link to relevant areas/projects if obvious

**Examples:**
```
User: "Save this: article about PARA method from Forte Labs"

Action:
Create 00-inbox/web-clips/forte-labs-para.md:
---
title: "PARA Method - Forte Labs"
source: https://fortelabs.com/blog/para/
tags: [productivity, para, organization]
saved: 2026-01-27
---

## Source
[PARA Method - Forte Labs](https://fortelabs.com/blog/para/)

## Summary
Comprehensive guide to PARA method for organizing digital information. Projects, Areas, Resources, Archive.

## Key Takeaways
- Projects = short-term, deadline-driven
- Areas = ongoing responsibilities
- Resources = reference material
- Archive = completed/inactive

## Applications
- Reorganize my knowledge vault using PARA
- Clear out old inbox items

Confirm: "Saved reference to inbox."
```

## File Structure

```
00-inbox/
├── quick-capture-*.md        # Quick thoughts and notes
├── meetings/                   # Unprocessed meeting notes
│   └── meeting-*.md
├── web-clips/                 # Saved articles and references
│   └── [source]-*.md
└── learnings/                  # Captured learnings
    └── learning-*.md
```

## Processing Inbox

**Trigger**: During weekly review (`/chiron-review`)

**Processing workflow:**

1. **For each item in inbox:**
   - Read content
   - Determine PARA category (consult `chiron-core`)
   - Move to appropriate location

2. **Task processing:**
   - Add to project task list if project-specific
   - Add to area task list if area-specific
   - Keep in `tasks/inbox.md` if general

3. **Note processing:**
   - Move to `03-resources/` if reference material
   - Move to `01-projects/` if project-specific
   - Move to `02-areas/` if area-specific
   - Archive to `04-archive/` if no longer relevant

4. **Delete irrelevant items**

**Example:**
```
Inbox has:
- Task: "Buy groceries" → Move to 02-areas/personal/health.md
- Note: "Obsidian tips" → Move to 03-resources/tools/obsidian.md
- Task: "Finish project X" → Move to 01-projects/work/project-x/_index.md
- Old reference from 2022 → Move to 04-archive/
```

## Best Practices

### Speed Over Structure
- Don't categorize during capture
- Don't add tags during capture
- Don't create projects during capture
- Focus on getting it out of your head

### Minimal Metadata
- Only add what's immediately obvious
- Date is automatic (filename or frontmatter)
- Don't overthink tags

### Batch Processing
- Process inbox during weekly review
- Don't process individually (except for urgent items)
- Group similar items when organizing

### Urgent Items
- If user specifies "urgent" or "critical":
  - Create directly in appropriate location (not inbox)
  - Add high priority (⏫)
  - Confirm: "This is urgent, created directly in [location]"

## Integration with Other Skills

**Delegates to:**
- `obsidian-management` - File creation and operations
- `chiron-core` - PARA methodology for processing inbox
- `daily-routines` - Inbox processing during weekly review

**Delegation rules:**
- Processing inbox → `daily-routines` (weekly review)
- Moving files → `obsidian-management`
- PARA categorization → `chiron-core`

## Quick Reference

| Capture Type | Command Pattern | Location |
|-------------|-----------------|------------|
| Task | "Capture: [task]" or "Todo: [task]" | tasks/inbox.md |
| Note | "Note: [content]" or "Remember: [content]" | 00-inbox/quick-capture-*.md |
| Meeting | "Meeting notes: [topic]" | 00-inbox/meetings/meeting-*.md |
| Learning | "Learned: [insight]" | 00-inbox/learnings/learning-*.md |
| Reference | "Save: [article]" or "Clip: [URL]" | 00-inbox/web-clips/[source]-*.md |

## Error Handling

### Inbox Directory Not Found
1. Create `00-inbox/` directory
2. Create subdirectories: `meetings/`, `web-clips/`, `learnings/`
3. Confirm structure created

### File Already Exists
1. Add timestamp to filename (if not present)
2. Or append to existing file
3. Ask user which approach

### Processing Conflicts
1. Ask user for clarification on PARA placement
2. Provide options with reasoning
3. Let user choose

## Resources

- `references/inbox-organization.md` - Detailed processing workflows
- `references/capture-formats.md` - Format specifications by type

**Load references when:**
- Detailed processing questions
- Format customization needed
- Troubleshooting organization issues
