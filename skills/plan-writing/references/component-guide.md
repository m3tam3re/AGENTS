# Component Selection Guide

Decision matrix for which templates to include based on project characteristics.

## Decision Matrix

| Question | If Yes | If No |
|----------|--------|-------|
| Team project (>1 person)? | +kickoff, +stakeholders | Use brief instead of kickoff |
| Duration >2 weeks? | +risk-register | Skip risks |
| External stakeholders? | +stakeholders (detailed) | Stakeholders optional |
| Complex dependencies? | +detailed todos with deps | Simple todo list |
| Ongoing tracking needed? | +progress-update template | One-time plan |

## Quick Selection by Project Type

### Solo, Short (<2 weeks)
```
✓ project-brief.md
✓ todo-structure.md
```

### Solo, Medium (2-4 weeks)
```
✓ project-brief.md
✓ todo-structure.md
✓ risk-register.md
```

### Solo, Long (>4 weeks)
```
✓ project-brief.md (or kickoff for complex)
✓ todo-structure.md
✓ risk-register.md
✓ progress-update.md (for self-tracking)
```

### Team, Any Duration
```
✓ project-kickoff.md (always for team alignment)
✓ stakeholder-map.md
✓ todo-structure.md
✓ risk-register.md (if >2 weeks)
✓ progress-update.md (for status updates)
```

## Template Purposes

### project-kickoff.md
Full 8-section document for team alignment:
1. Project essentials (name, owner, dates)
2. Goals and success criteria
3. Stakeholders overview
4. Timeline and milestones
5. Scope (in/out)
6. Risks overview
7. Communication plan
8. Next steps

**Use when**: Multiple people need alignment on what/why/how.

### project-brief.md
1-page summary for simpler projects:
- Goal statement
- Success criteria
- Key milestones
- Initial tasks

**Use when**: Solo project or simple scope that doesn't need formal kickoff.

### stakeholder-map.md
Communication matrix:
- Who needs information
- What they need to know
- How often
- Which channel

**Use when**: Team projects with multiple stakeholders needing different information.

### risk-register.md
Risk tracking table:
- Risk description
- Probability (H/M/L)
- Impact (H/M/L)
- Mitigation plan
- Owner

**Use when**: Projects >2 weeks or high-stakes projects of any duration.

### todo-structure.md
Hierarchical task breakdown:
- Phases or milestones
- Tasks under each phase
- Subtasks if needed
- Metadata: owner, estimate, due date, dependencies

**Use when**: Always. Every project needs task breakdown.

### progress-update.md
Status reporting template:
- Completed since last update
- In progress
- Blockers
- Next steps
- Metrics/progress %

**Use when**: Projects needing regular status updates (weekly, sprint-based, etc.).

## Customization Notes

Templates are starting points. Common customizations:
- Remove sections that don't apply
- Add project-specific sections
- Adjust detail level based on audience
- Combine templates for simpler output

The goal is useful documentation, not template compliance.
