---
name: brainstorming
description: "General-purpose ideation and strategic thinking. Use when: (1) clarifying thoughts on any topic, (2) exploring options and trade-offs, (3) building strategies or plans, (4) making decisions with multiple factors, (5) thinking through problems. Triggers: brainstorm, think through, explore options, clarify, what are my options, help me decide, strategy for, how should I approach."
compatibility: opencode
---

# Brainstorming

General-purpose ideation for any domain: business decisions, personal projects, creative work, strategic planning, problem-solving. Not tied to software development.

## Process

### 1. Understand Context

Start by understanding the situation:
- What's the situation? What triggered this thinking?
- What's the current state vs desired state?

**Ask one question at a time.** Prefer multiple choice when options are clear.

### 2. Clarify the Outcome

Before exploring solutions, clarify what success looks like:
- What would a good outcome enable?
- What would you be able to do that you can't now?
- Are there constraints on what "good" means?

### 3. Explore Constraints

Map the boundaries before generating options:
- **Time**: Deadlines, urgency, available hours
- **Resources**: Budget, people, skills, tools
- **External**: Dependencies, stakeholders, regulations
- **Preferences**: Non-negotiables vs nice-to-haves

### 4. Generate Options

Present 2-3 distinct approaches with trade-offs:

```
**Option A: [Name]**
- Approach: [Brief description]
- Pros: [Key advantages]
- Cons: [Key disadvantages]
- Best if: [When this option makes sense]

**Option B: [Name]**
...

**My recommendation**: Option [X] because [reasoning].
```

Lead with your recommendation but present alternatives fairly.

### 5. Validate Incrementally

Present thinking in 200-300 word sections. After each section, check:
- "Does this capture it correctly?"
- "Anything I'm missing?"
- "Should we go deeper on any aspect?"

Be ready to backtrack and clarify. Brainstorming is non-linear.

### 6. Capture Decision (Optional)

After reaching clarity, offer:

> "Would you like me to save this brainstorm to Obsidian for reference?"

If yes, create a brainstorm note in Obsidian:

```
File: ~/CODEX/03-resources/brainstorms/YYYY-MM-DD-[topic].md

---
date: {{date}}
created: {{timestamp}}
type: brainstorm
framework: {{framework_used}}
status: {{draft|final|archived}}
tags: #brainstorm #{{framework_tag}}
---

# {{topic}}

## Context
{{situation and trigger}}

## Outcome
{{what success looks like}}

## Constraints
{{time, resources, boundaries}}

## Options Explored
{{options considered}}

## Decision
{{final choice}}

## Rationale
{{reasoning behind decision}}

## Next Steps
{{action items}}

---
*Created: {{timestamp}}*
```

**Framework tags** (use in `tags:` frontmatter):
- `#pros-cons` - Pros/Cons analysis
- `#swot` - Strategic SWOT assessment
- `#5-whys` - Root cause analysis
- `#how-now-wow` - Prioritization matrix
- `#starbursting` - Comprehensive exploration (6 questions)
- `#constraint-mapping` - Boundary analysis

**Status tags** (use in `status:` frontmatter):
- `draft` - Initial capture
- `final` - Decision made
- `archived` - No longer active

---

## Template Setup

For a better editing experience, create a template in Obsidian:

1. Open Obsidian → ~/CODEX vault
2. Go to Content Model → Object Types → Brainstorm v2
3. Click Templates (top right) → Click + to create template
4. Name it "Brainstorm Session" and configure default fields:
   - Pre-populated structure matching the brainstorm workflow
   - Framework selector with options: None, Pros/Cons, SWOT, 5 Whys, How-Now-Wow, Starbursting, Constraint Mapping
   - Status selector with options: Draft, Final, Archived
5. Save the template - it will be available when creating new brainstorms

## Key Principles

| Principle | Why |
|-----------|-----|
| **One question at a time** | Avoids overwhelming, gets better answers |
| **Multiple choice preferred** | Easier to respond, clarifies options |
| **Domain-agnostic** | Works for any topic, not just technical |
| **YAGNI ruthlessly** | Remove unnecessary scope from all explorations |
| **Recommendation-first** | Always lead with your suggested approach |
| **Flexible** | Go back and clarify when needed |

## When to Use Frameworks

For structured analysis, consult [references/thinking-frameworks.md](references/thinking-frameworks.md):

| Situation | Framework |
|-----------|-----------|
| Binary decision (A or B, yes or no) | Pros/Cons |
| Strategic assessment | SWOT |
| Finding root cause | 5 Whys |
| Prioritizing many ideas | How-Now-Wow Matrix |
| Comprehensive exploration | Starbursting (6 Questions) |
| Understanding boundaries | Constraint Mapping |

**Only suggest frameworks when they add value.** Many brainstorms work fine with conversational exploration alone.

## Example Session

```
User: "I'm not sure how to approach launching my new course"

AI: "Let me help you think through this. First, what kind of course is it 
and who's the target audience?"

User: "NixOS course for developers who want to learn Nix"

AI: "Got it. What does success look like for this launch?
a) Maximum enrollments in first week
b) Building long-term audience/community
c) Validating the content before wider release
d) Something else?"

User: "B - building community"

AI: "That shapes the approach. What's your timeline?
a) Ready to launch now
b) 2-4 weeks to prepare
c) Flexible, no deadline"

...continues with options and recommendation...
```

## Handoff to Other Skills

After brainstorming, common next steps:

| Output | Next Skill | Trigger |
|--------|------------|---------|
| Project decision | plan-writing | "Create a project plan for this" |
| Task identified | task-management | "Add this to my tasks" |
| Work project | basecamp | "Set this up in Basecamp" |

All handoffs can reference the Obsidian brainstorm note via WikiLinks or file paths.
