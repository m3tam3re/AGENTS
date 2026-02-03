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

## Wave 2, Task 6: Create Athena (Work Knowledge) system prompt

### Prompt Structure Pattern Consistency

All subagent prompts follow identical structure from skill-creator guidance:
1. **Role definition**: "You are [name], the Greek [role], specializing in [domain]"
2. **Your Core Responsibilities**: Numbered list of primary duties
3. **Process**: Numbered steps for workflow execution
4. **Quality Standards**: Bulleted list of requirements
5. **Output Format**: Structure specification
6. **Edge Cases**: Bulleted list of exception handling
7. **Tool Usage**: Instructions for tool interaction (especially Question tool)
8. **Boundaries**: Explicit DO NOT statements with domain attribution

### Athena's Domain Specialization

**Role**: Work knowledge specialist for Outline wiki
- Primary tool: Outline wiki integration (document CRUD, search, collections, sharing)
- Core activities: wiki search, knowledge retrieval, documentation updates, knowledge organization
- Question tool usage: Document selection, search scope clarification, collection specification

**Differentiation from other agents:**
- Hermes (communication): Short messages, team communication tools (Basecamp, Teams, Outlook)
- Apollo (private knowledge): Obsidian vaults, personal notes, private data
- Calliope (writing): Documentation drafting, creative prose, reports
- Athena (work knowledge): Team wiki, Outline, shared documentation repositories

### Quality Focus for Knowledge Work

Key quality standards unique to Athena:
- Outline-specific understanding: collections, documents, sharing permissions, revision history
- Knowledge structure preservation: hierarchy, relationships, cross-references
- Identification of outdated information for updates
- Consistency in terminology across documentation
- Pattern recognition for organization improvements

### Boundary Clarity

Boundaries section explicitly references other agents' domains:
- "Do NOT handle short communication (Hermes's domain)"
- "Do NOT access private knowledge (Apollo's domain)"
- "Do NOT write creative content (Calliope's domain)"
- Collaboration section acknowledges cross-agent workflows

### Verification Approach

Used grep commands to verify domain presence:
- `grep -qi "outline"` → Confirms Outline tool specialization
- `grep -qi "wiki\|knowledge"` → Confirms knowledge base focus
- `grep -qi "document"` → Confirms document management capabilities

All verification checks passed successfully.

## Wave 2, Task 5: Create Hermes system prompt

### Prompt Structure Pattern

**Consistent sections across all subagent prompts:**
1. Role definition (You are [role] specializing in [domain])
2. Core Responsibilities (5-7 bullet points of primary duties)
3. Process (5-6 numbered steps for workflow)
4. Quality Standards (4-5 bullet points of output criteria)
5. Output Format (3-5 lines describing structure)
6. Edge Cases (5-6 bullet points of exceptional scenarios)
7. Tool Usage (Question tool + domain-specific MCP tools)
8. Boundaries (5-6 bullet points of what NOT to do)

### Hermes-Specific Domain Elements

**Greek mythology framing:** Hermes - god of communication, messengers, swift transactions

**Platform coverage:**
- Basecamp: tasks, projects, todos, message boards, campfire
- Outlook: email drafting, sending, inbox management
- Teams: meeting scheduling, channel messages, chat conversations

**Focus areas:** Task updates, email drafting, meeting scheduling, quick communication

**Question tool triggers:**
- Platform choice ambiguous
- Recipients unclear
- Project context missing

### Cross-Agent Boundaries

Hermes does NOT handle:
- Documentation repositories/wiki (Athena's domain)
- Personal tools/private knowledge (Apollo's domain)
- Long-form writing/reports (Calliope's domain)

### Verification Pattern

```bash
# Required content checks
grep -qi "basecamp" prompts/hermes.txt
grep -qiE "outlook|email" prompts/hermes.txt
grep -qiE "teams|meeting" prompts/hermes.txt
```

### Key Takeaways

- Use exact headers from SKILL.md template (line 358: "Your Core Responsibilities:")
- Second-person voice addressing agent directly
- 5-6 sections following consistent pattern
- Boundaries section explicitly references other agents' domains
- 45-50 lines is appropriate length for subagent prompts
- Include MCP tool references in Tool Usage section

## Wave 2, Task 3: Create Chiron (Plan Mode) system prompt

### Prompt Structure Pattern

**Standard sections (from agent-development/SKILL.md):**
- "You are [role]..." - Direct second-person address
- "**Your Core Responsibilities:**" - Numbered list (1, 2, 3), not bullet points
- "**Process:**" - Step-by-step workflow
- "**Quality Standards:**" - Evaluation criteria
- "**Output Format:**" - Response structure
- "**Edge Cases:**" - Exception handling
- "**Tool Usage:**" - Tool-specific guidance
- "**Boundaries:**" - Must NOT Do section

### Chiron-Specific Design

**Key role definition:**
- Main orchestrator in plan/analysis mode
- Read-only permissions, delegates execution to Chiron-Forge
- Coordinates 4 subagents via Task tool delegation

**Delegation logic:**
- Hermes: Work communication (email, messages, meetings)
- Athena: Work knowledge (wiki, documentation, project info)
- Apollo: Private knowledge (Obsidian vault, personal notes)
- Calliope: Writing (documentation, reports, prose)
- Chiron-Forge: Execution (file modifications, commands, builds)

**Question tool usage:**
- REQUIRED when requests are ambiguous
- Required for unclear intent or scope
- Required before delegation or analysis

**Boundaries:**
- Do NOT modify files directly (read-only)
- Do NOT execute commands (delegate to Chiron-Forge)
- Do NOT access subagent domains directly (Hermes, Athena, Apollo, Calliope)

### Style Reference

**Used apollo.txt and calliope.txt as style guides:**
- Consistent section headers with exact wording
- Second-person address throughout
- Numbered responsibilities list
- Clear separation between sections
- Specific tool usage instructions

### Verification Commands

**File size:**
```bash
wc -c prompts/chiron.txt  # Expected: > 500
```

**Keyword validation:**
```bash
grep -qi "orchestrat" prompts/chiron.txt  # Should find match
grep -qi "delegat" prompts/chiron.txt     # Should find match
grep -qi "hermes\|athena\|apollo\|calliope" prompts/chiron.txt  # Should find all 4
```

### Key Takeaways

- Standardized section headers critical for consistency across prompts
- Numbered lists for responsibilities (not bullet points) matches best practices
- Clear delegation routing prevents overlap between agent domains
- Question tool requirement prevents action on ambiguous requests
- Read-only orchestrator mode cleanly separates planning from execution
- All 4 subagents must be explicitly mentioned for routing clarity
