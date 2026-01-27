---
name: task-management
description: "PARA-based task management using Obsidian Tasks plugin format. Use when: (1) creating/managing tasks, (2) daily or weekly reviews, (3) prioritizing work, (4) searching for tasks, (5) planning sprints or focus blocks. Triggers: task, todo, find tasks, search tasks, overdue, prioritize."
compatibility: opencode
---

# Task Management

PARA-based task management using Obsidian Tasks plugin format for Chiron system.

## Obsidian Tasks Format

**Basic format:**
```markdown
- [ ] Task description #tag ⏫ 📅 YYYY-MM-DD
```

**Priority indicators:**
- ⏫ = Critical (urgent AND important)
- 🔼 = High (important, not urgent)
- 🔽 = Low (nice to have)

**Date indicators:**
- 📅 = Due date
- ⏳ = Start date
- 🛫 = Scheduled date

**Owner attribution:**
```markdown
- [ ] Task description #todo 👤 @owner ⏫ 📅 YYYY-MM-DD
```

## Task Locations

```
~/CODEX/
├── tasks/                    # Central task management
│   ├── inbox.md            # Unprocessed tasks
│   ├── waiting.md          # Blocked/delegated
│   ├── someday.md           # Future ideas
│   └── by-context/          # Context-based task lists
│       ├── work.md
│       ├── home.md
│       └── errands.md
├── 01-projects/             # Project-specific tasks (in _index.md or notes/tasks.md)
└── 02-areas/                # Area-specific tasks (in area files)
```

## Core Workflows

### Create Task

**When user says**: "Add task: X", "Todo: X", "Remember to: X"

**Steps:**

1. **Parse task from request:**
   - Task description
   - Priority (if specified: critical, high, low)
   - Due date (if specified)
   - Owner (if specified: @mention)
   - Context (if specified)
   - Project/area (if specified)

2. **Determine location:**
   - Project-specific → `01-projects/[project]/_index.md` or `tasks.md`
   - Area-specific → `02-areas/[area].md`
   - General → `tasks/inbox.md`

3. **Create task in Obsidian format:**
   ```markdown
   - [ ] [Task description] #tag [priority] 👤 [@owner] 📅 [date]
   ```

4. **Confirm creation**

**Examples:**
```
User: "Add task: Review Q1 budget proposal, critical, due Friday"

Action:
Create in tasks/inbox.md:
- [ ] Review Q1 budget proposal #inbox ⏫ 📅 2026-01-31

Confirm: "Created task in inbox."
```

```
User: "Task: Email John about project deadline, due Friday, @john"

Action:
Create in tasks/inbox.md:
- [ ] Email John about project deadline #inbox 🔼 👤 @john 📅 2026-01-31

Confirm: "Created task assigned to John."
```

```
User: "Add task to Project X: Create PRD, high priority"

Action:
Create in 01-projects/work/project-x/_index.md:
- [ ] Create PRD #high 📅 2026-02-15

Confirm: "Created task in Project X."
```

### Find Tasks

**When user says**: "Find tasks", "What tasks do I have?", "Show me tasks for [context/project]"

**Steps:**

1. **Determine search scope:**
   - All tasks → Search all task files
   - Context tasks → Search `tasks/by-context/[context].md`
   - Project tasks → Read project's `_index.md` or `tasks.md`
   - Area tasks → Read area file
   - Overdue tasks → Search for tasks with past due dates

2. **Search using rg:**
   ```bash
   # Find all tasks
   rg "- \\[ \\]" ~/CODEX --type md

   # Find tasks by tag
   rg "#work" ~/CODEX --type md

   # Find overdue tasks
   rg "- \\[ \\].*📅" ~/CODEX --type md | filter-past-dates
   ```

3. **Parse and organize:**
   - Extract task description
   - Extract priority indicators (⏫/🔼/🔽)
   - Extract due dates
   - Extract owners (@mentions)
   - Extract tags

4. **Present results grouped by:**
   - Priority
   - Due date
   - Context/project/area

**Output format:**
```markdown
# Found 15 tasks

## Critical Tasks (⏫)
1. [ ] Review Q1 budget #work ⏫ 📅 2026-01-31
2. [ ] Client presentation #work ⏫ 📅 2026-01-30

## High Priority (🔼)
1. [ ] Update documentation #project-a 🔼 📅 2026-02-15
2. [ ] Team meeting notes #work 🔼 👤 @john
3. [ ] Buy groceries #personal 🔼 📅 2026-01-28

## Upcoming (by due date)
This week:
- [ ] Submit expense report #work 🔼 📅 2026-01-29
- [ ] Dentist appointment #personal 🔼 📅 2026-01-30

Next week:
- [ ] Project milestone #work 🔼 📅 2026-02-05
- [ ] Car service #personal 🔼 📅 2026-02-07

## By Owner
Assigned to @john (2 tasks):
- [ ] Team meeting notes #work 🔼
- [ ] Email stakeholder #work 🔼 📅 2026-02-01
```

### Search Specific Contexts

**When user says**: "What [context] tasks do I have?", "Show work tasks", "Show personal tasks"

**Steps:**

1. **Read context file**: `tasks/by-context/[context].md`
2. **Parse tasks**
3. **Present filtered list**

**Available contexts:**
- `work.md` - Work-related tasks
- `home.md` - Household/admin tasks
- `errands.md` - Shopping/running errands
- `deep-work.md` - Focus work (no interruptions)
- `calls.md` - Phone/video calls
- `admin.md` - Administrative tasks

### Prioritize Tasks

**When user says**: "Prioritize my tasks", "What should I work on?", "Focus check"

**Steps:**

1. **Fetch all incomplete tasks**:
   - `rg "- \\[ \\]" ~/CODEX --type md`
   - Filter out completed (`[x]`)

2. **Sort by criteria:**
   - Priority (⏫ > 🔼 > 🔽 > no indicator)
   - Due date (sooner first)
   - Energy level (if specified: high/medium/low)

3. **Return top 3-5 tasks**
4. **Include rationale** for prioritization

**Output format:**
```markdown
# Focus Recommendations (5 tasks found)

## Top Priority: ⏫ Critical
1. **[Review Q1 budget]** #work ⏫ 📅 2026-01-31
   - Why: Due in 4 days, critical for Q2 planning
   - Area: Finances
   - Estimated time: 2 hours

## High Priority: 🔼 Important (due within week)
1. **[Client presentation]** #work 🔼 📅 2026-01-30
   - Why: Client commitment, high impact
   - Area: Work
   - Estimated time: 4 hours

2. **[Team standup]** #work 🔼
   - Why: Daily sync, keeps team aligned
   - Area: Work
   - Estimated time: 30 minutes

3. **[Car registration]** #personal 🔼 📅 2026-02-01
   - Why: Legal requirement, must complete
   - Area: Home
   - Estimated time: 1 hour

## Recommended Order
1. Team standup (30min, energizes for day)
2. Review Q1 budget (2 hours, critical, morning focus)
3. Client presentation (4 hours, high energy block)
4. Car registration (1 hour, after lunch)

## Not Now (someday)
- [ ] Learn Rust #personal 🔽
- [ ] Organize photos #personal 🔽
```

### Update Task Status

**When user says**: "Mark task X as done", "Complete: X", "Task X finished"

**Steps:**

1. **Find task** (by description or show options)
2. **Change checkbox:**
   ```markdown
   # Before:
   - [ ] Task description

   # After:
   - [x] Task description
   ```
3. **Update modified date** in frontmatter (if present)
4. **Confirm**

### Move Tasks

**When user says**: "Move task X to project Y", "Task X goes to area Z"

**Steps:**

1. **Find source task**
2. **Read target location** (project `_index.md` or area file)
3. **Move task** (copy to target, delete from source)
4. **Update task context/tags** if needed
5. **Confirm**

**Example:**
```
User: "Move 'Buy groceries' to Finances area"

Action:
1. Find task in tasks/inbox.md
2. Read 02-areas/personal/finances.md
3. Copy task to finances.md
4. Delete from tasks/inbox.md
5. Confirm: "Moved 'Buy groceries' to Finances area."
```

### Task Delegation/Blocking

**When user says**: "Delegate task X to Y", "Task X is blocked", "Waiting for X"

**Steps:**

1. **Find task**
2. **Add owner or blocking info:**
   ```markdown
   # Delegation:
   - [ ] Task description #waiting 👤 @owner ⏫ 📅 date

   # Blocked:
   - [ ] Task description #waiting 🛑 Blocked by: [reason]
   ```
3. **Move to `tasks/waiting.md`** if delegated/blocked
4. **Confirm**

## Integration with Other Skills

**Delegates to:**
- `obsidian-management` - File operations (create/update/delete tasks)
- `chiron-core` - PARA methodology for task placement
- `daily-routines` - Task prioritization and scheduling
- `project-structures` - Project task lists
- `meeting-notes` - Extract action items from meetings

**Delegation rules:**
- File operations → `obsidian-management`
- PARA placement → `chiron-core`
- Project tasks → `project-structures`
- Meeting actions → `meeting-notes`

## Quick Reference

| Action | Command Pattern | Location |
|--------|-----------------|------------|
| Create task | "Task: [description] [priority] [due] [@owner]" | tasks/inbox.md or project/area |
| Find tasks | "Find tasks" or "What tasks do I have?" | All task files |
| Context tasks | "Show [context] tasks" | tasks/by-context/[context].md |
| Prioritize | "Prioritize tasks" or "What should I work on?" | All tasks, sorted |
| Mark done | "Task [description] done" or "Complete: [description]" | Task location |
| Move task | "Move task [description] to [project/area]" | Target location |
| Defer | "Someday: [task]" or "Defer: [task]" | tasks/someday.md |

## Best Practices

### Creating Tasks
- Be specific (not vague like "follow up")
- Set realistic due dates
- Assign owners clearly
- Link to projects/areas immediately
- Use appropriate priorities

### Managing Tasks
- Review daily (delegate to daily-routines)
- Process inbox weekly
- Archive completed tasks regularly
- Update context when tasks move

### Searching Tasks
- Use tags for filtering
- Search by context when batching
- Check overdue tasks daily
- Review waiting tasks weekly

## Error Handling

### Task Not Found
1. Search similar tasks
2. Ask user: "Which task?"
3. List options with context

### Duplicate Tasks
1. Detect duplicates by description
2. Ask: "Merge or keep separate?"
3. If merge, combine due dates/priorities

### Location Not Found
1. Create directory structure
2. Ask user: "Create in this location?"
3. Create task in inbox as fallback

## Resources

- `references/task-formats.md` - Obsidian Tasks plugin syntax
- `references/prioritization-methods.md` - Eisenhower matrix, energy-based prioritization
- `references/search-patterns.md` - rg patterns for finding tasks

**Load references when:**
- Format questions arise
- Prioritization help needed
- Search issues occur
- Task automation questions

## Obsidian Tasks Plugin Configuration

For full functionality, configure Obsidian Tasks plugin:

**Settings:**
- Task format: `- [ ] Task #tag ⏫ 📅 YYYY-MM-DD`
- Priority symbols: ⏫, 🔼, 🔽
- Date format: YYYY-MM-DD
- Default file: tasks/inbox.md

**Queries:**
```dataview
TASK
WHERE !completed
GROUP BY priority
SORT due date ASC
```

```dataview
TASK
WHERE !completed AND due < date(today)
SORT due ASC
GROUP BY project
```
