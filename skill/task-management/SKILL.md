---
name: task-management
description: "PARA-based task and project management with Anytype integration. Use when: (1) creating/managing tasks or projects, (2) daily or weekly reviews, (3) prioritizing work, (4) capturing action items, (5) planning sprints or focus blocks, (6) asking 'what should I work on?'. Triggers: task, todo, project, priority, review, focus, plan, backlog, inbox, capture."
compatibility: opencode
---

# Task Management

PARA-based productivity system integrated with Anytype for Sascha's personal and professional task management.

## Quick Reference

| Action | Command Pattern |
|--------|-----------------|
| Quick capture | "Capture: [item]" or "Add to inbox: [item]" |
| Create task | "Task: [title] for [area/project]" |
| Create project | "New project: [title] in [area]" |
| Daily review | "Daily review" or "What's on for today?" |
| Weekly review | "Weekly review" or "Week planning" |
| Focus check | "What should I focus on?" |
| Context batch | "What [area] tasks can I batch?" |

## Anytype Configuration

**Space**: Chiron (create if not exists)

### Types

| Type | PARA Category | Purpose |
|------|---------------|---------|
| `project` | Projects | Active outcomes with deadlines |
| `area` | Areas | Ongoing responsibilities |
| `resource` | Resources | Reference materials |
| `task` | (within Projects/Areas) | Individual action items |
| `note` | (Inbox/Resources) | Quick captures, meeting notes |

### Key Properties

| Property | Type | Used On | Values |
|----------|------|---------|--------|
| `status` | select | Task, Project | `inbox`, `next`, `waiting`, `scheduled`, `done` |
| `priority` | select | Task, Project | `critical`, `high`, `medium`, `low` |
| `area` | relation | Task, Project | Links to Area objects |
| `due_date` | date | Task, Project | Deadline |
| `energy` | select | Task | `high`, `medium`, `low` |
| `context` | multi_select | Task | `deep-work`, `admin`, `calls`, `errands` |

## Core Workflows

### 1. Quick Capture

Minimal friction inbox capture. Process later during review.

```
User: "Capture: Review Q1 budget proposal"

Action:
1. Create note in Anytype with status=inbox
2. Confirm: "Captured to inbox. 12 items pending processing."
```

### 2. Create Task

Full task with metadata for proper routing.

```
User: "Task: Prepare board presentation for CTO Leadership, high priority, due Friday"

Action:
1. Find or create "CTO Leadership" area in Anytype
2. Create task object:
   - name: "Prepare board presentation"
   - area: [CTO Leadership object ID]
   - priority: high
   - due_date: [this Friday]
   - status: next
3. Confirm with task details
```

### 3. Create Project

Projects are outcomes with multiple tasks and a completion state.

```
User: "New project: Launch NixOS Flakes Course in m3ta.dev area"

Action:
1. Find "m3ta.dev" area
2. Create project object:
   - name: "Launch NixOS Flakes Course"
   - area: [m3ta.dev object ID]
   - status: active
3. Prompt: "What are the key milestones or first tasks?"
4. Create initial tasks if provided
```

### 4. Daily Review (Evening)

Run each evening to close the day and prep tomorrow.

**Workflow** - See [references/review-templates.md](references/review-templates.md) for full template.

Steps:
1. **Fetch today's completed** - Celebrate wins
2. **Fetch incomplete tasks** - Reschedule or note blockers
3. **Check inbox** - Quick process or defer to weekly
4. **Tomorrow's priorities** - Identify top 3 for morning focus
5. **Send summary via ntfy** (if configured)

```
User: "Daily review"

Output format:
## Daily Review - [Date]

### Completed Today
- [x] Task 1
- [x] Task 2

### Carried Forward
- [ ] Task 3 (rescheduled to tomorrow)
- [ ] Task 4 (blocked: waiting on X)

### Inbox Items: 5 pending

### Tomorrow's Top 3
1. [Highest impact task]
2. [Second priority]
3. [Third priority]
```

### 5. Weekly Review

Comprehensive PARA review. See [references/para-methodology.md](references/para-methodology.md).

**Workflow**:
1. **Get Clear** - Process inbox to zero
2. **Get Current** - Review each Area's active projects
3. **Get Creative** - Identify new projects or opportunities
4. **Plan Week** - Set weekly outcomes and time blocks

```
User: "Weekly review"

Process:
1. List all inbox items -> prompt to process each
2. For each Area, show active projects and their status
3. Flag stalled projects (no activity 7+ days)
4. Identify completed projects -> move to archive
5. Prompt for new commitments
6. Output weekly plan
```

### 6. Priority Focus

Impact-first prioritization using Sascha's preferences.

```
User: "What should I focus on?"

Logic:
1. Fetch tasks where status=next, sorted by:
   - priority (critical > high > medium > low)
   - due_date (sooner first)
   - energy match (if time of day known)
2. Return top 3-5 with rationale
3. Consider context batching opportunities

Output:
## Focus Recommendations

**Top Priority**: [Task] 
- Why: [Impact statement]
- Area: [Area name]
- Due: [Date or "no deadline"]

**Also Important**:
1. [Task 2] - [brief why]
2. [Task 3] - [brief why]

**Batching Opportunity**: You have 3 [context] tasks that could be done together.
```

### 7. Context Batching

Group similar tasks for focused execution.

```
User: "What admin tasks can I batch?"

Action:
1. Fetch tasks where context contains "admin"
2. Group by area
3. Estimate total time
4. Suggest execution order

Output:
## Admin Task Batch

**Estimated time**: ~45 minutes

1. [ ] Reply to vendor email (CTO Leadership) - 10min
2. [ ] Approve expense reports (CTO Leadership) - 15min  
3. [ ] Update team wiki (CTO Leadership) - 20min

Ready to start? I can track completion.
```

## Notification Integration (ntfy)

Send notifications for:
- Daily review summary (evening)
- Overdue task alerts
- Weekly review reminder (Sunday evening)

Format for ntfy:
```bash
curl -d "Daily Review: 5 completed, 3 for tomorrow. Top priority: [task]" \
  ntfy.sh/sascha-chiron
```

Configure topic in environment or Anytype settings.

## Anytype API Patterns

See [references/anytype-workflows.md](references/anytype-workflows.md) for:
- Space and type setup
- CRUD operations for tasks/projects
- Query patterns for reviews
- Batch operations

## PARA Methodology Reference

See [references/para-methodology.md](references/para-methodology.md) for:
- PARA category definitions
- When to use Projects vs Areas
- Archive criteria
- Maintenance rhythms

## Initial Setup

See [references/anytype-setup.md](references/anytype-setup.md) for:
- Step-by-step Anytype space creation
- Type and property configuration
- Initial Area objects to create
- View setup recommendations
