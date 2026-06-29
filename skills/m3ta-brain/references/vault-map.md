# Vault Map — m3ta-brain Structure Reference

> Full directory layout with purpose and content guidelines for each section.

## Root Files

| File | Purpose |
|---|---|
| `AGENTS.md` | Universal agent instructions: read order, write policy, conventions |
| `SCHEMA.md` | Frontmatter types, tag taxonomy, naming conventions, quality rules |
| `README.md` | Human-facing intro and quick-start guide |
| `INDEX.md` | Dashboard: stats, active projects, recent decisions, recent sessions |
| `.obsidian/app.json` | Obsidian settings: Wikilinks OFF, relative paths ON |
| `.gitignore` | Ignores workspace state, OS files, sync conflicts |

## Directory Detail

### 00-Telos/ (Identity)

| File | Content | Write Rule |
|---|---|---|
| `sascha.md` | Identity card: name, role, tech background, traits, motivation | Draft only |
| `goals.md` | Professional + personal goals with timeframes | Draft only |
| `constraints.md` | Hard constraints: team skills, budget, self-hosting, security | Draft only |

### 10-Preferences/ (How Sascha Works)

| File | Content | Write Rule |
|---|---|---|
| `communication.md` | Communication style: terse text, modality matching, language | Draft only |
| `tech-stack.md` | Full tech stack organized by category | Draft only |
| `working-style.md` | Delegation vs oversight, test-driven infra, iterative debugging | Draft only |
| `do-dont.md` | Explicit Do's and Don'ts table — HARD RULES | Draft only |

### 20-Projects/ (Active Work)

| File | Content | Write Rule |
|---|---|---|
| `overview.md` | Dashboard table of all projects with status/priority | Direct |
| `az-gruppe.md` | CTO role, Bestellungs-Pipeline, Appsmith, K8s | Direct |
| `nemoti.md` | Nemoti art support, YouTube/TikTok/Twitch/Website | Direct |
| `m3ta-home.md` | Portable NixOS profile framework | Direct |
| `m3-hermes.md` | Hermes Agent, Matrix gateway | Direct |
| `honcho.md` | Honcho self-hosting on m3-atlas | Direct |
| `hermes-nixos-setup.md` | Livestream + Blogpost standalone repo | Direct |
| `agent-hub.md` | Cross-agent coordination, Beads task queue | Direct |
| `infrastructure.md` | Server overview, domains, services | Direct |

### 30-Decisions/ (ADR-style)

| File | Content |
|---|---|
| `INDEX.md` | Table of all decisions sorted by date |
| `YYYY-MM-{slug}.md` | Individual decision records |

Each decision note has: Context → Decision → Rationale → Consequences → Revisit When → Related.

### 40-People/ (Contacts)

| File/Dir | Content | Sensitivity |
|---|---|---|
| `INDEX.md` | Index of all people | Internal |
| `family.md` | Nemoti profile | Confidential |
| `colleagues/README.md` | Placeholder + guidance for colleague profiles | Internal |
| `colleagues/{name}.md` | Individual colleague profiles | Confidential |
| `external/{name}.md` | External contacts | Internal |

### 50-Knowledge/ (Reference)

| Dir | Content |
|---|---|
| `systems/` | Infrastructure systems (Traefik, Netbird, Authentik, etc.) |
| `concepts/` | Methods, patterns, frameworks |
| `companies/` | Organization profiles |

### 60-Learning/ (Accumulated Wisdom)

| Dir | Content | Write Rule |
|---|---|---|
| `sessions/` | Session summaries (YYYY-MM-DD-slug.md) | Direct |
| `patterns/` | Recurring observations about work habits, preferences | Direct |
| `corrections/` | Things that were wrong and got fixed | Direct |
| `inbox/` | Candidates pending review (drafts before promotion) | Direct |

### 70-Collaboration/ (Working Agreement)

| File | Content | Write Rule |
|---|---|---|
| `how-we-work.md` | Delegation model, when to ask vs decide, session workflow | Draft only |
| `agent-conventions.md` | Rules for any agent working in this vault | Draft only |
| `multi-agent-setup.md` | How Pi/OpenCode/other agents use the vault | Draft only |

### 80-Templates/ (Note Templates)

Read-only reference. Contains: `project.md`, `decision.md`, `person.md`, `session-summary.md`, `learning.md`.

### 90-Archive/ (Deprecated)

Completed projects, superseded decisions, discarded candidates.

## Link Audit Command

To check for broken links across the vault:

```bash
python3 -c "
import os, re
from collections import defaultdict

VAULT = '/var/lib/hermes/workspace/m3ta-brain'
md_files = []
for root, dirs, files in os.walk(VAULT):
    if '.git' in root or '.obsidian' in root: continue
    for f in files:
        if f.endswith('.md'):
            md_files.append(os.path.relpath(os.path.join(root, f), VAULT))

# Build index
paths = set(md_files)
broken = []
for f in md_files:
    with open(os.path.join(VAULT, f)) as fh:
        for i, line in enumerate(fh, 1):
            for m in re.finditer(r'\[([^\]]+)\]\(([^)]+\.md)\)', line):
                target = m.group(2)
                if target.startswith('http'): continue
                resolved = os.path.normpath(os.path.join(os.path.dirname(f), target))
                if resolved not in paths:
                    broken.append((f, i, target))
print(f'Broken links: {len(broken)}')
for f, i, t in broken:
    print(f'  {f}:{i} → {t}')
"
```

## Tag Taxonomy (from SCHEMA.md)

| Tag | Use for |
|---|---|
| `infrastructure` | Servers, domains, networks, services |
| `nixos` | NixOS/Flakes/Nix-related |
| `work` | AZ-Gruppe / AZ-Intec related |
| `creative` | Nemoti art, music, lore |
| `decision` | Architecture/system decisions |
| `agent` | AI agent infrastructure |
| `security` | Security-relevant info |
| `process` | How-we-work conventions |
| `person` | Person profiles |
| `deprecated` | No longer current |
