# Learnings - Chiron Agent Framework

## Task: Update agents/agents.json with 6 Chiron agents

### Agent Configuration Pattern
- JSON structure: `{ "agent-name": { "description": "...", "mode": "...", "model": "...", "prompt": "{file:./prompts/...}", "permission": { "question": "..." } } }`
- Two primary agents: `chiron` (plan mode) and `chiron-forge` (build mode)
- Four subagents: `hermes` (work comm), `athena` (work knowledge), `apollo` (private knowledge), `calliope` (writing)
- All agents use `zai-coding-plan/glm-4.7` model
- Prompts are file references: `{file:./prompts/agent-name.txt}`
- Permissions use simple allow: `{ "question": "allow" }`

### Verification
- JSON validation: `python3 -c "import json; json.load(open('agents/agents.json'))"`
- No MCP configuration needed for agent definitions
- Mode values: "primary" or "subagent"

### Files Modified
- `agents/agents.json` - Expanded from 1 to 6 agents (8 lines → 57 lines)

### Successful Approaches
- Follow existing JSON structure pattern
- Maintain consistent indentation and formatting
- Use file references for prompts (not inline)

## Task: Create prompts/chiron-forge.txt

### Chiron-Forge Prompt Pattern
- Purpose: Execution/build mode counterpart to Chiron's planning mode
- Identity: Worker-mode AI assistant with full write access
- Core distinction: Chiron = planning/analysis, Chiron-Forge = building/executing
- Second-person addressing: "You are..." format

### Key Components
- **Identity**: "execution and build mode counterpart to Chiron"
- **Capabilities**: Full write access, read files, create/modify files, execute bash commands
- **Workflow**: Receive → Understand → Plan Action → Execute → Confirm (destructive) → Report
- **Safety**: Question tool for destructive operations (rm *, git push), sudo denied
- **Delegation**: Still delegates to subagents for specialized domains
- **Scope boundaries**: NOT planning/analysis agent, NOT evaluation of alternatives

### Verification
- File size: 3185 chars (target >500)
- Keywords present: execution, build, worker, write
- Lines: 67

### Files Created
- `prompts/chiron-forge.txt` - Chiron-Forge build mode system prompt
