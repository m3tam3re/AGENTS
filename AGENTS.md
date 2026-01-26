# Agent Instructions - Opencode Skills Repository

Configuration repository for Opencode Agent Skills, context files, and agent configurations. Files deploy to `~/.config/opencode/` via Nix flake + home-manager.

## Quick Commands

### Testing Skills
```bash
# List or validate all skills
./scripts/test-skill.sh              # List all development skills
./scripts/test-skill.sh --validate   # Validate all skills
./scripts/test-skill.sh <skill-name>  # Validate specific skill

# Test in Opencode (interactive)
./scripts/test-skill.sh --run        # Launch session with dev skills
```

### Creating Skills
```bash
python3 skills/skill-creator/scripts/init_skill.py <skill-name> --path skills/
python3 skills/skill-creator/scripts/quick_validate.py skills/<skill-name>
```

### Running Tests
```bash
# Run single test file
python3 -m unittest skills/pdf/scripts/check_bounding_boxes_test.py

# Run all tests in a module
python3 -m unittest discover -s skills/pdf/scripts -p "*_test.py"
```

### Issue Tracking
```bash
bd ready              # Find available work
bd create "title"     # Create new issue
bd update <id> --status in_progress
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Code Style Guidelines

### File Naming
- Skills: hyphen-case (e.g., `task-management`, `skill-creator`)
- Python: snake_case (e.g., `init_skill.py`, `quick_validate.py`)
- Markdown: UPPERCASE or sentence-case (e.g., `SKILL.md`, `profile.md`)
- Config: Standard conventions (e.g., `config.yaml`, `metadata.json`)

### Python Style
**Shebang**: Always `#!/usr/bin/env python3`

**Docstrings**:
```python
"""
Brief description

Usage:
    script.py <args>

Examples:
    script.py my-skill --path ~/.config/opencode/skill
"""
```

**Imports** (standard → third-party → local):
```python
import sys
import os
from pathlib import Path
import yaml
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
```python
print(f"✅ Success: {result}")
print(f"❌ Error: {error}")
```

### Bash Style
**Shebang**: Always `#!/usr/bin/env bash`
**Strict mode**: `set -euo pipefail`
**Functions**: `snake_case`, descriptive names

### Markdown Style
- YAML frontmatter between `---` delimiters
- ATX headers (`#`, `##`, `###`)
- Use `-` for unordered lists
- Specify language in code blocks (```python, ```bash, etc.)

### YAML Style
```yaml
name: skill-name
description: "Text with special chars in quotes"
compatibility: opencode
items:
  - first
  - second
```

## Directory Structure

```
.
├── agents/          # Agent definitions (agents.json)
├── prompts/         # Agent system prompts
├── context/         # User profiles and preferences
├── commands/        # Custom command definitions
├── skills/          # Opencode Agent Skills
│   ├── skill-name/
│   │   ├── SKILL.md
│   │   ├── scripts/     # Executable code (optional)
│   │   ├── references/   # Documentation (optional)
│   │   └── assets/      # Templates/files (optional)
├── scripts/         # Repository utilities
└── AGENTS.md        # This file
```

## Nix Deployment

**Flake input** (non-flake):
```nix
agents = {
  url = "git+https://code.m3ta.dev/m3tam3re/AGENTS";
  flake = false;
};
```

**Deployment mapping**:
- `skills/` → `~/.config/opencode/skill/` (symlink)
- `context/` → `~/.config/opencode/context/` (symlink)
- `commands/` → `~/.config/opencode/command/` (symlink)
- `prompts/` → `~/.config/opencode/prompts/` (symlink)
- `agents/agents.json` → Embedded into opencode config.json (not symlinked)

**Note**: Agent changes require `home-manager switch`; other changes visible after rebuild.

## Quality Gates

Before committing:
1. Validate skills: `./scripts/test-skill.sh --validate`
2. Validate YAML frontmatter: `python3 skills/skill-creator/scripts/quick_validate.py skills/<name>`
3. Check Python scripts have proper shebang and docstrings
4. Ensure no extraneous files (README.md, CHANGELOG.md in skills)
5. Git status clean

## Notes for AI Agents

1. **Config-only repo** - No compilation, no build, minimal test infrastructure
2. **Validation is manual** - Run scripts explicitly before committing
3. **Skills are documentation** - Write for AI consumption, not humans
4. **Directory naming** - Use `skills/` (plural), not `skill/`; `agents/` (plural), not `agent/`
5. **Commands naming** - Use `commands/` (plural), not `command/`
6. **Nix deployment** - Maintain structure expected by home-manager
7. **Always push** - Follow session completion workflow

## Optimization Opportunities

1. **Add Python linting** - Configure ruff or black for consistent formatting
2. **Add pre-commit hooks** - Auto-validate skills and run linters before commit
3. **Test coverage** - Add pytest for skill scripts beyond PDF skill
4. **CI/CD** - Add GitHub Actions to validate skills on PR
5. **Documentation** - Consolidate README.md and AGENTS.md to reduce duplication
