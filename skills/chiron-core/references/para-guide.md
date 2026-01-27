# PARA Methodology Guide

## What is PARA?

PARA is a productivity framework for organizing digital information:

- **P**rojects - Short-term efforts with deadlines
- **A**reas - Long-term responsibilities (no deadline)
- **R**esources - Topics of interest (reference material)
- **A**rchive - Inactive items (completed, cancelled, on hold)

## Why PARA Works

**Traditional problem**: Information scattered across multiple systems with no clear organization.

**PARA solution**: Single organizing principle based on **actionability** and **time horizon**.

## Detailed Definitions

### Projects (01-projects/)

**Definition**: Short-term efforts that you're working on now with clear goals and deadlines.

**Criteria for a project:**
- Has a clear goal or outcome
- Has a deadline or target date
- Takes effort to complete (not a single task)
- Active - you're working on it now

**Examples**:
- "Launch new website" (deadline: March 15)
- "Complete Q1 budget review" (deadline: Feb 28)
- "Learn Python basics" (deadline: End of month)
- "Organize home office" (deadline: This weekend)

**Project structure**:
```
01-projects/[work|personal]/[project-name]/
├── _index.md          # Main project file (MOC)
├── meetings/          # Meeting notes
├── decisions/         # Decision records
└── notes/            # General notes
```

**Project frontmatter**:
```yaml
---
status: active | on-hold | completed
deadline: YYYY-MM-DD
priority: critical | high | medium | low
tags: [work, personal]
---
```

### Areas (02-areas/)

**Definition**: Ongoing responsibilities with no end date. These define your roles in life.

**Criteria for an area:**
- No deadline - ongoing indefinitely
- Represents a responsibility or role
- Requires regular attention
- Contains multiple projects over time

**Examples**:
- "Health" (ongoing, has projects: "Run marathon", "Eat better")
- "Finances" (ongoing, has projects: "Tax preparation", "Investment plan")
- "Professional Development" (ongoing, has projects: "Learn AI", "Get certification")
- "Home & Family" (ongoing, has projects: "Plan vacation", "Renovate kitchen")

**Area structure**:
```
02-areas/[work|personal]/
├── health.md
├── finances.md
├── professional-development.md
└── home.md
```

**Area frontmatter**:
```yaml
---
review-frequency: weekly | biweekly | monthly
last_reviewed: YYYY-MM-DD
health: good | needs-attention | critical
---
```

### Resources (03-resources/)

**Definition**: Topics or themes of ongoing interest. Material you reference repeatedly.

**Criteria for a resource:**
- Reference material, not actionable
- Topic-based organization
- Used across multiple projects/areas
- Has long-term value

**Examples**:
- "Python Programming" (referenced for multiple coding projects)
- "Productivity Systems" (used across work and personal)
- "Cooking Recipes" (referenced repeatedly)
- "Productivity Tools" (knowledge about tools)

**Resource structure**:
```
03-resources/
├── programming/
│   ├── python/
│   ├── nix/
│   └── typescript/
├── tools/
│   ├── obsidian.md
│   ├── n8n.md
│   └── nixos.md
├── productivity/
└── cooking/
```

**Resource frontmatter**:
```yaml
---
type: reference | guide | documentation
tags: [programming, tools]
last_updated: YYYY-MM-DD
---
```

### Archive (04-archive/)

**Definition**: Completed or inactive items. Moved here when no longer active.

**When to archive:**
- Projects completed
- Areas no longer relevant (life change)
- Resources outdated
- Items on hold indefinitely

**Archive structure**:
```
04-archive/
├── projects/
├── areas/
└── resources/
```

## Decision Tree

**When deciding where to put something:**

```
Is it actionable?
├─ Yes → Has a deadline?
│  ├─ Yes → PROJECT (01-projects/)
│  └─ No → AREA (02-areas/)
└─ No → Is it reference material?
   ├─ Yes → RESOURCE (03-resources/)
   └─ No → Is it completed/inactive?
      ├─ Yes → ARCHIVE (04-archive/)
      └─ No → Consider if it's relevant at all
```

## PARA in Action

### Example: "Learn Python"

1. **Starts as** Resource in `03-resources/programming/python.md`
   - "Interesting topic, want to learn eventually"

2. **Becomes** Area: `02-areas/personal/learning.md`
   - "Learning is now an ongoing responsibility"

3. **Creates** Project: `01-projects/personal/learn-python-basics/`
   - "Active goal: Learn Python basics by end of month"

4. **Generates** Tasks:
   - `tasks/learning.md`:
     ```markdown
     - [ ] Complete Python tutorial #learning ⏫ 📅 2026-02-15
     - [ ] Build first project #learning 🔼 📅 2026-02-20
     ```

5. **Archives** when complete:
   - Project moves to `04-archive/projects/`
   - Knowledge stays in Resource

## PARA Maintenance

### Weekly Review (Sunday evening)

**Review Projects:**
- Check deadlines and progress
- Mark completed projects
- Identify stalled projects
- Create new projects from areas

**Review Areas:**
- Check area health (all areas getting attention?)
- Identify areas needing projects
- Update area goals

**Review Resources:**
- Organize recent additions
- Archive outdated resources
- Identify gaps

**Process Inbox:**
- File items into appropriate PARA category
- Create projects if needed
- Archive or delete irrelevant items

### Monthly Review (1st of month)

- Review all areas for health
- Identify quarterly goals
- Plan major projects
- Archive old completed items

### Quarterly Review

- Big picture planning
- Area rebalancing
- Life goal alignment
- System optimization

## Common Questions

**Q: Can something be both a Project and a Resource?**

A: Yes, at different times. Example: "Productivity" starts as a Resource (you're interested in it). When you decide to "Implement productivity system," it becomes a Project. After implementation, best practices become a Resource again.

**Q: How do I handle recurring tasks?**

A: If recurring task supports an Area, keep task in Area file and create Project instances when needed:
- Area: "Health" → "Annual physical" (recurring)
- Project: "Schedule 2026 physical" (one-time action with deadline)

**Q: What about someday/maybe items?**

A: Two approaches:
1. Keep in `tasks/someday.md` with low priority (🔽)
2. Archive and retrieve when relevant (PARA encourages active items only)

**Q: Should I organize by work vs personal?**

A: PARA organizes by actionability, not domain. However, within Projects/Areas/Resources, you can create subfolders:
- `01-projects/work/` and `01-projects/personal/`
- `02-areas/work/` and `02-areas/personal/`

## PARA + Obsidian Implementation

**Wiki-links**: Use `[[Project Name]]` for connections

**Tags**: Use `#work`, `#personal`, `#critical` for filtering

**Dataview queries**: Create dashboard views:
```dataview
LIST WHERE status = "active"
FROM "01-projects"
SORT deadline ASC
```

**Templates**: Use `_chiron/templates/` for consistent structure

**Tasks plugin**: Track tasks within PARA structure

## References

- [Forté Labs - PARA Method](https://fortelabs.com/blog/para/)
- [Building a Second Brain](https://buildingasecondbrain.com/)
- Obsidian Tasks Plugin documentation
- Dataview Plugin documentation
