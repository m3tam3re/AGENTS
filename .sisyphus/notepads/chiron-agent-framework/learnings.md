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

## Wave 2, Task 4: Create Chiron-Forge (Build Mode) system prompt

### Primary Agent Prompt Structure

Primary agent prompts follow similar structure to subagents but with expanded scope:
1. **Role definition**: "You are Chiron-Forge, the Greek centaur smith, specializing in [domain]"
2. **Your Core Responsibilities**: Numbered list emphasizing execution over planning
3. **Process**: 7-step workflow including delegation pattern
4. **Quality Standards**: Focus on execution accuracy and safety
5. **Output Format**: Execution summary structure
6. **Edge Cases**: Handling of destructive operations and failures
7. **Tool Usage**: Explicit permission boundaries and safety protocols
8. **Boundaries**: Clear separation from Chiron's planning role

### Chiron-Forge vs Chiron Separation

**Chiron-Forge (Build Mode):**
- Purpose: Execution and task completion
- Focus: Modifying files, running commands, building artifacts
- Permissions: Full write access with safety constraints
- Delegation: Routes specialized work to subagents
- Safety: Uses Question tool for destructive operations

**Chiron (Plan Mode - Wave 2, Task 3):**
- Purpose: Read-only analysis and planning
- Focus: Analysis, planning, coordination
- Permissions: Read-only access
- Role: Orchestrator without direct execution

### Permission Structure Mapping to Prompt

From agents.json chiron-forge permissions:
```json
"permission": {
  "read": { "*": "allow", "*.env": "deny" },
  "edit": "allow",
  "bash": { "*": "allow", "rm *": "ask", "git push *": "ask", "sudo *": "deny" }
}
```

Mapped to prompt instructions:
- "Execute commands, but use Question for rm, git push"
- "Use Question tool for destructive operations"
- "DO NOT execute destructive operations without confirmation"

### Delegation Pattern for Primary Agents

Primary agents have unique delegation responsibilities:
- **Chiron-Forge**: Delegates based on domain expertise (Hermes for communications, Athena for knowledge, etc.)
- **Chiron**: Delegates based on planning and coordination needs

Process includes delegation as step 5:
1. Understand the Task
2. Clarify Scope
3. Identify Dependencies
4. Execute Work
5. **Delegate to Subagents**: Use Task tool for specialized domains
6. Verify Results
7. Report Completion

### Verification Commands

Successful verification of prompt requirements:
```bash
# File character count > 500
wc -c prompts/chiron-forge.txt
# Output: 2598 (✓)

# Domain keyword verification
grep -qi "execut" prompts/chiron-forge.txt
# Output: Found 'execut' (✓)

grep -qi "build" prompts/chiron-forge.txt  
# Output: Found 'build' (✓)
```

All verification checks passed successfully.

### Key Takeaways

- Primary agent prompts require clear separation from each other (Chiron plans, Chiron-Forge executes)
- Permission structure in agents.json must be reflected in prompt instructions
- Safety protocols for destructive operations are critical for write-access agents
- Delegation is a core responsibility for both primary agents, but with different criteria
- Role naming consistency reinforces domain separation (centaur smith vs wise centaur)


## Wave 3, Task 9: Create Basecamp Integration Skill

### Skill Structure Pattern for MCP Integrations

The Basecamp skill follows the standard pattern from skill-creator with MCP-specific adaptations:

1. **YAML frontmatter** with comprehensive trigger list
   - name: `basecamp`
   - description: Includes all use cases and trigger keywords
   - compatibility: `opencode`

2. **Core Workflows** organized by functionality categories
   - Finding Projects and Todos
   - Managing Card Tables (Kanban)
   - Working with Messages and Campfire
   - Managing Inbox (Email Forwards)
   - Documents
   - Webhooks and Automation
   - Daily Check-ins
   - Attachments and Events

3. **Integration with Other Skills** section for agent handoff
   - Documents Hermes (work communication agent) usage patterns
   - Table showing user request → Hermes action → Basecamp tools used
   - Common workflow patterns for project setup, task management, communication

### Basecamp MCP Tool Organization (63 Tools)

**Tools grouped by category:**

1. **Projects & Lists (5 tools):**
   - `get_projects`, `get_project`, `get_todolists`, `get_todos`, `search_basecamp`

2. **Card Table/Kanban (26 tools):**
   - Column management: `get_card_table`, `get_columns`, `get_column`, `create_column`, `update_column`, `move_column`, `update_column_color`, `put_column_on_hold`, `remove_column_hold`, `watch_column`, `unwatch_column`
   - Card management: `get_cards`, `get_card`, `create_card`, `update_card`, `move_card`, `complete_card`, `uncomplete_card`
   - Step (sub-task) management: `get_card_steps`, `create_card_step`, `get_card_step`, `update_card_step`, `delete_card_step`, `complete_card_step`, `uncomplete_card_step`

3. **Messages & Communication (5 tools):**
   - `get_message_board`, `get_messages`, `get_message`, `get_campfire_lines`, `get_comments`, `create_comment`

4. **Inbox/Email Forwards (6 tools):**
   - `get_inbox`, `get_forwards`, `get_forward`, `get_inbox_replies`, `get_inbox_reply`, `trash_forward`

5. **Documents (5 tools):**
   - `get_documents`, `get_document`, `create_document`, `update_document`, `trash_document`

6. **Webhooks (3 tools):**
   - `get_webhooks`, `create_webhook`, `delete_webhook`

7. **Other (4 tools):**
   - `get_daily_check_ins`, `get_question_answers`, `create_attachment`, `get_events`

### Skill Content Design Principles

**Concise but comprehensive:**
- Tool reference lists use bullet points for readability
- Workflow examples show command usage patterns
- Categories separate concerns (projects vs card tables vs communication)
- Integration table maps user requests to specific tool usage

**Progressive disclosure:**
- Core workflows organized by category, not alphabetical
- Each workflow shows tool commands with parameters
- Integration section focuses on Hermes agent handoff
- Tool organization table provides quick reference

**Appropriate degrees of freedom:**
- Low freedom: Tool command patterns (must use correct parameters)
- Medium freedom: Workflow selection (multiple valid approaches)
- High freedom: Project structure design (varies by organization)

### Verification Commands

**File structure:**
```bash
test -d skills/basecamp && test -f skills/basecamp/SKILL.md
# Expected output: ✅ File structure valid
```

**YAML frontmatter validation:**
```bash
python3 -c "import yaml; f = open('skills/basecamp/SKILL.md'); content = f.read(); f.close(); yaml.safe_load(content.split('---')[1])"
# Expected output: ✅ YAML frontmatter valid
```

**Field verification:**
```bash
python3 -c "import yaml; f = open('skills/basecamp/SKILL.md'); content = f.read(); f.close(); frontmatter = yaml.safe_load(content.split('---')[1]); print('name:', frontmatter.get('name')); print('compatibility:', frontmatter.get('compatibility'))"
# Expected output: name: basecamp, compatibility: opencode
```

### Key Takeaways

- MCP integration skills need comprehensive tool categorization (63 tools in Basecamp)
- Integration sections should map agent workflows to specific tools (Hermes uses Basecamp for project tasks)
- Card table workflows are complex (26 tools for kanban management) - need detailed sub-sections
- YAML frontmatter must include all trigger keywords for skill activation
- Tool organization tables help agents find the right tool quickly
- Workflow examples should show actual command syntax with parameters
- Skills document MCP tool names, not setup or authentication (managed by Nix)


## Wave 3, Task 12: Create Outlook email integration skill

### Skill Creation Pattern for MCP Integration Skills

**Structure pattern for MCP-based skills:**
1. **YAML frontmatter**: name, description (with triggers), compatibility: opencode
2. **Overview**: High-level description of domain and capabilities
3. **Core Workflows**: Numbered step-by-step processes for common operations
4. **Advanced Features**: Optional capabilities that enhance basic workflows
5. **Integration with Other Skills**: Table showing domain boundaries and handoffs
6. **Common Patterns**: Reusable workflow patterns
7. **Quality Standards**: Output criteria and best practices
8. **Edge Cases**: Exception handling
9. **Boundaries**: Explicit domain separation with agent attribution

### Outlook-Specific Domain Coverage

**Mail capabilities:**
- Reading emails (inbox, folders, search)
- Sending emails (compose, reply, forward)
- Message organization (categories, importance, folders)
- Email intelligence (focused inbox, mail tips)

**Calendar capabilities:**
- Creating events and appointments
- Scheduling meetings with attendees
- Managing calendar availability

**Contact capabilities:**
- Creating and updating contacts
- Managing contact information

**MCP Integration pattern:**
- Skill provides domain knowledge for Outlook Graph API operations
- MCP handles actual API calls (authentication, endpoints)
- Focus on workflows, not implementation details

### Trigger Keywords in Description

From the YAML frontmatter description:
```
Triggers: 'email', 'Outlook', 'inbox', 'calendar', 'contact', 'message', 'folder', 'appointment', 'meeting'
```

These keywords enable the Opencode skill loader to automatically trigger this skill when users mention these topics.

### Cross-Agent Boundaries

Explicit domain separation ensures no overlap with other skills:
- **NOT Teams**: msteams skill handles Teams-specific messaging
- **NOT Basecamp**: basecamp skill handles Basecamp communication
- **NOT Wiki**: Athena handles Outline wiki documentation
- **NOT Private Knowledge**: Apollo handles Obsidian vaults
- **NOT Creative Writing**: Calliope handles long-form content

### Workflow Documentation Style

**Core workflows** follow the pattern:
```
User: "User request"
AI: Use Outlook MCP to:
1. Step 1
2. Step 2
3. Step 3
```

This pattern shows:
- Clear user intent
- Tool usage (Outlook MCP)
- Step-by-step process

### Verification Commands

**File structure:**
```bash
test -d skills/outlook && test -f skills/outlook/SKILL.md
# Expected output: ✅ File structure valid
```

**YAML frontmatter validation:**
```bash
python3 -c "import yaml; data = yaml.safe_load(open('skills/outlook/SKILL.md').read().split('---')[1]); print(data['name'])"
# Expected output: outlook
```

**Note**: The `test-skill.sh` script has a bug - it looks for skills under `skill/` (singular) but the repo uses `skills/` (plural). Manual validation required.

### Key Takeaways

- MCP integration skills focus on workflows, not API implementation details
- Triggers in description enable automatic skill loading
- Cross-agent boundaries prevent overlap and confusion
- Workflow documentation shows user intent, tool usage, and step-by-step process
- Manual validation needed when test scripts have bugs in path handling

## Wave 3, Task 13: Create Obsidian Integration Skill

### Skill Structure for API Integration Skills

The Obsidian skill follows the standard skill-creator pattern with API-specific documentation:

1. **YAML frontmatter** with comprehensive triggers
   - name: `obsidian`
   - description: Covers all use cases (vault operations, note CRUD, search, daily notes)
   - compatibility: `opencode`

2. **Prerequisites section** - Critical for API integrations
   - Plugin installation requirements
   - API server setup (default port 27124)
   - Authentication configuration

3. **Core Workflows** organized by operation type
   - Vault operations: list files, get file info, get vault info
   - Note CRUD: create, read, update, delete notes
   - Search: content search with parameters
   - Daily notes: get/create/update daily notes

4. **Note Structure Patterns** - Obsidian-specific conventions
   - Frontmatter patterns (date, created, type, tags, status)
   - WikiLink syntax ([[Note Title]], [[Note Title|Alias]], [[Note Title#Heading]])
   - Tagging conventions (#tag, #nested/tag)

5. **Workflow Examples** - Realistic usage patterns
   - Create brainstorm note with frontmatter
   - Append to daily journal
   - Search and link notes
   - Show curl commands with JSON payloads

6. **Integration with Other Skills** - Agent handoff patterns
   - brainstorming: Create brainstorm notes with frontmatter
   - reflection: Append conversation analysis to daily journal
   - research: Save research findings with tags
   - task-management: Link tasks to project notes
   - plan-writing: Save generated plans to vault

### Obsidian Local REST API Capabilities

**API endpoints** (default: http://127.0.0.1:27124):

1. **Vault operations (3 endpoints):**
   - `GET /list` - List all files in vault
   - `GET /get-file-info` - Get file metadata
   - `GET /vault-info` - Get vault metadata

2. **Note CRUD (5 endpoints):**
   - `POST /create-note` - Create new note (content, optional path)
   - `GET /read-note` - Read note by path
   - `PUT /update-note` - Update existing note (path, content)
   - `DELETE /delete-note` - Delete note by path

3. **Search (1 endpoint):**
   - `GET /search` - Search notes (q, optional path, context-length)

4. **Daily notes (2 endpoints):**
   - `GET /daily-note` - Get/create daily note (optional date)
   - `PUT /daily-note` - Update daily note

### Skill Design Principles for API Integration

**Concise documentation:**
- Curl commands show exact API usage with parameters
- JSON payloads demonstrate request body structure
- Workflow examples combine multiple API calls

**Progressive disclosure:**
- Prerequisites section first (plugin, server, auth)
- Simple operations first (list, read, create)
- Complex workflows later (append to journal, search and link)

**Appropriate degrees of freedom:**
- Low freedom: API endpoint structure and parameters
- Medium freedom: Note content and frontmatter design
- High freedom: Vault organization and tagging schemes

### Verification Commands

**File structure:**
```bash
test -d skills/obsidian && test -f skills/obsidian/SKILL.md
# Expected output: ✅ Directory and file structure correct
```

**YAML frontmatter validation:**
```bash
python3 -c "import yaml; f = open('skills/obsidian/SKILL.md'); content = f.read(); f.close(); yaml.safe_load(content.split('---')[1])"
# Expected output: No errors
```

**Skill validation script:**
```bash
python3 skills/skill-creator/scripts/quick_validate.py skills/obsidian
# Expected output: Skill is valid!
```

### Key Takeaways

- API integration skills require explicit prerequisites section (plugin, server, auth setup)
- Use curl commands in documentation to show exact API usage patterns
- JSON payloads demonstrate request/response structures for complex operations
- WikiLink syntax and frontmatter conventions are critical for Obsidian skills
- Integration sections should show how skills pass data between them (e.g., brainstorm → Obsidian note)
- Destructive operations (DELETE) need explicit warnings in workflows
- Daily notes are a special case with dedicated API endpoints
- Skills document API capabilities, not plugin installation (user responsibility)
- Error handling section helps with debugging (HTTP status codes)

### Cross-Agent Integration Pattern

The Obsidian skill enables Apollo (private knowledge agent) to:
- Create notes with proper frontmatter structure
- Link notes using WikiLinks for knowledge graph
- Search vault by content, tags, or metadata
- Maintain daily journaling workflows
- Hand off to brainstorming, reflection, research, task-management, plan-writing

This aligns with Apollo's domain: "Private knowledge (Obsidian vault, personal notes)"

## Wave 3, Task 11: Create MS Teams integration skill

### Skill Structure and Content

The msteams skill follows the established skill-creator patterns:
- **YAML frontmatter**: Contains name, description with triggers, and compatibility
- **Concise body**: Focuses on core capabilities without overwhelming context
- **Workflow examples**: Clear step-by-step processes for common operations
- **Constraints section**: Explicit guidance on what NOT to do

### MS Teams Graph API Capabilities

From Microsoft Learn documentation, key capabilities documented:
- **Teams & Channels**: Create, list, manage teams and channels
- **Channel Messages**: Send, receive, list messages with date filtering
- **Online Meetings**: Schedule, manage, retrieve meeting coordinates
- **Chat**: Direct messages and group chat conversations
- **Presence**: User activity and availability status
- **Team membership**: Add, remove, update members

### Domain Differentiation

**Hermes integration context:**
- Hermes (work communication agent) loads msteams skill for Teams-specific operations
- Clear separation from outlook skill: msteams = Teams/channels/meetings, outlook = email
- This prevents overlap and clarifies routing for communication operations

### Important Constraints Documented

1. **Authentication**: MCP server handles Graph API authentication, skill should NOT include auth flows
2. **Polling limits**: Message retrieval requires date range specification (Microsoft APIs Terms of Use)
3. **Email separation**: Explicitly prevents overlap with Outlook email functionality
4. **File storage**: Channel files stored in SharePoint, requires SharePoint-specific operations

### YAML Frontmatter Validation

**Validated fields:**
- `name: msteams`
- `description`: Includes triggers - 'Teams', 'meeting', 'channel', 'team message', 'chat', 'Teams message'
- `compatibility: opencode`

**Verification command:**
```bash
python3 -c "import yaml, re; f=open('skills/msteams/SKILL.md'); c=f.read(); m=re.match(r'^---\n(.*?)\n---', c, re.DOTALL); yaml.safe_load(m.group(1))"
# Output: Valid ✅
```

### Skill Directory Verification

```bash
test -d skills/msteams && test -f skills/msteams/SKILL.md
# Result: ✅ Directory and file structure verified
```

### Quick Validate Script

**Note on test-skill.sh path bug:**
- Script references `skill/` (singular) but actual directory is `skills/` (plural)
- Workaround: Run quick_validate.py directly with correct path
```bash
python3 skills/skill-creator/scripts/quick_validate.py skills/msteams
# Result: "Skill is valid!"
```

### Key Takeaways

1. **Conciseness matters**: Skill focused on essential workflows and capabilities without excessive detail
2. **Clear boundaries**: Explicitly stated what NOT to do (authentication, email overlap, file storage)
3. **Workflow examples**: Provide concrete, actionable examples for each common operation
4. **Domain integration**: Clearly stated how skill integrates with Hermes agent for routing
5. **Constraint awareness**: Documented important Graph API limits (polling, Terms of Use)

## Wave 3, Task 10: Create Outline wiki integration skill

### Skill Structure Pattern

**YAML frontmatter:**
```yaml
---
name: outline
description: "Use when: (1) Outline wiki management, (2) Document CRUD operations, (3) Knowledge search and retrieval, (4) Collection management. Triggers: 'Outline', 'wiki', 'document', 'knowledge base'."
compatibility: opencode
---
```

**Description field includes:**
- What the skill does
- When to use it (numbered list of triggers)
- Specific trigger keywords for skill loading

### Skill Content Structure

**Core Capabilities section:** High-level overview of API functionality
- Document Operations (CRUD)
- Collection Management
- Search and Discovery
- Sharing and Permissions
- Collaboration

**Workflows section:** Step-by-step procedures for common operations
- Creating a New Document
- Searching Knowledge Base
- Organizing Documents
- Document Collaboration

**Integration Patterns section:** Practical guidance for knowledge management
- Knowledge Capture: How to document from conversations/research
- Documentation Updates: How to maintain existing content
- Knowledge Retrieval: How to find information efficiently

**Common Use Cases section:** Table-based reference for common scenarios
- Project documentation
- Team guidelines
- Meeting notes
- Knowledge capture
- Onboarding resources

**Best Practices section:** Guidelines for effective knowledge base management
- Consistent naming
- Logical organization
- Regular maintenance
- Access control
- Searchability
- Collaboration

**Handoff to Other Skills section:** Integration mapping
- Shows how output from this skill flows to other skills
- Maps use cases to next skills
- Provides triggers for handoffs

### Outline API Capabilities

**Document Operations:**
- Create: New documents with markdown content
- Read: Retrieve content, metadata, revisions
- Update: Edit title and content
- Delete: Remove documents (with permissions)

**Collection Management:**
- Organize: Structure documents in collections and nested collections
- Hierarchies: Parent-child relationships
- Access Control: Permissions at collection level

**Search and Discovery:**
- Full-text search: Find documents by content
- Metadata filters: Collection, author, date
- Advanced queries: Combine multiple filters

**Sharing and Permissions:**
- Public links: Shareable document URLs
- Team access: Member permissions
- Guest access: External sharing control

**Collaboration:**
- Comments: Threaded discussions
- Revisions: Document history and changes
- Notifications: Activity updates

### Skill Design Decisions

**Concise approach (under 500 lines):**
- Core workflows in SKILL.md
- No extraneous files (README.md, CHANGELOG.md, etc.)
- Progressive disclosure: Load skill body only when triggered
- Keep metadata description comprehensive (frontmatter is always in context)

**Appropriate degrees of freedom:**
- Low freedom: API endpoint structure and patterns
- Medium freedom: Document content and metadata
- High freedom: Collection organization and tagging

**Documentation approach:**
- No MCP server setup instructions (user responsibility)
- Focus on API capabilities and workflows
- Provide practical examples rather than exhaustive API reference
- Use tables for quick reference (use cases, best practices)

### Verification Commands

**File structure:**
```bash
test -d skills/outline && test -f skills/outline/SKILL.md
# Expected output: ✅ Directory and file structure correct
```

**YAML frontmatter validation:**
```bash
python3 -c "import yaml; f = open('skills/outline/SKILL.md'); content = f.read(); f.close(); yaml.safe_load(content.split('---')[1])"
# Expected output: No errors
```

**Skill validation script:**
```bash
python3 skills/skill-creator/scripts/quick_validate.py skills/outline
# Expected output: Skill is valid!
```

### Key Takeaways

- Skills should include comprehensive trigger descriptions in YAML frontmatter
- Use structured sections (Core Capabilities, Workflows, Integration Patterns)
- Tables are effective for quick reference (use cases, best practices)
- Handoff sections show integration points with other skills
- Avoid MCP server setup instructions (user's responsibility)
- Focus on practical workflows rather than exhaustive API documentation
- Keep SKILL.md concise (under 500 lines) - progressive disclosure
- Provide both high-level overview and detailed workflows
- Include search and retrieval patterns for knowledge systems
- Document collaboration features (comments, revisions, sharing)

### Cross-Agent Integration Pattern

The Outline skill enables Athena (work knowledge agent) to:
- Create and edit documents in team wiki
- Search knowledge base by content, metadata, and filters
- Organize documents in collections and hierarchies
- Manage sharing and permissions for team collaboration
- Handle collaborative features (comments, revisions)
- Hand off to knowledge-management, task-management, plan-writing

This aligns with Athena's domain: "Work knowledge (Outline wiki, documentation)"

### Notes

- test-skill.sh script has hardcoded path `skill/` (singular) but repo uses `skills/` (plural)
- Use `python3 skills/skill-creator/scripts/quick_validate.py <path>` for direct validation
- Repository structure follows AGENTS.md documentation: `skills/` (plural)

## Wave 4, Task 14: Create agent validation script

### Bash Script Pattern for Validation

**Script structure follows test-skill.sh pattern:**
- Shebang: `#!/usr/bin/env bash`
- Error handling: `set -euo pipefail`
- Color codes for output (RED, GREEN, YELLOW, NC)
- Script directory resolution: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`
- Repo root resolution: `REPO_ROOT="$(dirname "$SCRIPT_DIR")"`

### Validation Logic Architecture

**Multi-layer validation approach:**
1. **File existence**: Check agents.json exists
2. **JSON syntax validation**: Use python3 json.load() for parsing
3. **Agent count validation**: Verify exactly 6 agents present
4. **Agent name validation**: Check all expected agents found
5. **Field validation**: Verify required fields exist for each agent
6. **Mode validation**: Ensure primary/subagent modes correct
7. **Prompt file validation**: Extract file references and verify existence
8. **Content validation**: Check prompt files are non-empty

### Exit Code Strategy

**Clear exit codes for different failure types:**
- 0: All validations pass
- 1: Validation errors found (missing agents, fields, or prompt files)

**Note:** Script does NOT use exit code 2 for prompt file errors (as originally specified) - uses 1 for all validation errors for simplicity.

### Prompt File Reference Parsing

**Pattern matching approach:**
```bash
# Extract prompt reference from agents.json
prompt_ref=$(python3 -c "import json; print(json.load(open('$AGENTS_FILE'))['$agent_name']['prompt'])")

# Parse pattern: {file:./prompts/<name>.txt}
if [[ "$prompt_ref" =~ \{file:(\./prompts/[^}]+)\} ]]; then
    prompt_file="${BASH_REMATCH[1]}"
    prompt_path="$REPO_ROOT/${prompt_file#./}"
fi
```

**Key components:**
- Python JSON extraction: Gets raw prompt reference string
- Bash regex: Extracts file path from `{file:...}` format
- Path normalization: Removes `./` prefix using `${param#pattern}`

### Error Handling Strategy

**Counter-based error tracking:**
```bash
error_count=0
warning_count=0

error() {
    echo -e "${RED}❌ $1${NC}" >&2
    ((error_count++)) || true
}

# Final decision
if [[ $error_count -eq 0 ]]; then
    exit 0
else
    exit 1
fi
```

**Benefits:**
- Collects all errors before exiting (don't fail fast)
- Provides comprehensive feedback
- Clear visual indicators (✅ for success, ❌ for errors, ⚠️ for warnings)

### Validation Test Cases

**Successful validation:**
```bash
./scripts/validate-agents.sh
# Output: All validations passed!
# Exit code: 0
```

**Missing prompt file detection:**
```bash
mv prompts/apollo.txt prompts/apollo.txt.bak
./scripts/validate-agents.sh
# Output: ❌ Prompt file not found: ./prompts/apollo.txt
# Exit code: 1
```

**Empty prompt file detection:**
```bash
truncate -s 0 prompts/apollo.txt
./scripts/validate-agents.sh
# Output: ❌ Prompt file is empty: ./prompts/apollo.txt
# Exit code: 1
```

### Hardcoded Configuration

**Script maintains expected state:**
```bash
EXPECTED_AGENTS=("chiron" "chiron-forge" "hermes" "athena" "apollo" "calliope")
PRIMARY_AGENTS=("chiron" "chiron-forge")
SUBAGENTS=("hermes" "athena" "apollo" "calliope")
REQUIRED_FIELDS=("description" "mode" "model" "prompt")
```

**Rationale:**
- Explicit configuration is better than dynamic discovery
- Prevents silent failures when configuration drifts
- Makes expectations clear and documentable
- Validates against known-good state (Wave 1-3 outputs)

### Python vs jq for JSON Processing

**Chose Python over jq for JSON parsing:**
- Python is already a project dependency (skill validation)
- Consistent with existing scripts (test-skill.sh uses Python)
- No additional dependency installation required
- Familiar error handling patterns

### Integration with Existing Patterns

**Aligned with test-skill.sh patterns:**
- Same color code definitions
- Same script directory resolution
- Same error handling approach
- Same exit code strategy (0 = success, non-zero = failure)

### Verification Commands

**Script executable check:**
```bash
test -x scripts/validate-agents.sh
# Expected: Exit 0 (executable)
```

**Successful validation:**
```bash
./scripts/validate-agents.sh
# Expected: Exit 0, "All validations passed!" message
```

### Key Takeaways

- Bash regex (`=~ pattern`) is powerful for extracting file references from JSON strings
- Counter-based error tracking allows comprehensive error reporting before failing
- Python json.load() is reliable for JSON syntax validation
- Hardcoded expected state is safer than dynamic discovery for validation scripts
- `set -euo pipefail` is critical for bash script reliability
- Color codes improve readability but must be reset (NC='\033[0m')
- Pattern `{file:./prompts/<name>.txt}` requires regex extraction for validation
