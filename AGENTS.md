# Agent Instructions - Opencode Skills Repository

This repository contains Opencode Agent Skills, context files, and agent configurations for personal productivity and AI-assisted workflows. Files are deployed to `~/.config/opencode/` via Nix flake + home-manager.

## Project Overview

**Type**: Configuration-only repository (no build/compile step)
**Purpose**: Central repository for Opencode Agent Skills, AI agent configurations, custom commands, and workflows. Extensible framework for productivity, automation, knowledge management, and AI-assisted development.
**Primary User**: Sascha Koenig (@m3tam3re)
**Deployment**: Nix flake → home-manager → `~/.config/opencode/`

### Current Focus Areas

- **Productivity & Task Management** - PARA methodology, Anytype integration, reviews
- **Knowledge Management** - Note capture, organization, research workflows
- **Communications** - Email drafts, follow-ups, calendar scheduling
- **AI Development** - Skill creation, agent configurations, custom commands
- **Memory & Context** - Persistent memory with Mem0, conversation analysis

### Extensibility

This repository serves as a foundation for any Opencode-compatible skill or agent configuration. Add new skills for:
- Domain-specific workflows (finance, legal, engineering, etc.)
- Tool integrations (APIs, databases, cloud platforms)
- Custom automation and productivity systems
- Specialized AI agents for different contexts

### Directory Structure

```
.
├── agent/           # AI agent configurations (chiron.md)
├── context/         # User profiles and preferences
├── command/         # Custom command definitions
├── skill/           # Opencode Agent Skills (8 skills)
│   ├── task-management/
│   ├── skill-creator/
│   ├── reflection/
│   ├── communications/
│   ├── calendar-scheduling/
│   ├── mem0-memory/
│   ├── research/
│   └── knowledge-management/
├── .beads/          # Issue tracking database
└── AGENTS.md        # This file
```

## Issue Tracking with Beads

This project uses **bd** (beads) for AI-native issue tracking.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
bd list               # View all issues
bd create "title"     # Create new issue
```

### Beads Workflow Integration

- Issues live in `.beads/` directory (git-tracked)
- Auto-syncs with commits
- CLI-first design for AI agents
- No web UI needed

## Skill Development

### Creating a New Skill

Use the skill initialization script:

```bash
python3 skill/skill-creator/scripts/init_skill.py <skill-name> --path skill/
```

This creates:
- `skill/<skill-name>/SKILL.md` with proper frontmatter template
- `skill/<skill-name>/scripts/` - For executable code
- `skill/<skill-name>/references/` - For documentation
- `skill/<skill-name>/assets/` - For templates/files

### Validating Skills

Run validation before committing:

```bash
python3 skill/skill-creator/scripts/quick_validate.py skill/<skill-name>
```

**Validation checks:**
- YAML frontmatter structure
- Required fields: `name`, `description`
- Name format: hyphen-case, max 64 chars
- Description: max 1024 chars, no angle brackets
- Allowed frontmatter properties: `name`, `description`, `compatibility`, `license`, `allowed-tools`, `metadata`

### Skill Structure Requirements

**SKILL.md Frontmatter** (required):
```yaml
---
name: skill-name
description: What it does and when to use it. Include trigger words.
compatibility: opencode
---
```

**Resource Directories** (optional):
- `scripts/` - Executable Python/Bash code for deterministic operations
- `references/` - Documentation loaded into context as needed
- `assets/` - Files used in output (templates, images, fonts)

### Skill Design Principles

1. **Concise is key** - Context window is shared resource
2. **Progressive disclosure** - Metadata → SKILL.md body → bundled resources
3. **Appropriate freedom** - Match specificity to task fragility
4. **No extraneous files** - No README.md, CHANGELOG.md, etc. in skills
5. **Reference patterns** - See `skill/skill-creator/references/workflows.md` and `output-patterns.md`

## Code Style Guidelines

### File Naming

**Skills**: Hyphen-case (e.g., `task-management`, `skill-creator`)
**Python scripts**: Snake_case (e.g., `init_skill.py`, `quick_validate.py`)
**Markdown files**: UPPERCASE or sentence-case (e.g., `SKILL.md`, `profile.md`)
**Configuration**: Standard conventions (e.g., `config.yaml`, `metadata.json`)

### Markdown Style

**Frontmatter**:
- Always use YAML format between `---` delimiters
- Required fields for skills: `name`, `description`
- Optional: `compatibility: opencode`, `mode: primary`

**Headers**:
- Use ATX-style (`#`, `##`, `###`)
- One H1 per file (skill title)
- Clear hierarchy

**Lists**:
- Use `-` for unordered lists (not `*`)
- Use numbered lists for sequential steps
- Indent nested lists with 2 spaces

**Code blocks**:
- Always specify language for syntax highlighting
- Use `bash` for shell commands
- Use `yaml`, `nix`, `python` as appropriate

**Tables**:
- Use for structured comparisons and reference data
- Keep aligned for readability in source
- Example:
  ```markdown
  | Header 1 | Header 2 |
  |----------|----------|
  | Value    | Value    |
  ```

### Python Style

**Shebang**: Always use `#!/usr/bin/env python3`

**Docstrings**:
```python
"""
Brief description of module/script

Usage:
    script_name.py <arg1> --flag <arg2>

Examples:
    script_name.py my-skill --path ~/.config/opencode/skill
"""
```

**Imports**:
```python
# Standard library
import sys
import os
from pathlib import Path

# Third-party (if any)
import yaml

# Local (if any)
from . import utilities
```

**Naming**:
- Functions: `snake_case`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Private: `_leading_underscore`

**Error handling**:
```python
try:
    # operation
except SpecificException as e:
    print(f"❌ Error: {e}")
    return None
```

**User feedback**:
- Use ✅ for success messages
- Use ❌ for error messages
- Print progress for multi-step operations

### YAML Style

```yaml
# Use lowercase keys with hyphens
skill-name: value

# Quotes for strings with special chars
description: "PARA-based task management. Use when: (1) item, (2) item."

# No quotes for simple strings
compatibility: opencode

# Lists with hyphens
items:
  - first
  - second
```

## Nix Flake Integration

This repository is designed to be consumed by a Nix flake via home-manager.

### Expected Deployment Pattern

```nix
# In your flake.nix or home.nix
xdg.configFile."opencode" = {
  source = /path/to/AGENTS;
  recursive = true;
};
```

This deploys:
- `agent/` → `~/.config/opencode/agent/`
- `skill/` → `~/.config/opencode/skill/`
- `context/` → `~/.config/opencode/context/`
- `command/` → `~/.config/opencode/command/`

### Best Practices for Nix

1. **Keep original structure** - Don't rename directories; Opencode expects this layout
2. **Use recursive = true** - Required for directory deployment
3. **Exclude .git and .beads** - These are development artifacts:
   ```nix
   xdg.configFile."opencode" = {
     source = /path/to/AGENTS;
     recursive = true;
     # Or filter with lib.cleanSource
   };
   ```
4. **No absolute paths in configs** - All references should be relative

## Quality Gates

Before committing changes, verify:

1. **Skill validation** - Run `quick_validate.py` on modified skills
2. **File structure** - Ensure no extraneous files (README in skills, etc.)
3. **Frontmatter** - Check YAML syntax and required fields
4. **Scripts executable** - Python scripts should have proper shebang
5. **Markdown formatting** - Check headers, lists, code blocks
6. **Git status** - No uncommitted or untracked files that should be tracked

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

### MANDATORY WORKFLOW

1. **File issues for remaining work** - Create beads issues for anything that needs follow-up
2. **Run quality gates** - Validate modified skills, check file structure
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

### CRITICAL RULES

- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

## Common Operations

### Test a Skill Locally

```bash
# Validate structure
python3 skill/skill-creator/scripts/quick_validate.py skill/<skill-name>

# Check skill triggers by reading SKILL.md frontmatter
grep -A5 "^description:" skill/<skill-name>/SKILL.md
```

### Create New Skill

```bash
# Initialize
python3 skill/skill-creator/scripts/init_skill.py my-new-skill --path skill/

# Edit SKILL.md and implement resources
# Delete unneeded example files from scripts/, references/, assets/

# Validate
python3 skill/skill-creator/scripts/quick_validate.py skill/my-new-skill
```

### Update User Context

Edit `context/profile.md` to update:
- Work style preferences
- PARA areas
- Communication preferences
- Integration status

### Modify Agent Behavior

Edit `agent/chiron.md` to adjust:
- Skill routing logic
- Communication protocols
- Daily rhythm support
- Operating principles

## Reference Documentation

**Skill creation guide**: `skill/skill-creator/SKILL.md`
**Workflow patterns**: `skill/skill-creator/references/workflows.md`
**Output patterns**: `skill/skill-creator/references/output-patterns.md`
**User profile**: `context/profile.md`
**Agent config**: `agent/chiron.md`
**Beads docs**: `.beads/README.md`

## Notes for AI Agents

1. **This is a config repo** - No compilation, no tests, no runtime
2. **Validation is manual** - Run scripts explicitly before committing
3. **Skills are documentation** - Write for AI consumption, not humans
4. **Context window matters** - Keep skills concise, use progressive disclosure
5. **Nix deployment** - Maintain structure expected by home-manager
6. **Always push** - Follow session completion workflow religiously
