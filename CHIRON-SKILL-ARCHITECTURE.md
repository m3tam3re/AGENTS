# Chiron Skill Architecture for Opencode

**Version:** 1.0
**Date:** 2026-01-27
**Status:** Architecture Design (Pre-Implementation)

---

## Executive Summary

This document defines the skill architecture for adapting the Chiron productivity system from Claude Code to Opencode. Chiron is a PARA-based personal productivity system that uses Obsidian for knowledge management, daily workflows for planning/reflection, and integrates with external tools (Basecamp, n8n, ntfy).

**Key Design Decisions:**

1. **Obsidian-first**: Chiron uses Obsidian Markdown vaults (not Anytype knowledge graphs) - this is a fundamental architectural difference from the existing task-management skill
2. **New skill cluster**: Create 4 new Chiron-specific skills rather than modifying existing stubs
3. **Preserve existing investments**: Basecamp and calendar integrations remain unchanged
4. **Complement, don't replace**: New skills complement existing ones (research, communications, plan-writing)

---

## Skill Overview Table (Command → Skill Mapping)

| Chiron Command | Primary Skill | Secondary Skills | Data Flow |
|----------------|---------------|------------------|------------|
| `/chiron-start` | `chiron-daily-routines` | `calendar-scheduling`, `task-management` | Daily Note ← Calendar + Tasks |
| `/chiron-end` | `chiron-daily-routines` | `reflection`, `task-management` | Daily Note → Reflection → Tasks |
| `/chiron-capture` | `chiron-capture-flows` | `knowledge-management` | Inbox ← Quick Capture |
| `/chiron-task` | `chiron-capture-flows` | `basecamp` (optional) | Tasks Inbox ← User Input |
| `/chiron-review` | `chiron-daily-routines` | `basecamp`, `task-management` | Weekly Review ← Projects + Tasks |
| `/chiron-search` | `chiron-vault-management` | `research` | Search Results ← Vault |
| `/chiron-project` | `chiron-project-workflows` | `basecamp` (optional) | Project Structure ← User Input |
| `/chiron-meeting` | `chiron-capture-flows` | `calendar-scheduling` | Meeting Note ← Calendar |
| `/chiron-learn` | `chiron-vault-management` | `research` | Resource Note ← Research/Content |

---

## Detailed Skill Specifications

### 1. chiron-daily-routines

**Purpose:** Orchestrates morning planning, evening reflection, and weekly review workflows using Obsidian vault.

**Description:** "Daily and weekly productivity workflows with Obsidian integration. Use when: (1) starting the day, (2) ending the day, (3) running weekly review, (4) planning time blocks, (5) reviewing progress. Triggers: morning routine, daily planning, evening reflection, weekly review, what did I do today, plan my week."

**Responsibilities:**

#### Morning Routine (`/chiron-start`)
- Read yesterday's daily note for incomplete items
- Create today's daily note with template
- Pull calendar events (via calendar-scheduling integration)
- Identify top 3 priorities
- Check blocked/waiting items
- Generate morning briefing with Chiron personality

**Example User Interaction:**
```
User: "Start my day"
Agent: "🏛️ CHIRON'S MORNINGBRIEFING
══════════════════════════════

📅 Heute: 2026-01-27

⚔️ HEUTIGE QUESTS
1. Review Q1 budget proposal (due today)
2. Prepare board presentation materials
3. Team 1:1 with Sarah at 14:00

📆 TERMINE
• 10:00 - Standup with dev team
• 14:00 - 1:1 with Sarah
• 16:00 - Client call

⚠️ AUFMERKSAMKEIT ERFORDERLICH
• Budget proposal due EOD - 3 hours estimated
• 2 tasks carried over from yesterday

Daily Note created: ~/CODEX/daily/2026/01-january/2026-01-27.md

Mögen deine Kämpfe siegreich sein, Held. 🏛️"
```

#### Evening Reflection (`/chiron-end`)
- Scan today's completed work (git commits, tasks, calendar)
- Update daily note with victories section
- Identify incomplete tasks
- Ask reflection questions (wins, challenges, wisdom)
- Preview tomorrow (calendar, deadlines)
- Save to mem0-memory (optional) for long-term patterns

**Example User Interaction:**
```
User: "End my day"
Agent: "## Daily Review - 2026-01-27

### Completed Today ✅
- [x] Review Q1 budget proposal (submitted 18:45)
- [x] Team standup meeting
- [x] Client call (rescheduled to Friday)

### Carried Forward
- [ ] Prepare board presentation materials (2/5 complete)
- [ ] Follow up with client after call

### Reflection Questions
**What victories did you achieve today?**
→ Budget proposal submitted on time, client relationship strengthened

**What challenges did you face?**
→ Board presentation took longer than expected

**What wisdom did you gain?**
→ Block out 2-hour focus blocks for creative work

### Tomorrow's Preview
Top priority: Complete board presentation slides
Deadlines: None
Calendar: 2 meetings, focus time available

Daily Note updated: ~/CODEX/daily/2026/01-january/2026-01-27.md"
```

#### Weekly Review (`/chiron-review`)
- Collect daily notes from the week
- Process inbox to zero
- Review project status across all areas
- Generate weekly metrics (completed tasks, focus hours)
- Identify stalled projects (7+ days inactive)
- Plan next week's top priorities
- Send summary via ntfy (optional)

**Integration Points:**
- **calendar-scheduling**: Pull calendar events for morning routine
- **basecamp**: Sync project status (optional, via basecamp skill)
- **task-management**: If user uses Anytype for tasks, sync tasks to daily notes
- **reflection**: Use reflection skill for structured question flow
- **mem0-memory**: Save patterns and insights from reflections

---

### 2. chiron-capture-flows

**Purpose:** Quick capture workflows for tasks, notes, ideas, and meeting notes to Obsidian inbox.

**Description:** "Quick capture workflows for Obsidian inbox. Use when: (1) capturing thoughts quickly, (2) adding tasks, (3) recording meeting notes, (4) saving ideas, (5) learning something new. Triggers: capture, quick note, add task, meeting notes, remember this, learned that."

**Responsibilities:**

#### Quick Capture (`/chiron-capture`)
- Parse input for type (task, idea, note, learning)
- Extract tags and metadata
- Format with timestamp
- Append to appropriate inbox file:
  - Tasks → `~/CODEX/tasks/inbox.md`
  - Notes/Ideas → `~/CODEX/00-inbox/quick-capture.md`
- Provide confirmation with count

**Example User Interaction:**
```
User: "Capture: Review Q1 budget proposal, needs attention"
Agent: "Captured to inbox.

Type: Task
Inbox: ~/CODEX/tasks/inbox.md
Tags: #work #priority

Content added:
- [ ] Review Q1 budget proposal #work #priority 📅 2026-01-27

7 items pending in tasks inbox."
```

#### Add Task (`/chiron-task`)
- Parse description for metadata (due date, priority, tags)
- Determine context (#work vs #personal)
- Format in Obsidian Tasks plugin format:
  ```markdown
  - [ ] Task description #tag ⏫ 📅 YYYY-MM-DD
  ```
- Save to `~/CODEX/tasks/inbox.md`
- Confirm with task details

**Example User Interaction:**
```
User: "Task: Prepare board presentation for CTO Leadership, high priority, due Friday"
Agent: "Task created.

Inbox: ~/CODEX/tasks/inbox.md

- [ ] Prepare board presentation for CTO Leadership #work ⏫ 📅 2026-01-31

8 items pending in tasks inbox. Process during daily review."
```

#### Meeting Notes (`/chiron-meeting`)
- If user provides title: Create structured meeting note from template
- If user provides notes: Parse for participants, action items, decisions
- Save to `~/CODEX/00-inbox/meetings/` or project-specific folder
- Extract action items → create tasks

**Example User Interaction:**
```
User: "Meeting notes with Sarah about Q1 roadmap"
Agent: "Created meeting note: ~/CODEX/00-inbox/meetings/2026-01-27-sarah-q1-roadmap.md

---
# Meeting: Q1 Roadmap Discussion
**Date:** 2026-01-27
**Participants:** Sascha, Sarah

## Agenda
- [ ] Review Q1 milestones
- [ ] Resource allocation discussion
- [ ] Timeline confirmation

## Notes
[User enters notes...]

## Action Items
- [ ] Finalize resource allocation (Sarah) - Due Feb 1
- [ ] Update project timeline - Due Feb 3

Extracted 2 action items to tasks inbox."
```

#### Learning Capture (`/chiron-learn`)
- Determine if input is topic (short) or content (long)
- If topic: Search existing notes, suggest connections
- If content: Format as resource note
- Save to `~/CODEX/03-resources/learning/` or topic-specific folder
- Link to related notes using WikiLinks

**Example User Interaction:**
```
User: "Learn: NixOS flakes vs channels"
Agent: "Created learning note: ~/CODEX/03-resources/programming/nix/nixos-flakes-vs-channels.md

---
# NixOS Flakes vs Channels

## Overview
[Content...]

## Key Differences
- [Point 1]
- [Point 2]

## Related Notes
- [[nixos-setup]]
- [[nixos-configuration]]

Linked to 2 existing notes."
```

**Integration Points:**
- **basecamp**: Option to sync tasks to Basecamp (via basecamp skill)
- **calendar-scheduling**: Pull meeting context from calendar
- **knowledge-management**: Use for organizing captured notes after processing
- **task-management**: If user maintains Anytype, offer bidirectional sync

---

### 3. chiron-vault-management

**Purpose:** Manages Obsidian vault structure, search, and organization using PARA methodology.

**Description:** "Obsidian vault management with PARA methodology. Use when: (1) searching knowledge base, (2) organizing notes, (3) creating new resources, (4) maintaining vault structure, (5) finding related content. Triggers: search vault, find notes, organize resources, PARA organization, vault structure."

**Responsibilities:**

#### Search (`/chiron-search`)
- Parse search intent:
  - Task search → search for `- [ ]` pattern
  - Tag search → filter by `#tag`
  - Recent search → filter by date (today, yesterday, this week)
  - Full-text → use ripgrep (`rg`) across vault
- Group results by relevance
- Provide context snippets
- Offer follow-up actions

**Example User Interaction:**
```
User: "Search vault for budget"
Agent: "Found 12 results in ~/CODEX:

### Tasks (3)
- [ ] Review Q1 budget proposal #work ⏫ (tasks/inbox.md)
- [ ] Approve Q2 budget #finance 🔼 (02-areas/finance.md)
- [x] Finalize 2025 budget #work (04-archive/projects/annual-budget.md)

### Notes (5)
- [[Q1 Budget Proposal]] (01-projects/work/q1-budget/_index.md)
- [[Budget Planning Process]] (03-resources/finance/budget-process.md)
...

### Related by Tag: #finance (4)
- [[Budget Planning Process]]
- [[Financial Tracking]]
...

Follow-up actions:
1. Open budget proposal note
2. Create task from search result
3. Search for more results

What would you like to do?"
```

#### PARA Structure Management
- Validate vault structure matches PARA (00-inbox, 01-projects, 02-areas, 03-resources, 04-archive)
- Create new project folders with standard structure:
  ```
  01-projects/[work|personal]/[project-name]/
  ├── _index.md
  ├── meetings/
  ├── decisions/
  └── notes/
  ```
- Create area notes with ongoing responsibilities
- Organize resources by topic hierarchy
- Archive completed projects

#### Create Resource (`/chiron-resource`)
- Determine resource type (code concept, tool, person, article)
- Create note with appropriate template
- Add to PARA Resources structure
- Link to related notes

**Example User Interaction:**
```
User: "Create resource for Obsidian Tasks plugin"
Agent: "Created resource note: ~/CODEX/03-resources/tools/obsidian-tasks.md

---
# Obsidian Tasks Plugin

## Overview
Task management plugin for Obsidian with natural language parsing.

## Key Features
- Task queries with Dataview
- Natural language due dates
- Priority indicators

## Configuration
[Details...]

## References
- [Obsidian Tasks Documentation](https://github.com/obsidian-tasks-group/obsidian-tasks)
- [[task-management-workflow]]

## Usage Examples
[Code snippets...]

Saved to ~/CODEX/03-resources/tools/"
```

**Integration Points:**
- **research**: Use for deep research workflows (references/ stored in vault)
- **knowledge-management**: Complement with Anytype if user maintains parallel systems
- **mem0-memory**: Store high-value insights for persistent recall

---

### 4. chiron-project-workflows

**Purpose:** Project creation, management, and synchronization workflows.

**Description:** "Project workflows with PARA methodology and Basecamp integration. Use when: (1) creating new projects, (2) managing project structure, (3) syncing projects to Basecamp, (4) reviewing project status, (5) archiving completed projects. Triggers: new project, create project, project structure, sync project to basecamp, project status."

**Responsibilities:**

#### Create Project (`/chiron-project`)
- Parse project name and type (--work, --personal)
- Create project folder structure
- Create `_index.md` with project metadata
- Ask for initial tasks/milestones
- Prompt: "Sync to Basecamp?" (optional)

**Example User Interaction:**
```
User: "Create project: Launch NixOS Flakes Course in work"
Agent: "Created project structure:

📁 ~/CODEX/01-projects/work/launch-nixos-flakes-course/
├── _index.md
├── meetings/
├── decisions/
└── notes/

Project index created:
---
# Launch NixOS Flakes Course

**Created:** 2026-01-27
**Status:** Active
**Area:** [[m3ta-dev]]

## Overview
[Description...]

## Milestones
- [ ] Course outline
- [ ] Video recordings
- [ ] Platform setup
- [ ] Launch

## Resources
[Links...]

Would you like to add initial tasks or sync to Basecamp?"
```

#### Project Status Review
- Show project dashboard with progress
- Identify blocked/stalled items
- Calculate completion percentage
- Highlight overdue milestones

#### Sync to Basecamp
- Parse project structure for tasks
- Create Basecamp todosets/cards via basecamp skill
- Maintain bidirectional reference links
- Sync status updates

**Example User Interaction:**
```
User: "Sync Launch NixOS Flakes Course to Basecamp"
Agent: "Found 8 tasks in project.

Basecamp target: [Select project]
1. Q2 Training Program
2. m3ta.dev Projects
3. Website Redesign

Choose destination (1-3): "

User: "2"
Agent: "Synced 8 tasks to m3ta.dev Projects.

Created todo list: 'NixOS Flakes Course'
- [ ] Course outline (due Feb 15)
- [ ] Video recordings (due Feb 28)
- [ ] Platform setup (due Feb 10)
- [ ] Launch (due Mar 1)

View in Basecamp: [Link]"
```

#### Archive Project
- Move project to `04-archive/projects/`
- Update project status to "Archived"
- Create archive note with final summary
- Reference in area overview

**Integration Points:**
- **basecamp**: Primary sync target for work projects
- **plan-writing**: Import project plans as project structure
- **task-management**: Sync tasks to Anytype if user maintains parallel system
- **knowledge-management**: Archive project knowledge as resources

---

## Integration Points & Dependencies

### Skill Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────┐
│                     CHIRON SKILL ECOSYSTEM                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │              chiron-daily-routines                        │   │
│  │  (Morning/Evening/Weekly Workflows)                     │   │
│  └────────────┬──────────────────────────────┬───────────────┘   │
│               │                              │                   │
│               ▼                              ▼                   │
│  ┌──────────────────────┐      ┌──────────────────────┐       │
│  │ calendar-scheduling  │      │   basecamp          │       │
│  │ (Existing Skill)    │      │   (Existing Skill)   │       │
│  └──────────────────────┘      └──────────────────────┘       │
│                                                              │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │              chiron-capture-flows                         │   │
│  │  (Task/Note/Meeting/Learning Capture)                   │   │
│  └──────────────────────┬───────────────────────────────────┘   │
│                       │                                      │
│                       ▼                                      │
│          ┌────────────────────────────────┐                     │
│          │   chiron-vault-management   │                     │
│          │   (PARA Structure & Search) │                     │
│          └────────────────────────────────┘                     │
│                       │                                      │
│                       ▼                                      │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │              chiron-project-workflows                     │   │
│  │  (Project Creation & Sync)                            │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                              │
│  External Integrations (Existing Skills):                         │
│  • basecamp           → Work project sync                      │
│  • calendar-scheduling → Meeting/time management                  │
│  • research           → Deep investigation workflows             │
│  • communications     → Email/follow-ups                      │
│  • plan-writing      → Project planning templates              │
│  • mem0-memory       → Long-term pattern storage               │
│  • reflection        → Structured reflection                   │
│                                                              │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Flow Patterns

#### 1. Capture Flow
```
User Input → chiron-capture-flows → Obsidian Inbox
                                      ↓
                              chiron-vault-management (organization)
                                      ↓
                              PARO: Resources/Projects
```

#### 2. Daily Workflow Flow
```
Calendar + Tasks → chiron-daily-routines (morning) → Daily Note
                                                          ↓
                        User executes throughout day
                                                          ↓
                     chiron-daily-routines (evening) → Reflection
                                                          ↓
                                       mem0-memory (optional patterns)
```

#### 3. Project Sync Flow
```
Project Definition → chiron-project-workflows → Obsidian Structure
                                                   ↓
                                          Basecamp (optional sync)
                                                   ↓
                             Bidirectional reference links
```

### Integration with Existing Skills

| Existing Skill | Integration Mode | Data Exchange |
|---------------|------------------|---------------|
| **basecamp** | Optional sync | Projects ↔ Basecamp projects, tasks ↔ todos/cards |
| **calendar-scheduling** | Read-only | Calendar events → daily notes, meetings → calendar |
| **task-management** | Optional parallel | Tasks in both systems (manual sync) |
| **knowledge-management** | Complement | Obsidian ↔ Anytype (if user maintains both) |
| **research** | Integration | Research output → Obsidian resources |
| **communications** | Action items | Meeting notes → follow-up tasks |
| **plan-writing** | Import source | Plan documents → project structure |
| **mem0-memory** | Pattern storage | Reflection insights → long-term memory |
| **reflection** | Structured flow | Daily/weekly reviews → reflection patterns |

---

## Decision Rules for Skill Routing

### Primary Routing Logic

**User Intent Keywords → Skill Selection:**

```
IF user says:
  "start my day", "morning routine", "daily plan", "briefing"
  → chiron-daily-routines (morning workflow)

IF user says:
  "end my day", "evening reflection", "daily review", "what did I do"
  → chiron-daily-routines (evening workflow)

IF user says:
  "weekly review", "week planning", "review my week"
  → chiron-daily-routines (weekly workflow)

IF user says:
  "capture", "quick note", "remember", "save this"
  → chiron-capture-flows (quick capture)

IF user says:
  "add task", "new task", "create task"
  → chiron-capture-flows (task creation)

IF user says:
  "meeting notes", "take notes", "record meeting"
  → chiron-capture-flows (meeting notes)

IF user says:
  "learned", "learn", "studied", "researched"
  → chiron-capture-flows (learning capture)

IF user says:
  "search vault", "find notes", "search knowledge base"
  → chiron-vault-management (search)

IF user says:
  "create project", "new project", "start project"
  → chiron-project-workflows (project creation)

IF user says:
  "project status", "project review", "sync to basecamp"
  → chiron-project-workflows (project management)
```

### Context-Aware Routing

**Contextual Overrides:**

```
IF user is in:
  • Active project directory
  • Daily note open
  • Meeting context

AND request is ambiguous (e.g., "add this to inbox")

THEN:
  → Use context-appropriate skill
  → Prompt: "Add as task or note?"
```

**Multi-Skill Coordination:**

```
IF request spans multiple domains:
  "Add meeting notes and create follow-up tasks"

THEN:
  1. chiron-capture-flows → create meeting note
  2. chiron-capture-flows → extract action items
  3. chiron-project-workflows → associate with project
  4. Confirm: "Created note with 3 tasks. Sync to Basecamp?"
```

### Fallback Logic

**When Intent Is Unclear:**

```
IF skill cannot determine primary intent:

1. Analyze keywords for strongest match
2. Propose top 2-3 options with examples
3. Wait for user clarification
4. Remember preference in mem0-memory (optional)
```

**Example:**
```
User: "Review my week"

Agent: "Would you like to:

1. Run weekly review with metrics and planning
   → chiron-daily-routines

2. Review specific project status
   → chiron-project-workflows

3. Search for notes from this week
   → chiron-vault-management

Which one?"
```

---

## Template & Asset Requirements

### 1. chiron-daily-routines Templates

**Required Assets in `assets/templates/`:**

| Template | Path | Purpose |
|----------|-------|---------|
| `daily-note.md` | `templates/obsidian/daily-note.md` | Morning routine template |
| `weekly-review.md` | `templates/obsidian/weekly-review.md` | Weekly review structure |
| `reflection-questions.md` | `templates/obsidian/reflection-questions.md` | Evening reflection prompts |

**Template: daily-note.md**
```markdown
---
date: {{date}}
created: {{timestamp}}
---

# Daily Note - {{date}}

## 📅 Calendar
{{calendar_events}}

## ⚔️ Today's Quests (Top 3)
1. [ ]
2. [ ]
3. [ ]

## ✅ Victories
[Fill out during evening review]

## 📝 Notes
{{notes}}

## 🔄 Carried Forward
{{incomplete_tasks}}

## 💡 Tomorrow's Preview
- Primary quest:
- Deadlines:
```

**Template: weekly-review.md**
```markdown
---
week: {{week_number}}
year: {{year}}
review_date: {{date}}
---

# Weekly Review - Week {{week_number}}, {{year}}

## 📊 Metrics
- Tasks completed: {{completed_count}}
- Focus hours: {{focus_hours}}
- Meetings: {{meeting_count}}
- New captures: {{capture_count}}

## 🏆 Top 3 Wins
1. [ ]
2. [ ]
3. [ ]

## ⚠️ Challenges
- [ ]

## 💡 Key Learnings
- [ ]

## 📋 Project Status Review
{{project_overview}}

## 🗂️ Inbox Processing
{{inbox_items}}

## 🎯 Next Week Priorities
1. [ ]
2. [ ]
3. [ ]
```

### 2. chiron-capture-flows Templates

**Required Assets:**

| Template | Path | Purpose |
|----------|-------|---------|
| `meeting-note.md` | `templates/obsidian/meeting-note.md` | Structured meeting notes |
| `learning-note.md` | `templates/obsidian/learning-note.md` | Learning/resource notes |
| `task-format.md` | `templates/obsidian/task-format.md` | Obsidian Tasks plugin format |

**Template: meeting-note.md**
```markdown
---
date: {{date}}
title: {{meeting_title}}
type: meeting
participants: {{participants}}
project: {{project_link}}
---

# {{meeting_title}}

**Date:** {{date}}
**Participants:** {{participants}}
**Project:** [[{{project_name}}]]

## Agenda
- [ ]
- [ ]
- [ ]

## Notes
{{notes}}

## Decisions
- [ ]
- [ ]

## Action Items
{{action_items}}

## Next Steps
{{next_steps}}
```

**Template: learning-note.md**
```markdown
---
created: {{timestamp}}
type: learning
tags: #learning {{tags}}
---

# {{topic}}

## Overview
{{overview}}

## Key Points
- {{point_1}}
- {{point_2}}
- {{point_3}}

## Questions to Explore
- [ ]
- [ ]

## Related Notes
{{wiki_links}}

## Resources
- [ ]({{url}})
```

### 3. chiron-vault-management Templates

**Required Assets:**

| Template | Path | Purpose |
|----------|-------|---------|
| `project-index.md` | `templates/obsidian/project-index.md` | Project main file |
| `area-index.md` | `templates/obsidian/area-index.md` | Area overview |
| `resource-note.md` | `templates/obsidian/resource-note.md` | Resource references |

**Template: project-index.md**
```markdown
---
created: {{timestamp}}
status: active
type: project
area: {{area_link}}
---

# {{project_name}}

**Created:** {{date}}
**Status:** {{status}}
**Area:** [[{{area_name}}]]
**Deadline:** {{deadline}}

## Overview
{{description}}

## Milestones
- [ ] {{milestone_1}}
- [ ] {{milestone_2}}
- [ ] {{milestone_3}}

## Resources
{{resources}}

## Notes
{{notes}}

## Meetings
{{meetings}}

## Decisions
{{decisions}}
```

**Template: area-index.md**
```markdown
---
type: area
---

# {{area_name}}

## Overview
{{description}}

## Active Projects
{{active_projects}}

## Ongoing Responsibilities
- [ ]
- [ ]
- [ ]

## Resources
{{resources}}

## Archive
{{archived_items}}
```

### 4. chiron-project-workflows Templates

**Required Assets:**

| Template | Path | Purpose |
|----------|-------|---------|
| `project-folder-structure.txt` | `assets/project-structure.txt` | Directory creation |
| `basecamp-sync-template.md` | `templates/basecamp/project-sync.md` | Basecamp sync format |

**Asset: project-folder-structure.txt**
```
01-projects/[work|personal]/[project-name]/
├── _index.md
├── meetings/
├── decisions/
├── notes/
└── resources/
```

### 5. Reference Documentation

**Required in `references/` for each skill:**

| File | Content | Purpose |
|-------|----------|---------|
| `obsidian-tasks-format.md` | Obsidian Tasks syntax | Task format reference |
| `para-methodology.md` | PARA definitions | Structure guidelines |
| `daily-rituals.md` | Morning/evening flows | Workflow details |
| `vault-setup.md` | Obsidian configuration | Installation guide |
| `basecamp-integration.md` | Sync procedures | Integration docs |

---

## Migration Notes (from Existing Skills)

### Skills to Preserve (No Changes)

| Skill | Reason | Action |
|--------|---------|---------|
| `basecamp` | Already implements Basecamp MCP | Keep as-is |
| `calendar-scheduling` | Calendar integration (stub, future work) | Keep as-is |
| `research` | Deep investigation workflows | Keep as-is |
| `communications` | Email management | Keep as-is |
| `brainstorming` | Ideation workflows | Keep as-is |
| `plan-writing` | Project planning templates | Keep as-is |
| `reflection` | Conversation analysis | Keep as-is |
| `mem0-memory` | Persistent memory | Keep as-is |
| `skill-creator` | Meta-skill | Keep as-is |

### Skills to Complement (Optional Parallel Use)

| Existing Skill | Chiron Skill | Relationship |
|---------------|---------------|--------------|
| `task-management` (Anytype-based) | `chiron-capture-flows` (Obsidian-based) | User chooses: single system or parallel sync |
| `knowledge-management` (stub) | `chiron-vault-management` | Existing skill becomes stub for Anytype; Chiron skills handle Obsidian |

### Skills to Update

| Skill | Change | Impact |
|--------|---------|--------|
| `chiron-core` | Replace template content with architecture reference | Skill becomes documentation hub |
| `task-management` | Add note about Obsidian alternative | User awareness of two options |

### Migration Decision Matrix

```
IF user:
  • Already uses Anytype for tasks
  • Wants to maintain existing workflow

THEN:
  • Keep task-management as primary
  • Optionally enable sync between Anytype and Obsidian
  • Use chiron-capture-flows only for notes/ideas

IF user:
  • Starting fresh
  • Prefers Obsidian over Anytype

THEN:
  • Use chiron-capture-flows for tasks
  • Use chiron-daily-routines for workflows
  • Ignore task-management (or archive it)

IF user:
  • Wants both systems
  • Has complex needs (work vs personal)

THEN:
  • Use task-management for work (Anytype + Basecamp)
  • Use chiron skills for personal (Obsidian)
  • Manual cross-reference between systems
```

### Data Migration Paths

**Anytype → Obsidian (if user wants to switch):**

1. Export Anytype to Markdown
2. Convert to Obsidian format (WikiLinks, frontmatter)
3. Organize into PARA structure
4. Update task format to Obsidian Tasks syntax

**Obsidian → Basecamp (work projects only):**

1. Parse project `_index.md` for tasks
2. Call basecamp skill via integration
3. Create todoset or card table
4. Link back to Obsidian project

---

## Implementation Priority

### Phase 1: Core Workflows (High Priority)

1. **chiron-capture-flows** - Foundation for all workflows
   - Quick capture
   - Task creation
   - Meeting notes
   - Learning capture

2. **chiron-daily-routines** - Daily productivity engine
   - Morning routine
   - Evening reflection
   - Basic templates

### Phase 2: Vault Management (Medium Priority)

3. **chiron-vault-management** - Structure and search
   - PARA structure validation
   - Search functionality
   - Resource creation

### Phase 3: Project Workflows (Medium Priority)

4. **chiron-project-workflows** - Project lifecycle
   - Project creation
   - Status review
   - Archive workflows

### Phase 4: Integrations (Low Priority)

5. **Basecamp sync** - Work project integration
6. **Calendar integration** - Meeting context
7. **Mem0 patterns** - Long-term insights

---

## Example User Interactions

### Complete Daily Workflow

```
[Morning]
User: "Start my day"
→ chiron-daily-routines generates morning briefing

[Throughout Day]
User: "Capture: Need to review Q1 budget"
→ chiron-capture-flows adds to tasks inbox

User: "Task: Call client about contract renewal"
→ chiron-capture-flows creates task

User: "Meeting notes: Weekly team sync"
→ chiron-capture-flows creates meeting note, extracts 3 action items

[Evening]
User: "End my day"
→ chiron-daily-routines runs evening reflection
→ Extracts completed tasks from daily note
→ Asks reflection questions
→ Generates tomorrow preview

[Weekly]
User: "Weekly review"
→ chiron-daily-routines collects daily notes
→ Calculates metrics
→ Reviews project status
→ Plans next week
```

### Project Creation & Sync

```
User: "Create project: Launch NixOS Flakes Course in work"
→ chiron-project-workflows creates project structure
→ Prompts for initial tasks

User: "Sync to Basecamp"
→ chiron-project-workflows calls basecamp skill
→ Creates todoset with 8 tasks
→ Links back to Obsidian project

User: "Search vault for NixOS"
→ chiron-vault-management finds 15 results
→ Groups by projects, resources, tasks
→ Suggests opening project index
```

### Learning & Research Flow

```
User: "Learn: NixOS flakes vs channels"
→ chiron-capture-flows creates learning note
→ Links to 3 existing NixOS notes

User: "Research: Best practices for NixOS configuration"
→ research skill gathers information
→ chiron-vault-management creates resource note
→ Links to learning note

User: "Search vault for configuration patterns"
→ chiron-vault-management finds all config notes
→ Shows related by tag: #nix #configuration
```

---

## Technical Considerations

### Obsidian vs Anytype Trade-offs

| Aspect | Obsidian (Chiron Choice) | Anytype (Existing) |
|--------|-------------------------|-------------------|
| **File Access** | Direct Markdown, no API | Requires Anytype API/MCP |
| **Mobile** | Obsidian app (native) | Anytype app (native) |
| **Search** | ripgrep (fast, local) | Graph search (slower, semantic) |
| **Sync** | Syncthing/Git (manual) | Anytype Cloud (automatic) |
| **Structure** | File system (flexible) | Knowledge graph (structured) |
| **Learning Curve** | Steeper (Markdown, plugins) | Easier (visual) |

### Performance Optimization

- **Search**: Use ripgrep for vault-wide searches (fast, low latency)
- **Templates**: Pre-generate common templates, avoid runtime string building
- **Sync**: Batch Basecamp sync operations (minimize API calls)
- **Cache**: Cache daily note path, project list for session

### Error Handling

- **Missing vault**: Prompt user to create ~/CODEX directory
- **Invalid structure**: Suggest running vault initialization script
- **Template errors**: Provide raw format and prompt to fix
- **Sync failures**: Log to daily note, continue with local-only mode

---

## Future Extensions

### Potential New Skills

1. **chiron-automation** - n8n workflow orchestration
2. **chiron-mobile** - Mobile capture workflows (ntfy integration)
3. **chiron-analytics** - Productivity metrics and visualization
4. **chiron-ai-assist** - AI-powered task prioritization

### Integration Opportunities

- **Excalidraw**: Add diagrams to project notes
- **Baserow**: Structured data for project metrics
- **Linear**: Sync work tasks to issue tracker
- **GitHub**: Connect code commits to projects

---

## Conclusion

This architecture provides a comprehensive mapping of Chiron's Claude Code implementation to Opencode's skill system. The 4 new skills (daily-routines, capture-flows, vault-management, project-workflows) create a cohesive productivity system that:

1. **Preserves Chiron's PARA methodology** - Obsidian structure remains core
2. **Integrates with existing tools** - Basecamp, calendar, research skills
3. **Provides progressive disclosure** - SKILL.md stays lean, details in references/
4. **Supports user choice** - Can use Chiron skills alongside existing Anytype-based workflows
5. **Enables future growth** - Clear integration points for n8n, ntfy, mobile

The next step is implementation of Phase 1 skills (capture-flows and daily-routines) with templates and basic vault management.

---

**Document Status:** Architecture Design Complete
**Next Action:** Begin implementation of chiron-capture-flows skill
**Contact:** Review with Chiron system stakeholder before proceeding
