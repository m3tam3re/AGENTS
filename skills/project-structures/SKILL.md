---
name: project-structures
description: "PARA project initialization and lifecycle management. Use when: (1) creating new projects, (2) reviewing project status, (3) archiving completed projects, (4) structuring project files, (5) linking projects to areas. Triggers: new project, create project, project status, archive project."
compatibility: opencode
---

# Project Structures

PARA-based project creation, organization, and lifecycle management for Chiron system.

## Project Structure

```
01-projects/
├── work/
│   └── [project-name]/
│       ├── _index.md          # Main project file (MOC)
│       ├── meetings/           # Meeting notes
│       ├── decisions/          # Decision records
│       ├── notes/             # General notes
│       └── resources/         # Project-specific resources
└── personal/
    └── [project-name]/
        └── [same structure]
```

## Create New Project

**When user says**: "Create project: X", "New project: X", "Start project: X", "/chiron-project X"

**Steps:**

1. **Parse project request:**
   - Project name
   - Context (work/personal) - ask if unspecified
   - Deadline (if specified)
   - Priority (if specified)
   - Related area (if specified)

2. **Create project directory**:
   - Path: `01-projects/[work|personal]/[project-name]/`
   - Create subdirectories: `meetings/`, `decisions/`, `notes/`, `resources/`

3. **Create _index.md** using template:
   - Template: `_chiron/templates/project.md`
   - Fill in: title, status, deadline, priority, tags
   - Set to `status: active`

4. **Create initial files:**
   - `notes/_index.md` - Project notes index
   - Link to related area if provided

5. **Confirm creation**
   - Show project structure
   - Ask: "Ready to add tasks?"

**Output format:**
```markdown
---
title: "Project Name"
status: active
created: 2026-01-27
deadline: 2026-03-31
priority: high
area: [[Area Name]]
tags: [work, development]
---

## Project Overview
[Brief description of what this project is about]

## Goals
1. [Goal 1]
2. [Goal 2]
3. [Goal 3]

## Success Criteria
- [Criteria 1]
- [Criteria 2]
- [Criteria 3]

## Timeline
- Start: 2026-01-27
- Milestone 1: 2026-02-15
- Milestone 2: 2026-03-15
- Deadline: 2026-03-31

## Tasks
See [[Project Tasks]] for full task list

## Resources
- [[Related Resource 1]]
- [[Related Resource 2]]

## Notes
See [[Project Notes]] for detailed notes

## Decisions
See [[Project Decisions]] for decision history
```

**Example:**
```
User: "Create project: Q1 Budget Review, work, critical, due March 15"

Action:
1. Parse: name="Q1 Budget Review", context="work", priority="critical", deadline="2026-03-15"
2. Create: 01-projects/work/q1-budget-review/
3. Create subdirectories
4. Create _index.md with template filled
5. Confirm: "Created Q1 Budget Review project in work. Ready to add tasks?"
```

## Project Status Review

**When user says**: "Project status", "Review projects", "How's project X going?"

**Steps:**

1. **Find project** (by name or list all)
2. **Read _index.md** for status and metadata
3. **Check task completion**:
   - Read project task list (in `_index.md` or separate file)
   - Calculate: completed vs total tasks
   - Identify overdue tasks
4. **Check milestones**:
   - Compare current date vs milestone dates
   - Identify: on track, behind, ahead
5. **Generate status report**

**Output format:**
```markdown
# Project Status: Q1 Budget Review

## Current Status: 🟡 On Track

## Progress
- Tasks: 8/12 completed (67%)
- Deadline: 2026-03-15 (48 days remaining)
- Priority: Critical

## Milestones
- ✅ Milestone 1: Draft budget (Completed 2026-02-10)
- 🟡 Milestone 2: Review with team (Due 2026-02-20)
- ⏭️ Milestone 3: Final approval (Due 2026-03-15)

## Completed Tasks
- [x] Gather historical data
- [x] Draft initial budget
- [x] Review with finance team

## In Progress
- [ ] Address feedback from finance
- [ ] Prepare presentation for leadership
- [ ] Schedule review meeting

## Overdue
- [ ] Collect final approval signatures ⏫ 📅 2026-02-20 (DUE YESTERDAY)

## Blockers
- Leadership review delayed - waiting for director availability

## Recommendations
1. Follow up with director to schedule review meeting
2. Prioritize final approval task
3. Update team on timeline

## Related Notes
- [[Budget Review Meeting 2026-02-10]]
- [[Finance Team Notes]]
```

## Project Search & List

**When user says**: "List projects", "Show all projects", "Find project X"

**Steps:**

1. **Search project directories**:
   - `rg "- status:" 01-projects --type md -A 2`
   - Extract: title, status, deadline, priority
2. **Group by context** (work/personal)
3. **Sort by priority/deadline**
4. **Present summary**

**Output format:**
```markdown
# Active Projects

## Work Projects (4 active)

| Project | Priority | Deadline | Status | Progress |
|----------|-----------|-----------|----------|-----------|
| Q1 Budget Review | ⏫ Critical | 2026-03-15 | 🟡 On Track |
| Website Relaunch | 🔼 High | 2026-04-30 | 🟡 On Track |
| API Integration | 🔼 High | 2026-02-28 | 🔴 Behind |
| Team Onboarding | 🔽 Low | 2026-03-01 | 🟢 Ahead |

## Personal Projects (2 active)

| Project | Priority | Deadline | Status | Progress |
|----------|-----------|-----------|----------|-----------|
| Learn Rust | 🔼 High | 2026-04-30 | 🟡 On Track |
| Home Office Setup | 🔽 Low | 2026-02-15 | 🟢 Ahead |

## Summary
- Total active projects: 6
- Critical projects: 1
- Behind schedule: 1
- Projects with overdue tasks: 1
```

## Archive Project

**When user says**: "Archive project: X", "Complete project: X", "Project X is done"

**Steps:**

1. **Find project**
2. **Confirm completion**:
   - Show project status
   - Ask: "Is this project complete? All tasks done?"
3. **Update _index.md**:
   - Set `status: completed`
   - Add `completed_date: YYYY-MM-DD`
4. **Move to archive**:
   - Source: `01-projects/[work|personal]/[project]/`
   - Destination: `04-archive/projects/[work|personal]/[project]/`
5. **Update project _index.md** (if exists):
   - Mark project as completed
   - Add to completed list
6. **Confirm archive**

**Output format:**
```markdown
# Project Archived: Q1 Budget Review

## Archive Summary
- Status: ✅ Completed
- Completed date: 2026-03-14 (1 day before deadline)
- Location: 04-archive/projects/work/q1-budget-review/

## Outcomes
- Budget approved and implemented
- $50K savings identified
- New process documented

## Lessons Learned
1. Start stakeholder reviews earlier
2. Include finance team from beginning
3. Automated tools would reduce manual effort

## Related Resources
- [[Final Budget Document]]
- [[Process Documentation]]
```

## Project Notes Management

**When user says**: "Add note to project X", "Project X notes: [content]"

**Steps:**

1. **Find project directory**
2. **Create or update note** in `notes/`:
   - Use timestamp for new notes
   - Add frontmatter with date and tags
3. **Link to _index.md**:
   - Update _index.md if it's the main project file
   - Add to "Notes" section
4. **Confirm**

**Example:**
```
User: "Add note to Q1 Budget Review: Remember to check last year's Q1 for comparison"

Action:
Create 01-projects/work/q1-budget-review/notes/2026-02-01-comparison.md:
---
title: "Comparison with Last Year"
date: 2026-02-01
project: [[Q1 Budget Review]]
tags: [research, historical]
---

Check last year's Q1 budget for comparison points:
- Categories that increased significantly
- One-time expenses from last year
- Adjustments made mid-year

Confirm: "Added note to Q1 Budget Review."
```

## Decision Recording

**When user says**: "Record decision for project X", "Decision: [topic]", "Made a decision: [content]"

**Steps:**

1. **Create decision note** in `decisions/`:
   - Filename: `decision-[topic]-YYYYMMDD.md`
   - Use decision template
2. **Fill in sections**:
   - Decision made
   - Options considered
   - Reasoning
   - Impact
   - Alternatives rejected
3. **Link to _index.md**
4. **Confirm**

**Output format:**
```markdown
---
title: "Decision: Use External Vendor"
date: 2026-02-15
project: [[Q1 Budget Review]]
tags: [decision, vendor, budget]
---

## Decision Made
Use External Vendor for cloud infrastructure instead of building internally.

## Context
Need to decide between internal build vs external purchase for cloud infrastructure.

## Options Considered
1. **Build internally**
   - Pros: Full control, no recurring cost
   - Cons: High initial cost, maintenance burden, 6-month timeline

2. **Purchase external**
   - Pros: Quick deployment, no maintenance, lower risk
   - Cons: Monthly cost, vendor lock-in

## Reasoning
- Timeline pressure (need by Q2)
- Team expertise is in product, not infrastructure
- Monthly cost is within budget
- Vendor has strong SLA guarantees

## Impact
- Project timeline reduced by 4 months
- $120K savings in development cost
- Monthly operational cost: $2,000
- Reduced risk of project failure

## Alternatives Rejected
- Build internally: Too slow and expensive for current timeline

## Next Actions
- [ ] Contract vendor by 2026-02-20
- [ ] Plan migration by 2026-03-01
- [ ] Budget review by 2026-03-15
```

## Project-Area Linking

**When user says**: "Link project to area", "Project X belongs to area Y"

**Steps:**

1. **Read project _index.md**
2. **Find or create area file**:
   - Location: `02-areas/[work|personal]/[area].md`
3. **Update project _index.md**:
   - Add `area: [[Area Name]]` to frontmatter
   - Update links section
4. **Update area file**:
   - Add project to area's project list
   - Link back to project

**Example:**
```
User: "Link Q1 Budget Review to Finances area"

Action:
1. Read 01-projects/work/q1-budget-review/_index.md
2. Read 02-areas/personal/finances.md
3. Update project _index.md frontmatter:
   area: [[Finances]]
4. Update finances.md:
   ## Active Projects
   - [[Q1 Budget Review]]

Confirm: "Linked Q1 Budget Review to Finances area."
```

## Integration with Other Skills

**Delegates to:**
- `obsidian-management` - File operations and templates
- `chiron-core` - PARA methodology guidance
- `task-management` - Project task lists
- `quick-capture` - Quick meeting/decision capture
- `meeting-notes` - Meeting note templates

**Delegation rules:**
- File creation → `obsidian-management`
- Task operations → `task-management`
- PARA guidance → `chiron-core`
- Meeting/decision templates → `meeting-notes`

## Best Practices

### Creating Projects
- Use clear, descriptive names
- Set realistic deadlines
- Define success criteria
- Link to areas immediately
- Create task list early

### Managing Projects
- Update status regularly
- Document decisions
- Track progress visibly
- Celebrate milestones
- Learn from completed projects

### Archiving
- Document outcomes
- Capture lessons learned
- Keep accessible for reference
- Update area health after archive

## Quick Reference

| Action | Command Pattern |
|--------|-----------------|
| Create project | "Create project: [name] [work|personal]" |
| Project status | "Project status: [name]" or "Review projects" |
| Archive project | "Archive project: [name]" or "Complete project: [name]" |
| Add note | "Add note to project [name]: [content]" |
| Record decision | "Decision: [topic] for project [name]" |
| Link to area | "Link project [name] to area [area]" |

## Error Handling

### Project Already Exists
1. Ask user: "Update existing or create variant?"
2. If update: Open existing _index.md
3. If variant: Create with version suffix

### Area Not Found
1. Ask user: "Create new area [name]?"
2. If yes: Create area file
3. Link project to new area

### Archive Conflicts
1. Check if already in archive
2. Ask: "Overwrite or create new version?"
3. Use timestamp if keeping both

## Resources

- `references/project-templates.md` - Project initiation templates
- `references/decision-frameworks.md` - Decision-making tools
- `assets/project-structure/` - Project file templates

**Load references when:**
- Customizing project templates
- Complex decision-making
- Project troubleshooting
