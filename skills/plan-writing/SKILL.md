---
name: plan-writing
description: "Transform ideas into comprehensive, actionable project plans with templates. Use when: (1) creating project kickoff documents, (2) structuring new projects, (3) building detailed task breakdowns, (4) documenting project scope and stakeholders, (5) setting up project for execution. Triggers: project plan, kickoff document, plan out, structure project, project setup, create plan for, what do I need to start."
compatibility: opencode
---

# Plan Writing

Transform brainstormed ideas into comprehensive, actionable project plans using modular templates.

## Quick Reference

| Project Type | Templates to Use |
|--------------|------------------|
| Solo, <2 weeks | project-brief, todo-structure |
| Solo, >2 weeks | project-brief, todo-structure, risk-register |
| Team, any size | project-kickoff, stakeholder-map, todo-structure, risk-register |

## Process

### 1. Intake

Gather initial context:
- What project are we planning?
- Check for existing brainstorming output in `docs/brainstorms/`
- If starting fresh, gather basic context first

### 2. Scope Assessment

Ask these questions (one at a time):

1. **Solo or team project?**
   - Solo → lighter documentation
   - Team → need alignment docs (kickoff, stakeholders)

2. **Rough duration estimate?**
   - <2 weeks → skip risk register
   - >2 weeks → include risk planning

3. **Known deadline or flexible?**
   - Hard deadline → prioritize milestone planning
   - Flexible → focus on phased approach

4. **Which PARA area does this belong to?** (optional)
   - Helps categorization and later task-management integration

### 3. Component Selection

Based on scope, select appropriate templates:

```
"Based on [team project, 6 weeks], I'll include:
✓ Project Kickoff (team alignment)
✓ Stakeholder Map (communication planning)
✓ Todo Structure (task breakdown)
✓ Risk Register (duration >2 weeks)

Shall I proceed with this structure?"
```

See [references/component-guide.md](references/component-guide.md) for selection logic.

### 4. Draft Generation

For each selected template:
1. Load template from `assets/templates/`
2. Fill with project-specific content
3. Present each major section for validation
4. Adjust based on feedback

Work through templates in this order:
1. Kickoff/Brief (establishes context)
2. Stakeholders (who's involved)
3. Todos (what needs doing)
4. Risks (what could go wrong)

### 5. Output

Generate final documents:
- Create `docs/plans/<project-name>/` directory
- Write each component as separate file
- Create `index.md` linking all components

```
docs/plans/<project-name>/
├── index.md           # Links to all components
├── kickoff.md         # or brief.md for solo projects
├── stakeholders.md    # if team project
├── tasks.md           # task breakdown
├── risks.md           # if >2 weeks duration
└── updates/           # for future progress updates
    └── YYYY-MM-DD.md
```

### 6. Handoff (Optional)

After plan is complete, offer next steps:

> "Ready to create this project in Basecamp? I can:
> - Create todo lists from the task structure
> - Set up card table columns from phases
> - Add initial cards/todos with due dates"

This triggers the basecamp skill for execution.

## Templates

All templates in `assets/templates/`:

| Template | Purpose | When to Include |
|----------|---------|-----------------|
| project-kickoff.md | Comprehensive 8-section kickoff | Team projects |
| project-brief.md | 1-page summary | Solo or simple projects |
| stakeholder-map.md | Who needs what, when | Team projects |
| risk-register.md | Risks and mitigations | Projects >2 weeks |
| todo-structure.md | Hierarchical task breakdown | Always |
| progress-update.md | Status update template | For ongoing tracking |

## PARA Integration (Optional)

If user wants PARA integration:
1. Prompt for Area assignment (from their defined Areas)
2. Can trigger task-management skill to create Obsidian task entries
3. Include Area reference in kickoff/brief document

This is optional - not all users use PARA.

## Integration with Other Skills

| From | To plan-writing | Output |
|------|-----------------|--------|
| brainstorming | Decision/context | Informs kickoff scope |
| plan-writing | → basecamp | Todo lists, cards |
| plan-writing | → task-management | Obsidian tasks (optional) |

## Example Workflow

```
User: "Create a project plan for launching the Q2 training program"

AI: "I'll help structure this project. First, a few questions:

Is this a solo project or will others be involved?"

User: "Team - 3 people"

AI: "Duration estimate?
a) Less than 2 weeks
b) 2-4 weeks  
c) More than a month"

User: "B - about 3 weeks"

AI: "Got it. For a 3-week team project, I'll include:
✓ Project Kickoff (team alignment)
✓ Stakeholder Map (communication)
✓ Todo Structure (task breakdown)
✓ Risk Register (3 weeks warrants this)

Shall I proceed?"

User: "Yes"

AI: [Proceeds through each template, filling with project details]
```
