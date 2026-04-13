# Agent Skills Repository

Configuration repository for AI Agent Skills, canonical agent definitions, context files, and agent configurations. Deployed via Nix home-manager to `~/.config/opencode/` (or equivalent paths for other tools).

## Quick Commands

```bash
# Skill validation
./scripts/test-skill.sh --validate   # Validate all skills
./scripts/test-skill.sh <skill-name>  # Validate specific skill
./scripts/test-skill.sh --run        # Test interactively

# Skill creation
python3 skills/skill-creator/scripts/init_skill.py <name> --path skills/

# Verify agent TOML parses
for f in agents/*/agent.toml; do nix eval --impure --expr "builtins.fromTOML (builtins.readFile ./$f)" --json > /dev/null && echo "OK: $f"; done
```

## Directory Structure

```
.
├── skills/          # Agent skills (15 modules)
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

## Code Conventions

**File naming**: hyphen-case (skills), snake_case (Python), UPPERCASE/sentence-case (MD)

**SKILL.md structure**:
```yaml
---
name: skill-name
description: "Use when: (1) X, (2) Y. Triggers: a, b, c."
compatibility: opencode
---

## Overview (1 line)
## Core Workflows (step-by-step)
## Integration with Other Skills
```

**Python**: `#!/usr/bin/env python3` + docstrings + emoji feedback (✅/❌)
**Bash**: `#!/usr/bin/env bash` + `set -euo pipefail`
**Markdown**: YAML frontmatter, ATX headers, `-` lists, language in code blocks

## Anti-Patterns (CRITICAL)

**Frontend Design**: NEVER use generic AI aesthetics, NEVER converge on common choices
**Excalidraw**: NEVER use `label` property (use boundElements + text element pairs instead)
**Debugging**: NEVER fix just symptom, ALWAYS find root cause first
**Excel**: ALWAYS respect existing template conventions over guidelines
**Structure**: NEVER place scripts/docs outside scripts/references/ directories

## Testing Patterns

**Unique conventions** (skill-focused, not CI/CD):
- Manual validation via `test-skill.sh`, no automated CI
- Tests co-located with source (not separate test directories)
- YAML frontmatter validation = primary quality gate
- Mixed formats: Python unittest, markdown pressure tests, A/B prompt testing

**Known deviations**:
- `systematic-debugging/test-*.md` - Academic/pressure testing in wrong location
- `pdf/forms.md`, `pdf/reference.md` - Docs outside references/

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

| Tool | Output | Path |
|------|--------|------|
| OpenCode | `.opencode/agents/*.md` | `~/.config/opencode/agents/` |
| Claude Code | `.claude/agents/*.md` + `settings.json` | `~/.claude/` |
| Pi | `AGENTS.md` + `SYSTEM.md` | `~/.pi/agent/` |

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

**Nix flake pattern**:
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
    externalSkills = [
      { src = inputs.skills-anthropic; }
    ];
  };
```

**Project flake example (selective):**
```nix
".agents/skills".source =
  inputs.agents.lib.mkOpencodeSkills {
    pkgs = nixpkgs.legacyPackages.${system};
    externalSkills = [
      { src = inputs.skills-anthropic; selectSkills = [ "mcp-builder" ]; }
    ];
  };
```

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

1. **Config-only repo** - No compilation, no build, manual validation only
2. **Skills are documentation** - Write for AI consumption, progressive disclosure
3. **Consistent structure** - All skills follow 4-level deep pattern (skills/name/ + optional subdirs)
4. **Cross-cutting concerns** - Standardized SKILL.md, workflow patterns, delegation rules
5. **Always push** - Session completion workflow: commit + git push

## Quality Gates

Before committing:
1. `./scripts/test-skill.sh --validate`
2. Python shebang + docstrings check
3. No extraneous files (README.md, CHANGELOG.md in skills/)
4. If skill has scripts with external dependencies → verify `flake.nix` is updated (see skill-creator Step 4)
5. Git status clean
