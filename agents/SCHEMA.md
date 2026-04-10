# Canonical `agent.toml` Schema

This document defines the canonical TOML schema for agent definitions in the AGENTS
repository. The format is **harness-agnostic**: every renderer (OpenCode, Claude Code,
Pi) consumes the same file and silently drops fields it cannot map.

The schema is intentionally minimal. Fields that belong to the deployment environment
(model selection, MCP configuration) are excluded. Fields that belong to a specific
renderer (hooks, datetime) are excluded. The TOML file describes *what the agent is
and what it can do*, not *how it is deployed*.

---

## Required Fields

| Field | Type | Constraints |
|-------|------|-------------|
| `name` | string | kebab-case slug; pattern `[a-z0-9-]+`; must be unique across all agents |
| `description` | string | Human-readable purpose statement; single line; no trailing period |

### Examples

```toml
name = "chiron"
description = "Personal AI assistant (Plan Mode). Read-only analysis, planning, and guidance"
```

```toml
name = "chiron-forge"
description = "Personal AI assistant (Build Mode). Full execution and task completion capabilities with safety prompts"
```

**Constraint notes**:
- `name` must be kebab-case (lowercase, hyphens only). The OpenCode renderer uses it as
  the agent identifier; Claude Code requires `[a-z0-9-]+` and will reject spaces.
- `description` is required by Claude Code. OpenCode uses it in the agent picker.

---

## Optional Fields

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `display_name` | string | — | Human-readable label (e.g. `"Chiron (Assistant)"`). Used by OpenCode in the agent picker. Ignored by Claude Code. |
| `mode` | string | `"all"` | One of: `"primary"`, `"subagent"`, `"all"` |
| `tags` | array of strings | `[]` | Freeform labels for grouping/filtering |
| `max_turns` | integer | — | Max agentic loop iterations. Maps to `steps` in OpenCode, `maxTurns` in Claude Code. Ignored by Pi. |
| `skills` | array of strings | `[]` | Skill names to load (e.g. `["systematic-debugging", "git-master"]`). Same `SKILL.md` format across all renderers. |
| `context` | array of strings | `[]` | Relative file paths to inject as context (e.g. `["../context/profile.md"]`) |
| `rules` | array of strings | `[]` | Rule references from the `rules/` directory (e.g. `["languages/nix", "concerns/testing"]`) |

### `mode` semantics

| Value | Meaning |
|-------|---------|
| `"primary"` | Agent is offered as a top-level choice to the user |
| `"subagent"` | Agent is invoked programmatically by other agents; not shown in primary picker |
| `"all"` | Both primary and subagent (default if omitted) |

**Renderer note**: Claude Code has no distinction between primary and subagent — all
agents are effectively subagents. Pi only renders a `SYSTEM.md` for primary agents.

---

## Permission Schema

Permissions describe what each tool is allowed to do. The schema uses two-level TOML
tables: one section per tool.

### Structure

```toml
[permissions.TOOL_NAME]
intent = "allow" | "deny" | "ask"   # required
rules = ["pattern:action", ...]      # optional
```

- **`intent`** — the default action taken when no specific rule matches.
  - `"allow"` — permit the operation without prompting
  - `"deny"` — block the operation silently
  - `"ask"` — prompt the user for confirmation
- **`rules`** — ordered list of override entries. Each entry is a string in the form
  `"pattern:action"` where `action` is one of `allow`, `deny`, or `ask`.
  Rules are evaluated first-match; the `intent` applies only when no rule matches.

### Supported tool names

| Tool | Description |
|------|-------------|
| `bash` | Shell command execution |
| `edit` | File creation and modification |
| `webfetch` | HTTP fetch to external URLs |
| `websearch` | Web search queries |
| `question` | Interactive user question prompts |
| `external_directory` | Access to filesystem paths outside the project |

### Simple permission (no per-pattern overrides)

```toml
[permissions.webfetch]
intent = "allow"

[permissions.websearch]
intent = "deny"

[permissions.question]
intent = "allow"
```

### Structured permission with rules

```toml
[permissions.bash]
intent = "ask"
rules = [
  "git status*:allow",
  "git log*:allow",
  "git diff*:allow",
  "git branch*:allow",
  "rm -rf *:deny",
  "git push --force*:deny",
]

[permissions.edit]
intent = "allow"
rules = [
  "/run/agenix/**:deny",
]

[permissions.external_directory]
intent = "ask"
rules = [
  "~/p/**:allow",
  "~/.config/opencode/**:allow",
  "/tmp/**:allow",
  "/run/agenix/**:allow",
]
```

### Pattern syntax

Patterns follow glob conventions:
- `*` — matches any characters within a single path segment or command token
- `**` — matches any characters including path separators
- Patterns are matched left-to-right; first match wins

---

## Excluded Fields

The following fields are intentionally absent from the canonical schema.

| Field | Reason |
|-------|--------|
| `model` | Per-machine concern. Model selection is configured in `home-manager` (via `programs.opencode.settings`) and varies by host. Including it in `agent.toml` would couple the agent definition to deployment infrastructure. |
| `prompt` | System prompt content lives in a sibling `system-prompt.md` file alongside `agent.toml`. This allows renderers to consume it independently (e.g., Claude Code reads `prompt.md`, Pi generates `SYSTEM.md`). Embedding prompt paths in TOML adds indirection without benefit. |
| `mcp` | MCP server configuration is tool-specific infrastructure (e.g., `claude mcp add`). It belongs to the deployment layer, not the agent definition. |
| `hooks` | Claude Code-exclusive concept. Lifecycle hooks (pre-tool, post-tool, etc.) have no equivalent in OpenCode or Pi. Including them would leak renderer-specific concerns into the canonical schema. |
| Datetime types | `builtins.fromTOML` in Nix does not support TOML datetime values. This is a confirmed parser limitation (verified in Task 2 spike). All date/time data must be represented as strings if needed. |

---

## Per-Renderer Support Matrix

The table below shows how each field is consumed by each renderer. "✓" means full
support, "~" means partial/mapped support, "–" means ignored.

| Field | OpenCode | Claude Code | Pi |
|-------|----------|-------------|----|
| `name` | ✓ agent identifier | ✓ must be `[a-z0-9-]+` | in `AGENTS.md` |
| `description` | ✓ agent picker | ✓ required | in `AGENTS.md` |
| `display_name` | ✓ picker label | – ignored | – ignored |
| `mode` | ✓ maps to `mode` | – all are subagents | primary only → `SYSTEM.md` |
| `tags` | ~ future use | – ignored | – ignored |
| `max_turns` | ✓ maps to `steps` | ✓ maps to `maxTurns` | – ignored |
| `skills` | ✓ SKILL.md loaded | ✓ SKILL.md loaded | ✓ SKILL.md loaded |
| `context` | ✓ injected | ✓ injected | ~ manual inclusion |
| `rules` | ✓ rule injection | ✓ rule injection | – ignored |
| `permissions.bash` | ✓ rule DSL | ✓ bash tool perms | – no granularity |
| `permissions.edit` | ✓ path rules | ✓ path rules | – no granularity |
| `permissions.webfetch` | ✓ intent only | ✓ intent only | – ignored |
| `permissions.websearch` | ✓ intent only | ✓ intent only | – ignored |
| `permissions.question` | ✓ intent only | – not a tool | – not a concept |
| `permissions.external_directory` | ✓ path rules | – not supported | – not supported |

**Renderer summary**:
- **OpenCode** — full support; most fields have direct mappings
- **Claude Code** — strong support; drops `display_name`, `external_directory`, `mode`
- **Pi** — minimal support; reads `name`/`description` from `AGENTS.md`, skills via `SKILL.md`; permissions ignored

---

## Sample `agent.toml`

The following is a complete, valid example for the "chiron" agent. It demonstrates all
field categories and can be parsed with `builtins.fromTOML`.

```toml
# agents/chiron/agent.toml
# Chiron — Personal AI Assistant (Plan Mode)

name        = "chiron"
display_name = "Chiron (Assistant)"
description = "Personal AI assistant (Plan Mode). Read-only analysis, planning, and guidance"
mode        = "primary"
tags        = ["assistant", "plan-mode", "read-only"]
max_turns   = 50

skills  = ["systematic-debugging", "git-master", "brainstorming"]
context = ["../../context/profile.md"]
rules   = ["languages/nix", "languages/python", "concerns/testing"]

[permissions.question]
intent = "allow"

[permissions.webfetch]
intent = "allow"

[permissions.websearch]
intent = "allow"

[permissions.edit]
intent = "deny"

[permissions.bash]
intent = "ask"
rules = [
  "git status*:allow",
  "git log*:allow",
  "git diff*:allow",
  "git branch*:allow",
  "git show*:allow",
  "grep *:allow",
  "ls *:allow",
  "cat *:allow",
  "head *:allow",
  "tail *:allow",
  "wc *:allow",
  "which *:allow",
  "echo *:allow",
  "nix *:allow",
]

[permissions.external_directory]
intent = "ask"
rules = [
  "~/p/**:allow",
  "~/.config/opencode/**:allow",
  "/tmp/**:allow",
  "/run/agenix/**:allow",
]
```

### Parse verification

This sample can be verified with:

```bash
nix eval --impure \
  --expr 'builtins.fromTOML (builtins.readFile /path/to/agent.toml)' \
  --json | jq .
```

Expected top-level keys: `name`, `display_name`, `description`, `mode`, `tags`,
`max_turns`, `skills`, `context`, `rules`, `permissions`.

Expected `permissions` keys: `question`, `webfetch`, `websearch`, `edit`, `bash`,
`external_directory`.

---

## Schema Version

This document describes schema version **1.0.0** (initial canonical definition).
Changes to field names, types, or semantics must be reflected here with a version bump.
