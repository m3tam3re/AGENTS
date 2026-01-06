# Rating Guidelines

How to classify findings from conversation analysis.

## Rating Criteria

### High Priority (Explicit Constraints)

**Definition:** Direct corrections or explicit rules that MUST be followed.

**Characteristics:**
- User explicitly states a constraint
- Correction of incorrect behavior
- Safety or correctness requirements
- Repeated violations cause frustration

**Examples:**
- "Never commit without asking first"
- "Always use TypeScript, not JavaScript"
- "You forgot to run tests before committing"
- "Don't use global state"

**Action:** These become hard constraints in the skill documentation.

**Format in OBSERVATIONS.md:**
```markdown
## HIGH: [Constraint Title]
**Context:** [Which skill/scenario]
**Signal:** [What the user said/did]
**Constraint:** [The specific rule to follow]
**Proposed Change:** [Exact text to add to skill]
```

### Medium Priority (Preferences & Patterns)

**Definition:** Approaches that work well or user preferences that improve workflow.

**Characteristics:**
- Positive reinforcement from user
- Patterns that user adopts repeatedly
- Workflow optimizations
- Style preferences

**Examples:**
- "That output format is perfect, use that"
- User consistently requests bullet points over paragraphs
- User prefers parallel tool execution
- "I like how you broke that down"

**Action:** These become preferred approaches or default patterns in skills.

**Format in OBSERVATIONS.md:**
```markdown
## MEDIUM: [Preference Title]
**Context:** [Which skill/scenario]
**Signal:** [What the user said/did]
**Preference:** [The preferred approach]
**Rationale:** [Why this works well]
**Proposed Change:** [Suggested skill update]
```

### Low Priority (Observations)

**Definition:** Contextual insights, minor preferences, or exploratory findings.

**Characteristics:**
- Environmental context
- Tentative patterns (need more data)
- Nice-to-have improvements
- Exploratory feedback

**Examples:**
- User tends to work on deep tasks in morning
- User sometimes asks for alternative approaches
- User occasionally needs extra context
- Formatting preferences for specific outputs

**Action:** Document for future consideration. May become higher priority with more evidence.

**Format in OBSERVATIONS.md:**
```markdown
## LOW: [Observation Title]
**Context:** [Which skill/scenario]
**Signal:** [What was noticed]
**Observation:** [The pattern or insight]
**Potential Action:** [Possible future improvement]
```

## Classification Decision Tree

```
1. Did user explicitly correct behavior?
   YES → HIGH
   NO → Continue

2. Did user express satisfaction with approach?
   YES → Was it repeated/adopted as pattern?
      YES → MEDIUM
      NO → LOW
   NO → Continue

3. Is this a repeated pattern (3+ instances)?
   YES → MEDIUM
   NO → LOW

4. Is this exploratory/tentative?
   YES → LOW
```

## Edge Cases

**Implicit corrections (repeated fixes by user):**
- First instance: LOW (observe)
- Second instance: MEDIUM (pattern emerging)
- Third instance: HIGH (clear constraint)

**Contradictory signals:**
- Document both
- Note the contradiction
- Mark for user clarification

**Context-dependent preferences:**
- Rate based on specificity
- Document the context clearly
- If context is always present: MEDIUM
- If context is occasional: LOW
