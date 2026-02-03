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

## Task: Create prompts/calliope.txt

### Calliope Prompt Pattern
- Purpose: Writing specialist for documentation, reports, meeting notes, and professional prose
- Identity: Greek muse of epic poetry and eloquence
- Core distinction: Focuses on eloquence and structure, not technical implementation
- Second-person addressing: "You are..." format

### Key Components
- **Identity**: "Greek muse of epic poetry and eloquence, specializing in writing assistance"
- **Capabilities**: Draft documentation, create reports, transform notes to summaries, professional writing
- **Workflow**: Understand → Clarify (Question tool) → Gather → Draft → Refine → Review
- **Quality Standards**: Clarity, logical structure, consistent terminology, accurate representation
- **Output Format**: Clear hierarchy, bullet/numbered lists, tables, executive summaries, action items

### Scope Boundaries
- DO NOT execute code or run commands (delegate to technical agents)
- DO NOT handle short communication (Hermes's domain)
- DO NOT manage wiki knowledge bases (Athena's domain)
- DO NOT make factual assertions without verification
- DO NOT write specialized domain content without input

### Verification
- File size: 3390 chars (well above 500 minimum)
- Keywords present: writing, document, report, summaries
- Lines: 48
- Follows standard prompt structure from agent-development skill

### Files Created
- `prompts/calliope.txt` - Calliope writing specialist system prompt (48 lines)

## Task: Create skills/msteams/SKILL.md

### MS Teams Skill Pattern
- Description format: Clear trigger conditions with numbered use cases
- Structure: Quick start → Core API capabilities → Common workflows → API endpoint reference → Best practices → Integration examples
- Scope: Channels, messages, meetings, chat operations
- Excluded: Authentication flows (handled externally), Outlook email functionality

### Verification
- YAML frontmatter validation: `python3 -c "import yaml; yaml.safe_load()"`
- Required fields: name, description, compatibility
- Body content: >7400 chars, comprehensive coverage

### Files Created
- `skills/msteams/SKILL.md` - Complete Teams Graph API integration documentation

## Task: Create skills/obsidian/SKILL.md

### Obsidian Skill Pattern
- Purpose: Document Obsidian Local REST API integration
- API base URL: http://localhost:27124
- Core capabilities: vault operations, note CRUD, search, daily notes

### SKILL.md Requirements
- YAML frontmatter with quoted description when using special characters
- Required fields: name, description, compatibility: opencode
- Description must include "Use when:" triggers and "Triggers:" examples
- Body follows markdown structure with ATX headers (#, ##, ###)

### Key Sections
1. Quick Start - API overview and base URL
2. Core Workflows - Step-by-step API operations
3. Note Structure Patterns - Frontmatter and WikiLink formats
4. Search Patterns - Tag-based, path-based, combined searches
5. Integration with Other Skills - Handoff triggers to other skills
6. Error Handling - HTTP status codes
7. Best Practices - Usage guidelines
8. Example Workflows - Practical curl examples

### YAML Frontmatter Gotchas
- Must quote description if it contains colons, parentheses, or other special YAML characters
- Example: description: "Text with (parentheses) and colons: like this"
- Without quotes: causes YAML parsing errors

### Obsidian Local REST API Endpoints
- GET /vault/ - List all files
- GET /active/ - Get active note
- POST /notes/ - Create note
- GET /notes/{path} - Read note
- PUT /notes/{path} - Update note
- DELETE /notes/{path} - Delete note
- GET /search/simple - Search content
- POST /search/ - Advanced search
- POST /daily/note - Create daily note
- GET /daily/note - Get daily note

### Frontmatter Pattern
```yaml
---
date: YYYY-MM-DD
created: ISO8601_timestamp
type: note_type
status: draft|final|archived
tags: #tag1 #tag2
---
```

### WikiLink Format
- [[Link]] - Basic link
- [[Link|Alias]] - Link with alias
- [[#Section]] - Section link
- [[Note#Section]] - Section in other note

### Search Query Patterns
- tag:#tagname - Tag search
- path:directory/ - Path restriction
- Combined with contextLength parameter

### Files Created
- skills/obsidian/SKILL.md (250 lines, 6443 bytes)

## Task: Create skills/outlook/SKILL.md

### Outlook Skill Pattern
- Purpose: Document Outlook Graph API integration via MCP
- Core capabilities: Mail CRUD, folder management, calendar events, contacts, search
- Excluded: Graph API authentication (handled externally), Teams functionality

### SKILL.md Structure for API Skills
- YAML frontmatter with clear "Use when:" triggers and "Triggers:" examples
- Description follows pattern: "API integration via MCP. Use when: (1) ..., (2) ... Triggers: '...', '...', '...'"
- Body sections: Core Operations → Common Workflows → IDs and Discovery → Important Notes

### API Documentation Pattern
- Group operations by domain (Mail Access, Mail CRUD, Folder Management, Calendar Events, Contacts, Search)
- Each operation format: **Function name**: `function_name(params)` - Brief description
- Include parameter defaults: `param=value` in function signatures
- Document common workflows with step-by-step examples

### Verification
- YAML frontmatter validation: `python3 skills/skill-creator/scripts/quick_validate.py skills/outlook/`
- Required fields: name, description, compatibility: opencode
- File size: 7572 chars (comprehensive but not excessive)

### Files Created
- skills/outlook/SKILL.md (160 lines, 7572 bytes)
## Task: Create scripts/validate-agents.sh

### Validation Script Pattern
- Bash script follows existing test-skill.sh conventions
- Shebang: `#!/usr/bin/env bash`
- Strict mode: `set -euo pipefail`
- Color output: RED, GREEN, YELLOW, NC (no color)
- Helper functions for specific checks
- Main case statement for option handling

### Script Structure
```bash
# Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
check_json_valid() - Validates JSON syntax
check_required_fields() - Validates agent structure
check_prompt_file() - Verifies prompt file exists and non-empty

# Main case statement handles --help, default validation
```

### Agent Validation Checks
1. JSON validity: `python3 -m json.tool`
2. Required fields: description, mode, model, prompt, permission
3. Prompt file extraction: Regex from `{file:./prompts/filename}` format
4. File existence: Check prompt file exists in prompts/ directory
5. Non-empty check: Use `-s` test operator

### Regex Pattern for Prompt References
```bash
[[ $prompt_ref =~ \{file:./prompts/([^}]+)\} ]]
# BASH_REMATCH[1] contains the filename
```

### Python Integration in Bash Scripts
- Validate JSON: `python3 -m json.tool file`
- Parse JSON: `python3 -c "import json; json.load(open('file'))"`
- Extract data: `python3 -c "import json; data = json.load(open('file')); print('\n'.join(data.keys()))"`
- Check fields: `python3 -c "import sys, json; data = json.load(sys.stdin); exit(0 if 'field' in data else 1)"`

### Comment Discipline
- Keep file header documentation (usage, purpose, checks)
- Remove inline comments for self-explanatory code (function names, clear operations)
- Keep comments for complex/regex patterns
- Follow existing repository conventions (e.g., "# Main" section marker)

### Files Created
- `scripts/validate-agents.sh` - Bash validation script (130 lines)

### Verification
- Script executable: `chmod +x`
- Runs successfully: Validates all 6 agents
- Error handling: Detects missing files, invalid JSON, missing fields
- Help documentation: `--help` flag

