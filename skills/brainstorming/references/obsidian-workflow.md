# Brainstorm Obsidian Workflow

This document describes how to create and use brainstorm notes in Obsidian.

## Quick Create

Create a brainstorm note in Obsidian markdown format:

```markdown
File: ~/CODEX/03-resources/brainstorms/YYYY-MM-DD-[topic].md

---
date: 2026-01-27
created: 2026-01-27T18:30:00Z
type: brainstorm
framework: pros-cons
status: draft
tags: #brainstorm #pros-cons
---

# NixOS Course Launch Strategy

## Context
Want to launch NixOS course for developers who want to learn Nix

## Outcome
Build long-term audience/community around NixOS expertise

## Constraints
- 2-4 weeks preparation time
- Solo creator (no team yet)
- Limited budget for marketing

## Options Explored

### Option A: Early Access Beta
- **Approach**: Release course to 10-20 people first, gather feedback, then full launch
- **Pros**: Validates content, builds testimonials, catches bugs early
- **Cons**: Slower to revenue, requires managing beta users
- **Best if**: Quality is critical and you have patient audience

### Option B: Free Preview + Upsell
- **Approach**: Release first module free, full course for paid
- **Pros**: Low barrier to entry, demonstrates value, builds email list
- **Cons**: Lower conversion rate, can feel "bait-and-switchy"
- **Best if**: Content quality is obvious from preview

### Option C: Full Launch with Community
- **Approach**: Launch full course immediately with Discord/Community for support
- **Pros**: Immediate revenue, maximum reach, community built-in
- **Cons**: No validation, bugs in production, overwhelmed support
- **Best if**: Content is well-tested and you have support capacity

## Decision
**Early Access Beta** - Build anticipation while validating content

## Rationale
Quality and community trust matter more than speed. A beta launch lets me:
1. Catch errors before they damage reputation
2. Build testimonials that drive full launch
3. Gather feedback to improve the product
4. Create a community of early adopters who become evangelists

## Next Steps
1. Create landing page with beta signup
2. Build email list from signups
3. Create course outline and first modules
4. Select 10-20 beta users from community
5. Set up feedback collection system (notion/obsidian)
6. Launch beta (target: Feb 15)
7. Collect feedback for 2 weeks
8. Finalize content based on feedback
9. Full launch (target: March 1)
```

## Note Structure

| Frontmatter Field | Purpose | Values |
|-----------------|---------|---------|
| `date` | Date created | YYYY-MM-DD |
| `created` | Timestamp | ISO 8601 |
| `type` | Note type | `brainstorm` |
| `framework` | Framework used | `none`, `pros-cons`, `swot`, `5-whys`, `how-now-wow`, `starbursting`, `constraint-mapping` |
| `status` | Progress status | `draft`, `final`, `archived` |
| `tags` | Categorization | Always include `#brainstorm`, add framework tag |

## Framework Tags

| Framework | Tag | When to Use |
|-----------|------|-------------|
| None | `#none` | Conversational exploration without structure |
| Pros/Cons | `#pros-cons` | Binary decision (A or B, yes or no) |
| SWOT | `#swot` | Strategic assessment of situation |
| 5 Whys | `#5-whys` | Finding root cause of problem |
| How-Now-Wow | `#how-now-wow` | Prioritizing many ideas by impact/effort |
| Starbursting | `#starbursting` | Comprehensive exploration (6 questions) |
| Constraint Mapping | `#constraint-mapping` | Understanding boundaries and constraints |

## Status Values

| Status | Description | When to Use |
|--------|-------------|-------------|
| `draft` | Initial capture, work in progress | Start with this, update as you work |
| `final` | Decision made, brainstorm complete | When you've reached clarity |
| `archived` | No longer relevant or superseded | Historical reference only |

## Template Setup

For a better editing experience, create a template in Obsidian:

1. Open Obsidian → ~/CODEX vault
2. Create folder: `_chiron/templates/` if not exists
3. Create template file: `brainstorm-note.md` with:
   - Frontmatter with placeholder values
   - Markdown structure matching the sections above
   - Empty sections ready to fill in
4. Set up Obsidian Templates plugin (optional) to use this template

**Obsidian Template:**
```markdown
---
date: {{date}}
created: {{timestamp}}
type: brainstorm
framework: {{framework}}
status: draft
tags: #brainstorm #{{framework}}
---

# {{topic}}

## Context

## Outcome

## Constraints

## Options Explored

### Option A: {{option_a_name}}
- **Approach**:
- **Pros**:
- **Cons**:
- **Best if**:

### Option B: {{option_b_name}}
- **Approach**:
- **Pros**:
- **Cons**:
- **Best if**:

## Decision

## Rationale

## Next Steps
1.
2.
3.
```

## Linking to Other Notes

After creating a brainstorm, link it to related notes using WikiLinks:

```markdown
## Related Projects
- [[Launch NixOS Flakes Course]]
- [[Q2 Training Program]]

## Related Tasks
- [[Tasks]]
```

## Searching Brainstorms

Find brainstorms by topic, framework, or status using Obsidian search:

**Obsidian search:**
- Topic: `path:03-resources/brainstorms "NixOS"`
- Framework: `#pros-cons path:03-resources/brainstorms`
- Status: `#draft path:03-resources/brainstorms`

**Dataview query (if using plugin):**
```dataview
TABLE date, topic, framework, status
FROM "03-resources/brainstorms"
WHERE type = "brainstorm"
SORT date DESC
```

## Best Practices

1. **Create brainstorms for any significant decision** - Capture reasoning while fresh
2. **Mark as Final when complete** - Helps with search and review
3. **Link to related notes** - Creates context web via WikiLinks
4. **Use frameworks selectively** - Not every brainstorm needs structure
5. **Review periodically** - Brainstorms can inform future decisions
6. **Keep structure consistent** - Same sections make reviews easier
7. **Use tags for filtering** - Framework and status tags are essential

## Integration with Other Skills

| From brainstorming | To skill | Handoff trigger |
|------------------|------------|-----------------|
| Project decision | plan-writing | "Create a project plan for this" |
| Task identified | task-management | "Add this to my tasks" |
| Work project | basecamp | "Set this up in Basecamp" |

All handoffs can reference the Obsidian brainstorm note via WikiLinks or file paths.
