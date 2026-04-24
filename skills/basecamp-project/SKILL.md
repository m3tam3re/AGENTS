---
name: basecamp-project
description: |
  Use when: (1) User wants to create a Basecamp project from an existing plan document,
  (2) User wants to generate a project draft before confirming creation.
  Triggers: "create basecamp project from plan", "setup project in basecamp",
  "basecamp draft", "plan to basecamp", "launch project", "initialize project in basecamp"
compatibility: opencode
---

## Overview

Creates a Basecamp project from a markdown plan document via a human-in-the-loop workflow:
draft first, review, then create. Extracts project structure from the plan, prompts for missing
information, generates a proposal, and creates the full project on confirmation.

## Prerequisites

- Basecamp CLI configured (`basecamp doctor` passes)
- Plans stored as markdown files in `docs/plans/`
- Basecamp skill available for API calls

## Core Workflow

### Step 1: List Plans

List all markdown files in `docs/plans/`:

```bash
ls -1 docs/plans/*.md
```

Present as numbered list for easy selection.

### Step 2: User Selects Plan

User picks a plan by number or filename. Validate the file exists before proceeding.

### Step 3: Parse Plan

Read the selected file and extract available fields:

| Field | Source | Required |
|-------|--------|----------|
| Project name | First heading (`# Title`) or frontmatter `title:` | Yes |
| Description | Frontmatter `description:` or second paragraph | Yes |
| Start date | Frontmatter `start:`, `starts:`, or natural mention | Yes |
| End date | Frontmatter `end:`, `due:`, `deadline:`, or natural mention | Yes |
| Milestones | Sections with dates (e.g., "## Phase 1: Discovery") | Yes |
| Tasks | Bulleted lists under milestones | Yes |
| Assignees | Task modifiers (`@person`, `--assignee`) or frontmatter `team:` | No |
| Documents | Links (`[ref](url)`) or frontmatter `attachments:` | No |

If frontmatter uses a non-standard structure, parse body content and use natural language cues.

### Step 4: Prompt for Missing Information

Prompt one field at a time, in this order:

1. **Project name** — if not found
2. **Start date** — if not found (use "When should this project begin?")
3. **End date** — if not found (use "When should this project be completed?")
4. **Team members** — if not found:
   - First, fetch Basecamp people: `basecamp people list --json`
   - Present as picker with names
   - Fall back to free text if not found
5. **Assignees** — map tasks to team members (one prompt per unassigned task group)
6. **Milestone dates** — if milestones lack dates, prompt for each

For date fields, accept natural language (`"next Monday"`, `"May 15"`, `"2025-06-01"`).

### Step 5: Generate Draft

Compose a structured proposal as markdown:

```markdown
# Project Proposal: {name}

## Overview
{description}

## Timeline
- **Start:** {start_date}
- **End:** {end_date}
- **Duration:** {X weeks/days}

## Milestones

### {Milestone 1}
- Date: {date}
- Tasks:
  - [ ] {task 1}
  - [ ] {task 2}
  - Assigned: @{assignee}

### {Milestone 2}
...

## Team
{list of members}

## Basecamp Structure
| Tool | Content |
|------|---------|
| Message Board | Kickoff message + decision posts |
| To-Dos | Tasks grouped by milestone |
| Documents | Project spec and references |
| Schedule | Milestone dates |
```

### Step 6: Present Draft

Show the draft and offer three options:

1. **Save to markdown** — write to `docs/drafts/{slug}-{timestamp}.md`
2. **Confirm and create** — proceed to project creation
3. **Cancel** — discard and exit

Use inline confirmation: `"Save draft | Create project | Cancel"`

### Step 7: Create Project (on confirm)

Use basecamp skill primitives. Execute in order:

#### 7.1 Create Project

```bash
basecamp projects create "{name}" --json
```

Extract `project_id` from response.

#### 7.2 Add Team Members

```bash
# Look up person IDs first
basecamp people list --jq '.data[] | select(.name == "Name") | .id'

# Add to project
basecamp people add {person_id} --project {project_id}
```

#### 7.3 Create Kickoff Message

```bash
basecamp message "Kickoff" "{description}" --in {project_id} --json
```

#### 7.4 Create To-Do Lists by Milestone

For each milestone:

```bash
# Create todolist for milestone
basecamp todolists create "{Milestone Name}" --in {project_id} --json

# Extract todolist_id, then add tasks
basecamp todo "{task}" --in {project_id} --list {todolist_id} --due {date} --json

# Assign if known
basecamp assign {todo_id} --to {person_id} --in {project_id}
```

#### 7.5 Create Schedule Entries for Milestones

```bash
basecamp schedule create "{Milestone Name}" \
  --starts-at "{date}T09:00:00Z" \
  --all-day \
  --in {project_id} --json
```

#### 7.6 Create Documents (if referenced)

```bash
basecamp files doc create "{doc title}" "{content}" --in {project_id} --json
```

#### 7.7 Pin Kickoff Message

```bash
basecamp messages pin {message_id} --in {project_id}
```

### Step 8: Report Success

Show summary with links:

```
✅ Project created: {name}
🔗 https://3.basecamp.com/{account_id}/buckets/{project_id}

Structure:
  • Message Board: 1 message (kickoff)
  • To-Dos: {N} todolists, {M} tasks
  • Schedule: {X} milestones
  • Documents: {Y} docs
```

## Integration with Basecamp Skill

This skill delegates all Basecamp API calls to the basecamp skill. The basecamp skill
provides:

- `basecamp projects create` — create project
- `basecamp people list/add` — team management
- `basecamp message` — message board posts
- `basecamp todolists create` — milestone grouping
- `basecamp todo` — individual tasks
- `basecamp schedule create` — milestone scheduling
- `basecamp files doc create` — documents

Always use `--json` flag for structured output and `--jq` for filtering.

## Project Structure Mapping

| Plan Element | Basecamp Tool | Notes |
|--------------|---------------|-------|
| Overview/description | Message Board | First message pinned as kickoff |
| Milestones/phases | To-Do Lists | One todolist per milestone |
| Tasks | To-Dos | Under appropriate todolist |
| Task assignees | Todo assignment | Map from plan or prompt |
| Task due dates | Todo due date | Relative to milestone or absolute |
| Milestone dates | Schedule | All-day entries |
| References/docs | Documents | Links or inline content |
| Team | Project members | Add via `people add` |

## Error Handling

| Scenario | Action |
|----------|--------|
| Plan file not found | Show error, re-list plans for selection |
| Basecamp auth failure | Prompt to run `basecamp auth login` |
| Project creation fails | Show error, suggest checking Basecamp limits |
| Person not found | Offer free text entry for name |
| Rate limit (429) | Wait and retry with backoff |
| Invalid date input | Reprompt with format hint |

## Handoff to Other Skills

| Output | Next Skill | Trigger |
|--------|------------|---------|
| Draft saved | — | User chose save option |
| Project created | — | User confirmed |
| Plan not found | brainstorming | "I need to plan this first" |
| Task tracking | basecamp | "Add a todo to this project" |
| Team changes | basecamp | "Add someone to the project" |
