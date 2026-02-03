# Learnings - Chiron Agent Framework

## Wave 1, Task 1: Create agents.json with 6 agent definitions

### Agent Structure Pattern

**Required fields per agent:**
- `description`: Clear purpose statement
- `mode`: "primary" for orchestrators, "subagent" for specialists
- `model`: "zai-coding-plan/glm-4.7" (consistent across all agents)
- `prompt`: File reference pattern `{file:./prompts/<name>.txt}`
- `permission`: Either explicit permissions or simple "question": "allow"

### Primary vs Subagent Modes

**Primary agents** (2): chiron, chiron-forge
- Can be invoked directly by user
- Orchestrate and delegate work
- Higher permission levels (external_directory rules)

**Subagents** (4): hermes, athena, apollo, calliope
- Invoked by primary agents via Task tool
- Specialized single-purpose workflows
- Simpler permission structure (question: "allow")

### Permission Patterns

**Primary agents**: Complex permission structure
```json
"permission": {
  "external_directory": {
    "~/p/**": "allow",
    "*": "ask"
  }
}
```

**Subagents**: Simple permission structure
```json
"permission": {
  "question": "allow"
}
```

### Agent Domains

1. **chiron**: Plan Mode - Read-only analysis and planning
2. **chiron-forge**: Build Mode - Full execution with safety prompts
3. **hermes**: Work communication (Basecamp, Outlook, Teams)
4. **athena**: Work knowledge (Outline wiki, documentation)
5. **apollo**: Private knowledge (Obsidian vault, personal notes)
6. **calliope**: Writing (documentation, reports, prose)

### Verification Commands

**Agent count:**
```bash
python3 -c "import json; data = json.load(open('agents/agents.json')); print(len(data))"
# Expected output: 6
```

**Agent names:**
```bash
python3 -c "import json; data = json.load(open('agents/agents.json')); print(sorted(data.keys()))"
# Expected output: ['apollo', 'athena', 'calliope', 'chiron', 'chiron-forge', 'hermes']
```

### Key Takeaways

- Prompt files use file references, not inline content (Wave 2 will create these)
- Model is consistent across all agents for predictable behavior
- Permission structure matches agent capability level (more complex for primaries)
- Mode determines how agent can be invoked (direct vs delegated)
