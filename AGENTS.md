# Agent Skills Repository

Configuration repository for AI Agent Skills, canonical agent definitions, context files, and agent configurations. Deployed via Nix home-manager to `~/.config/opencode/` (or equivalent paths for other tools).

## Build / Lint / Test Commands

```bash
# Validate a single skill (PRIMARY quality gate)
./scripts/test-skill.sh <skill-name>
python3 skills/skill-creator/scripts/quick_validate.py skills/<skill-name>

# Validate all skills
./scripts/test-skill.sh --validate

# Validate agent configuration (agents.json + prompt files)
./scripts/validate-agents.sh

# Launch interactive opencode with dev skills (test without deploying)
./scripts/test-skill.sh --run

# Test with external skills.sh repos merged in
./scripts/test-skill.sh --run --external /path/to/external/skills

# Scaffold a new skill
python3 skills/skill-creator/scripts/init_skill.py <name> --path skills/

# Verify agent TOML parses
for f in agents/*/agent.toml; do nix eval --impure --expr "builtins.fromTOML (builtins.readFile ./$f)" --json > /dev/null && echo "OK: $f"; done
```

**No automated CI.** All validation is manual via the scripts above.

## Directory Structure

```
.
├── skills/          # Agent skills (one subdirectory per skill)
│   └── skill-name/
│       ├── SKILL.md         # Required: YAML frontmatter + workflows
│       ├── scripts/         # Executable code (optional)
│       ├── references/      # Domain docs (optional)
│       └── assets/          # Templates/files (optional)
├── rules/           # AI coding rules (languages, concerns, frameworks)
│   ├── languages/   # Python, TypeScript, Nix, Shell
│   ├── concerns/    # Testing, naming, documentation, etc.
│   └── frameworks/  # Framework-specific rules (n8n, etc.)
├── agents/          # Canonical agent definitions (harness-agnostic)
│   ├── SCHEMA.md            # Canonical agent.toml schema definition
│   └── <name>/
│       ├── agent.toml       # Agent metadata, permissions, references
│       └── system-prompt.md # Agent system prompt (markdown)
├── context/         # User profiles
├── commands/        # Custom commands
└── scripts/         # Repo utilities (test-skill.sh, validate-agents.sh)
```

## SKILL.md Structure (Required Format)

```yaml
---
name: skill-name
description: "Use when: (1) X, (2) Y. Triggers: keyword-a, keyword-b."
compatibility: opencode
---

## Overview
One-line summary.

## Core Workflows
Step-by-step instructions for the AI agent.

## Integration with Other Skills
When and how to delegate to other skills.
```

**YAML frontmatter is the primary quality gate.** The `quick_validate.py` script checks that `name`, `description`, and `compatibility` fields are present and well-formed.

## Code Style Guidelines

### General (All Languages)

- Prioritize readability over cleverness
- Fail fast and explicitly — never silently swallow errors
- Keep functions under 20 lines; extract duplicated logic
- Use guard clauses to reduce nesting (avoid arrow-shaped code)
- Validate inputs at function boundaries
- Write self-documenting code; comments explain **why**, not **what**
- Never commit commented-out code

### Python

- **Shebang**: `#!/usr/bin/env python3`
- **Docstrings**: Google-style (`Args:`, `Returns:`, `Raises:`)
- **Formatting**: `ruff` with `line-length = 100`, `quote-style = "double"`
- **Types**: Full type annotations; use `pyright` in strict mode
- **Imports**: Explicit only — no `from module import *`; stdlib → third-party → local
- **Error handling**: Catch specific exceptions; always log context, never `except: pass`
- **Defaults**: Use `None` sentinel, not mutable defaults (`def f(x=None): if x is None: x = []`)
- **State**: Avoid `global`; encapsulate state in classes
- **Feedback**: Use emoji in user-facing output (`✅` success, `❌` error, `⚠️` warning)
- **Package management**: `uv` for projects; `pyproject.toml` with `[tool.ruff]` and `[tool.pyright]`

### Bash / Shell

- **Shebang**: `#!/usr/bin/env bash` (never `/bin/bash`)
- **Strict mode**: `set -euo pipefail` at the top of every script
- **Variables**: Always quote: `"${var}"`, use arrays for lists
- **Functions**: Parentheses style (`my_func() { local var; ... }`)
- **Substitution**: Use `$()` not backticks
- **Cleanup**: Use `trap cleanup EXIT` for temp files/dirs
- **Indentation**: 2 spaces; lines ≤ 80 chars
- **Lint**: Run `shellcheck` before committing
- **Colors**: Define `RED`, `GREEN`, `YELLOW`, `NC` constants for terminal output

### Nix

- **Formatting**: `alejandra` (2-space indent, no trailing whitespace)
- **Naming**: camelCase for variables, PascalCase for types, hyphen-case for files
- **Packages**: Explicit `pkgs.vim` references — avoid `with pkgs;` namespace pollution
- **Inputs**: Always use flake inputs, never `import <nixpkgs>` or `builtins.fetchTarball`
- **Conditionals**: Use `lib.mkIf`, `lib.mkMerge`, `lib.mkOptionDefault`
- **Attributes**: Use `lib.attrByPath`/`lib.optionalAttrs` instead of `builtins.getAttr`

### Markdown

- YAML frontmatter where required (skills, commands)
- ATX-style headers (`##`, not underlines)
- `-` for unordered lists (not `*`)
- Always specify language in fenced code blocks

## Naming Conventions

| Context        | Python                               | TypeScript    | Nix           | Shell         |
| -------------- | ------------------------------------ | ------------- | ------------- | ------------- |
| Variables      | `snake_case`                         | `camelCase`   | `camelCase`   | `UPPER_SNAKE` |
| Functions      | `snake_case`                         | `camelCase`   | `camelCase`   | `lower_case`  |
| Classes        | `PascalCase`                         | `PascalCase`  | —             | —             |
| Constants      | `UPPER_SNAKE`                        | `UPPER_SNAKE` | `camelCase`   | `UPPER_SNAKE` |
| Files          | `snake_case`                         | `camelCase`   | `hyphen-case` | `hyphen-case` |
| Skill dirs     | `hyphen-case`                        | —             | —             | —             |
| Markdown files | `UPPERCASE.md` or `sentence-case.md` |               |               |               |

Function names: verb-noun pattern (`get_user_data`, `validate_skill`). Classes: descriptive nouns, no abbreviations.

## Anti-Patterns (CRITICAL — Never Do These)

**Skills:**

- NEVER place scripts or docs outside `scripts/` and `references/` subdirectories
- NEVER add `README.md` or `CHANGELOG.md` inside a skill directory
- NEVER create a skill without valid YAML frontmatter

**Frontend Design:**

- NEVER use generic AI aesthetics; NEVER converge on common design choices

**Excalidraw:**

- NEVER use the `label` property; use `boundElements` + separate text elements

**Debugging:**

- NEVER fix just the symptom; ALWAYS find and address the root cause first

**Excel / Spreadsheets:**

- ALWAYS respect existing template conventions over general guidelines

**Python:**

- NEVER use bare `except:` — always catch specific exception types
- NEVER use mutable default arguments

**Nix:**

- NEVER use `with pkgs;` — always use explicit `pkgs.packageName` references

## Testing Patterns

This repo is **documentation-only** (no compilation, no CI). Testing is skill-focused:

```bash
# Validate single skill's YAML frontmatter and structure
python3 skills/skill-creator/scripts/quick_validate.py skills/<skill-name>

# Validate all skills
./scripts/test-skill.sh --validate

# Live integration test: launch opencode with dev skills
./scripts/test-skill.sh --run
```

**Test structure for Python scripts** (when writing `scripts/*.py`):

- Use `pytest` + `hypothesis` for property-based tests
- Arrange-Act-Assert pattern; one behavior per test
- Test public contracts and observable behavior, not internals
- Mock external I/O (network, filesystem); don't mock internal logic

**Known structural deviations** (do not replicate):

- `systematic-debugging/test-*.md` — pressure tests in wrong location
- `pdf/forms.md`, `pdf/reference.md` — docs outside `references/`

## Git Workflow

**Commit format**: `<type>(<scope>): <subject>` (Conventional Commits)

- Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`, `style`
- Subject: imperative mood, ≤ 72 chars, no trailing period
- Example: `feat(skill-creator): add YAML frontmatter auto-repair`

**Branch naming**: `<type>/<short-description>` (lowercase, hyphens, ≤ 50 chars)

**Session completion workflow**: commit + `git push` (always push at end of session)

## Canonical Agent Format

Agent definitions live in `agents/<name>/agent.toml` + `agents/<name>/system-prompt.md`.
This is a **harness-agnostic** format — renderers in m3ta-nixpkgs generate tool-specific configs.

See `agents/SCHEMA.md` for the full schema definition.

### Adding a new agent

1. Create `agents/<name>/agent.toml` with required fields (`name`, `description`) and optional fields (`mode`, `permissions`, etc.)
2. Create `agents/<name>/system-prompt.md` with the agent's system prompt
3. Verify: `nix eval --impure --expr 'builtins.fromTOML (builtins.readFile ./agents/<name>/agent.toml)' --json`
4. Add the agent to renderers by updating the consuming flake inputs

### How renderers work

Renderers live in **m3ta-nixpkgs** (not this repo). They consume `lib.loadAgents` and produce:

| Tool        | Output                                  | Path                         |
| ----------- | --------------------------------------- | ---------------------------- |
| OpenCode    | `.opencode/agents/*.md`                 | `~/.config/opencode/agents/` |
| Claude Code | `.claude/agents/*.md` + `settings.json` | `~/.claude/`                 |
| Pi          | `AGENTS.md` + `SYSTEM.md`               | `~/.pi/agent/`               |

### Project-level usage

```nix
# In project flake.nix
m3taLib.agents.shellHookForTool {
  inherit pkgs;
  agentsInput = inputs.agents;
  tool = "opencode";
  modelOverrides = { chiron = "anthropic/claude-sonnet-4"; };
};
```

## Deployment

**Agent changes** (`agents/agents.json`, `prompts/*.txt`) require `home-manager switch`.  
**All other changes** (skills, context, commands) are visible immediately via symlinks.

```nix
agents = {
  url = "git+https://code.m3ta.dev/m3tam3re/AGENTS";
  inputs.nixpkgs.follows = "nixpkgs";  # Optional but recommended
};
```

**Exports:**

- `lib.loadAgents` — loads all canonical `agents/*/agent.toml` + `system-prompt.md` into an attrset
- `lib.mkOpencodeSkills` — compose custom + external [skills.sh](https://skills.sh) skills into one directory
- `lib.agentsJson` — backward-compat bridge producing legacy agents.json shape (temporary, will be removed)
- `packages.skills-runtime` — composable runtime with all skill dependencies
- `devShells.default` — dev environment for working with skills

**Mapping** (via home-manager + m3ta-nixpkgs renderers):

- `agents/` → rendered per-tool via `lib.agents.renderForTool` in m3ta-nixpkgs
- `skills/` → composed via `mkOpencodeSkills` (custom + external merged)
- `context/`, `commands/` → symlinks
- Agent changes via file-based agents: visible on next tool restart (no `home-manager switch` needed for prompt changes)

### External Skills (skills.sh)

This repo supports composing skills from external [skills.sh](https://skills.sh) repositories
alongside custom skills. External repos follow the [Agent Skills](https://agentskills.io)
standard (same `SKILL.md` format).

**`lib.mkOpencodeSkills` parameters:**

- `pkgs` (required) — nixpkgs package set
- `customSkills` (optional) — path to custom skills directory (e.g., `"${inputs.agents}/skills"`)
- `externalSkills` (optional) — list of external sources, each with:
  - `src` — flake input or path to repo root
  - `skillsDir` — subdirectory containing skills (default: `"skills"`)
  - `selectSkills` — list of skill names to include (default: all)

**Collision handling:** Custom skills always win. Among externals, earlier entries take priority.

**Home-manager example:**

```nix
inputs = {
  agents.url = "git+https://code.m3ta.dev/m3tam3re/AGENTS";
  skills-anthropic = { url = "github:anthropics/skills"; flake = false; };
};

xdg.configFile."opencode/skills".source =
  inputs.agents.lib.mkOpencodeSkills {
    pkgs = nixpkgs.legacyPackages.${system};
    customSkills = "${inputs.agents}/skills";
  };
```

See `README.md` for full deployment examples including external skill composition.

## Migration Guide (for the repo owner)

This section documents how to complete the migration from the legacy `agents.json` + `prompts/*.txt` format to the canonical `agent.toml` + `system-prompt.md` format. The canonical files already exist; what remains is updating the consumer configs and removing legacy files.

### Current state

- ✅ All 6 agents exist in canonical format: `agents/{name}/agent.toml` + `agents/{name}/system-prompt.md`
- ✅ `lib.loadAgents` loads canonical agents from TOML
- ✅ `lib.agentsJson` backward-compat bridge produces the old JSON shape from TOML
- ⏳ Legacy files still present: `agents/agents.json`, `prompts/*.txt`
- ⏳ Consumer (home-manager) still reads `agents.json` directly via the old `coding.opencode` module

### Step 1: Update home-manager config in your NixOS/HM flake

Change from the old `coding.opencode` agent options to the new `coding.agents.opencode` module:

```nix
# BEFORE (legacy — agents embedded in config.json):
coding.opencode = {
  enable = true;
  agentsInput = inputs.agents;
  externalSkills = [ ... ];
  ohMyOpencodeSettings = { ... };
  extraSettings = { ... };
};

# AFTER (new — file-based agents from canonical TOML):
coding.opencode = {
  enable = true;  # handles theme, plugins, formatter, oh-my-opencode
  ohMyOpencodeSettings = { ... };
  extraSettings = { ... };
};

coding.agents.opencode = {
  enable = true;
  agentsInput = inputs.agents;
  externalSkills = [ ... ];
  modelOverrides = {
    chiron = "zai-coding-plan/glm-5";
    "chiron-forge" = "zai-coding-plan/glm-5";
  };
};
```

Key changes:

- `agentsInput` and `externalSkills` move from `coding.opencode` to `coding.agents.opencode`
- `modelOverrides` is new — per-agent model selection (previously hardcoded in agents.json)
- Skills, context, commands are now handled by the agents module
- Agents are deployed as file-based `~/.config/opencode/agents/*.md` instead of embedded in config.json

### Step 2: Run home-manager switch

```bash
home-manager switch --flake .
```

Verify that `~/.config/opencode/agents/` contains 6 `.md` files with the correct frontmatter.

### Step 3: Remove legacy files from AGENTS repo

After confirming everything works with the new setup:

```bash
cd /home/m3tam3re/p/AI/AGENTS

# Remove legacy agent definition
rm agents/agents.json

# Remove legacy prompt files (now in agents/*/system-prompt.md)
rm prompts/chiron.txt prompts/chiron-forge.txt prompts/hermes.txt \
   prompts/athena.txt prompts/apollo.txt prompts/calliope.txt
rmdir prompts/  # if empty

# Remove backward-compat bridge from flake.nix
# Delete the lib.agentsJson section from flake.nix
```

After removing `lib.agentsJson`, update flake.nix to remove the bridge function. The `lib.loadAgents` and `lib.mkOpencodeSkills` exports remain.

### Step 4: Verify

```bash
# AGENTS repo: all TOML files parse
cd /home/m3tam3re/p/AI/AGENTS
for f in agents/*/agent.toml; do
  nix eval --impure --expr "builtins.fromTOML (builtins.readFile ./$f)" --json > /dev/null && echo "OK: $f"
done
nix flake check

# nixpkgs: flake check passes
cd /home/m3tam3re/p/NIX/nixpkgs
nix flake check

# Home-manager: agents deployed correctly
ls ~/.config/opencode/agents/
```

### Optional: Enable other tool renderers

To also deploy agents for Claude Code or Pi, add to your home-manager config:

```nix
# Claude Code agents
coding.agents.claude-code = {
  enable = true;
  agentsInput = inputs.agents;
  modelOverrides = { };
};

# Pi agents
coding.agents.pi = {
  enable = true;
  agentsInput = inputs.agents;
};
```

## Rules System

Centralized AI coding rules consumed via `mkCodingRules` from m3ta-nixpkgs
(`mkOpencodeRules` still works as backward-compat alias):

```nix
# In project flake.nix
m3taLib.coding-rules.mkCodingRules {
  inherit agents;
  languages = [ "python" "typescript" ];
  frameworks = [ "n8n" ];
};
```

See `rules/USAGE.md` for full documentation.

## Notes for AI Agents

1. **Config-only repo** — no compilation step; `./scripts/test-skill.sh --validate` is the build
2. **Skills are documentation** — write for AI consumption with progressive disclosure
3. **Consistent 4-level structure** — `skills/name/{SKILL.md,scripts/,references/,assets/}`
4. **Delegation model** — `Chiron (Assistant)` (plan-only), `Chiron Forge (Builder)` (execute), `Hermes (Communication)` (comms), `Athena (Researcher)` (research), `Apollo (Knowledge Management)` (private knowledge), `Calliope (Writer)` (writing). All use model `zai-coding-plan/glm-5`.
5. **Always push** — end every session with commit + `git push`
6. **Rules system** — `rules/` contains language + concern rules injected into projects via `mkOpencodeRules`; edit these when updating cross-repo coding standards
