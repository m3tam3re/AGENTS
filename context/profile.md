# Sascha Koenig - Personal Context

## Identity

- **Name**: Sascha Koenig (m3tam3re)
- **Role**: CTO at company with 150 employees
- **Location**: Germany
- **Creator**: m3ta.dev, YouTube @m3tam3re
- **Background**: E-commerce automation expert, former 7-figure business owner
- **Tech Focus**: NixOS, self-hosting, AI automation, n8n, Docker

## Work Style

| Aspect | Preference |
|--------|------------|
| Focus hours | Early mornings |
| Review time | Evenings |
| Prioritization | Impact-first |
| Batching | Context-based (similar tasks together) |
| Methodology | PARA |

## PARA Areas

1. **CTO Leadership** - Team management, technical strategy, architecture decisions, hiring
2. **m3ta.dev** - Content creation, courses (NixOS Flakes), coaching, tutoring programs
3. **YouTube @m3tam3re** - Technical exploration videos, tutorials, self-hosting guides
4. **Technical Exploration** - NixOS, self-hosting, AI agents, automation experiments
5. **Personal Development** - Learning, skills growth, reading
6. **Health & Wellness** - Exercise, rest, sustainability
7. **Family** - Quality time, responsibilities

## Communication Preferences

### Response Style
- Concise and direct
- Bullet points over paragraphs
- No fluff or pleasantries
- Code examples over explanations

### Proactivity Level
- Anticipate needs and prepare ahead
- Suggest next actions when obvious
- Flag potential issues early

### Notifications
- **Daily**: Evening summaries of completed/pending items
- **Real-time**: Only for urgent/important items
- **Channel**: ntfy for push notifications

### Information Depth
- Quick summaries first
- Drill down on explicit request
- Data-driven with gut-check validation

## Learning Style

- Reading and text-based content
- Examples and walkthroughs
- Step-by-step with rationale
- Real-world use cases

## Decision Making

1. Data-driven analysis first
2. Gut-check validation
3. Options presented with recommendation
4. Final call is mine

## Current Integrations

| System | Purpose | Status |
|--------|---------|--------|
| Obsidian | Knowledge management, PARA system | Active |
| ntfy | Push notifications | Active |
| n8n | Workflow automation | Active |
| Proton Mail | Email | Active |
| Proton Calendar | Scheduling | Active |
| Android | Mobile | Active |

## Obsidian Configuration

- **Vault**: ~/CODEX
- **Structure**: PARA methodology
- **Note Types**: Project, Area, Resource, Archive, Task, Note, Brainstorm

## Context for AI Interactions

### What I Value
- Efficiency over ceremony
- Working solutions over perfect solutions
- Automation over manual processes
- Self-hosted over SaaS when practical
- Open source when available

### Pet Peeves
- Unnecessary verbosity
- Obvious statements
- Asking for confirmation on trivial decisions
- Over-explaining basic concepts

### How to Help Me Best
- Get to the point quickly
- Propose solutions, not just problems
- Batch related information together
- Remember my preferences across sessions
- Proactively surface relevant information

---

## Memory System

AI agents have access to a dual-layer memory system for persistent context across sessions.

### Configuration

| Setting | Value |
|---------|-------|
| **Mem0 Endpoint** | `http://localhost:8000` |
| **Mem0 User ID** | `m3tam3re` |
| **Obsidian Vault** | `~/CODEX` |
| **Memory Folder** | `80-memory/` |
| **Auto-Capture** | Enabled (max 3 per session) |
| **Auto-Recall** | Enabled (top 5, score > 0.7) |

### Memory Categories

| Category | Purpose | Example |
|----------|---------|---------|
| `preference` | Personal preferences | UI settings, workflow styles |
| `fact` | Objective information | Tech stack, role, constraints |
| `decision` | Choices with rationale | Tool selections, architecture |
| `entity` | People, orgs, systems | Key contacts, important APIs |
| `other` | Everything else | General learnings |

### MCP Server

| Setting | Value |
|---------|-------|
| **Server** | `cyanheads/obsidian-mcp-server` |
| **Config** | See `skills/memory/references/mcp-config.md` |

### Usage Notes

- Memories are stored in BOTH Mem0 and Obsidian for redundancy
- Use explicit "remember this" to store important information
- Auto-capture happens at session end with user confirmation
- Relevant memories are injected at session start based on context
