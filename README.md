# Opencode Agent Skills & Configurations

Central repository for [Opencode](https://opencode.ai) Agent Skills, AI agent configurations, custom commands, and AI-assisted workflows. This is an extensible framework for building productivity systems, automations, knowledge management, and specialized AI capabilities.

## 🎯 What This Repository Provides

This repository serves as a **personal AI operating system** - a collection of skills, agents, and configurations that extend Opencode's capabilities for:

- **Productivity & Task Management** - PARA methodology, GTD workflows, project tracking
- **Knowledge Management** - Note-taking, research workflows, information organization
- **Communications** - Email management, meeting scheduling, follow-up tracking
- **AI Development** - Tools for creating new skills and agent configurations
- **Memory & Context** - Persistent memory systems, conversation analysis
- **Document Processing** - PDF manipulation, spreadsheet handling, diagram generation
- **Custom Workflows** - Domain-specific automation and specialized agents

## 📂 Repository Structure

```
.
├── agents/          # Agent definitions (agents.json)
├── prompts/         # Agent system prompts (chiron.txt, chiron-forge.txt, etc.)
├── context/         # User profiles and preferences
│   └── profile.md   # Work style, PARA areas, preferences
├── commands/        # Custom command definitions
│   └── reflection.md
├── skills/          # Opencode Agent Skills (18 skills)
│   ├── agent-development/    # Agent creation and configuration
│   ├── basecamp/             # Basecamp project management
│   ├── brainstorming/        # Ideation & strategic thinking
│   ├── doc-translator/       # Documentation translation
│   ├── excalidraw/           # Architecture diagrams
│   ├── frontend-design/      # UI/UX design patterns
│   ├── memory/               # Persistent memory system
│   ├── mem0-memory/          # DEPRECATED (use memory)
│   ├── msteams/              # Microsoft Teams integration
│   ├── obsidian/             # Obsidian vault management
│   ├── outline/              # Outline wiki integration
│   ├── outlook/              # Outlook email & calendar
│   ├── pdf/                  # PDF manipulation toolkit
│   ├── prompt-engineering-patterns/   # Prompt patterns
│   ├── reflection/           # Conversation analysis
│   ├── skill-creator/        # Meta-skill for creating skills
│   ├── systematic-debugging/ # Debugging methodology
│   └── xlsx/                 # Spreadsheet handling
├── scripts/         # Repository utility scripts
│   └── test-skill.sh # Test skills without deploying
├── rules/           # Development rules and conventions
├── tools/           # Utility tools
├── AGENTS.md        # Developer documentation
└── README.md        # This file
```

## 🚀 Getting Started

### Prerequisites

- **Opencode** - AI coding assistant ([opencode.dev](https://opencode.ai))
- **Nix** (optional) - For declarative deployment via home-manager
- **Python 3** - For skill validation and creation scripts

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
  "opencode/skills".source = "${inputs.agents}/skills";
  "opencode/context".source = "${inputs.agents}/context";
  "opencode/commands".source = "${inputs.agents}/commands";
  "opencode/prompts".source = "${inputs.agents}/prompts";
};

# Agent config is embedded into config.json, not deployed as files
programs.opencode.settings.agent = builtins.fromJSON
  (builtins.readFile "${inputs.agents}/agents/agents.json");
```

Rebuild your system:

```bash
home-manager switch
```

**Note**: The `agents/` directory is NOT deployed as files. Instead, `agents.json` is read at Nix evaluation time and embedded into the opencode `config.json`.

#### Option 2: Manual Installation

Clone and symlink:

```bash
# Clone repository
git clone https://github.com/yourusername/AGENTS.git ~/AGENTS

# Create symlinks to Opencode config directory
ln -s ~/AGENTS/skills ~/.config/opencode/skills
ln -s ~/AGENTS/context ~/.config/opencode/context
ln -s ~/AGENTS/commands ~/.config/opencode/commands
ln -s ~/AGENTS/prompts ~/.config/opencode/prompts
```

### Verify Installation

Check that Opencode can see your skills:

```bash
# Skills should be available at ~/.config/opencode/skills/
ls ~/.config/opencode/skills/
```

## 🎨 Creating Your First Skill

Skills are modular packages that extend Opencode with specialized knowledge and workflows.

### 1. Initialize a New Skill

```bash
python3 skills/skill-creator/scripts/init_skill.py my-skill-name --path skills/
```

This creates:

- `skills/my-skill-name/SKILL.md` - Main skill documentation
- `skills/my-skill-name/scripts/` - Executable code (optional)
- `skills/my-skill-name/references/` - Reference documentation (optional)
- `skills/my-skill-name/assets/` - Templates and files (optional)

### 2. Edit the Skill

Open `skills/my-skill-name/SKILL.md` and customize:

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
python3 skills/skill-creator/scripts/quick_validate.py skills/my-skill-name
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

| Skill                       | Purpose                                                        | Status       |
| --------------------------- | -------------------------------------------------------------- | ------------ |
| **agent-development**       | Create and configure Opencode agents                           | ✅ Active    |
| **basecamp**                | Basecamp project & todo management via MCP                     | ✅ Active    |
| **brainstorming**           | General-purpose ideation and strategic thinking                | ✅ Active    |
| **doc-translator**          | Documentation translation to German/Czech with Outline publish | ✅ Active    |
| **excalidraw**              | Architecture diagrams from codebase analysis                   | ✅ Active    |
| **frontend-design**         | Production-grade UI/UX with high design quality                | ✅ Active    |
| **memory**                  | SQLite-based persistent memory with hybrid search              | ✅ Active    |
| **mem0-memory**             | Legacy memory system (deprecated)                              | ⚠️ Deprecated |
| **msteams**                 | Microsoft Teams integration via Graph API                      | ✅ Active    |
| **obsidian**                | Obsidian vault management via Local REST API                   | ✅ Active    |
| **outline**                 | Outline wiki integration for team documentation                | ✅ Active    |
| **outlook**                 | Outlook email, calendar, and contact management                | ✅ Active    |
| **pdf**                     | PDF manipulation, extraction, creation, and forms              | ✅ Active    |
| **prompt-engineering-patterns** | Advanced prompt engineering techniques                     | ✅ Active    |
| **reflection**              | Conversation analysis and skill improvement                    | ✅ Active    |
| **skill-creator**           | Guide for creating new Opencode skills                         | ✅ Active    |
| **systematic-debugging**    | Debugging methodology for bugs and test failures               | ✅ Active    |
| **xlsx**                    | Spreadsheet creation, editing, and analysis                    | ✅ Active    |

## 🤖 AI Agents

### Primary Agents

| Agent               | Mode    | Purpose                                              |
| ------------------- | ------- | ---------------------------------------------------- |
| **Chiron**          | Plan    | Read-only analysis, planning, and guidance           |
| **Chiron Forge**    | Build   | Full execution and task completion with safety       |

### Subagents (Specialists)

| Agent               | Domain           | Purpose                                    |
| ------------------- | ---------------- | ------------------------------------------ |
| **Hermes**          | Communication    | Basecamp, Outlook, MS Teams                |
| **Athena**          | Research         | Outline wiki, documentation, knowledge     |
| **Apollo**          | Private Knowledge| Obsidian vault, personal notes             |
| **Calliope**        | Writing          | Documentation, reports, prose              |

**Configuration**: `agents/agents.json` + `prompts/*.txt`

## 🛠️ Development Workflow

### Quality Gates

Before committing:

1. **Validate skills**: `./scripts/test-skill.sh --validate` or `python3 skills/skill-creator/scripts/quick_validate.py skills/<name>`
2. **Test locally**: `./scripts/test-skill.sh --run` to launch opencode with dev skills
3. **Check formatting**: Ensure YAML frontmatter is valid
4. **Update docs**: Keep README and AGENTS.md in sync

## 🎓 Learning Resources

### Essential Documentation

- **AGENTS.md** - Complete developer guide for AI agents
- **skills/skill-creator/SKILL.md** - Comprehensive skill creation guide
- **skills/skill-creator/references/workflows.md** - Workflow pattern library
- **skills/skill-creator/references/output-patterns.md** - Output formatting patterns

### Skill Design Principles

1. **Concise is key** - Context window is a shared resource
2. **Progressive disclosure** - Load information as needed
3. **Appropriate freedom** - Match specificity to task fragility
4. **No extraneous files** - Keep skills focused and minimal

### Example Skills to Study

- **skill-creator/** - Meta-skill with bundled resources
- **reflection/** - Conversation analysis with rating system
- **basecamp/** - MCP server integration with multiple tool categories
- **brainstorming/** - Framework-based ideation with Obsidian markdown save
- **memory/** - SQLite-based hybrid search implementation

## 🔧 Customization

### Modify Agent Behavior

Edit `agents/agents.json` for agent definitions and `prompts/*.txt` for system prompts:

- `agents/agents.json` - Agent names, models, permissions
- `prompts/chiron.txt` - Chiron (Plan Mode) system prompt
- `prompts/chiron-forge.txt` - Chiron Forge (Build Mode) system prompt
- `prompts/hermes.txt` - Hermes (Communication) system prompt
- `prompts/athena.txt` - Athena (Research) system prompt
- `prompts/apollo.txt` - Apollo (Private Knowledge) system prompt
- `prompts/calliope.txt` - Calliope (Writing) system prompt

**Note**: Agent changes require `home-manager switch` to take effect (config is embedded, not symlinked).

### Update User Context

Edit `context/profile.md` to configure:

- Work style preferences
- PARA areas and projects
- Communication preferences
- Integration status

### Add Custom Commands

Create new command definitions in `commands/` directory following the pattern in `commands/reflection.md`.

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
- [PARA Method](https://fortelabs.com/blog/para/) - Productivity methodology
- [Obsidian](https://obsidian.md) - Knowledge management platform

## 🙋 Questions?

- Check `AGENTS.md` for detailed developer documentation
- Review existing skills in `skills/` for examples
- See `skills/skill-creator/SKILL.md` for skill creation guide

---

**Built with** ❤️ **for AI-augmented productivity**
