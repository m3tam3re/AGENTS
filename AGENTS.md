# Opencode Skills Repository

Configuration repository for Opencode Agent Skills, context files, and agent configurations. Deployed via Nix home-manager to `~/.config/opencode/`.

## Quick Commands

```bash
# Skill validation
./scripts/test-skill.sh --validate   # Validate all skills
./scripts/test-skill.sh <skill-name>  # Validate specific skill
./scripts/test-skill.sh --run        # Test interactively

# Skill creation
python3 skills/skill-creator/scripts/init_skill.py <name> --path skills/

# Issue tracking (beads)
bd ready && bd create "title" && bd close <id> && bd sync
```

## Directory Structure

```
.
├── skills/          # Agent skills (25 modules)
│   └── skill-name/
│       ├── SKILL.md         # Required: YAML frontmatter + workflows
│       ├── scripts/         # Executable code (optional)
│       ├── references/      # Domain docs (optional)
│       └── assets/         # Templates/files (optional)
├── agents/          # Agent definitions (agents.json)
├── prompts/         # System prompts (chiron*.txt)
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
**Excalidraw**: NEVER use diamond shapes (broken arrows), NEVER use `label` property
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

## Deployment

**Nix pattern** (non-flake input):
```nix
agents = {
  url = "git+https://code.m3ta.dev/m3tam3re/AGENTS";
  flake = false;  # Files only, not a Nix flake
};
```

**Mapping** (via home-manager):
- `skills/`, `context/`, `commands/`, `prompts/` → symlinks
- `agents/agents.json` → embedded into config.json
- Agent changes: require `home-manager switch`
- Other changes: visible immediately

## Notes for AI Agents

1. **Config-only repo** - No compilation, no build, manual validation only
2. **Skills are documentation** - Write for AI consumption, progressive disclosure
3. **Consistent structure** - All skills follow 4-level deep pattern (skills/name/ + optional subdirs)
4. **Cross-cutting concerns** - Standardized SKILL.md, workflow patterns, delegation rules
5. **Always push** - Session completion workflow: commit + bd sync + git push

## Quality Gates

Before committing:
1. `./scripts/test-skill.sh --validate`
2. Python shebang + docstrings check
3. No extraneous files (README.md, CHANGELOG.md in skills/)
4. Git status clean
