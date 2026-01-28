# Teams Transcript Processing Workflow

Manual workflow for processing Teams meeting transcripts (.docx) into structured meeting notes with action items.

## Table of Contents
1. [Workflow Overview](#workflow-overview)
2. [Prerequisites](#prerequisites)
3. [Step-by-Step Process](#step-by-step-process)
4. [Templates](#templates)
5. [Integration Points](#integration-points)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## Workflow Overview

```
Teams Transcript (.docx)
    ↓
[Manual: Upload transcript]
    ↓
[Extract text content]
    ↓
[AI Analysis: Extract key info]
    ├─→ Attendees
    ├─→ Topics discussed
    ├─→ Decisions made
    └─→ Action items
    ↓
[Create Obsidian meeting note]
    ├─→ Use meeting-notes template
    ├─→ Include transcript summary
    └─→ Extract action items as tasks
    ↓
[Optional: Sync to Basecamp]
    ├─→ Create todos in Basecamp
    └─→ Assign to project
```

---

## Prerequisites

### Tools Needed
- Teams (for recording and downloading transcripts)
- Python with `python-docx` library (for text extraction)
- Obsidian (for storing meeting notes)
- Basecamp MCP (for syncing action items - optional)

### Install Dependencies

```bash
pip install python-docx
```

---

## Step-by-Step Process

### Step 1: Download Teams Transcript

**In Teams**:
1. Go to meeting recording
2. Click "..." (more options)
3. Select "Open transcript" or "Download transcript"
4. Save as `.docx` file
5. Note filename (includes date/time)

**Filename format**: `MeetingTitle_YYYY-MM-DD_HHMM.docx`

### Step 2: Extract Text from DOCX

**Python script** (`/tmp/extract_transcript.py`):

```python
#!/usr/bin/env python3
from docx import Document
import sys
import os

def extract_transcript(docx_path):
    """Extract text from Teams transcript DOCX"""
    try:
        doc = Document(docx_path)
        full_text = '\n'.join([para.text for para in doc.paragraphs])
        return full_text
    except Exception as e:
        print(f"Error reading DOCX: {e}")
        return None

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python extract_transcript.py <transcript.docx>")
        sys.exit(1)

    docx_path = sys.argv[1]
    text = extract_transcript(docx_path)
    
    if text:
        print(text)
        # Optionally save to text file
        output_path = docx_path.replace('.docx', '.txt')
        with open(output_path, 'w') as f:
            f.write(text)
        print(f"\nExtracted to: {output_path}")
```

**Usage**:
```bash
python extract_transcript.py "MeetingName_2026-01-28_1400.docx"
```

### Step 3: AI Analysis of Transcript

**Prompt for AI** (ask your AI assistant):

```
Analyze this Teams meeting transcript and extract:

1. Attendees:
   - Names and roles (if mentioned)
   - Who spoke the most
   - Any key stakeholders

2. Topics Discussed:
   - Main topics (3-5 key items)
   - Brief summary of each topic

3. Decisions Made:
   - Clear decisions with reasoning
   - Format: "Decision: [what] - [reasoning]"
   - Include: "Deferred decisions" if applicable

4. Action Items:
   - Extract specific, actionable tasks
   - Include: owner (@mention), due date (if mentioned), priority (implicit from context)
   - Format: "- [ ] Task description #meeting #todo 🔼 👤 @name 📅 YYYY-MM-DD"

5. Next Steps:
   - Follow-up meetings needed
   - Deliverables expected
   - Blockers or dependencies

Format output in markdown ready for Obsidian meeting template.
```

### Step 4: Create Obsidian Meeting Note

**Ask AI to**:
- Use meeting-notes skill template
- Format extracted content
- Create proper frontmatter
- Add wiki-links to related projects/areas

**Template structure** (from meeting-notes skill):

```markdown
---
title: "[Meeting Title]"
platform: teams
date: YYYY-MM-DD
time: HH:mm-HH:mm
duration: "X minutes"
attendees: [names]
transcript_file: "MeetingName_2026-01-28.docx"
project: [[Project Name]]
tags: [meeting, work, teams]
---

## Attendees
- [Name] - [Role]
- [Name] - [Role]

## Topics Discussed
### [Topic 1]
- [Summary]

### [Topic 2]
- [Summary]

## Decisions Made
1. [Decision] - [Reasoning]
2. [Decision] - [Reasoning]

## Action Items
- [ ] [Action description] #meeting #todo 🔼 👤 @name 📅 YYYY-MM-DD
- [ ] [Action description] #meeting #todo 🔽 👤 @self 📅 YYYY-MM-DD

## Next Steps
- [ ] Schedule follow-up meeting
- [ ] Share notes with team
```

### Step 5: Save to Obsidian

**Location**:
```
~/CODEX/01-projects/work/[project]/meetings/[topic]-YYYYMMDD.md
```

**Ask AI to**:
- Determine project from context
- Create proper folder structure
- Use kebab-case for filename
- Add to project MOC

### Step 6: Sync Action Items to Basecamp (Optional)

**When to sync**:
- Meeting was about a specific project
- Action items have clear owners
- Project uses Basecamp for task tracking

**Ask user**: "Sync these action items to Basecamp?"

**If yes**:
1. Delegate to basecamp skill
2. Ask: "Which Basecamp project?"
3. Create todos with:
   - Proper due dates
   - Assignees (from @mentions)
   - Linked to project
4. Confirm: "Created X todos in [project]"

---

## Templates

### AI Analysis Prompt Template

**Copy this prompt** for consistent results:

```text
You are a meeting analysis assistant. Analyze this Teams meeting transcript and extract:

1. Attendees:
   - List all participants mentioned
   - Identify speakers (who talked most)
   - Note any key stakeholders (managers, decision-makers)

2. Topics Discussed (3-5 main topics):
   For each topic:
   - Title (2-4 words)
   - Summary (2-3 sentences)
   - Time spent on topic (if discernible from transcript)

3. Decisions Made:
   For each decision:
   - Decision statement (what was decided)
   - Reasoning (brief justification)
   - Consensus level (unanimous / majority / proposed)
   - Format as checklist item: `- [ ] Decision: [text]`

4. Action Items:
   For each action item:
   - Description (specific, actionable verb)
   - Owner (@mention if clear, otherwise "Unassigned")
   - Due date (YYYY-MM-DD if mentioned, else "No deadline")
   - Priority (implicit: ⏫ urgent, 🔼 high, 🔽 low)
   - Format: `- [ ] Task #meeting #todo [priority] 👤 @owner 📅 date`

5. Next Steps:
   - Follow-up meetings needed?
   - Deliverables expected?
   - Blockers or dependencies?

**Output Format**: Markdown ready for Obsidian meeting note template.

**Meeting Type**: [standup / 1:1 / workshop / decision]

Transcript:
[PASTE TEAMS TRANSCRIPT HERE]
```

### Meeting Note Template (Enhanced for Teams)

```markdown
---
title: "[Meeting Title]"
platform: teams
date: YYYY-MM-DD
time: HH:mm-HH:mm
duration: "X minutes"
attendees: [Name 1 - Role, Name 2 - Role, ...]
transcript_file: "transcripts/[Topic]-YYYYMMDD.docx"
recording_link: "[Teams recording URL if available]"
project: [[Project Name]]
tags: [meeting, work, teams, transcript]
---

## Attendees

| Name | Role | Company |
|-------|-------|---------|
| [Name] | [Role] | [Company] |
| [Name] | [Role] | [Company] |

## Agenda
[If agenda was known in advance]
1. [Item 1]
2. [Item 2]
3. [Item 3]

## Transcript Summary

[AI-generated summary of transcript]

## Topics Discussed

### [Topic 1]
- [Summary points]
- [Time spent: X minutes]

### [Topic 2]
- [Summary points]
- [Time spent: X minutes]

## Decisions Made

1. ✅ [Decision 1]
   - **Reasoning**: [Why this decision]
   - **Owner**: [Who made decision]
   - **Due**: [If applicable]

2. ✅ [Decision 2]
   - **Reasoning**: [Why this decision]
   - **Owner**: [Who made decision]

### Deferred Decisions
- [ ] [Decision deferred] - [Why deferred, revisit date]

## Action Items

- [ ] [Task 1] #meeting #todo 🔼 👤 @owner 📅 YYYY-MM-DD
- [ ] [Task 2] #meeting #todo ⏫ 👤 @owner 📅 YYYY-MM-DD
- [ ] [Task 3] #meeting #todo 🔽 👤 self 📅 YYYY-MM-DD

### Action Item Summary

| Task | Owner | Due | Priority |
|-------|--------|------|----------|
| [Task 1] | @owner | YYYY-MM-DD | ⏫ |
| [Task 2] | @owner | YYYY-MM-DD | 🔼 |
| [Task 3] | @self | N/A | 🔽 |

## Next Steps

- [ ] Schedule follow-up meeting: [Topic] - [Proposed date]
- [ ] Share notes with: [attendee list]
- [ ] Update project status in Basecamp

## Notes

[Additional notes, observations, or clarifications]

## Links

- 📹 Teams Recording: [URL if available]
- 📄 Transcript: [[transcript_filename]]
- 🗄 Project: [[Project Name]]
- 📄 Related Docs: [[Related Outline Doc]](outline://document/abc123)
```

---

## Integration Points

### With meeting-notes Skill

**Flow**:
```
User: "Process transcript: [file.docx]"

1. Extract text from DOCX
2. Ask AI to analyze transcript
3. AI extracts: attendees, topics, decisions, action items
4. Create meeting note using meeting-notes skill
5. Ask: "Sync action items to Basecamp?"
```

### With basecamp Skill

**Flow** (optional):
```
User: "Yes, sync to Basecamp"

1. Ask: "Which Basecamp project?"
2. List available projects
3. For each action item:
   - create_todo(project_id, todolist_id, content, due_on, assignee_ids)
4. Confirm: "Created X todos in [project]"
```

### With obsidian-management Skill

**Flow**:
```
1. Create meeting note at: 01-projects/work/[project]/meetings/[topic]-YYYYMMDD.md
2. Update project MOC with link to meeting:
   - Add to "Meetings" section in project _index.md
3. If decision made, create in decisions/ folder
4. If applicable, export decision to Outline wiki
```

---

## Best Practices

### During Meeting
1. **Use Teams recording**: Get transcript automatically
2. **Name attendees**: Add their roles to transcript
3. **Speak clearly**: Improves transcript accuracy
4. **Agenda first**: Helps AI structure analysis

### Processing Transcripts
1. **Process quickly**: Within 24 hours while fresh
2. **Clean up text**: Remove filler words (um, ah, like)
3. **Be specific**: Action items must be actionable, not vague
4. **Assign owners**: Every action item needs @mention
5. **Set due dates**: Even if approximate (next week, by next meeting)

### Storage
1. **Consistent location**: All work meetings in project/meetings/
2. **Link everything**: Link to project, related docs, areas
3. **Tag properly**: #meeting, #work, #teams, #transcript
4. **Archive old**: Move completed project meetings to archive/

### Basecamp Sync
1. **Sync important meetings**: Not every meeting needs sync
2. **Use project context**: Sync to relevant project
3. **Verify in Basecamp**: Check todos were created correctly
4. **Follow up**: Check completion status regularly

---

## Troubleshooting

### Transcript Won't Open

**Problem**: DOCX file corrupted or wrong format

**Solution**:
1. Re-download from Teams
2. Try opening in Word first to verify
3. Use alternative: Copy-paste text manually

### AI Misses Action Items

**Problem**: Transcript analysis misses clear action items

**Solution**:
1. Manually add missed items to meeting note
2. Reprompt AI with specific context: "Review transcript again, focus on action items"
3. Check transcript: Was the audio clear?

### Wrong Project Assigned

**Problem**: Meeting note created in wrong project folder

**Solution**:
1. Move file to correct location
2. Update links in project MOCs
3. Use consistent naming conventions

### Basecamp Sync Fails

**Problem**: Todos not created in Basecamp

**Solution**:
1. Check Basecamp MCP is connected
2. Verify project ID is correct
3. Check assignee IDs are valid
4. Check todo list exists in project
5. Retry with fewer items

---

## Example End-to-End

### Input
**Teams transcript**: `api-design-review_2026-01-28_1400.docx`

### AI Output
```markdown
## Attendees
- Alice (Product Owner)
- Bob (Lead Developer)
- Charlie (Tech Lead)
- Sarah (UX Designer)

## Topics Discussed
1. API Authentication Design (20 min)
2. Rate Limiting Strategy (15 min)
3. Error Handling (10 min)

## Decisions Made
1. Use OAuth2 with refresh tokens - Industry standard, better security
2. Implement 1000 req/min rate limit - Based on load tests

## Action Items
- [ ] Create OAuth2 implementation guide #meeting #todo 🔼 👤 @alice 📅 2026-02-05
- [ ] Document rate limiting policy #meeting #todo 🔼 👤 @bob 📅 2026-02-10
- [ ] Update error handling documentation #meeting #todo 🔽 👤 @sarah 📅 2026-02-15
```

### Obsidian Note Created
**File**: `~/CODEX/01-projects/work/api-integration-platform/meetings/api-design-review-20260128.md`

### Basecamp Sync
**Project**: API Integration Platform
**Todos created**: 3
- OAuth2 guide (assigned to Alice, due 2026-02-05)
- Rate limiting (assigned to Bob, due 2026-02-10)
- Error handling (assigned to Sarah, due 2026-02-15)

---

## Automation (Future n8n Implementation)

When n8n is added, automate:

1. **Watch transcript folder**: Auto-trigger on new .docx files
2. **AI auto-analysis**: Use AI API to extract meeting info
3. **Auto-create meeting notes**: Save to Obsidian automatically
4. **Auto-sync to Basecamp**: Create todos for action items
5. **Send notifications**: "Meeting processed, X action items created"

**Workflow diagram**:
```
Teams transcript folder
    ↓ (n8n: Watch folder)
[Trigger: new .docx]
    ↓
[Extract text]
    ↓
[AI Analysis]
    ↓
[Create meeting note]
    ↓
[Sync to Basecamp] (conditional)
    ↓
[Send ntfy notification]
```

---

## Quick Reference

| Action | Tool/Script |
|--------|--------------|
| Download transcript | Teams UI |
| Extract text | python extract_transcript.py |
| Analyze transcript | AI assistant prompt |
| Create meeting note | meeting-notes skill |
| Sync to Basecamp | basecamp skill |
| Store in Obsidian | obsidian-management skill |
| Export decision | outline skill (optional) |
