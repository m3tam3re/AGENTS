# Chiron Personal Agent Framework

## TL;DR

> **Quick Summary**: Create an Oh-My-Opencode-style agent framework for personal productivity with Chiron as the orchestrator, 4 specialized subagents (Hermes, Athena, Apollo, Calliope), and 5 tool integration skills (Basecamp, Outline, MS Teams, Outlook, Obsidian).
> 
> **Deliverables**:
> - 6 agent definitions in `agents.json`
> - 6 system prompt files in `prompts/`
> - 5 tool integration skills in `skills/`
> - Validation script extension in `scripts/`
> 
> **Estimated Effort**: Medium
> **Parallel Execution**: YES - 3 waves
> **Critical Path**: Task 1 (agents.json) → Task 3-7 (prompts) → Task 9-13 (skills) → Task 14 (validation)

---

## Context

### Original Request
Create an agent framework similar to Oh-My-Opencode but focused on personal productivity:
- Manage work tasks, appointments, projects via Basecamp, Outline, MS Teams, Outlook
- Manage private tasks and knowledge via Obsidian
- Greek mythology naming convention (avoiding Oh My OpenCode names)
- Main agent named "Chiron"

### Interview Summary
**Key Discussions**:
- **Chiron's Role**: Main orchestrator that delegates to specialized subagents
- **Agent Count**: Minimal (3-4 agents initially) + 2 primary agents
- **Domain Separation**: Separate work vs private agents with clear boundaries
- **Tool Priority**: All 4 work tools + Obsidian equally important
- **Basecamp MCP**: User confirmed working MCP at georgeantonopoulos/Basecamp-MCP-Server

**Research Findings**:
- Oh My OpenCode names to avoid: Sisyphus, Atlas, Prometheus, Hephaestus, Metis, Momus, Oracle, Librarian, Explore, Multimodal-Looker, Sisyphus-Junior
- MCP servers available for all work tools + Obsidian
- Protonmail requires custom IMAP/SMTP (deferred)
- Current repo has established skill patterns with SKILL.md + optional subdirectories

### Metis Review
**Identified Gaps** (addressed in plan):
- Delegation model clarified: Chiron uses Question tool for ambiguous requests
- Behavioral difference between Chiron and Chiron-Forge defined
- Executable acceptance criteria added for all tasks
- Edge cases documented in guardrails section
- MCP authentication assumed pre-configured by NixOS (explicit scope boundary)

---

## Work Objectives

### Core Objective
Create a personal productivity agent framework following Oh-My-Opencode patterns, enabling AI-assisted management of work and private life through specialized agents that integrate with existing tools.

### Concrete Deliverables
1. `agents/agents.json` - 6 agent definitions (2 primary, 4 subagent)
2. `prompts/chiron.txt` - Chiron (plan mode) system prompt
3. `prompts/chiron-forge.txt` - Chiron-Forge (build mode) system prompt
4. `prompts/hermes.txt` - Work communication agent prompt
5. `prompts/athena.txt` - Work knowledge agent prompt
6. `prompts/apollo.txt` - Private knowledge agent prompt
7. `prompts/calliope.txt` - Writing agent prompt
8. `skills/basecamp/SKILL.md` - Basecamp integration skill
9. `skills/outline/SKILL.md` - Outline wiki integration skill
10. `skills/msteams/SKILL.md` - MS Teams integration skill
11. `skills/outlook/SKILL.md` - Outlook email integration skill
12. `skills/obsidian/SKILL.md` - Obsidian integration skill
13. `scripts/validate-agents.sh` - Agent validation script

### Definition of Done
- [ ] `python3 -c "import json; json.load(open('agents/agents.json'))"` → Exit 0
- [ ] All 6 prompt files exist and are non-empty
- [ ] All 5 skill directories have valid SKILL.md with YAML frontmatter
- [ ] `./scripts/test-skill.sh --validate` passes for new skills
- [ ] `./scripts/validate-agents.sh` passes

### Must Have
- All agents use Question tool for multi-choice decisions
- External prompt files (not inline in JSON)
- Follow existing skill structure patterns
- Greek naming convention for agents
- Clear separation between plan mode (Chiron) and build mode (Chiron-Forge)
- Skills provide tool-specific knowledge that agents load on demand

### Must NOT Have (Guardrails)
- **NO MCP server configuration** - Managed by NixOS, outside this repo
- **NO authentication handling** - Assume pre-configured MCP tools
- **NO cross-agent state sharing** - Each agent operates independently
- **NO new opencode commands** - Use existing command patterns only
- **NO generic "I'm an AI assistant" prompts** - Domain-specific responsibilities only
- **NO Protonmail integration** - Deferred to future phase
- **NO duplicate tool knowledge across skills** - Each skill focuses on ONE tool
- **NO scripts outside scripts/ directory**
- **NO model configuration changes** - Keep current `zai-coding-plan/glm-4.7`

---

## Verification Strategy (MANDATORY)

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> ALL tasks in this plan MUST be verifiable WITHOUT any human action.
> This is NOT conditional - it applies to EVERY task, regardless of test strategy.

### Test Decision
- **Infrastructure exists**: YES (test-skill.sh)
- **Automated tests**: Tests-after (validation scripts)
- **Framework**: bash + python for validation

### Agent-Executed QA Scenarios (MANDATORY - ALL tasks)

**Verification Tool by Deliverable Type:**

| Type | Tool | How Agent Verifies |
|------|------|-------------------|
| agents.json | Bash (python/jq) | Parse JSON, validate structure, check required fields |
| Prompt files | Bash (file checks) | File exists, non-empty, contains expected sections |
| SKILL.md files | Bash (test-skill.sh) | YAML frontmatter valid, name matches directory |
| Validation scripts | Bash | Script is executable, runs without error, produces expected output |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately):
├── Task 1: Create agents.json configuration [no dependencies]
└── Task 2: Create prompts/ directory structure [no dependencies]

Wave 2 (After Wave 1):
├── Task 3: Chiron prompt [depends: 2]
├── Task 4: Chiron-Forge prompt [depends: 2]
├── Task 5: Hermes prompt [depends: 2]
├── Task 6: Athena prompt [depends: 2]
├── Task 7: Apollo prompt [depends: 2]
└── Task 8: Calliope prompt [depends: 2]

Wave 3 (Can parallel with Wave 2):
├── Task 9: Basecamp skill [no dependencies]
├── Task 10: Outline skill [no dependencies]
├── Task 11: MS Teams skill [no dependencies]
├── Task 12: Outlook skill [no dependencies]
└── Task 13: Obsidian skill [no dependencies]

Wave 4 (After Wave 2 + 3):
└── Task 14: Validation script [depends: 1, 3-8]

Critical Path: Task 1 → Task 2 → Tasks 3-8 → Task 14
Parallel Speedup: ~50% faster than sequential
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | 14 | 2, 9-13 |
| 2 | None | 3-8 | 1, 9-13 |
| 3-8 | 2 | 14 | Each other, 9-13 |
| 9-13 | None | None | Each other, 1-2 |
| 14 | 1, 3-8 | None | None (final) |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Category |
|------|-------|---------------------|
| 1 | 1, 2 | quick |
| 2 | 3-8 | quick (parallel) |
| 3 | 9-13 | quick (parallel) |
| 4 | 14 | quick |

---

## TODOs

### Wave 1: Foundation

 - [x] 1. Create agents.json with 6 agent definitions

  **What to do**:
  - Update existing `agents/agents.json` to add all 6 agents
  - Each agent needs: description, mode, model, prompt reference
  - Primary agents: chiron, chiron-forge
  - Subagents: hermes, athena, apollo, calliope
  - All agents should have `question: "allow"` permission

  **Must NOT do**:
  - Do not add MCP server configuration
  - Do not change model from current pattern
  - Do not add inline prompts (use file references)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`agent-development`]
    - `agent-development`: Provides agent configuration patterns and best practices

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 2)
  - **Blocks**: Task 14
  - **Blocked By**: None

  **References**:
  - `agents/agents.json:1-7` - Current chiron agent configuration pattern
  - `skills/agent-development/SKILL.md:40-76` - JSON agent structure reference
  - `skills/agent-development/SKILL.md:226-277` - Permissions system reference
  - `skills/agent-development/references/opencode-agents-json-example.md` - Complete examples

  **Acceptance Criteria**:

  ```
  Scenario: agents.json is valid JSON with all 6 agents
    Tool: Bash (python)
    Steps:
      1. python3 -c "import json; data = json.load(open('agents/agents.json')); print(len(data))"
      2. Assert: Output is "6"
      3. python3 -c "import json; data = json.load(open('agents/agents.json')); print(sorted(data.keys()))"
      4. Assert: Output contains ['apollo', 'athena', 'calliope', 'chiron', 'chiron-forge', 'hermes']
    Expected Result: JSON parses, all 6 agents present
    Evidence: Command output captured

  Scenario: Each agent has required fields
    Tool: Bash (python)
    Steps:
      1. python3 -c "
         import json
         data = json.load(open('agents/agents.json'))
         for name, agent in data.items():
             assert 'description' in agent, f'{name}: missing description'
             assert 'mode' in agent, f'{name}: missing mode'
             assert 'prompt' in agent, f'{name}: missing prompt'
         print('All agents valid')
         "
      2. Assert: Output is "All agents valid"
    Expected Result: All required fields present
    Evidence: Validation output captured

  Scenario: Primary agents have correct mode
    Tool: Bash (python)
    Steps:
      1. python3 -c "
         import json
         data = json.load(open('agents/agents.json'))
         assert data['chiron']['mode'] == 'primary'
         assert data['chiron-forge']['mode'] == 'primary'
         print('Primary modes correct')
         "
    Expected Result: Both primary agents have mode=primary
    Evidence: Command output

  Scenario: Subagents have correct mode
    Tool: Bash (python)
    Steps:
      1. python3 -c "
         import json
         data = json.load(open('agents/agents.json'))
         for name in ['hermes', 'athena', 'apollo', 'calliope']:
             assert data[name]['mode'] == 'subagent', f'{name}: wrong mode'
         print('Subagent modes correct')
         "
    Expected Result: All subagents have mode=subagent
    Evidence: Command output
  ```

  **Commit**: YES
  - Message: `feat(agents): add chiron agent framework with 6 agents`
  - Files: `agents/agents.json`
  - Pre-commit: `python3 -c "import json; json.load(open('agents/agents.json'))"`

---

 - [x] 2. Create prompts directory structure

  **What to do**:
  - Create `prompts/` directory if not exists
  - Directory will hold all agent system prompt files

  **Must NOT do**:
  - Do not create prompt files yet (done in Wave 2)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 1)
  - **Blocks**: Tasks 3-8
  - **Blocked By**: None

  **References**:
  - `skills/agent-development/SKILL.md:148-159` - Prompt file conventions

  **Acceptance Criteria**:

  ```
  Scenario: prompts directory exists
    Tool: Bash
    Steps:
      1. test -d prompts && echo "exists" || echo "missing"
      2. Assert: Output is "exists"
    Expected Result: Directory created
    Evidence: Command output
  ```

  **Commit**: NO (groups with Task 1)

---

### Wave 2: Agent Prompts

 - [x] 3. Create Chiron (Plan Mode) system prompt

  **What to do**:
  - Create `prompts/chiron.txt`
  - Define Chiron as the main orchestrator in plan/analysis mode
  - Include delegation logic to subagents (Hermes, Athena, Apollo, Calliope)
  - Include Question tool usage for ambiguous requests
  - Focus on: planning, analysis, guidance, delegation
  - Permissions: read-only, no file modifications

  **Must NOT do**:
  - Do not allow write/edit operations
  - Do not include execution responsibilities
  - Do not overlap with Chiron-Forge's build capabilities

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`agent-development`]
    - `agent-development`: System prompt design patterns

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 4-8)
  - **Blocks**: Task 14
  - **Blocked By**: Task 2

  **References**:
  - `skills/agent-development/SKILL.md:349-386` - System prompt design patterns
  - `skills/agent-development/SKILL.md:397-415` - Prompt best practices
  - `skills/agent-development/references/system-prompt-design.md` - Detailed prompt patterns

  **Acceptance Criteria**:

  ```
  Scenario: Chiron prompt file exists and is substantial
    Tool: Bash
    Steps:
      1. test -f prompts/chiron.txt && echo "exists" || echo "missing"
      2. Assert: Output is "exists"
      3. wc -c < prompts/chiron.txt
      4. Assert: Output is > 500 (substantial content)
    Expected Result: File exists with meaningful content
    Evidence: File size captured

  Scenario: Chiron prompt contains orchestrator role
    Tool: Bash (grep)
    Steps:
      1. grep -qi "orchestrat" prompts/chiron.txt && echo "found" || echo "missing"
      2. Assert: Output is "found"
      3. grep -qi "delegat" prompts/chiron.txt && echo "found" || echo "missing"
      4. Assert: Output is "found"
    Expected Result: Prompt describes orchestration and delegation
    Evidence: grep output

  Scenario: Chiron prompt references subagents
    Tool: Bash (grep)
    Steps:
      1. grep -qi "hermes" prompts/chiron.txt && echo "found" || echo "missing"
      2. grep -qi "athena" prompts/chiron.txt && echo "found" || echo "missing"
      3. grep -qi "apollo" prompts/chiron.txt && echo "found" || echo "missing"
      4. grep -qi "calliope" prompts/chiron.txt && echo "found" || echo "missing"
    Expected Result: All 4 subagents mentioned
    Evidence: grep outputs
  ```

  **Commit**: YES (group with Tasks 4-8)
  - Message: `feat(prompts): add chiron and subagent system prompts`
  - Files: `prompts/*.txt`
  - Pre-commit: `for f in prompts/*.txt; do test -s "$f" || exit 1; done`

---

 - [x] 4. Create Chiron-Forge (Build Mode) system prompt

  **What to do**:
  - Create `prompts/chiron-forge.txt`
  - Define as Chiron's execution/build counterpart
  - Full write access for task execution
  - Can modify files, run commands, complete tasks
  - Still delegates to subagents for specialized domains
  - Uses Question tool for destructive operations confirmation

  **Must NOT do**:
  - Do not make it a planning-only agent (that's Chiron)
  - Do not allow destructive operations without confirmation

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`agent-development`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 3, 5-8)
  - **Blocks**: Task 14
  - **Blocked By**: Task 2

  **References**:
  - `skills/agent-development/SKILL.md:316-346` - Complete agent example with chiron/chiron-forge pattern
  - `skills/agent-development/SKILL.md:253-277` - Permission patterns for bash commands

  **Acceptance Criteria**:

  ```
  Scenario: Chiron-Forge prompt file exists
    Tool: Bash
    Steps:
      1. test -f prompts/chiron-forge.txt && wc -c < prompts/chiron-forge.txt
      2. Assert: Output > 500
    Expected Result: File exists with substantial content
    Evidence: File size

  Scenario: Chiron-Forge prompt emphasizes execution
    Tool: Bash (grep)
    Steps:
      1. grep -qi "execut" prompts/chiron-forge.txt && echo "found" || echo "missing"
      2. grep -qi "build" prompts/chiron-forge.txt && echo "found" || echo "missing"
    Expected Result: Execution/build terminology present
    Evidence: grep output
  ```

  **Commit**: YES (groups with Task 3)

---

 - [x] 5. Create Hermes (Work Communication) system prompt

  **What to do**:
  - Create `prompts/hermes.txt`
  - Specialization: Basecamp tasks, Outlook email, MS Teams meetings
  - Greek god of communication, messengers, quick tasks
  - Uses Question tool for: which tool to use, clarifying recipients
  - Focus on: task updates, email drafting, meeting scheduling

  **Must NOT do**:
  - Do not handle documentation (Athena's domain)
  - Do not handle personal/private tools (Apollo's domain)
  - Do not write long-form content (Calliope's domain)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`agent-development`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 14
  - **Blocked By**: Task 2

  **References**:
  - `skills/agent-development/SKILL.md:349-378` - Standard prompt structure

  **Acceptance Criteria**:

  ```
  Scenario: Hermes prompt defines communication domain
    Tool: Bash (grep)
    Steps:
      1. grep -qi "basecamp" prompts/hermes.txt && echo "found" || echo "missing"
      2. grep -qi "outlook\|email" prompts/hermes.txt && echo "found" || echo "missing"
      3. grep -qi "teams\|meeting" prompts/hermes.txt && echo "found" || echo "missing"
    Expected Result: All 3 tools mentioned
    Evidence: grep outputs
  ```

  **Commit**: YES (groups with Task 3)

---

 - [x] 6. Create Athena (Work Knowledge) system prompt

  **What to do**:
  - Create `prompts/athena.txt`
  - Specialization: Outline wiki, documentation, knowledge organization
  - Greek goddess of wisdom and strategic warfare
  - Focus on: wiki search, knowledge retrieval, documentation updates
  - Uses Question tool for: which document to update, clarifying search scope

  **Must NOT do**:
  - Do not handle communication (Hermes's domain)
  - Do not handle private knowledge (Apollo's domain)
  - Do not write creative content (Calliope's domain)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`agent-development`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 14
  - **Blocked By**: Task 2

  **References**:
  - `skills/agent-development/SKILL.md:349-378` - Standard prompt structure

  **Acceptance Criteria**:

  ```
  Scenario: Athena prompt defines knowledge domain
    Tool: Bash (grep)
    Steps:
      1. grep -qi "outline" prompts/athena.txt && echo "found" || echo "missing"
      2. grep -qi "wiki\|knowledge" prompts/athena.txt && echo "found" || echo "missing"
      3. grep -qi "document" prompts/athena.txt && echo "found" || echo "missing"
    Expected Result: Outline and knowledge terms present
    Evidence: grep outputs
  ```

  **Commit**: YES (groups with Task 3)

---

 - [x] 7. Create Apollo (Private Knowledge) system prompt

  **What to do**:
  - Create `prompts/apollo.txt`
  - Specialization: Obsidian vault, personal notes, private knowledge graph
  - Greek god of knowledge, prophecy, and light
  - Focus on: note search, personal task management, knowledge retrieval
  - Uses Question tool for: clarifying which vault, which note

  **Must NOT do**:
  - Do not handle work tools (Hermes/Athena's domain)
  - Do not expose personal data to work contexts
  - Do not write long-form content (Calliope's domain)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`agent-development`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 14
  - **Blocked By**: Task 2

  **References**:
  - `skills/agent-development/SKILL.md:349-378` - Standard prompt structure

  **Acceptance Criteria**:

  ```
  Scenario: Apollo prompt defines private knowledge domain
    Tool: Bash (grep)
    Steps:
      1. grep -qi "obsidian" prompts/apollo.txt && echo "found" || echo "missing"
      2. grep -qi "personal\|private" prompts/apollo.txt && echo "found" || echo "missing"
      3. grep -qi "note\|vault" prompts/apollo.txt && echo "found" || echo "missing"
    Expected Result: Obsidian and personal knowledge terms present
    Evidence: grep outputs
  ```

  **Commit**: YES (groups with Task 3)

---

 - [x] 8. Create Calliope (Writing) system prompt

  **What to do**:
  - Create `prompts/calliope.txt`
  - Specialization: documentation writing, reports, meeting notes, prose
  - Greek muse of epic poetry and eloquence
  - Focus on: drafting documents, summarizing, writing assistance
  - Uses Question tool for: clarifying tone, audience, format

  **Must NOT do**:
  - Do not manage tools directly (delegates to other agents for tool access)
  - Do not handle short communication (Hermes's domain)
  - Do not overlap with Athena's wiki management

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`agent-development`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 14
  - **Blocked By**: Task 2

  **References**:
  - `skills/agent-development/SKILL.md:349-378` - Standard prompt structure

  **Acceptance Criteria**:

  ```
  Scenario: Calliope prompt defines writing domain
    Tool: Bash (grep)
    Steps:
      1. grep -qi "writ" prompts/calliope.txt && echo "found" || echo "missing"
      2. grep -qi "document" prompts/calliope.txt && echo "found" || echo "missing"
      3. grep -qi "report\|summar" prompts/calliope.txt && echo "found" || echo "missing"
    Expected Result: Writing and documentation terms present
    Evidence: grep outputs
  ```

  **Commit**: YES (groups with Task 3)

---

### Wave 3: Tool Integration Skills

 - [x] 9. Create Basecamp integration skill

  **What to do**:
  - Create `skills/basecamp/SKILL.md`
  - Document Basecamp MCP capabilities (63 tools from georgeantonopoulos/Basecamp-MCP-Server)
  - Include: projects, todos, messages, card tables, campfire, webhooks
  - Provide workflow examples for common operations
  - Reference MCP tool names for agent use

  **Must NOT do**:
  - Do not include MCP server setup instructions (managed by Nix)
  - Do not duplicate general project management advice
  - Do not include authentication handling

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`skill-creator`]
    - `skill-creator`: Provides skill structure patterns and validation

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 10-13)
  - **Blocks**: None
  - **Blocked By**: None

  **References**:
  - `skills/skill-creator/SKILL.md` - Skill creation patterns
  - `skills/brainstorming/SKILL.md` - Example skill structure
  - https://github.com/georgeantonopoulos/Basecamp-MCP-Server - MCP tool documentation

  **Acceptance Criteria**:

  ```
  Scenario: Basecamp skill has valid structure
    Tool: Bash
    Steps:
      1. test -d skills/basecamp && echo "dir exists"
      2. test -f skills/basecamp/SKILL.md && echo "file exists"
      3. ./scripts/test-skill.sh --validate basecamp || echo "validation failed"
    Expected Result: Directory and SKILL.md exist, validation passes
    Evidence: Command outputs

  Scenario: Basecamp skill has valid frontmatter
    Tool: Bash (python)
    Steps:
      1. python3 -c "
         import yaml
         content = open('skills/basecamp/SKILL.md').read()
         front = content.split('---')[1]
         data = yaml.safe_load(front)
         assert data['name'] == 'basecamp', 'name mismatch'
         assert 'description' in data, 'missing description'
         print('Valid')
         "
    Expected Result: YAML frontmatter valid with correct name
    Evidence: Python output
  ```

  **Commit**: YES
  - Message: `feat(skills): add basecamp integration skill`
  - Files: `skills/basecamp/SKILL.md`
  - Pre-commit: `./scripts/test-skill.sh --validate basecamp`

---

 - [x] 10. Create Outline wiki integration skill

  **What to do**:
  - Create `skills/outline/SKILL.md`
  - Document Outline API capabilities
  - Include: document CRUD, search, collections, sharing
  - Provide workflow examples for knowledge management

  **Must NOT do**:
  - Do not include MCP server setup
  - Do not duplicate wiki concepts

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`skill-creator`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3
  - **Blocks**: None
  - **Blocked By**: None

  **References**:
  - `skills/skill-creator/SKILL.md` - Skill creation patterns
  - https://www.getoutline.com/developers - Outline API documentation

  **Acceptance Criteria**:

  ```
  Scenario: Outline skill has valid structure
    Tool: Bash
    Steps:
      1. test -d skills/outline && test -f skills/outline/SKILL.md && echo "exists"
      2. ./scripts/test-skill.sh --validate outline || echo "failed"
    Expected Result: Valid skill structure
    Evidence: Command output
  ```

  **Commit**: YES
  - Message: `feat(skills): add outline wiki integration skill`
  - Files: `skills/outline/SKILL.md`
  - Pre-commit: `./scripts/test-skill.sh --validate outline`

---

 - [x] 11. Create MS Teams integration skill

  **What to do**:
  - Create `skills/msteams/SKILL.md`
  - Document MS Teams Graph API capabilities via MCP
  - Include: channels, messages, meetings, chat
  - Provide workflow examples for team communication

  **Must NOT do**:
  - Do not include Graph API authentication flows
  - Do not overlap with Outlook email functionality

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`skill-creator`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3
  - **Blocks**: None
  - **Blocked By**: None

  **References**:
  - `skills/skill-creator/SKILL.md` - Skill creation patterns
  - https://learn.microsoft.com/en-us/graph/api/resources/teams-api-overview - Teams API

  **Acceptance Criteria**:

  ```
  Scenario: MS Teams skill has valid structure
    Tool: Bash
    Steps:
      1. test -d skills/msteams && test -f skills/msteams/SKILL.md && echo "exists"
      2. ./scripts/test-skill.sh --validate msteams || echo "failed"
    Expected Result: Valid skill structure
    Evidence: Command output
  ```

  **Commit**: YES
  - Message: `feat(skills): add ms teams integration skill`
  - Files: `skills/msteams/SKILL.md`
  - Pre-commit: `./scripts/test-skill.sh --validate msteams`

---

 - [x] 12. Create Outlook email integration skill

  **What to do**:
  - Create `skills/outlook/SKILL.md`
  - Document Outlook Graph API capabilities via MCP
  - Include: mail CRUD, calendar, contacts, folders
  - Provide workflow examples for email management

  **Must NOT do**:
  - Do not include Graph API authentication
  - Do not overlap with Teams functionality

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`skill-creator`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3
  - **Blocks**: None
  - **Blocked By**: None

  **References**:
  - `skills/skill-creator/SKILL.md` - Skill creation patterns
  - https://learn.microsoft.com/en-us/graph/outlook-mail-concept-overview - Outlook API

  **Acceptance Criteria**:

  ```
  Scenario: Outlook skill has valid structure
    Tool: Bash
    Steps:
      1. test -d skills/outlook && test -f skills/outlook/SKILL.md && echo "exists"
      2. ./scripts/test-skill.sh --validate outlook || echo "failed"
    Expected Result: Valid skill structure
    Evidence: Command output
  ```

  **Commit**: YES
  - Message: `feat(skills): add outlook email integration skill`
  - Files: `skills/outlook/SKILL.md`
  - Pre-commit: `./scripts/test-skill.sh --validate outlook`

---

 - [x] 13. Create Obsidian integration skill

  **What to do**:
  - Create `skills/obsidian/SKILL.md`
  - Document Obsidian Local REST API capabilities
  - Include: vault operations, note CRUD, search, daily notes
  - Reference skills/brainstorming/references/obsidian-workflow.md for patterns

  **Must NOT do**:
  - Do not include plugin installation
  - Do not duplicate general note-taking advice

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`skill-creator`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3
  - **Blocks**: None
  - **Blocked By**: None

  **References**:
  - `skills/skill-creator/SKILL.md` - Skill creation patterns
  - `skills/brainstorming/references/obsidian-workflow.md` - Existing Obsidian patterns
  - https://coddingtonbear.github.io/obsidian-local-rest-api/ - Local REST API docs

  **Acceptance Criteria**:

  ```
  Scenario: Obsidian skill has valid structure
    Tool: Bash
    Steps:
      1. test -d skills/obsidian && test -f skills/obsidian/SKILL.md && echo "exists"
      2. ./scripts/test-skill.sh --validate obsidian || echo "failed"
    Expected Result: Valid skill structure
    Evidence: Command output
  ```

  **Commit**: YES
  - Message: `feat(skills): add obsidian integration skill`
  - Files: `skills/obsidian/SKILL.md`
  - Pre-commit: `./scripts/test-skill.sh --validate obsidian`

---

### Wave 4: Validation

 - [x] 14. Create agent validation script

  **What to do**:
  - Create `scripts/validate-agents.sh`
  - Validate agents.json structure and required fields
  - Verify all referenced prompt files exist
  - Check prompt files are non-empty
  - Integrate with existing test-skill.sh patterns

  **Must NOT do**:
  - Do not require MCP servers for validation
  - Do not perform functional agent testing (just structural)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Sequential (Wave 4)
  - **Blocks**: None
  - **Blocked By**: Tasks 1, 3-8

  **References**:
  - `scripts/test-skill.sh` - Existing validation script pattern

  **Acceptance Criteria**:

  ```
  Scenario: Validation script is executable
    Tool: Bash
    Steps:
      1. test -x scripts/validate-agents.sh && echo "executable" || echo "not executable"
      2. Assert: Output is "executable"
    Expected Result: Script has execute permission
    Evidence: Command output

  Scenario: Validation script runs successfully
    Tool: Bash
    Steps:
      1. ./scripts/validate-agents.sh
      2. Assert: Exit code is 0
    Expected Result: All validations pass
    Evidence: Script output

  Scenario: Validation script catches missing files
    Tool: Bash
    Steps:
      1. mv prompts/chiron.txt prompts/chiron.txt.bak
      2. ./scripts/validate-agents.sh
      3. Assert: Exit code is NOT 0
      4. mv prompts/chiron.txt.bak prompts/chiron.txt
    Expected Result: Script detects missing prompt file
    Evidence: Error output
  ```

  **Commit**: YES
  - Message: `feat(scripts): add agent validation script`
  - Files: `scripts/validate-agents.sh`
  - Pre-commit: `./scripts/validate-agents.sh`

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1, 2 | `feat(agents): add chiron agent framework with 6 agents` | agents/agents.json, prompts/ | `python3 -c "import json; json.load(open('agents/agents.json'))"` |
| 3-8 | `feat(prompts): add chiron and subagent system prompts` | prompts/*.txt | `for f in prompts/*.txt; do test -s "$f"; done` |
| 9 | `feat(skills): add basecamp integration skill` | skills/basecamp/ | `./scripts/test-skill.sh --validate basecamp` |
| 10 | `feat(skills): add outline wiki integration skill` | skills/outline/ | `./scripts/test-skill.sh --validate outline` |
| 11 | `feat(skills): add ms teams integration skill` | skills/msteams/ | `./scripts/test-skill.sh --validate msteams` |
| 12 | `feat(skills): add outlook email integration skill` | skills/outlook/ | `./scripts/test-skill.sh --validate outlook` |
| 13 | `feat(skills): add obsidian integration skill` | skills/obsidian/ | `./scripts/test-skill.sh --validate obsidian` |
| 14 | `feat(scripts): add agent validation script` | scripts/validate-agents.sh | `./scripts/validate-agents.sh` |

---

## Success Criteria

### Verification Commands
```bash
# Validate agents.json
python3 -c "import json; json.load(open('agents/agents.json'))"  # Expected: exit 0

# Count agents
python3 -c "import json; print(len(json.load(open('agents/agents.json'))))"  # Expected: 6

# Validate all prompts exist
for f in chiron chiron-forge hermes athena apollo calliope; do
  test -s prompts/$f.txt && echo "$f: OK" || echo "$f: MISSING"
done

# Validate all skills
./scripts/test-skill.sh --validate  # Expected: all pass

# Run full validation
./scripts/validate-agents.sh  # Expected: exit 0
```

### Final Checklist
 - [x] All 6 agents defined in agents.json
- [ ] All 6 prompt files exist and are non-empty
- [ ] All 5 skills have valid SKILL.md with YAML frontmatter
- [ ] validate-agents.sh passes
- [ ] test-skill.sh --validate passes
- [ ] No MCP configuration in repo
- [ ] No inline prompts in agents.json
- [ ] All agent names are Greek mythology (not conflicting with Oh My OpenCode)
