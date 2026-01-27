# Opencode Agent Skills & Configurations

Central repository for [Opencode](https://opencode.dev) Agent Skills, AI agent configurations, custom commands, and AI-assisted workflows. This is an extensible framework for building productivity systems, automations, knowledge management, and specialized AI capabilities.

## 🎯 What This Repository Provides

This repository serves as a **personal AI operating system** - a collection of skills, agents, and configurations that extend Opencode's capabilities for:

- **Productivity & Task Management** - PARA methodology, GTD workflows, project tracking
- **Knowledge Management** - Note-taking, research workflows, information organization
- **Communications** - Email management, meeting scheduling, follow-up tracking
- **AI Development** - Tools for creating new skills and agent configurations
- **Memory & Context** - Persistent memory systems, conversation analysis
- **Custom Workflows** - Domain-specific automation and specialized agents

## 📂 Repository Structure

```
.
├── agent/           # Agent definitions (agents.json)
├── prompts/         # Agent system prompts (chiron.txt, chiron-forge.txt)
├── context/         # User profiles and preferences
│   └── profile.md   # Work style, PARA areas, preferences
├── command/         # Custom command definitions
│   └── reflection.md
├── skill/           # Opencode Agent Skills (11+ skills)
│   ├── task-management/      # PARA-based productivity
│   ├── skill-creator/        # Meta-skill for creating skills
│   ├── reflection/           # Conversation analysis
│   ├── communications/       # Email & messaging
│   ├── calendar-scheduling/  # Time management
│   ├── mem0-memory/          # Persistent memory
│   ├── research/             # Investigation workflows
│   ├── knowledge-management/ # Note capture & organization
│   ├── basecamp/             # Basecamp project management
│   ├── brainstorming/        # Ideation & strategic thinking
│   └── plan-writing/         # Project planning templates
├── scripts/         # Repository utility scripts
│   └── test-skill.sh # Test skills without deploying
├── .beads/          # Issue tracking database
├── AGENTS.md        # Developer documentation
└── README.md        # This file
```

## 🚀 Getting Started

### Prerequisites

- **Opencode** - AI coding assistant ([opencode.dev](https://opencode.dev))
- **Nix** (optional) - For declarative deployment via home-manager
- **Python 3** - For skill validation and creation scripts
- **bd (beads)** (optional) - For issue tracking

### Installation

#### Option 1: Nix Flake (Recommended)

This repository is consumed as a **non-flake input** by your NixOS configuration:

```nix
# In your flake.nix
inputs.agents = {
  url = "git+https://code.m3ta.dev/m3tam3re/AGENTS";
  flake = false;  # Pure files, not a Nix flake
};

# In your home-manager module (e.g., opencode.nix)
xdg.configFile = {
  "opencode/skill".source = "${inputs.agents}/skill";
  "opencode/context".source = "${inputs.agents}/context";
  "opencode/command".source = "${inputs.agents}/command";
  "opencode/prompts".source = "${inputs.agents}/prompts";
};

# Agent config is embedded into config.json, not deployed as files
programs.opencode.settings.agent = builtins.fromJSON 
  (builtins.readFile "${inputs.agents}/agent/agents.json");
```

Rebuild your system:
```bash
home-manager switch
```

**Note**: The `agent/` directory is NOT deployed as files. Instead, `agents.json` is read at Nix evaluation time and embedded into the opencode `config.json`.

#### Option 2: Manual Installation

Clone and symlink:

```bash
# Clone repository
git clone https://github.com/yourusername/AGENTS.git ~/AGENTS

# Create symlink to Opencode config directory
ln -s ~/AGENTS ~/.config/opencode
```

### Verify Installation

Check that Opencode can see your skills:

```bash
# Skills should be available at ~/.config/opencode/skill/
ls ~/.config/opencode/skill/
```

## 🎨 Creating Your First Skill

Skills are modular packages that extend Opencode with specialized knowledge and workflows.

### 1. Initialize a New Skill

```bash
python3 skill/skill-creator/scripts/init_skill.py my-skill-name --path skill/
```

This creates:
- `skill/my-skill-name/SKILL.md` - Main skill documentation
- `skill/my-skill-name/scripts/` - Executable code (optional)
- `skill/my-skill-name/references/` - Reference documentation (optional)
- `skill/my-skill-name/assets/` - Templates and files (optional)

### 2. Edit the Skill

Open `skill/my-skill-name/SKILL.md` and customize:

```yaml
---
name: my-skill-name
description: What it does and when to use it. Include trigger keywords.
compatibility: opencode
---

# My Skill Name

## Overview

[Your skill instructions for Opencode]
```

### 3. Validate the Skill

```bash
python3 skill/skill-creator/scripts/quick_validate.py skill/my-skill-name
```

### 4. Test the Skill

Test your skill without deploying via home-manager:

```bash
# Use the test script to validate and list skills
./scripts/test-skill.sh my-skill-name    # Validate specific skill
./scripts/test-skill.sh --list           # List all dev skills
./scripts/test-skill.sh --run            # Launch opencode with dev skills
```

The test script creates a temporary config directory with symlinks to this repo's skills, allowing you to test changes before committing.

## 📚 Available Skills

| Skill | Purpose | Status |
|-------|---------|--------|
| **task-management** | PARA-based productivity with Obsidian Tasks integration | ✅ Active |
| **skill-creator** | Guide for creating new Opencode skills | ✅ Active |
| **reflection** | Conversation analysis and skill improvement | ✅ Active |
| **communications** | Email drafts, follow-ups, message management | ✅ Active |
| **calendar-scheduling** | Time blocking, meeting management | ✅ Active |
| **mem0-memory** | Persistent memory storage and retrieval | ✅ Active |
| **research** | Investigation workflows, source management | ✅ Active |
| **knowledge-management** | Note capture, knowledge organization | ✅ Active |
| **basecamp** | Basecamp project & todo management via MCP | ✅ Active |
| **brainstorming** | General-purpose ideation with Obsidian save | ✅ Active |
| **plan-writing** | Project plans with templates (kickoff, tasks, risks) | ✅ Active |

## 🤖 AI Agents

### Chiron - Personal Assistant

**Configuration**: `agent/agents.json` + `prompts/chiron.txt`

Chiron is a personal AI assistant focused on productivity and task management. Named after the wise centaur from Greek mythology, Chiron provides:

- Task and project management guidance
- Daily and weekly review workflows
- Skill routing based on user intent
- Integration with productivity tools (Obsidian, ntfy, n8n)

**Modes**:
- **Chiron** (Plan Mode) - Read-only analysis and planning (`prompts/chiron.txt`)
- **Chiron-Forge** (Worker Mode) - Full write access with safety prompts (`prompts/chiron-forge.txt`)

**Triggers**: Personal productivity requests, task management, reviews, planning

## 🛠️ Development Workflow

### Issue Tracking with Beads

This project uses [beads](https://github.com/steveyegge/beads) for AI-native issue tracking:

```bash
bd ready              # Find available work
bd create "title"     # Create new issue
bd update <id> --status in_progress
bd close <id>         # Complete work
bd sync               # Sync with git
```

### Quality Gates

Before committing:

1. **Validate skills**: `./scripts/test-skill.sh --validate` or `python3 skill/skill-creator/scripts/quick_validate.py skill/<name>`
2. **Test locally**: `./scripts/test-skill.sh --run` to launch opencode with dev skills
3. **Check formatting**: Ensure YAML frontmatter is valid
4. **Update docs**: Keep README and AGENTS.md in sync

### Session Completion

When ending a work session:

1. File beads issues for remaining work
2. Run quality gates
3. Update issue status
4. **Push to remote** (mandatory):
   ```bash
   git pull --rebase
   bd sync
   git push
   ```
5. Verify changes are pushed

See `AGENTS.md` for complete developer documentation.

## 🎓 Learning Resources

### Essential Documentation

- **AGENTS.md** - Complete developer guide for AI agents
- **skill/skill-creator/SKILL.md** - Comprehensive skill creation guide
- **skill/skill-creator/references/workflows.md** - Workflow pattern library
- **skill/skill-creator/references/output-patterns.md** - Output formatting patterns

### Skill Design Principles

1. **Concise is key** - Context window is a shared resource
2. **Progressive disclosure** - Load information as needed
3. **Appropriate freedom** - Match specificity to task fragility
4. **No extraneous files** - Keep skills focused and minimal

### Example Skills to Study

- **task-management/** - Full implementation with Obsidian Tasks integration
- **skill-creator/** - Meta-skill with bundled resources
- **reflection/** - Conversation analysis with rating system
- **basecamp/** - MCP server integration with multiple tool categories
- **brainstorming/** - Framework-based ideation with Obsidian markdown save
- **plan-writing/** - Template-driven document generation

## 🔧 Customization

### Modify Agent Behavior

Edit `agent/agents.json` for agent definitions and `prompts/*.txt` for system prompts:
- `agent/agents.json` - Agent names, models, permissions
- `prompts/chiron.txt` - Chiron (Plan Mode) system prompt
- `prompts/chiron-forge.txt` - Chiron-Forge (Worker Mode) system prompt

**Note**: Agent changes require `home-manager switch` to take effect (config is embedded, not symlinked).

### Update User Context

Edit `context/profile.md` to configure:
- Work style preferences
- PARA areas and projects
- Communication preferences
- Integration status

### Add Custom Commands

Create new command definitions in `command/` directory following the pattern in `command/reflection.md`.

## 🌟 Use Cases

### Personal Productivity

Use the PARA methodology with Obsidian Tasks integration:
- Capture tasks and notes quickly
- Run daily/weekly reviews
- Prioritize work based on impact
- Batch similar tasks for efficiency

### Knowledge Management

Build a personal knowledge base:
- Capture research findings
- Organize notes and references
- Link related concepts
- Retrieve information on demand

### AI-Assisted Development

Extend Opencode for specialized domains:
- Create company-specific skills (finance, legal, engineering)
- Integrate with APIs and databases
- Build custom automation workflows
- Deploy via Nix for reproducibility

### Team Collaboration

Share skills and agents across teams:
- Document company processes as skills
- Create shared knowledge bases
- Standardize communication templates
- Build domain expertise libraries

## 🤝 Contributing

This is a personal repository, but the patterns and structure are designed to be reusable:

1. **Fork** this repository
2. **Customize** for your own use case
3. **Share** interesting skills and patterns
4. **Learn** from the skill-creator documentation

## 📝 License

This repository contains personal configurations and skills. Feel free to use the patterns and structure as inspiration for your own setup.

## 🔗 Links

- [Opencode](https://opencode.dev) - AI coding assistant
- [Beads](https://github.com/steveyegge/beads) - AI-native issue tracking
- [PARA Method](https://fortelabs.com/blog/para/) - Productivity methodology
- [Obsidian](https://obsidian.md) - Knowledge management platform

## 🙋 Questions?

- Check `AGENTS.md` for detailed developer documentation
- Review existing skills in `skill/` for examples
- See `skill/skill-creator/SKILL.md` for skill creation guide

---

**Built with** ❤️ **for AI-augmented productivity**
