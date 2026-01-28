---
name: daily-routines
description: "Daily and weekly productivity workflows for Chiron system. Use when: (1) morning planning, (2) evening reflection, (3) weekly review, (4) prioritizing work, (5) reviewing progress. Triggers: morning, evening, weekly, review, planning, start day, end day, prioritize."
compatibility: opencode
---

# Daily Routines

Morning planning, evening reflection, and weekly review workflows for the Chiron productivity system.

## Workflows

### Morning Plan (/chiron-start)

**When user says**: "Start day", "Morning planning", "What's today?", "/chiron-start"

**Steps:**

1. **Read yesterday's daily note**
   - File: `~/CODEX/daily/YYYY/MM/DD/YYYY-MM-DD.md`
   - Extract: incomplete tasks, carry-over items

2. **Check today's tasks**
   - Read `~/CODEX/tasks/inbox.md`
   - Scan project files for today's tasks
   - Check calendar (via calendar-scheduling skill)

3. **Prioritize using energy and deadlines**
   - High energy: Complex, creative work (Quadrant 2)
   - Medium energy: Communication, collaboration (Quadrant 3)
   - Low energy: Admin, simple tasks (Quadrant 1 easy wins)

4. **Create today's plan**
   - 3-5 critical tasks (⏫)
   - 5-8 high priority tasks (🔼)
   - Schedule deep work blocks
   - Identify quick wins

5. **Generate daily note using template**
   - Template: `_chiron/templates/daily-note.md`
   - Fill: focus areas, energy blocks, tasks

6. **Ask for confirmation**
   - "Ready to start, or need to adjust?"

**Output format:**
```markdown
# 🌅 Morning Plan - YYYY-MM-DD

## Focus Areas (Top 3)
1. [Priority 1] - [estimated time]
2. [Priority 2] - [estimated time]
3. [Priority 3] - [estimated time]

## Deep Work Blocks
- [9:00-11:00] [Project A]
- [14:00-16:00] [Project B]

## Quick Wins (<15min)
- [Task 1]
- [Task 2]
- [Task 3]

## Meetings
- [10:00-11:00] [Meeting title]

## Carried Over from Yesterday
- [Task from yesterday]

## Inbox to Process
- [X] items in 00-inbox/ to process
```

**Delegation triggers:**
- Calendar operations → `calendar-scheduling`
- Task extraction → `task-management`
- File operations → `obsidian-management`

### Evening Reflection (/chiron-end)

**When user says**: "End day", "Evening review", "How was today?", "/chiron-end"

**Steps:**

1. **Review completed tasks**
   - Check off completed items in daily note
   - Count completed vs planned
   - Identify wins

2. **Capture key learnings**
   - What went well?
   - What didn't?
   - What surprised me?

3. **Identify blockers**
   - What stopped progress?
   - What resources were missing?
   - What context was challenging?

4. **Update daily note**
   - Mark completed tasks
   - Add wins section
   - Add challenges section
   - Add learnings section

5. **Plan tomorrow**
   - Carry over incomplete tasks
   - Identify tomorrow's priorities
   - Note energy levels

6. **Ask reflection question**
   - Example: "What's one thing you're grateful for today?"

**Output format:**
```markdown
# 🌙 Evening Reflection - YYYY-MM-DD

## Tasks Completed
- ✅ [Task 1]
- ✅ [Task 2]
- ⏭️ [Task 3 - carried over]

## Wins
1. [Win 1] - why this matters
2. [Win 2] - why this matters
3. [Win 3] - why this matters

## Challenges
- [Blocker 1] - impact and next step
- [Blocker 2] - impact and next step

## Learnings
- [Learning 1]
- [Learning 2]

## Tomorrow's Focus
1. [Priority 1]
2. [Priority 2]
3. [Priority 3]

## Energy Level
- Morning: ___/10
- Midday: ___/10
- Evening: ___/10

## Reflection
[User's response to reflection question]
```

**Delegation triggers:**
- Task updates → `task-management`
- Note updates → `obsidian-management`

### Weekly Review (/chiron-review)

**When user says**: "Weekly review", "Week planning", "/chiron-review"

**Steps:**

1. **Collect daily notes for the week**
   - Read all daily notes from Monday-Sunday
   - Extract: completed tasks, wins, challenges

2. **Calculate metrics**
   - Tasks completed count
   - Deep work hours (estimate from daily notes)
   - Focus score (self-rated from daily notes)
   - Quadrant distribution (time spent)

3. **Review project status**
   - Scan all projects in `01-projects/`
   - Check: status, deadlines, progress
   - Identify: stalled projects, completed projects, new projects needed

4. **Process inbox**
   - Review items in `00-inbox/`
   - File to appropriate PARA category
   - Delete irrelevant items
   - Create tasks from actionable items

5. **Review area health**
   - Check `02-areas/` files
   - Identify areas needing attention
   - Update area status (health scores)

6. **Identify patterns and trends**
   - Productivity patterns
   - Energy patterns
   - Recurring blockers

7. **Plan next week**
   - Top 3 priorities
   - Key projects to focus on
   - Areas to nurture
   - New habits to try

8. **Generate weekly review note**
   - Template: `_chiron/templates/weekly-review.md`
   - File: `~/CODEX/daily/weekly-reviews/YYYY-W##.md`

**Output format:**
```markdown
# 📊 Weekly Review - W## (Mon DD-MMM to Sun DD-MMM)

## Metrics
- Tasks completed: NN
- Deep work hours: NN
- Focus score average: N.N/10
- Energy score average: N.N/10
- Quadrant distribution: Q1: NN%, Q2: NN%, Q3: NN%, Q4: NN%

## Top 3 Wins
1. [Win 1] - impact and why it mattered
2. [Win 2] - impact and why it mattered
3. [Win 3] - impact and why it mattered

## Key Challenges
- [Challenge 1] - root cause and solution
- [Challenge 2] - root cause and solution

## Patterns & Insights
- Productivity pattern: [observation]
- Energy pattern: [observation]
- Recurring blocker: [observation]

## Project Status

### Completed
- [Project 1] - outcome
- [Project 2] - outcome

### On Track
- [Project 1] - progress, deadline
- [Project 2] - progress, deadline

### Behind Schedule
- [Project 1] - why, what's needed

### New Projects Started
- [Project 1] - goals, deadline
- [Project 2] - goals, deadline

### Stalled Projects
- [Project 1] - why stalled, action needed

## Area Health Review

| Area | Health | Needs Attention |
|-------|--------|----------------|
| Health | N/10 | [specific needs] |
| Finances | N/10 | [specific needs] |
| Work | N/10 | [specific needs] |
| Relationships | N/10 | [specific needs] |
| Learning | N/10 | [specific needs] |

## Inbox Status
- Items processed: NN
- Items remaining: NN
- Filed to Projects: NN
- Filed to Resources: NN
- Archived: NN
- Deleted: NN

## Next Week Priorities

### Top 3
1. [Priority 1] - why critical
2. [Priority 2] - why important
3. [Priority 3] - why important

### Projects to Focus
- [Project 1] - key milestone
- [Project 2] - key milestone
- [Project 3] - key milestone

### Areas to Nurture
- [Area 1] - specific focus
- [Area 2] - specific focus

### New Habits/Experiments
- [Habit 1] - what to try
- [Habit 2] - what to try

## Reflection Question
[Weekly reflection from chiron-core references/reflection-questions.md]
```

**Delegation triggers:**
- PARA organization → `chiron-core`
- Task aggregation → `task-management`
- File operations → `obsidian-management`
- Area review → `chiron-core`

## Integration with Other Skills

**Calls to:**
- `obsidian-management` - Create/update daily notes, templates
- `task-management` - Extract/update tasks
- `chiron-core` - PARA guidance, prioritization, reflection questions
- `calendar-scheduling` - Calendar integration
- `basecamp` - Fetch work todos, check project status
- `outline` - Search wiki for work context

**Delegation rules:**
- User wants to understand PARA → `chiron-core`
- User asks about tasks → `task-management`
- User needs file operations → `obsidian-management`
- User needs calendar → `calendar-scheduling`
- User needs work context → `basecamp`
- User needs wiki knowledge → `outline`

---

## Work Context Integration

### Morning Planning with Work

**Enhanced morning plan workflow:**

```
1. Read yesterday's daily note (personal + work)
2. Check today's work todos:
   - Delegate to basecamp skill: "Show my Basecamp todos due today"
   - Get: project name, task title, due date, assignee
3. Check project status:
   - For each active work project:
     Delegate to basecamp: "What's status of [project]?"
     - Get: completion %, overdue items, next milestones
4. Check wiki for relevant docs:
   - Delegate to outline: "Search Outline for [topic]"
   - Get: related docs, decisions, processes
5. Create integrated morning plan:
   - Personal priorities (from PARA areas)
   - Work priorities (from Basecamp)
   - Meeting schedule (from calendar)
   - Deep work blocks aligned with energy
```

**Morning plan with work context:**
```markdown
# 🌅 Morning Plan - YYYY-MM-DD

## Work Focus (Top 3)
1. [[API Integration Platform]] - Complete OAuth flow (Basecamp: 3 todos today)
2. [[Customer Portal Redesign]] - Review mockups (Basecamp: 2 todos due)
3. [[Data Analytics Dashboard]] - Fix query performance (Basecamp: 1 overdue)

## Personal Focus (Top 2)
1. Health - Morning workout
2. Finances - Review monthly budget

## Deep Work Blocks
- [9:00-11:00] [[API Integration Platform]] (High energy, no meetings)
- [14:00-16:00] [[Customer Portal Redesign]] (Design work)

## Meetings (Work)
- [11:00-12:00] Project Sync (Teams)
- [15:00-16:00] Architecture Review (Zoom)

## Quick Wins (<15min)
- [ ] Respond to urgent emails
- [ ] Update project status in Basecamp
- [ ] Process inbox items (3 items)

## Work Wiki Resources
- 📄 [[OAuth Setup Guide]](outline://doc/abc123) - Reference for project 1
- 📄 [[UI Design System]](outline://doc/def456) - Reference for project 2

## Inbox to Process
- [X] items in 00-inbox/ to process
```

### Evening Reflection with Work

**Enhanced evening reflection workflow:**

```
1. Review completed tasks (personal + work)
   - Check Basecamp: "What did I complete today in Basecamp?"
   - Get: todos marked complete, cards moved to Done
2. Check project progress:
   - For each active project: get status
   - Note: milestones reached, blockers encountered
3. Capture work learnings:
   - Technical learnings (to document later)
   - Process insights (to export to wiki)
   - Team collaboration notes
4. Sync to Obsidian:
   - Create work summary in project notes
   - Export decisions to Outline (if n8n available)
5. Plan tomorrow:
   - Carry over incomplete Basecamp todos
   - Update project priorities based on today's progress
   - Identify personal priorities
```

**Evening reflection with work context:**
```markdown
# 🌙 Evening Reflection - YYYY-MM-DD

## Work Tasks Completed
- ✅ Complete OAuth2 implementation (Basecamp)
- ✅ Review dashboard mockups (Basecamp)
- ✅ Respond to 5 team messages (Teams)
- ⏭️ Fix query performance (carried over)

## Personal Tasks Completed
- ✅ Morning workout
- ✅ Weekly grocery shopping
- ⏭️ Read book chapter (carried over)

## Work Wins
1. OAuth2 implementation complete ahead of schedule
2. Team approved dashboard design direction
3. Documented architecture decision in wiki

## Personal Wins
1. Maintained morning routine
2. Saved money on groceries

## Work Challenges
- Blocker: Waiting for API key from security team (project 1)
- Solution: Scheduled meeting tomorrow to expedite

## Work Learnings
- OAuth2 token refresh pattern is simpler than expected
- Team prefers async communication over meetings

## Project Status Updates

### [[API Integration Platform]]
- Progress: 65% complete
- Completed: OAuth2, token management
- Next: API endpoints implementation
- Deadline: 2026-03-15 (on track)

### [[Customer Portal Redesign]]
- Progress: 40% complete
- Completed: Research, mockups
- Next: User testing
- Deadline: 2026-04-30 (slightly behind)

## Tomorrow's Work Focus
1. Complete API endpoints (OAuth Integration Platform)
2. Conduct user testing (Customer Portal Redesign)
3. Follow up on API key (Security team)

## Tomorrow's Personal Focus
1. Evening workout
2. Update budget with new expenses

## Energy Level
- Morning: 8/10
- Midday: 6/10 (meeting-heavy)
- Evening: 7/10

## Reflection
[User's response]
```

### Weekly Review with Work

**Enhanced weekly review workflow:**

```
1. Collect completed work:
   - Get Basecamp stats: "Show my completed todos this week"
   - Get project milestones achieved
2. Review all projects:
   - For each work project: get status
   - Identify: at risk, on track, completed
3. Review area health:
   - Work areas: current-job, team-management, technical-excellence
   - Check: balance, attention needed
4. Process work inbox:
   - Review 00-inbox/work/ items
   - File to appropriate work projects or areas
5. Plan next week:
   - Work priorities from Basecamp
   - Project milestones to focus on
   - Personal priorities from PARA areas
```

**Weekly review with work context:**
```markdown
# 📊 Weekly Review - W## (Mon DD-MMM to Sun DD-MMM)

## Work Metrics
- Basecamp tasks completed: 23
- Projects progressed: 5
- Meetings attended: 12
- Documents created/updated: 8
- Wiki exports: 3 decisions, 2 guides

## Personal Metrics
- Tasks completed: 15
- Deep work hours: 8
- Focus score: 7.5/10

## Work Wins
1. OAuth2 platform delivered 3 days early
2. Team approved new architecture decision
3. Security audit passed with minor findings

## Personal Wins
1. Maintained workout routine (5/5 days)
2. Read 2 books
3. Saved target amount

## Work Challenges
- Challenge 1: API integration delayed by dependency
   Root cause: Waiting on security team approval
   Solution: Parallel track started for next sprint

## Work Patterns
- Productivity: High on Mon-Tue, dropped on Fri (meeting-heavy)
- Energy: Mornings best for deep work, afternoons for collaboration
- Meetings: Average 2.4/day, need to reduce to 1-2

## Project Status

### Completed
- [[Security Audit 2026]] - Passed with 2 minor findings

### On Track
- [[API Integration Platform]] - 65% complete, on track
- [[Customer Portal Redesign]] - 40% complete, slightly behind
- [[Data Analytics Dashboard]] - 70% complete, ahead of schedule

### Behind Schedule
- [[Documentation Revamp]] - Delayed waiting for SME availability
   Action: Book dedicated session next week

### At Risk
- [[Infrastructure Migration]] - Waiting on approval from ops team
   Action: Escalate to manager tomorrow

### Stalled
- [[Mobile App v2.0]] - On hold, waiting for strategy decision
   Action: Follow up with product owner

## Work Area Health Review

| Area | Health | Needs Attention |
|-------|--------|----------------|
| Current Job | 8/10 | Balance work/personal time better |
| Professional Dev | 9/10 | On track with learning goals |
| Team Management | 7/10 | Follow up on stalled mobile app |
| Company Knowledge | 6/10 | Need to document more processes |
| Technical Excellence | 8/10 | Good code quality, maintain standards |

## Work Inbox Status
- Items processed: 12
- Items remaining: 3
- Filed to Projects: 8
- Filed to Resources: 2
- Archived: 1

## Next Week Work Priorities

### Top 3
1. Complete API endpoints (API Integration Platform) - Critical path
2. User testing feedback (Customer Portal Redesign) - Milestone due
3. Follow up on infrastructure approval (Infrastructure Migration) - Unblock project

### Projects to Focus
- [[API Integration Platform]] - Deliver MVP
- [[Customer Portal Redesign]] - User testing phase
- [[Data Analytics Dashboard]] - Performance optimization

### Work Areas to Nurture
- Team Management - Address mobile app stall
- Company Knowledge - Document 3 key processes
- Technical Excellence - Code review for new OAuth implementation

## Next Week Personal Priorities

### Top 3
1. Health - 5 workouts, meal prep
2. Finances - Monthly review, budget adjustment
3. Learning - Complete TypeScript course module

## Work Habits/Experiments
- Try: 2-hour deep work blocks (instead of 1.5 hours)
- Try: No meeting mornings (9-11 AM protected)
- Try: End-of-day 15-min Basecamp review

## Reflection Question
[Weekly reflection from chiron-core references/reflection-questions.md]
```

## Workflow Decision Tree

```
User request
│
├─ "Start day" → Morning Plan
│  ├─ Read yesterday's note
│  ├─ Check today's tasks
│  ├─ Prioritize (delegate to chiron-core)
│  ├─ Create daily note (delegate to obsidian-management)
│  └─ Confirm focus
│
├─ "End day" → Evening Reflection
│  ├─ Review completed tasks
│  ├─ Capture wins/challenges
│  ├─ Update daily note (delegate to obsidian-management)
│  ├─ Plan tomorrow
│  └─ Ask reflection question
│
└─ "Weekly review" → Weekly Review
   ├─ Collect daily notes
   ├─ Calculate metrics
   ├─ Review projects
   ├─ Process inbox (delegate to quick-capture)
   ├─ Review areas (delegate to chiron-core)
   ├─ Identify patterns
   ├─ Plan next week
   └─ Generate review note (delegate to obsidian-management)
```

## Templates

All workflows use templates from `_chiron/templates/`:

| Workflow | Template | Variables |
|----------|----------|------------|
| Morning Plan | `daily-note.md` | {{date}}, {{focus}}, {{tasks}} |
| Evening Reflection | `daily-note.md` (update) | N/A |
| Weekly Review | `weekly-review.md` | {{week}}, {{date}}, {{metrics}} |

**Template usage:**
1. Read template file
2. Replace variables with actual data
3. Create/update note in appropriate location
4. Fill in placeholder sections

## Best Practices

### Morning Planning
- Limit critical tasks to 3-5
- Schedule deep work blocks first
- Protect high-energy times
- Include breaks and transition time

### Evening Reflection
- Focus on patterns, not just details
- Be honest about challenges
- Capture learnings, not just outcomes
- Plan tomorrow before bed

### Weekly Review
- Dedicated time (60-90 min)
- Use reflection questions from chiron-core
- Focus on system improvements
- Plan, don't just review

## Quick Reference

| Workflow | Trigger | Duration | Output |
|----------|----------|-----------|--------|
| Morning Plan | "Start day", "/chiron-start" | 5-10 min | Daily note with focus areas |
| Evening Reflection | "End day", "/chiron-end" | 5-10 min | Updated daily note |
| Weekly Review | "Weekly review", "/chiron-review" | 60-90 min | Weekly review note |

## Resources

- `references/reflection-questions.md` - Weekly and monthly reflection questions (from chiron-core)
- `references/weekly-review-template.md` - Detailed weekly review structure
- `references/morning-planning.md` - Morning planning best practices

**Load references when:**
- Weekly review preparation
- User asks about reflection techniques
- Customizing review workflows
