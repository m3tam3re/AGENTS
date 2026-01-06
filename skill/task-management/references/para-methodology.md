# PARA Methodology Reference

PARA is a universal system for organizing digital information, created by Tiago Forte.

## The Four Categories

### Projects

**Definition**: A series of tasks linked to a goal, with a deadline.

**Characteristics**:
- Has a clear outcome/deliverable
- Has a deadline (explicit or implicit)
- Requires multiple tasks to complete
- Can be completed (finite)

**Examples**:
- Launch NixOS Flakes course
- Hire senior backend developer
- Complete Q1 board presentation
- Publish self-hosting playbook video

**Questions to identify**:
- What am I committed to finishing?
- What has a deadline?
- What would I celebrate completing?

### Areas

**Definition**: A sphere of activity with a standard to be maintained over time.

**Characteristics**:
- Ongoing responsibility (infinite)
- Has standards, not deadlines
- Requires regular attention
- Never "complete" - only maintained

**Sascha's Areas**:
1. CTO Leadership
2. m3ta.dev
3. YouTube @m3tam3re
4. Technical Exploration
5. Personal Development
6. Health & Wellness
7. Family

**Questions to identify**:
- What roles do I maintain?
- What standards must I uphold?
- What would suffer if I ignored it?

### Resources

**Definition**: A topic or theme of ongoing interest.

**Characteristics**:
- Reference material for future use
- No immediate action required
- Supports projects and areas
- Can be shared or reused

**Examples**:
- NixOS configuration patterns
- n8n workflow templates
- Self-hosting architecture docs
- AI prompt libraries
- Book notes and highlights

**Questions to identify**:
- What might be useful later?
- What do I want to learn more about?
- What reference material do I need?

### Archives

**Definition**: Inactive items from the other three categories.

**Characteristics**:
- Completed projects
- Areas no longer active
- Resources no longer relevant
- Preserved for reference, not action

**When to archive**:
- Project completed or cancelled
- Role/responsibility ended
- Topic no longer relevant
- Information outdated

## The PARA Workflow

### Capture
Everything starts in the **Inbox**. Don't organize during capture.

### Clarify
Ask: "Is this actionable?"
- **Yes** → Is it a single task or a project?
- **No** → Is it reference material or trash?

### Organize
Place items in the appropriate category:
- Active work → Projects (linked to Area)
- Ongoing standards → Areas
- Reference → Resources
- Done/irrelevant → Archives

### Review
- **Daily**: Process inbox, check today's tasks
- **Weekly**: Review all projects, check areas, process resources
- **Monthly**: Archive completed, assess areas, audit resources

## Project vs Area Confusion

The most common PARA mistake is confusing projects and areas.

| If you treat a Project as an Area | If you treat an Area as a Project |
|-----------------------------------|-----------------------------------|
| Never feels "done" | Feels like constant failure |
| Scope creeps infinitely | Standards slip without noticing |
| No sense of progress | Burnout from "finishing" the infinite |

**Test**: Can I complete this in a single work session series? 
- Yes → Project
- No, it's ongoing → Area

## Maintenance Rhythms

### Daily (Evening - 10 min)
1. Process inbox items
2. Review completed tasks
3. Set tomorrow's priorities

### Weekly (Sunday evening - 30 min)
1. Get clear: Inbox to zero
2. Get current: Review each Area
3. Review all active Projects
4. Plan next week's outcomes

### Monthly (First Sunday - 60 min)
1. Review Area standards
2. Archive completed Projects
3. Evaluate stalled Projects
4. Audit Resources relevance

### Quarterly (90 min)
1. Review life Areas balance
2. Set quarterly outcomes
3. Major archives cleanup
4. System improvements

## PARA in Anytype

### Type Mapping

| PARA | Anytype Type | Notes |
|------|--------------|-------|
| Project | `project` | Has area relation, deadline |
| Area | `area` | Top-level organization |
| Resource | `resource` | Reference material |
| Archive | Use `archived` property | Or separate Archive type |
| Task | `task` | Lives within Project or Area |
| Inbox | `note` with status=inbox | Quick capture |

### Recommended Properties

**On Projects**:
- `area` (relation) - Which area owns this
- `status` (select) - active, on-hold, completed
- `due_date` (date) - Target completion
- `outcome` (text) - What does "done" look like

**On Tasks**:
- `project` or `area` (relation) - Parent container
- `status` (select) - inbox, next, waiting, scheduled, done
- `priority` (select) - critical, high, medium, low
- `due_date` (date) - When it's needed
- `energy` (select) - Required energy level
- `context` (multi_select) - Where/how it can be done

**On Areas**:
- `description` (text) - Standards to maintain
- `review_frequency` (select) - daily, weekly, monthly

## Common Pitfalls

1. **Over-organizing during capture** - Just dump it in inbox
2. **Too many projects** - Active projects should be <15
3. **Orphan tasks** - Every task needs a project or area
4. **Stale resources** - Archive what you haven't touched in 6 months
5. **Skipping reviews** - The system only works if you review it
