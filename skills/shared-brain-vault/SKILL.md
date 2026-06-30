---
name: shared-brain-vault
description: "Build and maintain a Git-synced Obsidian vault as shared working memory between user and AI agents. Use when: (1) Writing session summaries or project updates, (2) Recording decisions or learnings, (3) Adding people/profiles to the vault, (4) Populating or restructuring the vault, (5) Setting up multi-agent vault access, (6) Answering 'what did we decide' or 'where do we stand on X'. Triggers: 'shared brain', 'm3ta-brain', 'session summary', 'vault update', 'decision note', 'project status', 'what did we decide'."
compatibility: opencode
---

# Shared Brain Vault

Manage the Git-synced Obsidian vault that serves as shared working memory between Sascha and his AI agents.

## Vault Location

- **Repo**: `ssh://gitea@code.m3ta.dev/m3tam3re/m3ta-brain.git`
- **Standard clone path**: `~/m3ta-brain` (on m3-hermes this resolves to `/var/lib/hermes/m3ta-brain`)
- **Local clone** (Sascha's machines): opened as Obsidian vault

## Scheduled Dream Pass / Cron

When configuring or troubleshooting the nightly m3ta-brain Dream Pass cron, use this installed skill name: `shared-brain-vault`. Do **not** attach a non-existent `m3ta-brain` skill unless it has actually been deployed in the active Hermes profile. The cron prompt should explicitly say to load `shared-brain-vault` and then follow the canonical vault files `~/m3ta-brain/AGENTS.md` and `~/m3ta-brain/SCHEMA.md`; if those disagree with the skill, the vault files win.

Pitfall: a cron run may do useful work and even commit/push, but still be marked `error` if the scheduled job references a missing skill. Fix the job's `skills` field first, then remember that `last_status` will remain `error` until the next successful run.

Cross-agent note: the skill being installed in `~/.hermes/skills/` does not mean it exists in the AGENTS/agent-hub repo. If Sascha asks whether it is in the AGENTS repo, check/ensure `.agents/skills/shared-brain-vault/SKILL.md` separately.

## Read Order (Session Start)

1. `AGENTS.md` — the rules (canonical source for all agents)
2. `SCHEMA.md` — frontmatter types, tag taxonomy, naming conventions
3. `INDEX.md` — dashboard, what's new, what needs attention
4. `20-Projects/` — scan for current project context
5. `10-Preferences/do-dont.md` — hard rules

Do NOT read the entire vault. Read by need.

## Write Policy

### Agent MAY write directly (no review):
- `60-Learning/sessions/` — session summaries after substantial work
- `60-Learning/patterns/` — recurring observations
- `60-Learning/corrections/` — things that were wrong and got fixed
- `60-Learning/inbox/` — candidates pending user review
- `20-Projects/*.md` — status updates after concrete work
- `30-Decisions/*.md` — when a clear decision was made

### Agent SHOULD write as DRAFT (`status: draft`):
- `00-Telos/*.md` — identity, goals, constraints
- `10-Preferences/*.md` — personal preferences, working style
- `40-People/*.md` — person profiles (especially colleagues)
- `70-Collaboration/*.md` — collaboration agreements

### Agent MUST NOT write:
- Passwords, API keys, tokens, secrets
- Intimate/private details without explicit consent
- Speculative assumptions stated as facts
- Full chat transcripts (use summaries, not raw dumps)

## Session-End Workflow

After substantial work in a session:

1. Write session summary to `60-Learning/sessions/YYYY-MM-DD-{slug}.md`
2. If a decision was made → create/update `30-Decisions/` note
3. If project state changed → update `20-Projects/{project}.md`
4. If something new was learned → candidate in `60-Learning/inbox/`
5. Update `INDEX.md` if new notes were added
6. `git add -A && git commit -m "update: {description}" && git push`

Not every session needs a summary. Only sessions that produced durable value.

## Language & Link Conventions

- **Language**: German primary, English technical terms (match how Sascha communicates)
- **Links**: Standard Markdown relative links (`[Text](relative/path.md)`) — works in Gitea AND Obsidian. Do not write Obsidian-only double-bracket links.
- **Tags**: YAML frontmatter `tags:` list, not inline `#tag`
- **Dates**: `YYYY-MM-DD` everywhere
- **File naming**: `kebab-case.md`

> **CRITICAL**: Current `AGENTS.md` and `SCHEMA.md` in the vault are canonical. If this skill disagrees with them, follow the vault files and patch the skill.

## Vault Structure

```
00-Telos/           Who Sascha is, goals, constraints
10-Preferences/     Communication, tech-stack, working-style, do-don't
20-Projects/        Active project cards (state, next actions, decisions)
30-Decisions/       ADR-style decision records
40-People/          Colleagues, external contacts, family
50-Knowledge/       Reference knowledge (systems, concepts, companies)
60-Learning/        Session summaries, patterns, corrections
70-Collaboration/   How agents and human work together
80-Templates/       Note templates (project, decision, person, etc.)
90-Archive/         Completed/deprecated
```

## Multi-Agent Compatibility

This vault works with ANY agent (Hermes, Pi, OpenCode, Claude Code, Codex):
- `AGENTS.md` at root = universal instructions (no agent-specific assumptions)
- Agent identity stays in commit messages, not in note bodies
- Multiple agents may read/write — last-writer-wins via Git
- Sascha uses Pi + OpenCode on work laptop (with Basecamp CLI access)

### Agent-Hub skill deployment

When Sascha asks whether this skill is in the AGENTS/agent-hub repo, verify `.agents/skills/shared-brain-vault/SKILL.md`; the Hermes-installed copy under `~/.hermes/skills/` is not enough for cross-agent use. If deploying it, copy the whole skill directory including `references/` and `scripts/`, stage only `.agents/skills/shared-brain-vault`, run the link audit and Agent-Hub checks, then commit without mixing pre-existing dirty Agent-Hub files. See `references/agent-hub-skill-deployment.md` for the command recipe and verification checklist.

## Initial Population Technique

When populating the vault from scratch or doing a major migration:

1. **Extract context** from all available sources:
   - Hermes internal memory (`~/.hermes/memories/MEMORY.md`, `USER.md`)
   - Honcho peer card and user profile
   - Session search for key topics (5-10 queries covering all major projects)
   - Existing wikis (tech wiki, nemoti wiki)
   - Git repos for infrastructure details
2. **Compile into a single source file** at `/tmp/m3ta-brain-source/context.md`
3. **Dispatch parallel subagents** (up to 3), each handling distinct sections:
   - Agent A: Telos + Preferences + Collaboration
   - Agent B: Projects + Decisions + Knowledge
   - Agent C: People + Learning
4. Each subagent reads AGENTS.md + SCHEMA.md + context file, writes its files
5. **Merge, update INDEX.md, commit, push**

See `references/km-landscape-research.md` for the research that informed this design (Karpathy LLM Wiki, Miessler PAI, qmd, Obsidian MCP integrations).

See the vault's current link-audit command (documented in the `m3ta-brain` skill's `references/vault-map.md` when available, or in vault maintenance notes) after any vault population or restructuring.

## Relationship to Other Knowledge Stores

| Store | Path | Purpose | Links |
|---|---|---|---|
| **m3ta-brain** (this) | `~/m3ta-brain` | Shared working memory | Standard Markdown relative links |
| Tech Wiki | `/var/lib/hermes/wiki` | Research, concepts (EN) | Standard Markdown relative links |
| Nemoti Wiki | `/var/lib/hermes/wiki-nemoti` | Lore, art strategy (DE) | Standard Markdown relative links |
| Hermes Memory | `~/.hermes/memories/` | Hot cache, high-priority facts | N/A |
| Session DB | Hermes internal | Raw transcripts | `session_search()` |

**Rule**: Don't duplicate content across stores. m3ta-brain holds context and cross-references; research wikis hold detailed knowledge; Hermes memory holds hot facts for fast injection.

## Pitfalls

- **Use standard Markdown links in m3ta-brain** — Gitea compatibility matters. This differs from older Obsidian-only guidance; current vault rules in `AGENTS.md` and `SCHEMA.md` are canonical.
- **Don't dump raw chat transcripts** — write concise summaries with decisions, learnings, next actions.
- **Don't create notes without cross-links** — minimum 2 internal Markdown links per note. Orphan notes break the graph.
- **Don't write to 00-Telos or 10-Preferences without `status: draft`** — these are personal and need user review.
- **Don't forget to `git push`** — the vault is useless if changes stay local.
- **Don't confuse vault purposes** — m3ta-brain is working memory (state, decisions, learnings), not a research encyclopedia. For research, use the `research-intelligence` skill.
- **People profiles are sensitive** — use `sensitivity: confidential` and `status: draft` for all person notes. Add colleagues only as information is learned through actual work.
- **Subagents produce broken links** — after ANY parallel subagent population, run a Markdown-link audit and fix broken relative targets. Common errors: paths relative to vault root instead of the current file, placeholder example links, directory-only links with no target file, and ambiguous note names.
- **`.gitkeep` is invisible in Obsidian** — use `README.md` instead for placeholder/directory-explanation content. Obsidian only shows `.md` files in the file explorer; hidden files are excluded.
- **`execute_code` may be blocked in cron profiles** — run the link audit via `terminal`/`python3`, not via `execute_code`, if cron execution rejects Python tool calls.
- **Dream Pass cron skill names can drift** — if a scheduled vault job reports `Skill(s) not found` for a vault-specific alias such as `m3ta-brain`, first list installed skills and update the cron to use the available class-level skill (`shared-brain-vault`) while keeping `~/m3ta-brain/AGENTS.md` and `~/m3ta-brain/SCHEMA.md` as canonical runtime instructions. Update both the cron `skills` field and any prompt text that tells the agent to load the missing skill; otherwise the next run may still be marked failed even if the task succeeds via fallback.
