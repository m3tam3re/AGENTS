# PARA Structure Design for Work Integration

## Vault Root Structure

```
~/CODEX/
├── _chiron/
│   ├── context.md              # Chiron system context
│   └── templates/             # Note templates
│       ├── daily-note.md
│       ├── weekly-review.md
│       ├── project.md
│       ├── meeting.md
│       ├── meeting-transcript.md   # New: For Teams transcripts
│       ├── area.md
│       └── resource.md
│
├── 00-inbox/                    # Quick captures
│   ├── learnings/
│   └── work-captures/
│
├── 01-projects/                 # Active projects
│   ├── work/                    # WORK PROJECTS (10 Basecamp projects)
│   │   ├── _basecamp-activity.md    # Basecamp sync log
│   │   ├── _projects-index.md       # Master index of all work projects
│   │   │
│   │   ├── project-a/                # [PROJECT NAME 1]
│   │   │   ├── _index.md            # Project MOC (links to Basecamp)
│   │   │   ├── meetings/            # Teams meetings
│   │   │   │   ├── standup-20260128.md
│   │   │   │   └── planning-20260125.md
│   │   │   │
│   │   │   ├── decisions/           # Decision records
│   │   │   │   ├── tech-stack-20260120.md
│   │   │   │   └── feature-priority-20260115.md
│   │   │   │
│   │   │   ├── notes/              # Project notes
│   │   │   │   ├── research-api.md
│   │   │   │   └── design-ideas.md
│   │   │   │
│   │   │   └── basecamp-todos.md     # Reference to Basecamp todos
│   │   │
│   │   ├── project-b/                # [PROJECT NAME 2]
│   │   │   ├── _index.md
│   │   │   ├── meetings/
│   │   │   ├── decisions/
│   │   │   ├── notes/
│   │   │   └── basecamp-todos.md
│   │   │
│   │   ├── project-c/                # [PROJECT NAME 3]
│   │   ├── project-d/                # [PROJECT NAME 4]
│   │   ├── project-e/                # [PROJECT NAME 5]
│   │   ├── project-f/                # [PROJECT NAME 6]
│   │   ├── project-g/                # [PROJECT NAME 7]
│   │   ├── project-h/                # [PROJECT NAME 8]
│   │   ├── project-i/                # [PROJECT NAME 9]
│   │   └── project-j/                # [PROJECT NAME 10]
│   │
│   └── personal/                # Personal projects
│       ├── learn-rust/
│       ├── home-office/
│       └── fitness-challenge/
│
├── 02-areas/                    # Ongoing responsibilities
│   ├── work/                     # Work areas
│   │   ├── current-job.md        # Current role and responsibilities
│   │   ├── professional-dev.md   # Learning goals, certifications
│   │   ├── team-management.md    # Team coordination, 1:1s
│   │   ├── company-knowledge.md # Org-specific knowledge
│   │   └── processes.md         # SOPs, workflows
│   │
│   └── personal/                 # Personal areas
│       ├── health.md
│       ├── finances.md
│       ├── relationships.md
│       ├── learning.md
│       └── home.md
│
├── 03-resources/                # Reference material (tool-agnostic + tool-specific)
│   ├── work/                     # Work resources
│   │   ├── wiki-mirror/           # Outline wiki exports (REPLACEABLE)
│   │   │   ├── outline-api-guide.md
│   │   │   ├── outline-deployment-sop.md
│   │   │   ├── outline-monitoring.md
│   │   │   └── _wiki-index.md     # Master wiki index
│   │   │
│   │   ├── teams-archive/         # Teams recordings/notes (REPLACEABLE)
│   │   │   └── _teams-index.md
│   │   │
│   │   ├── basecamp-references/   # Basecamp docs/guides (REPLACEABLE)
│   │   │   └── _basecamp-docs.md
│   │   │
│   │   ├── company-procedures/     # SOPs, processes (KEEP)
│   │   │   ├── code-review.md
│   │   │   ├── deployment.md
│   │   │   └── onboarding.md
│   │   │
│   │   ├── technical-stack/       # Tech documentation (KEEP)
│   │   │   ├── backend.md
│   │   │   ├── frontend.md
│   │   │   └── infrastructure.md
│   │   │
│   │   └── _work-resources-index.md
│   │
│   └── personal/                 # Personal resources
│       ├── recipes.md
│       ├── books.md
│       └── travel.md
│
├── 04-archive/                  # Completed/inactive
│   ├── work/
│   │   ├── old-job-2024/        # Archived employment
│   │   └── projects/              # Completed projects
│   │
│   └── personal/
│       └── projects/
│
├── daily/                       # Daily notes
│   ├── YYYY/
│   │   └── MM/
│   │       └── DD/
│   │           └── YYYY-MM-DD.md
│   └── weekly-reviews/
│       └── YYYY-W##.md
│
└── tasks/                       # Task management
    ├── inbox.md                  # All incoming tasks
    ├── recurring.md              # Recurring tasks
    └── someday.md               # Backlog items
```

---

## Work Project Template

Each of the 10 Basecamp projects should follow this structure:

### 1. Project _index.md (MOC)

```markdown
---
title: "[Project Name]"
status: active | on-hold | completed
deadline: YYYY-MM-DD
priority: critical | high | medium | low
source: basecamp
basecamp_id: [BC_PROJECT_ID]
basecamp_url: [BC_PROJECT_URL]
tags: [work, basecamp, active]
---

# [Project Name]

## Overview
[Brief description of project goals and scope]

## Basecamp Link
[View in Basecamp](basecamp_url)

## Related Areas
- [[current-job]]
- [[team-management]]

## Resources
- [[outline-api-guide]]
- [[technical-stack-backend]]

## Quick Links
- [ ] Basecamp Todos
- [ ] Basecamp Messages
- [ ] Teams Channel
- [ ] Wiki Documentation

## Notes
- [ ] Latest update (YYYY-MM-DD): [Summary]
- [ ] Latest update (YYYY-MM-DD): [Summary]

## Sub-Projects/Milestones
- [ ] Milestone 1
- [ ] Milestone 2
- [ ] Milestone 3
```

### 2. meetings/ folder

Naming pattern: `[type]-YYYYMMDD.md`

Example: `standup-20260128.md`, `planning-20260125.md`, `review-20260120.md`

### 3. decisions/ folder

Naming pattern: `[topic]-YYYYMMDD.md`

Example: `tech-stack-choice-20260120.md`, `feature-priority-20260115.md`

### 4. notes/ folder

Free-form project notes. Organize by topic or date.

Example: `research-api.md`, `design-ideas.md`, `bug-analysis.md`

---

## Tool-Specific vs Tool-Agnostic Folders

### Keep These (Tool-Agnostic)
```
~/CODEX/
├── 02-areas/work/           # Job-specific knowledge (stays with you)
├── 03-resources/work/
│   ├── company-procedures/   # Your documented processes
│   ├── technical-stack/       # Tech knowledge
│   └── learnings/          # What you learned
└── 01-projects/work/         # Project structure (stays)
```

### Replace These (Tool-Specific)
```
~/CODEX/03-resources/work/
├── wiki-mirror/           # Delete when switching jobs (Outline)
├── teams-archive/         # Delete when switching jobs (Teams)
├── basecamp-references/   # Delete when switching jobs (Basecamp)
└── [other-tools]/        # Delete when switching jobs
```

---

## Master Index Files

### _projects-index.md

```markdown
# Work Projects Index

Last updated: YYYY-MM-DD

## Active Projects (10 total)

| Project | Status | Deadline | Priority | Basecamp |
|---------|--------|-----------|-----------|-----------|
| [[project-a]] | Active | 2026-03-15 | High | [Link] |
| [[project-b]] | On Hold | 2026-04-01 | Medium | [Link] |
| [[project-c]] | Active | 2026-02-28 | Critical | [Link] |
| ... | ... | ... | ... | ... |

## By Priority

### Critical (2 projects)
- [[project-c]]
- [[project-g]]

### High (5 projects)
- [[project-a]]
- [[project-d]]
- [[project-f]]
- [[project-h]]
- [[project-j]]

### Medium (3 projects)
- [[project-b]]
- [[project-e]]
- [[project-i]]

## By Deadline

### Due This Week
- [[project-a]] (2026-02-01)

### Due Next Week
- [[project-c]] (2026-03-15)

### Due This Month
- [[project-b]] (2026-04-01)
```

### _basecamp-activity.md

```markdown
# Basecamp Activity Log

Last sync: YYYY-MM-DD HH:mm

## Today (YYYY-MM-DD)
- [10:30] Created todo: "Implement feature X" in project-a
- [11:45] Completed todo: "Review PR #123" in project-c
- [14:00] Comment added to "API Design" message in project-a

## Yesterday (YYYY-MM-DD)
- [09:00] Created card: "Bug fix investigation" in project-b
- [16:30] Completed todo: "Update documentation" in project-g

## This Week
- Total todos created: 23
- Total todos completed: 18
- Total messages: 5
- Active projects: 10

## Quick Stats
- Project with most activity: [[project-a]] (8 items)
- Overdue todos: 3
- Cards in review: 5
```

---

## Migration Guide (Job Switch)

When switching jobs:

### Step 1: Archive Current Work
```bash
# Move entire work structure to archive
mv ~/CODEX/01-projects/work/ ~/CODEX/04-archive/work/old-job-2024/

# Archive work areas (optional, if job-specific)
mv ~/CODEX/02-areas/work/ ~/CODEX/04-archive/work/areas-old-job/

# Archive tool-specific resources
rm -rf ~/CODEX/03-resources/work/wiki-mirror/
rm -rf ~/CODEX/03-resources/work/teams-archive/
rm -rf ~/CODEX/03-resources/work/basecamp-references/
```

### Step 2: Clean Areas (Keep What's Generic)
```bash
# Keep professional-dev.md (generic learning)
# Keep processes.md (if generic)
# Delete job-specific files in 02-areas/work/
rm ~/CODEX/02-areas/work/current-job.md
rm ~/CODEX/02-areas/work/team-management.md
rm ~/CODEX/02-areas/work/company-knowledge.md
```

### Step 3: Set Up New Job
```bash
# Create new work project structure
mkdir -p ~/CODEX/01-projects/work/
mkdir -p ~/CODEX/01-projects/work/_basecamp-activity.md
mkdir -p ~/CODEX/01-projects/work/_projects-index.md

# Create new work areas
echo "---\ntitle: \"Current Job\"\nstatus: active\n---\n# Current Job\n\n## Role\n[Your role]\n\n## Responsibilities\n- [Responsibility 1]\n- [Responsibility 2]\n" > ~/CODEX/02-areas/work/current-job.md

# Set up new tool folders
mkdir -p ~/CODEX/03-resources/work/wiki-mirror/
mkdir -p ~/CODEX/03-resources/work/teams-archive/
mkdir -p ~/CODEX/03-resources/work/basecamp-references/
```

### Step 4: Import Basecamp Projects
Use `basecamp` skill:
```
User: "Show my Basecamp projects"
# Review 10 projects

User: "Create project notes for all Basecamp projects"
# Generates _index.md for each project
# Populates _projects-index.md
```

### Step 5: Configure n8n Workflows
- Update Basecamp webhook URLs
- Configure Outline API for new job
- Update Teams transcript webhook
- Test all automations

---

## Implementation Checklist

### Initial Setup (One-time)
- [ ] Create directory structure in ~/CODEX/
- [ ] Create _projects-index.md template
- [ ] Create _basecamp-activity.md
- [ ] Configure basecamp skill with project IDs
- [ ] Set up n8n workflows
- [ ] Configure Outline MCP server
- [ ] Create meeting-transcript.md template

### Ongoing Maintenance
- [ ] Weekly: Review project status and update _projects-index.md
- [ ] Weekly: Archive completed projects to 04-archive/
- [ ] Weekly: Process inbox items
- [ ] Weekly: Review _basecamp-activity.md
- [ ] Monthly: Review 02-areas/work/ health

### Job Switch (When needed)
- [ ] Archive 01-projects/work/ to 04-archive/work/
- [ ] Archive tool-specific resources (wiki-mirror, teams-archive, basecamp-references/)
- [ ] Clean up job-specific areas
- [ ] Set up new project structure
- [ ] Import new Basecamp projects
- [ ] Configure new tool integrations
