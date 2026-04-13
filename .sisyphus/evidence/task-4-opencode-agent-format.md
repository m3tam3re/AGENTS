# Task 4: OpenCode File-Based Agent Format Research

**Date**: 2026-04-10  
**Status**: ✅ Complete  
**Research Method**: WebFetch + Documentation Analysis

---

## Executive Summary

OpenCode supports **two agent configuration methods**:
1. **JSON** - Embedded in `opencode.json` (config.json)
2. **Markdown Files** - File-based in `.opencode/agents/` directory (per-project) or `~/.config/opencode/agents/` (global)

This research focuses on the **file-based markdown format**, which is the target for the harness-agnostic migration.

---

## File Location & Discovery

### Directory Structure

**Per-project agents** (takes precedence):
```
.opencode/agents/
├── agent-name.md
├── another-agent.md
└── ...
```

**Global agents** (fallback):
```
~/.config/opencode/agents/
├── agent-name.md
├── another-agent.md
└── ...
```

### Discovery Mechanism

- OpenCode **scans both directories** for `*.md` files
- The **filename (without .md extension)** becomes the **agent name**
- Per-project agents **override** global agents with the same name
- All agents are loaded at startup and available via `Tab` switching or `@mention`

### Key Finding

**The agent name is derived from the filename**, not from a `name` field in the frontmatter. Example:
- File: `review.md` → Agent name: `review`
- File: `code-reviewer.md` → Agent name: `code-reviewer`

---

## YAML Frontmatter Specification

All file-based agent markdown files must include YAML frontmatter with the following fields:

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `description` | string | Brief description of agent purpose and when to use it. **REQUIRED**. | `"Reviews code for quality and best practices"` |

### Optional Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `mode` | string | `all` | Agent mode: `primary`, `subagent`, or `all` |
| `model` | string | Model globally configured in config | Override LLM model for this agent |
| `temperature` | float | Model-specific (usually 0 or 0.55 for Qwen) | LLM response randomness (0.0–1.0) |
| `top_p` | float | — | Alternative to temperature for diversity control |
| `steps` | integer | No limit | Max agentic iterations before forced text-only response |
| `disable` | boolean | `false` | Set to `true` to disable the agent |
| `hidden` | boolean | `false` | Hide from `@` autocomplete (subagents only) |
| `color` | string | — | Hex color (e.g., `#FF5733`) or theme color (primary, secondary, accent, success, warning, error, info) |
| `permission` | object | — | Permission rules for edit, bash, webfetch, question, websearch, external_directory |
| `task` | object | — | Control which subagents this agent can invoke via Task tool |

### Provider-Specific Fields

Any additional fields are **passed through directly to the LLM provider**. Example for OpenAI reasoning models:
```yaml
---
description: Agent using high reasoning effort
model: openai/gpt-5
reasoningEffort: high
textVerbosity: low
---
```

---

## Permission Format (YAML)

Permissions control what actions an agent can perform. The format supports two styles:

### Simple Format (Single Action)

```yaml
permission:
  edit: deny
  bash: ask
  webfetch: allow
```

### Granular Format (Rules Array)

For more control over specific patterns:

```yaml
permission:
  edit: 
    "*": allow
    "/run/agenix/**": deny
  bash:
    "*": ask
    "git status*": allow
    "git log*": allow
    "git push": ask
    "grep *": allow
  webfetch: deny
  question: allow
  websearch: allow
  external_directory:
    "*": ask
    "~/p/**": allow
    "~/.config/opencode/**": allow
    "/tmp/**": allow
```

### Permission Actions

| Value | Meaning |
|-------|---------|
| `allow` | Tool allowed without approval |
| `ask` | Prompt user for approval before running |
| `deny` | Tool disabled |

### Supported Permission Keys

| Key | Values | Notes |
|-----|--------|-------|
| `edit` | `allow\|ask\|deny` or nested rules | File write/patch operations |
| `bash` | `allow\|ask\|deny` or nested rules | Bash command execution; supports glob patterns |
| `webfetch` | `allow\|ask\|deny` | HTTP requests |
| `question` | `allow\|ask\|deny` | User questions/clarification |
| `websearch` | `allow\|ask\|deny` | Web search operations |
| `external_directory` | `allow\|ask\|deny` or nested rules | Access to external directories |
| `task` | nested rules | Subagent invocation control (glob patterns) |

### Glob Pattern Support

Patterns support wildcards and recursion:
- `*` — single-level wildcard
- `**` — recursive wildcard
- `git push*` — suffix matching
- `~/p/**` — home directory paths
- `/run/agenix/**` — absolute paths

### Rule Precedence

When multiple rules match, the **last matching rule wins**:

```yaml
bash:
  "*": ask
  "git status*": allow
  "git push*": deny
```

In this example:
- `git status` matches both `*` and `git status*` → result: **allow** (last rule wins)
- `git push origin main` matches both `*` and `git push*` → result: **deny**
- `ls -la` matches only `*` → result: **ask**

---

## Mode Field Values

| Mode | Type | Description |
|------|------|-------------|
| `primary` | Primary agent | Agent available via `Tab` key switching; handles main conversation |
| `subagent` | Specialized agent | Invoked via `@mention` or automatically by other agents for specific tasks |
| `all` | Flexible | Can be used as both primary and subagent (default if omitted) |

---

## System Prompt Delivery

The markdown file body (after the YAML frontmatter) contains the **system prompt**:

```markdown
---
description: Code review without edits
mode: subagent
permission:
  edit: deny
---
You are a code reviewer. Focus on:
- Code quality and best practices
- Potential bugs and edge cases
- Performance implications
- Security considerations

Provide constructive feedback without making direct changes.
```

The **markdown content is passed directly as the system prompt** to the LLM. It supports:
- Inline markdown formatting
- Lists and sections
- Structured instructions
- Code examples (fenced with backticks)

---

## Default Behavior for Omitted Fields

| Field | Default | Notes |
|-------|---------|-------|
| `description` | **ERROR** | Required; absence causes parse failure |
| `mode` | `all` | Agent can be used as primary or subagent |
| `model` | Global config model | Primary agents use global model; subagents use parent's model |
| `temperature` | Model-specific | Usually 0 for most models; 0.55 for Qwen models |
| `permission` | Full access | If omitted, all tools enabled (no restrictions) |
| `disable` | `false` | Agent is enabled by default |
| `hidden` | `false` | Agent visible in `@` autocomplete (if subagent) |

---

## Interaction with config.json (JSON Format)

### Current State (Task 1 Finding)

The current system embeds agents in **config.json** via JSON:

```json
{
  "agent": {
    "build": {
      "description": "...",
      "mode": "primary",
      "permission": { ... }
    }
  }
}
```

### File-Based Agents Complement, Don't Replace

- **JSON agents** (in config.json) are loaded from embedded config
- **Markdown agents** (.opencode/agents/*.md files) are symlinked
- **Both are loaded** and available simultaneously
- **Markdown agents override** JSON agents with the same name

### Migration Path

The harness-agnostic migration will:
1. Move agent definitions from `agents.json` → `.opencode/agent/{name}.md` files
2. Update home-manager deployment to symlink `.opencode/agents/` instead of embedding `agents.json`
3. System prompt changes (markdown file edits) will **NOT require `home-manager switch`**

---

## Key Advantage: Prompt Changes Don't Require home-manager switch

### Current Limitation (JSON/Embedded)

```
agents.json → home-manager → embedded into config.json
↓
Change required in nixpkgs module
↓
home-manager switch (full system rebuild)
```

### New Capability (File-Based)

```
.opencode/agents/{name}.md → home-manager → symlinks to ~/.config/opencode/agents/
↓
Change markdown file directly
↓
OpenCode reloads on next startup (NO home-manager switch needed)
```

**This is the KEY ADVANTAGE** of file-based agents: faster iteration on prompts and agent configuration.

---

## Limitations & Gotchas

### No Name Field in Frontmatter

- Agent name comes from **filename only**
- No `name: foo` field in frontmatter
- Renaming file renames the agent

### Model References with {file:...}

In JSON config, you can reference external files:
```json
{
  "prompt": "{file:./prompts/build.txt}"
}
```

In markdown files, the **body IS the prompt** — no `{file:...}` syntax. The entire markdown content after frontmatter is the system prompt.

### Subdirectories Not Scanned

- Only files directly in `.opencode/agents/` are loaded
- Subdirectories are ignored
- All agent definitions must be in one directory level

### Filename Validation

The filename should follow these conventions (not enforced, but recommended):
- Lowercase letters, numbers, hyphens: `[a-z0-9-]+`
- No spaces, no special characters
- Examples: `code-reviewer.md`, `security-auditor.md`, `docs-writer.md`

---

## Complete Example: File-Based Agent

### File: `.opencode/agents/code-reviewer.md`

```markdown
---
description: Performs comprehensive code review focusing on quality, security, and performance
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
permission:
  edit:
    "*": deny
  bash:
    "*": allow
    "grep *": allow
    "git diff*": allow
  webfetch: allow
  question: allow
---
You are an expert code reviewer with deep knowledge of software architecture, security best practices, and performance optimization.

## Your Mission

Review code for:
1. **Correctness** - Logic errors, edge cases, off-by-one bugs
2. **Security** - Input validation, injection vulnerabilities, data exposure
3. **Performance** - Algorithmic efficiency, memory usage, unnecessary allocations
4. **Maintainability** - Code clarity, naming, documentation, SOLID principles
5. **Testing** - Coverage gaps, missing test cases, integration test concerns

## Process

1. Ask clarifying questions about context and constraints
2. Provide specific, actionable feedback with examples
3. Suggest refactorings with rationale
4. Never make changes directly (read-only mode)
5. Prioritize critical issues over style concerns

## Output Format

- **Critical Issues** (must fix before merge)
- **Important Improvements** (should fix)
- **Nice-to-Have Suggestions** (consider for future)
- **Questions** (for author clarification)
```

---

## Complete Example: JSON Config Format (For Reference)

For comparison, here's the equivalent in JSON config.json:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "code-reviewer": {
      "description": "Performs comprehensive code review focusing on quality, security, and performance",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "temperature": 0.1,
      "permission": {
        "edit": {
          "*": "deny"
        },
        "bash": {
          "*": "allow",
          "grep *": "allow",
          "git diff*": "allow"
        },
        "webfetch": "allow",
        "question": "allow"
      },
      "prompt": "You are an expert code reviewer...\n\n## Your Mission\n..."
    }
  }
}
```

---

## Source Materials

### Documentation

- **Official**: https://opencode.ai/docs/agents
- **Agents Section**: Comprehensive spec for all agent config options
- **Markdown Example**: Review agent example provided in docs
- **Security Auditor Example**: Security-focused agent example

### Code References

- **GitHub**: https://github.com/anomalyco/opencode (dev branch)
- **Config Spec**: schema.json embedded in docs
- **Test Cases**: `.opencode/agents/` in opencode repo (example files)

### Current System Reference

- **Nix Module**: `/home/m3tam3re/p/NIX/nixpkgs/modules/home-manager/coding/opencode.nix`
  - Line 149: `agent = builtins.fromJSON (builtins.readFile "${inputs.agents}/agents/agents.json");`
  - Line 149: Shows current embedding pattern
  
- **AGENTS repo**: `/home/m3tam3re/p/AI/AGENTS/agents/agents.json`
  - 6 agents: Chiron, Chiron Forge, Hermes, Athena, Apollo, Calliope
  - Permission structure: nested objects with wildcard patterns

---

## Questions Addressed

### Q: Do file-based agents need `home-manager switch` for prompt changes?

**A: NO** ✅

- File changes are immediately available
- `.opencode/agents/` is symlinked (not embedded)
- OpenCode reloads agent definitions at startup
- Prompt changes require only file edit + app restart

**This is the KEY ADVANTAGE** driving the migration.

### Q: What directory: `agent` or `agents`?

**A: `agents` (plural)** (both global and per-project)
- Global: `~/.config/opencode/agents/`
- Per-project: `.opencode/agents/`

### Q: Do agent names need a `name` field in frontmatter?

**A: NO** 

- Agent name comes from **filename only**
- No `name: foo` field in frontmatter
- Example: `review.md` → agent name is `review`

### Q: What YAML frontmatter fields are required?

**A: Only `description`** is truly required

- All other fields have sensible defaults
- Missing fields use their defaults
- Frontmatter-less file will fail to parse

### Q: How are permissions specified in markdown?

**A: Same nested object format as JSON**

```yaml
permission:
  edit: 
    "*": allow
    "/sensitive/**": deny
  bash:
    "*": ask
    "git push": deny
```

---

## Confirmation Summary

| Question | Finding |
|----------|---------|
| **Directory**: `agent` or `agents`? | `agents/` (both global and per-project) |
| **File naming**: How determined? | Filename (without .md) becomes agent name |
| **Required fields**: What's mandatory? | `description` only; others have defaults |
| **Permission format**: YAML or different? | Same nested object format as JSON |
| **Mode values**: Options? | `primary` \| `subagent` \| `all` |
| **Prompt format**: How specified? | Markdown body after frontmatter |
| **Requires HM switch for prompt changes?** | **NO** ✅ (major advantage) |
| **Does frontmatter need `name` field?** | **NO** (filename is the name) |
| **Can agents be in subdirectories?** | **NO** (only root level of `.opencode/agents/`) |
| **Can you override agents from JSON config?** | **YES** (markdown agents override JSON with same name) |

---

## Next Steps (Task 9: OpenCode Renderer)

The renderer will generate `.opencode/agents/{name}.md` files with:

1. **Frontmatter generation**:
   - Convert agent.toml `[description]` → YAML `description:`
   - Convert `[mode]` → YAML `mode:`
   - Convert `[temperature]` → YAML `temperature:`
   - Convert `[permission]` from two-level format → nested YAML objects

2. **Body generation**:
   - Use agent.toml `system_prompt` field → markdown body

3. **File naming**:
   - Filename: `{agent_name}.md` (from agent.toml `name` field)
   - Agent name in OpenCode: derived from filename automatically

---

## Evidence Collection

- **Source 1**: https://opencode.ai/docs/agents (Official documentation)
- **Source 2**: `/home/m3tam3re/p/NIX/nixpkgs/modules/home-manager/coding/opencode.nix` (Current deployment)
- **Source 3**: `/home/m3tam3re/p/AI/AGENTS/agents/agents.json` (Current agent definitions)
- **Source 4**: `/home/m3tam3re/p/AI/AGENTS/AGENTS.md` (Repository documentation)

**Research Date**: 2026-04-10  
**Researcher**: Sisyphus-Junior  
**Task**: Task 4 of harness-agnostic-migration plan
