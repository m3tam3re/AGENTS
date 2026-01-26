---
name: agent-development
description: "(opencode - Skill) Create and configure agents for Opencode. Use when: (1) creating a new agent, (2) adding agents to agents.json or opencode.json, (3) configuring agent permissions, (4) setting up primary vs subagent modes, (5) writing agent system prompts, (6) understanding agent triggering. Triggers: create agent, add agent, agents.json, subagent, primary agent, agent permissions, agent configuration, agent prompt."
compatibility: opencode
---

# Agent Development for Opencode

## Overview

Agents are specialized AI assistants configured for specific tasks and workflows. Opencode supports two agent types with different configuration formats.

### Agent Types

| Type | Description | Invocation |
|------|-------------|------------|
| **Primary** | Main assistants for direct interaction | Tab key to cycle, or configured keybind |
| **Subagent** | Specialized assistants for delegated tasks | Automatically by primary agents, or @ mention |

**Built-in agents:**
- `build` (primary) - Full development with all tools enabled
- `plan` (primary) - Analysis/planning with edit/bash requiring approval
- `general` (subagent) - Multi-step tasks with full tool access
- `explore` (subagent) - Fast, read-only codebase exploration

### Configuration Formats

Agents can be defined in two formats. Ask the user which format they prefer; default to **JSON** if no preference stated.

**Format 1: JSON** (recommended for central management)
- In `opencode.json` under the `agent` key
- Or standalone `agents.json` file
- Best for: version control, Nix flake consumption, central configuration

**Format 2: Markdown** (for quick addition)
- Global: `~/.config/opencode/agents/*.md`
- Per-project: `.opencode/agents/*.md`
- Best for: project-specific agents, quick prototyping

## JSON Agent Structure

### In opencode.json

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "agent-name": {
      "description": "When to use this agent",
      "mode": "primary",
      "model": "provider/model-id",
      "prompt": "{file:./prompts/agent-name.txt}",
      "permission": { ... },
      "tools": { ... }
    }
  }
}
```

### Standalone agents.json

```json
{
  "agent-name": {
    "description": "When to use this agent",
    "mode": "subagent",
    "model": "anthropic/claude-sonnet-4-20250514",
    "prompt": "You are an expert...",
    "tools": {
      "write": false,
      "edit": false
    }
  }
}
```

## Markdown Agent Structure

File: `~/.config/opencode/agents/agent-name.md` or `.opencode/agents/agent-name.md`

```markdown
---
description: When to use this agent
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
tools:
  write: false
  edit: false
  bash: false
permission:
  bash:
    "*": ask
    "git diff": allow
---

You are an expert [role]...

**Your Core Responsibilities:**
1. [Responsibility 1]
2. [Responsibility 2]
```

The filename becomes the agent name (e.g., `review.md` → `review` agent).

## Configuration Options

### description (required)

Defines when Opencode should use this agent. Critical for subagent triggering.

```json
"description": "Reviews code for best practices and security issues"
```

### mode

Controls how the agent can be used.

| Value | Behavior |
|-------|----------|
| `primary` | Directly accessible via Tab cycling |
| `subagent` | Invoked by Task tool or @ mention |
| `all` | Both (default if omitted) |

```json
"mode": "primary"
```

**IMPORTANT**: Always explicitly set the `mode` field for clarity:
- Primary agents: `"mode": "primary"`
- Subagents: `"mode": "subagent"`
- Avoid relying on defaults; explicit declaration makes intent clear and follows best practices

### model

Override the model for this agent. Format: `provider/model-id`.

```json
"model": "anthropic/claude-sonnet-4-20250514"
```

If omitted: primary agents use globally configured model; subagents inherit from invoking primary agent.

### prompt

System prompt defining agent behavior. Can be inline or file reference.

**Inline:**
```json
"prompt": "You are an expert code reviewer..."
```

**File reference:**
```json
"prompt": "{file:./prompts/agent-name.txt}"
```

File paths are relative to the config file location.

### temperature

Control response randomness (0.0 - 1.0).

| Range | Use Case |
|-------|----------|
| 0.0-0.2 | Focused, deterministic (code analysis, planning, research) |
| 0.3-0.5 | Balanced (general development, writing) |
| 0.6-1.0 | Creative (brainstorming, ideation) |

```json
"temperature": 0.1
```

**RECOMMENDATIONS BY AGENT TYPE:**
- **Research/Analysis**: 0.0-0.2 (focused, deterministic, consistent results)
- **Code Generation**: 0.1-0.3 (precise but allows slight creativity)
- **Code Review**: 0.0-0.2 (strict adherence to patterns)
- **Brainstorming/Creative**: 0.6-1.0 (explore many options)
- **General Purpose**: 0.3-0.5 (balanced approach)

### maxSteps

Limit agentic iterations before forcing text-only response.

```json
"maxSteps": 10
```

### tools

Control which tools are available. Boolean to enable/disable, or object for granular control.

**Disable specific tools:**
```json
"tools": {
  "write": false,
  "edit": false,
  "bash": false
}
```

**Wildcard for MCP tools:**
```json
"tools": {
  "mymcp_*": false
}
```

### hidden

Hide subagent from @ autocomplete menu. Agent can still be invoked via Task tool.

```json
"hidden": true
```

### disable

Disable the agent entirely.

```json
"disable": true
```

## Permissions System

Permissions control what actions require approval. Each rule resolves to:
- `"allow"` - Run without approval
- `"ask"` - Prompt for approval
- `"deny"` - Block the action

### Permission Types

| Permission | Matches Against |
|------------|-----------------|
| `read` | File path |
| `edit` | File path (covers edit, write, patch, multiedit) |
| `bash` | Parsed command |
| `task` | Subagent type |
| `external_directory` | Paths outside project |
| `doom_loop` | Repeated identical tool calls |

### Simple Permissions

```json
"permission": {
  "edit": "ask",
  "bash": "ask"
}
```

### Granular Permissions with Glob Patterns

Rules evaluated in order; **last matching rule wins**.

```json
"permission": {
  "read": {
    "*": "allow",
    "*.env": "deny",
    "*.env.*": "deny",
    "*.env.example": "allow"
  },
  "bash": {
    "*": "ask",
    "git status*": "allow",
    "git log*": "allow",
    "git diff*": "allow",
    "rm *": "ask",
    "sudo *": "deny"
  },
  "edit": "allow",
  "external_directory": "ask",
  "doom_loop": "ask"
}
```

### Task Permissions (Subagent Control)

Control which subagents an agent can invoke via Task tool.

```json
"permission": {
  "task": {
    "*": "deny",
    "code-reviewer": "allow",
    "test-generator": "ask"
  }
}
```

## Complete JSON Example

```json
{
  "chiron": {
    "description": "Personal AI assistant (Plan Mode). Read-only analysis and planning.",
    "mode": "primary",
    "model": "anthropic/claude-sonnet-4-20250514",
    "prompt": "{file:./prompts/chiron.txt}",
    "permission": {
      "read": {
        "*": "allow",
        "*.env": "deny",
        "*.env.*": "deny",
        "*.env.example": "allow",
        "*/.ssh/*": "deny",
        "*credentials*": "deny"
      },
      "edit": "ask",
      "bash": "ask",
      "external_directory": "ask"
    }
  },
  "chiron-forge": {
    "description": "Personal AI assistant (Worker Mode). Full write access.",
    "mode": "primary",
    "model": "anthropic/claude-sonnet-4-20250514",
    "prompt": "{file:./prompts/chiron-forge.txt}",
    "permission": {
      "read": {
        "*": "allow",
        "*.env": "deny"
      },
      "edit": "allow",
      "bash": {
        "*": "allow",
        "rm *": "ask",
        "git push *": "ask",
        "sudo *": "deny"
      }
    }
  },
  "code-reviewer": {
    "description": "Reviews code for quality, security, and best practices",
    "mode": "subagent",
    "model": "anthropic/claude-sonnet-4-20250514",
    "temperature": 0.1,
    "tools": {
      "write": false,
      "edit": false
    },
    "prompt": "You are an expert code reviewer..."
  }
}
```

## System Prompt Design

Write prompts in second person, addressing the agent directly.

### Standard Structure

```
You are [role] specializing in [domain].

**Your Core Responsibilities:**  ← USE THIS EXACT HEADER
1. [Primary responsibility]
2. [Secondary responsibility]
3. [Additional responsibilities]

**Process:**
1. [Step one]
2. [Step two]
3. [Continue with clear steps]

**Quality Standards:**
- [Standard 1]
- [Standard 2]

**Output Format:**
[What to include and how to structure]

**Edge Cases:**
- [Edge case 1]: [How to handle]
- [Edge case 2]: [How to handle]
```

**IMPORTANT**: Use exact section headers for consistency:
- Use "Your Core Responsibilities:" (not "capabilities", "duties", etc.)
- Use "Process:" for step-by-step workflows
- Use "Quality Standards:" for evaluation criteria
- Use "Output Format:" for response structure
- Use "Edge Cases:" for exception handling

### Prompt File Convention

Store prompts in a `prompts/` directory with `.txt` extension:
- `prompts/agent-name.txt`

Reference in config:
```json
"prompt": "{file:./prompts/agent-name.txt}"
```

### Best Practices

**DO:**
- Use second person ("You are...", "You will...")
- Be specific about responsibilities
- Use numbered lists for responsibilities (1, 2, 3) - not bullet points
- Provide step-by-step processes
- Define output format
- Include quality standards
- Address edge cases
- Keep under 10,000 characters
- Keep section names consistent with standard structure, but adapt if semantically equivalent (e.g., "Ethical Guidelines" vs "Quality Standards" for research agents)

**DON'T:**
- Write in first person
- Be vague or generic
- Omit process steps
- Leave output format undefined

## Creating Agents

### Method 1: Opencode CLI (Interactive)

```bash
opencode agent create
```

Prompts for: location, description, tools, then generates the agent file.

### Method 2: JSON Configuration

1. Add agent to `opencode.json` or `agents.json`
2. Create prompt file in `prompts/` directory
3. Validate with: `python3 -c "import json; json.load(open('agents.json'))"` for syntax check

### Method 3: Markdown File

1. Create `~/.config/opencode/agents/agent-name.md` or `.opencode/agents/agent-name.md`
2. Add frontmatter with configuration
3. Write system prompt as markdown body

## Validation

Validate agent configuration:

```bash
# Validate agents.json
python3 -c "import json; json.load(open('agents.json'))"
```

## Testing

1. Reload opencode or start new session
2. For primary agents: use Tab to cycle
3. For subagents: use @ mention or let primary agent invoke via Task tool
4. Verify expected behavior and tool access

## Quick Reference

### JSON Agent Template

```json
{
  "my-agent": {
    "description": "What this agent does and when to use it",
    "mode": "subagent",
    "model": "anthropic/claude-sonnet-4-20250514",
    "prompt": "{file:./prompts/my-agent.txt}",
    "tools": {
      "write": false,
      "edit": false
    }
  }
}
```

### Markdown Agent Template

```markdown
---
description: What this agent does and when to use it
mode: subagent
model: anthropic/claude-sonnet-4-20250514
tools:
  write: false
  edit: false
---

You are an expert [role]...
```

### Configuration Options Summary

| Option | Required | Type | Default |
|--------|----------|------|---------|
| description | Yes | string | - |
| mode | No | primary/subagent/all | all |
| model | No | string | inherited |
| prompt | No | string | - |
| temperature | No | number | model default |
| maxSteps | No | number | unlimited |
| tools | No | object/boolean | all enabled |
| permission | No | object | allow |
| hidden | No | boolean | false |
| disable | No | boolean | false |

## Additional Resources

- **System prompt patterns**: See `references/system-prompt-design.md`
- **Triggering examples**: See `references/triggering-examples.md`
- **AI-assisted generation**: See `examples/agent-creation-prompt.md`
- **Complete examples**: See `examples/complete-agent-examples.md`
- **Real-world JSON example**: See `references/opencode-agents-json-example.md`
