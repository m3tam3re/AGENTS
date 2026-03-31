# Opencode Skills Repository

Configuration repository for Opencode Agent Skills, context files, and agent configurations. Deployed via Nix home-manager to `~/.config/opencode/`.

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

# Enter dev shell (provides Python, jq, poppler, playwright)
nix develop
# or with direnv:
direnv allow
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
├── rules/           # AI coding rules consumed by mkOpencodeRules
│   ├── languages/   # python.md, typescript.md, nix.md, shell.md
│   ├── concerns/    # coding-style.md, naming.md, testing.md, git-workflow.md, etc.
│   └── frameworks/  # Framework-specific rules (n8n.md)
├── agents/          # agents.json — embedded into opencode config.json
├── prompts/         # System prompts (chiron.txt, chiron-forge.txt, etc.)
├── context/         # User profile (profile.md)
├── commands/        # Custom command definitions (reflection.md)
├── scripts/         # Repo utilities (test-skill.sh, validate-agents.sh)
├── flake.nix        # Nix flake: devShells, packages, lib.mkOpencodeSkills
└── .envrc           # direnv: activates nix develop automatically
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

| Context        | Python       | TypeScript   | Nix          | Shell           |
| -------------- | ------------ | ------------ | ------------ | --------------- |
| Variables      | `snake_case` | `camelCase`  | `camelCase`  | `UPPER_SNAKE`   |
| Functions      | `snake_case` | `camelCase`  | `camelCase`  | `lower_case`    |
| Classes        | `PascalCase` | `PascalCase` | —            | —               |
| Constants      | `UPPER_SNAKE`| `UPPER_SNAKE`| `camelCase`  | `UPPER_SNAKE`   |
| Files          | `snake_case` | `camelCase`  | `hyphen-case`| `hyphen-case`   |
| Skill dirs     | `hyphen-case`| —            | —            | —               |
| Markdown files | `UPPERCASE.md` or `sentence-case.md` | | | |

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

## Deployment

**Agent changes** (`agents/agents.json`, `prompts/*.txt`) require `home-manager switch`.  
**All other changes** (skills, context, commands) are visible immediately via symlinks.

```nix
# Minimal home-manager setup
xdg.configFile."opencode/skills".source =
  inputs.agents.lib.mkOpencodeSkills {
    pkgs = nixpkgs.legacyPackages.${system};
    customSkills = "${inputs.agents}/skills";
  };
```

See `README.md` for full deployment examples including external skill composition.

## Quality Gates (Before Committing)

1. `./scripts/test-skill.sh --validate` — all skills pass
2. `./scripts/validate-agents.sh` — agent config is valid (if agents/ changed)
3. Python scripts have `#!/usr/bin/env python3` shebang + Google-style docstrings
4. No extraneous files (`README.md`, `CHANGELOG.md`) inside skill directories
5. If skill scripts have new dependencies → update `flake.nix` `pythonEnv` or `paths`
6. Git status clean before pushing

## Notes for AI Agents

1. **Config-only repo** — no compilation step; `./scripts/test-skill.sh --validate` is the build
2. **Skills are documentation** — write for AI consumption with progressive disclosure
3. **Consistent 4-level structure** — `skills/name/{SKILL.md,scripts/,references/,assets/}`
4. **Delegation model** — `Chiron (Assistant)` (plan-only), `Chiron Forge (Builder)` (execute), `Hermes (Communication)` (comms), `Athena (Researcher)` (research), `Apollo (Knowledge Management)` (private knowledge), `Calliope (Writer)` (writing). All use model `zai-coding-plan/glm-5`.
5. **Always push** — end every session with commit + `git push`
6. **Rules system** — `rules/` contains language + concern rules injected into projects via `mkOpencodeRules`; edit these when updating cross-repo coding standards
