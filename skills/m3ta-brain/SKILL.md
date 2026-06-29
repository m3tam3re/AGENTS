---
name: m3ta-brain
description: "Shared Obsidian vault for human-agent collaboration. Use when: (1) Loading project context at session start (auto-recall), (2) Writing session summaries, decisions, project updates, or learning notes, (3) Searching for past decisions or project state, (4) Running nightly/weekly digest passes, (5) Creating or updating person profiles, (6) Any reference to 'the vault', 'shared brain', 'our context', 'what did we decide'. Triggers: m3ta-brain, shared brain, vault, session summary, decision note, project update, memory candidate, brain vault, auto-recall, digest, nightly pass."
compatibility: opencode
---

# m3ta-brain

Shared Obsidian vault — the persistent, compounding working memory between Sascha and all AI agents. Git-versioned, standard Markdown, works in Obsidian and Gitea.

## Prerequisites

- Vault cloned at `~/m3ta-brain` (resolves per-machine: `/var/lib/hermes/m3ta-brain` on m3-hermes, `/home/m3tam3re/m3ta-brain` on desktop, etc.)
- Git configured with push access to `ssh://gitea@code.m3ta.dev/m3tam3re/m3ta-brain.git`
- Obsidian settings (auto-configured via `.obsidian/app.json`): Wikilinks OFF, relative paths ON

Always pull before reading or writing:

```bash
cd ~/m3ta-brain && git pull --rebase
```

## Vault Structure (Quick Reference)

See `references/vault-map.md` for full layout. Key directories:

| Dir | Purpose | Write Access |
|---|---|---|
| `00-Telos/` | Identity, goals, constraints | Draft only |
| `10-Preferences/` | Communication, tech stack, do's & don'ts | Draft only |
| `20-Projects/` | Active project cards (state, next actions) | Direct |
| `30-Decisions/` | Architecture Decision Records | Direct |
| `40-People/` | Person profiles | Draft + confidential |
| `50-Knowledge/` | Systems, concepts, companies | Direct |
| `60-Learning/` | Sessions, patterns, corrections, inbox | Direct (inbox = candidates) |
| `70-Collaboration/` | How-we-work, agent conventions | Draft only |
| `80-Templates/` | Note templates | Read-only reference |

---

## Workflow 1: Session Start (Auto-Recall)

**When:** At the beginning of any substantial work session, or when the user references past context.

### Step 1: Pull latest

```bash
cd ~/m3ta-brain && git pull --rebase
```

### Step 2: Read core context

Read in this order (stop early if context is sufficient — do NOT read the entire vault):

1. `AGENTS.md` — the rules (skim if already known)
2. `INDEX.md` — dashboard, what's new, stats
3. `10-Preferences/do-dont.md` — hard rules to respect THIS session

### Step 3: Load project-specific context

Determine the relevant project(s) from the user's message or working directory. Read only the relevant project cards:

```
20-Projects/{project-slug}.md
```

If the topic is ambiguous, read `20-Projects/overview.md` for the dashboard.

### Step 4: Search for relevant history (optional, when deeper context needed)

If qmd is installed:

```bash
qmd query "{topic}" -c brain --md -n 5
```

If qmd is NOT installed, use `search_files` on the vault directory:

```
search_files(pattern="{topic}", path="~/m3ta-brain", target="content")
```

### Step 5: Recall relevant decisions

For architectural or strategic questions, check recent decisions:

```
30-Decisions/INDEX.md
```

### Token budget

Cap auto-recall to ~2000 tokens of injected context. Summarize rather than dumping full notes.

---

## Workflow 2: Session End (Persist Learnings)

**When:** After substantial work — at minimum when explicitly asked, ideally proactively for any session that produced decisions, project changes, or learnings.

### Step 1: Write session summary

File: `60-Learning/sessions/YYYY-MM-DD-{slug}.md`

Use template `80-Templates/session-summary.md`. Fill all sections:

```yaml
---
type: session-summary
created: YYYY-MM-DD
updated: YYYY-MM-DD
session_date: YYYY-MM-DD
projects: []
tags: [session]
---
```

Content sections: What We Discussed → Decisions Made → New Context Learned → Project Updates → Open Questions → Suggested Memory Candidates → Next Actions.

### Step 2: Create/update decision notes

If a clear decision was made during the session, create `30-Decisions/YYYY-MM-{slug}.md` using the decision template. Link it from the project card.

### Step 3: Update project cards

If project state changed, update the relevant `20-Projects/{project}.md`: Current State, Next Actions, Active Threads.

### Step 4: File memory candidates

If something new was learned about the user, a person, or a pattern — write to `60-Learning/inbox/YYYY-MM-DD-{slug}.md` with `status: draft`. These get reviewed in the digest pass.

### Step 5: Commit and push

```bash
cd ~/m3ta-brain
git add -A
git commit -m "session: {brief description}

- {what was written/updated}
- {key files}"
git push origin main
```

---

## Workflow 3: Decision Note

**When:** A clear architectural, strategic, or process decision is made.

File: `30-Decisions/YYYY-MM-{slug}.md`

Required frontmatter:

```yaml
---
type: decision
created: YYYY-MM-DD
updated: YYYY-MM-DD
decided: YYYY-MM-DD
decision_status: accepted  # accepted | proposed | superseded
impact: high  # high | medium | low
alternatives: []
tags: [decision]
---
```

Required sections: Context → Decision → Rationale → Consequences → Revisit When → Related.

Update `30-Decisions/INDEX.md` with a new row.

---

## Workflow 4: Person Profile

**When:** The user mentions a colleague, client, or contact with enough detail to warrant a profile.

### Rules

- **sensitivity: confidential** for all person profiles
- **status: draft** until the user confirms the content is accurate
- Only write confirmed facts — mark speculation as `(unsicher)`
- Do NOT create profiles for people mentioned in passing
- Do NOT write sensitive personal details without explicit consent
- Prefer the `60-Learning/inbox/` candidate workflow for new observations about existing people

### File location

```
40-People/colleagues/{firstname-lastname}.md  — work colleagues
40-People/external/{firstname-lastname}.md    — external contacts
40-People/family.md                           — family (already exists)
```

### When to add to an existing profile vs. write a new one

- New person → new file
- New observation about existing person → append to their profile under "Interaction History"
- Pattern observed across multiple people → `60-Learning/patterns/` note instead

---

## Workflow 5: Nightly Dream Pass

**When:** Runs automatically every night at 3:00 AM as a cronjob. Can also be triggered manually.

**Cronjob ID:** `0b52e6f0eac8` (scheduled, delivers to Matrix)

**Autonomy level:** Full autonomous — may promote patterns, create decisions, update projects, mark stale, fix links, sync memory. Only reports the digest.

### Purpose

The vault accumulates drafts, candidates, and potentially stale information. The dream pass:
1. Harvests learnings from recent sessions (session_search → vault)
2. Consolidates inbox candidates
3. Synthesizes new patterns from accumulated observations
4. Flags stale projects
5. Fixes broken links
6. Syncs stable facts to Hermes internal memory
7. Reports a summary to the user

### Step 1: Pull

```bash
cd ~/m3ta-brain && git pull --rebase
```

### Step 2: Session Harvest (last 24h)

Use `session_search()` (browse mode) to list recent sessions. For each relevant session:
- If important work was done and no session summary exists yet → write one to `60-Learning/sessions/`
- If a decision was made without an ADR → create `30-Decisions/`
- If project state changed without a project update → update `20-Projects/`

### Step 3: Process Inbox

Read all files in `60-Learning/inbox/`. For each:

- **Promote**: if the candidate is confirmed and stable → move to `60-Learning/patterns/` or update the relevant `10-Preferences/` note. Remove from inbox.
- **Keep**: if still uncertain → leave in inbox with a `reviewed: YYYY-MM-DD` frontmatter field.
- **Discard**: if proven wrong or stale → move to `90-Archive/`.

### Step 4: Pattern Synthesis

Read the last 5-10 session summaries and existing patterns. Look for recurring themes:
- Same correction multiple times → `60-Learning/corrections/` note
- Same preference confirmed → update `10-Preferences/` or create new pattern
- Recurring project topic → update project card
- New stable insight about working style → create pattern note

### Step 5: Check Project Freshness

For each `20-Projects/*.md`, check the `updated` frontmatter field:

- **> 30 days without update** → flag as "stale" in the digest report
- **Next Actions all checked** → suggest archiving (but do not archive without user confirmation)

### Step 6: Link Health Check

Run the link audit script (see `references/vault-map.md`). If broken links found: fix them (standard markdown relative links).

### Step 7: Update INDEX.md

Refresh stats, recent decisions, recent sessions.

### Step 8: Memory Sync

If new stable facts were discovered that belong in Hermes internal memory (short, critical hot facts): update internal memory. Only for things that must be present at every session start. The vault is the detailed source, internal memory is the cache.

### Step 9: Commit and Push

```bash
cd ~/m3ta-brain
git add -A
git commit -m "dream: $(date +%Y-%m-%d) nightly pass

- {N} sessions harvested
- {N} inbox items processed ({promoted} promoted, {kept} kept, {discarded} discarded)
- {N} patterns created/updated
- {N} decisions created
- {N} stale projects flagged
- {N} broken links fixed"
git push origin main
```

Only push if something changed (skip on empty diff).

### Step 10: Report to User

Send a concise digest:

```
🌙 m3ta-brain Dream Pass — {date}

Sessions: {N} harvested, {N} summaries written
Inbox: {N} processed ({promoted} promoted, {kept} kept, {discarded} discarded)
Patterns: {N} created/updated
Decisions: {N} new
Stale Projects: {list or "none"}
Broken Links: {N} fixed
Memory: {N} facts synced
```

---

## Link Conventions

**CRITICAL:** Use standard Markdown links with file-relative paths. NOT `[[wikilinks]]`.

```markdown
<!-- Same directory -->
[Project Name](project-name.md)

<!-- Cross-directory (from 30-Decisions/ to 20-Projects/) -->
[AZ-Gruppe](../20-Projects/az-gruppe.md)

<!-- Cross-directory (from 60-Learning/patterns/ to 20-Projects/) -->
[Hermes](../../20-Projects/m3-hermes.md)
```

Rules:
- File-relative paths only (`../dir/file.md`)
- Always include `.md` extension
- URL-encode spaces in filenames as `%20` (avoid spaces in filenames instead)
- Minimum 2 internal links per note
- Every note should be linked FROM at least one other note (no orphans)
- Templates may contain `[[]]` placeholders — these are Obsidian template syntax, leave as-is

---

## Git Conventions

### Commit messages

```
session: {brief description}      — after a work session
decision: {slug}                   — new decision note
update: {project} status           — project card update
digest: {date} pass                — nightly/weekly digest
fix: {what was fixed}              — corrections
add: {what was added}              — new note or section
```

### When to push

- After writing session summaries or decision notes
- After updating project cards
- After digest passes
- NOT after every single small edit — batch related changes

### Conflict handling

If `git pull --rebase` fails:

```bash
# Check what conflicted
git status
# Resolve manually, then:
git add -A && git rebase --continue
```

Do NOT force-push. The vault is shared — last-writer-wins via normal Git.

---

## What NOT to Do

- **Do NOT** write secrets, passwords, API keys, or tokens to the vault
- **Do NOT** write intimate/private details without explicit consent
- **Do NOT** create profiles for people mentioned only in passing
- **Do NOT** dump full chat transcripts — use summaries
- **Do NOT** use `[[wikilinks]]` — they don't render in Gitea
- **Do NOT** assume facts — mark speculation as `(unsicher)` or `status: draft`
- **Do NOT** duplicate content from the Tech Wiki or Nemoti Wiki — link to them instead
- **Do NOT** modify `80-Templates/` during a session — they are structural
- **Do NOT** force-push (`git push --force`) — the vault is shared

---

## Relationship to Other Systems

| System | Role | When to use |
|---|---|---|
| m3ta-brain (this vault) | Shared working memory, project context, decisions, learnings | Session start, session end, decisions |
| Hermes internal memory | Hot cache of critical facts for fast recall | Automatic, small entries only |
| Tech Wiki (`/var/lib/hermes/wiki`) | Research, concepts, entities (English) | Deep research, new technology |
| Nemoti Wiki (`/var/lib/hermes/wiki-nemoti`) | Lore, characters, art strategy (German) | Nemoti creative work |
| Session Search | Raw session transcripts | "What did we do about X?" |
| qmd | Hybrid search across vaults (if installed) | Cross-vault semantic queries |
| Agent Hub | Cross-agent task coordination | Beads task queue |

Rule: **m3ta-brain is the working context layer.** Research goes to Tech Wiki. Lore goes to Nemoti Wiki. Raw session history stays in session search. m3ta-brain holds the glue: decisions, project state, preferences, learnings, people.

---

## Multi-Agent Compatibility

This vault is designed for ANY agent (Hermes, Pi, OpenCode, Claude Code, Codex). Rules:

- No agent-specific assumptions in note content
- Agent identity stays in commit messages, not in note bodies
- Multiple agents may read/write — last-writer-wins via Git
- The vault is the single source of truth — agent-internal memory is a cache
- If another agent made changes, `git pull` before writing

---

## Pitfalls

- **Forgetting to pull**: Always `git pull --rebase` before reading or writing. The vault may have been updated by another agent or by Sascha from another device.
- **Using wikilinks**: `[[wikilinks]]` do NOT render as links in Gitea. Always use `[Text](relative/path.md)`.
- **Wrong relative paths**: Links must be relative FROM the source file, not from vault root. From `30-Decisions/X.md` to `20-Projects/Y.md` → `../20-Projects/Y.md`.
- **Overwriting drafts**: `00-Telos/`, `10-Preferences/`, `40-People/` are `status: draft`. Do not overwrite without explicit user confirmation.
- **INDEX.md drift**: When adding notes, update `INDEX.md` in the same commit. Stale indexes defeat the purpose.
- **Orphan notes**: Every note must be linked FROM at least one other note. Unlinked notes are invisible in the graph.
- **External wiki duplication**: Do not copy Tech Wiki or Nemoti Wiki content into m3ta-brain. Summarize and link: `[Tech Wiki: Nix CLI](/var/lib/hermes/wiki/concepts/nix-cli-migration.md)`.
