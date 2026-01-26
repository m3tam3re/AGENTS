# Reflection Command Usage

## Toggle Commands

### Enable Reflection Mode
```
/reflection on
```

**Effect:** Enables automatic detection of correction signals during conversation. I will proactively suggest skill improvements when patterns are detected.

### Disable Reflection Mode  
```
/reflection off
```

**Effect:** Disables automatic detection. Reflection only occurs when explicitly requested.

### Check Status
```
/reflection status
```

**Effect:** Shows whether reflection mode is currently on or off.

## Behavior by Mode

### Mode: ON

**Automatic triggers:**
- User corrects same thing 2+ times → Offer reflection
- Explicit corrections detected ("No, do it this way") → Ask "Should I reflect on [skill]?"
- After skill usage with clear signals → Proactive suggestion

**Example:**
```
User: "No, run tests before committing, not after"
[conversation continues]
User: "Again, tests must run first"

Agent: "I notice you've corrected the workflow order twice. 
Should I reflect on the relevant skill to add this constraint?"
```

### Mode: OFF (Default)

**Manual triggers only:**
- User says "reflect", "improve", "learn from this"
- User explicitly asks to analyze skill

**Example:**
```
User: "Reflect on the task-management skill"

Agent: [Runs full reflection workflow]
```

## Session Persistence

Reflection mode is **session-scoped**:
- Setting persists for current conversation
- Resets to OFF for new sessions
- Use `/reflection on` at session start if desired

## When to Use Each Mode

### Use ON when:
- Actively developing/tuning a new skill
- Testing skill behavior with real usage
- Learning preferences for a new domain
- Want proactive improvement suggestions

### Use OFF when:
- Skills are stable and working well
- Don't want interruptions
- Only need reflection occasionally
- Prefer manual control

## Integration with Skill

The reflection skill checks conversation context for mode state:
- Looks for recent `/reflection on` or `/reflection off` commands
- Defaults to OFF if no command found
- Auto-triggers only when ON and signals detected
- Always responds to explicit "reflect" requests regardless of mode
