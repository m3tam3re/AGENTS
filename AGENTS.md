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
├── agent/           # Agent definitions (agents.json)
├── prompts/         # Agent system prompts (chiron.txt, chiron-forge.txt)
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
├── scripts/         # Repository-level utility scripts
└── AGENTS.md        # This file
```


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

This repository is the central source for all Opencode configuration, consumed as a **non-flake input** by your NixOS configuration.

### Integration Reference

**NixOS config location**: `~/p/NIX/nixos-config/home/features/coding/opencode.nix`

**Flake input definition** (in `flake.nix`):
```nix
agents = {
  url = "git+https://code.m3ta.dev/m3tam3re/AGENTS";
  flake = false;  # Pure files, not a Nix flake
};
```

### Deployment Mapping

| Source | Deployed To | Method |
|--------|-------------|--------|
| `skill/` | `~/.config/opencode/skill/` | xdg.configFile (symlink) |
| `context/` | `~/.config/opencode/context/` | xdg.configFile (symlink) |
| `command/` | `~/.config/opencode/command/` | xdg.configFile (symlink) |
| `prompts/` | `~/.config/opencode/prompts/` | xdg.configFile (symlink) |
| `agent/agents.json` | `programs.opencode.settings.agent` | **Embedded into config.json** |

### Important: Agent Configuration Nuance

The `agent/` directory is **NOT** deployed as files to `~/.config/opencode/agent/`. Instead, `agents.json` is read at Nix evaluation time and embedded directly into the opencode `config.json` via:

```nix
programs.opencode.settings.agent = builtins.fromJSON (builtins.readFile "${inputs.agents}/agent/agents.json");
```

**Implications**:
- Agent changes require `home-manager switch` to take effect
- Skills, context, and commands are symlinked (changes visible immediately after rebuild)
- The `prompts/` directory is referenced by `agents.json` via `{file:./prompts/chiron.txt}` syntax


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


## Testing Skills

Since this repo deploys via Nix/home-manager, changes require a rebuild to appear in `~/.config/opencode/`. Use these methods to test skills during development.

### Method 1: XDG_CONFIG_HOME Override (Recommended)

Test skills by pointing opencode to this repository directly:

```bash
# From the AGENTS repository root
cd ~/p/AI/AGENTS

# List skills loaded from this repo (not the deployed ones)
XDG_CONFIG_HOME=. opencode debug skill

# Run an interactive session with development skills
XDG_CONFIG_HOME=. opencode

# Or use the convenience script
./scripts/test-skill.sh              # List all development skills
./scripts/test-skill.sh task-management  # Validate specific skill
./scripts/test-skill.sh --run        # Launch interactive session
```

**Note**: The convenience script creates a temporary directory with proper symlinks since opencode expects `$XDG_CONFIG_HOME/opencode/skill/` structure.

### Method 2: Project-Local Skills

For quick iteration on a single skill, use `.opencode/skill/` in any project:

```bash
cd /path/to/any/project
mkdir -p .opencode/skill/

# Symlink the skill you're developing
ln -s ~/p/AI/AGENTS/skill/my-skill .opencode/skill/

# Skills in .opencode/skill/ are auto-discovered alongside global skills
opencode debug skill
```

### Method 3: Validation Only

Validate skill structure without running opencode:

```bash
# Validate a single skill
python3 skill/skill-creator/scripts/quick_validate.py skill/<skill-name>

# Validate all skills
for dir in skill/*/; do
  python3 skill/skill-creator/scripts/quick_validate.py "$dir"
done
```

### Verification Commands

```bash
# List all loaded skills (shows name, description, location)
opencode debug skill

# Show resolved configuration
opencode debug config

# Show where opencode looks for files
opencode debug paths
```


## Common Operations

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

Edit `agent/agents.json` to adjust agent definitions, and `prompts/*.txt` for system prompts:
- `agent/agents.json` - Agent names, models, permissions
- `prompts/chiron.txt` - Chiron (Plan Mode) system prompt
- `prompts/chiron-forge.txt` - Chiron-Forge (Worker Mode) system prompt

## Reference Documentation

**Skill creation guide**: `skill/skill-creator/SKILL.md`
**Workflow patterns**: `skill/skill-creator/references/workflows.md`
**Output patterns**: `skill/skill-creator/references/output-patterns.md`
**User profile**: `context/profile.md`
**Agent config**: `agent/agents.json`

## Notes for AI Agents

1. **This is a config repo** - No compilation, no tests, no runtime
2. **Validation is manual** - Run scripts explicitly before committing
3. **Skills are documentation** - Write for AI consumption, not humans
4. **Context window matters** - Keep skills concise, use progressive disclosure
5. **Nix deployment** - Maintain structure expected by home-manager
6. **Always push** - Follow session completion workflow religiously
