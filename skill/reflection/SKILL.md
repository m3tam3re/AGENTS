---
name: reflection
description: "Conversation analysis to improve skills based on user feedback. Use when: (1) user explicitly requests reflection ('reflect', 'improve', 'learn from this'), (2) reflection mode is ON and clear correction signals detected, (3) user asks to analyze skill performance. Triggers: reflect, improve, learn, analyze conversation, skill feedback. Toggle with /reflection on|off command."
compatibility: opencode
---

# Reflection

Analyze conversations to detect user corrections, preferences, and observations, then propose skill improvements.

## Reflection Mode

**Toggle:** Use `/reflection on|off|status` command

**When mode is ON:**
- Actively monitor for correction signals during conversation
- Auto-suggest reflection when clear patterns detected
- Proactively offer skill improvements

**When mode is OFF (default):**
- Only trigger on explicit user request
- No automatic signal detection

## Core Workflow

When triggered, follow this sequence:

### 1. Identify Target Skill

**If skill explicitly mentioned:**
```
User: "Reflect on the task-management skill"
→ Target: task-management
```

**If not specified, ask:**
```
"Which skill should I analyze? Recent skills used: [list from session]"
```

### 2. Scan Conversation

Use session tools to analyze the current conversation:

```bash
# Read current session messages
session_read --session_id [current] --include_todos true
```

**Analyze for:**
- When target skill was used
- User responses after skill usage
- Correction signals (see references/signal-patterns.md)
- Workflow patterns
- Repeated interactions

### 3. Classify Findings

Rate each finding using 3-tier system (see references/rating-guidelines.md):

**HIGH (Explicit Constraints):**
- Direct corrections: "No, don't do X"
- Explicit rules: "Always/Never..."
- Repeated violations

**MEDIUM (Preferences & Patterns):**
- Positive reinforcement: "That's perfect"
- Adopted patterns (used 3+ times)
- Workflow optimizations

**LOW (Observations):**
- Contextual insights
- Tentative patterns
- Environmental preferences

### 4. Read Target Skill

Before proposing changes, read the current skill implementation:

```bash
# Read the skill file
read skill/[target-skill]/SKILL.md

# Check for references if needed
glob pattern="**/*.md" path=skill/[target-skill]/references/
```

### 5. Generate Proposals

**For each finding, create:**

**HIGH findings:**
- Specific constraint text to add
- Location in skill where it should go
- Exact wording for the rule

**MEDIUM findings:**
- Preferred approach description
- Suggested default behavior
- Optional: code example or workflow update

**LOW findings:**
- Observation description
- Potential future action
- Context for when it might apply

### 6. User Confirmation

**Present findings in structured format:**

```markdown
## Reflection Analysis: [Skill Name]

### HIGH Priority (Constraints)
1. **[Finding Title]**
   - Signal: [What user said/did]
   - Proposed: [Specific change to skill]

### MEDIUM Priority (Preferences)
1. **[Finding Title]**
   - Signal: [What user said/did]
   - Proposed: [Suggested update]

### LOW Priority (Observations)
[List observations]

---

Approve changes to [skill name]? (yes/no/selective)
```

### 7. Apply Changes or Document

**If user approves (yes):**
1. Edit skill/[target-skill]/SKILL.md with proposed changes
2. Confirm: "Updated [skill name] with [N] improvements"
3. Show diff of changes

**If user selects some (selective):**
1. Ask which findings to apply
2. Edit skill with approved changes only
3. Write rejected findings to OBSERVATIONS.md

**If user declines (no):**
1. Create/append to skill/[target-skill]/OBSERVATIONS.md
2. Document all findings with full context
3. Confirm: "Documented [N] observations in OBSERVATIONS.md for future reference"

## OBSERVATIONS.md Format

When writing observations file:

```markdown
# Observations for [Skill Name]

Generated: [Date]
From conversation: [Session ID if available]

## HIGH: [Finding Title]
**Context:** [Which scenario/workflow]
**Signal:** [User's exact words or repeated pattern]
**Constraint:** [The rule to follow]
**Proposed Change:** [Exact text to add to skill]
**Status:** Pending user approval

---

## MEDIUM: [Finding Title]
**Context:** [Which scenario/workflow]
**Signal:** [What indicated this preference]
**Preference:** [The preferred approach]
**Rationale:** [Why this works well]
**Proposed Change:** [Suggested skill update]
**Status:** Pending user approval

---

## LOW: [Observation Title]
**Context:** [Which scenario/workflow]
**Signal:** [What was noticed]
**Observation:** [The pattern or insight]
**Potential Action:** [Possible future improvement]
**Status:** Noted for future consideration
```

## Signal Detection Patterns

Key patterns to watch for (detailed in references/signal-patterns.md):

**Explicit corrections:**
- "No, that's wrong..."
- "Actually, you should..."
- "Don't do X, do Y instead"

**Repeated clarifications:**
- User explains same thing multiple times
- Same mistake corrected across sessions

**Positive patterns:**
- "Perfect, keep doing it this way"
- User requests same approach repeatedly
- "That's exactly what I needed"

**Workflow corrections:**
- "You skipped step X"
- "Wrong order"
- "You should have done Y first"

## Usage Examples

### Example 1: Post-Skill Usage

```
User: "Reflect on how the task-management skill performed"

Agent:
1. Read current session
2. Find all task-management skill invocations
3. Analyze user responses afterward
4. Read skill/task-management/SKILL.md
5. Present findings with confirmation prompt
```

### Example 2: User-Prompted Learning

```
User: "Learn from this conversation - I had to correct you several times"

Agent:
1. Ask which skill to analyze (if multiple used)
2. Scan full conversation for correction signals
3. Classify by severity (HIGH/MEDIUM/LOW)
4. Propose changes with confirmation
```

### Example 3: Detected Signals

```
# During conversation, user corrects workflow twice
User: "No, run tests BEFORE committing, not after"
[later]
User: "Again, tests first, then commit"

# Later when user says "reflect" or at end of session
Agent detects: HIGH priority constraint for relevant skill
```

## References

- **signal-patterns.md** - Comprehensive list of correction patterns to detect
- **rating-guidelines.md** - Decision tree for classifying findings (HIGH/MEDIUM/LOW)

Load these when analyzing conversations for detailed pattern matching and classification logic.

## Important Constraints

1. **Never edit skills without user approval** - Always confirm first
2. **Read the skill before proposing changes** - Avoid suggesting what already exists
3. **Preserve existing structure** - Match the skill's current organization and style
4. **Be specific** - Vague observations aren't actionable
5. **Full conversation scan** - Don't just analyze last few messages
6. **Context matters** - Include why the finding matters, not just what was said
