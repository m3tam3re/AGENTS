# Memory System for AGENTS + Obsidian CODEX

## TL;DR

> **Quick Summary**: Build a dual-layer memory system equivalent to openclaw's — Mem0 for fast semantic search/auto-recall + Obsidian CODEX vault for human-readable, versioned knowledge. Memories are stored in both layers and cross-referenced via IDs.
>
> **Deliverables**:
> - New `skills/memory/SKILL.md` — Core orchestration skill (auto-capture, auto-recall, dual-layer sync)
> - New `80-memory/` folder in CODEX vault with category subfolders + memory template
> - Obsidian MCP server configuration (cyanheads/obsidian-mcp-server)
> - Updated skills (mem0-memory, obsidian), Apollo prompt, CODEX docs, user profile
>
> **Estimated Effort**: Medium (9 tasks across config/docs, no traditional code)
> **Parallel Execution**: YES — 4 waves
> **Critical Path**: Task 1 (vault infra) → Task 4 (memory skill) → Task 9 (validation)

---

## Context

### Original Request
Adapt openclaw's memory system for the opencode AGENTS repo, integrated with the Obsidian CODEX vault at `~/CODEX`. The vault should serve as a "second brain" for both the user AND AI agents.

### Interview Summary
**Key Discussions**:
- Analyzed openclaw's 3-layer memory architecture (SQLite+vectors builtin, memory-core plugin, memory-lancedb plugin with auto-capture/auto-recall)
- User confirmed Mem0 is available self-hosted at localhost:8000 — just needs spinning up
- User chose `80-memory/` as dedicated vault folder with category subfolders
- User chose auto+explicit capture (LLM extraction at session end + "remember this" commands)
- User chose agent QA only (no unit test infrastructure — repo is config/docs only)
- No Obsidian MCP server currently configured — plan to add cyanheads/obsidian-mcp-server

**Research Findings**:
- cyanheads/obsidian-mcp-server (363 stars) — Best MCP server: frontmatter management, vault cache, search with pagination, tag management
- GitHub Copilot's memory system: citation-based verification pattern (Phase 2 candidate)
- Production recommendation: dual-layer (operational memory + documented knowledge)
- Mem0 provides semantic search, user_id/agent_id/run_id scoping, metadata support, `/health` endpoint
- Auto-capture best practice: max 3 per session, LLM extraction > regex patterns

### Metis Review
**Identified Gaps** (addressed):
- 80-memory/ subfolders vs flat pattern: Resolved — follows `30-resources/` pattern (subfolders by TYPE), not `50-zettelkasten/` flat pattern
- Mem0 health check: Added prerequisite validation step
- Error handling undefined: Defined — Mem0 unavailable → skip, Obsidian unavailable → Mem0 only
- Deployment order: Defined — CODEX first → MCP config → skills → validation
- Scope creep risk: Locked down — citation verification, memory deletion/lifecycle, dashboards all Phase 2
- Agent role clarity: Defined — memory skill loadable by any agent, Apollo is primary memory specialist

---

## Work Objectives

### Core Objective
Build a dual-layer memory system for opencode agents that stores memories in Mem0 (semantic search, operational) AND the Obsidian CODEX vault (human-readable, versioned, wiki-linked). Equivalent in capability to openclaw's memory system.

### Concrete Deliverables
**AGENTS repo** (`~/p/AI/AGENTS`):
- `skills/memory/SKILL.md` — NEW: Core memory skill
- `skills/memory/references/mcp-config.md` — NEW: Obsidian MCP server config documentation
- `skills/mem0-memory/SKILL.md` — UPDATED: Add categories, dual-layer sync
- `skills/obsidian/SKILL.md` — UPDATED: Add 80-memory/ conventions
- `prompts/apollo.txt` — UPDATED: Add memory management responsibilities
- `context/profile.md` — UPDATED: Add memory system configuration

**CODEX vault** (`~/CODEX`):
- `80-memory/` — NEW: Folder with subfolders (preferences/, facts/, decisions/, entities/, other/)
- `templates/memory.md` — NEW: Memory note template
- `tag-taxonomy.md` — UPDATED: Add #memory/* tags
- `AGENTS.md` — UPDATED: Add 80-memory/ docs, folder decision tree, memory workflows
- `README.md` — UPDATED: Add 80-memory/ to folder structure

**Infrastructure** (Nix home-manager — outside AGENTS repo):
- Add cyanheads/obsidian-mcp-server to opencode.json MCP section

### Definition of Done
- [x] All 11 files created/updated as specified
- [x] `curl http://localhost:8000/health` returns 200 (Mem0 running)
- [~] `curl http://127.0.0.1:27124/vault-info` returns vault info (Obsidian REST API) — *Requires Obsidian desktop app to be open*
- [x] `./scripts/test-skill.sh --validate` passes for new/updated skills
- [x] 80-memory/ folder exists in CODEX vault with 5 subfolders
- [x] Memory template creates valid notes with correct frontmatter

### Must Have
- Dual-layer storage: every memory in Mem0 AND Obsidian
- Auto-capture at session end (LLM-based, max 3 per session)
- Explicit "remember this" command support
- Auto-recall: inject relevant memories before agent starts
- 5 categories: preference, fact, decision, entity, other
- Health checks before memory operations
- Cross-reference: mem0_id in Obsidian frontmatter, obsidian_ref in Mem0 metadata
- Error handling: graceful degradation when either layer unavailable

### Must NOT Have (Guardrails)
- NO citation-based memory verification (Phase 2)
- NO memory expiration/lifecycle management (Phase 2)
- NO memory deletion/forget functionality (Phase 2)
- NO memory search UI or Obsidian dashboards (Phase 2)
- NO conflict resolution UI between layers (manual edit only)
- NO unit tests (repo has no test infrastructure — agent QA only)
- NO subfolders in 50-zettelkasten/ or 70-tasks/ (respect flat structure)
- NO new memory categories beyond the 5 defined
- NO modifications to existing Obsidian templates (only ADD memory.md)
- NO changes to agents.json (no new agents or agent config changes)

---

## Verification Strategy

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> ALL tasks MUST be verifiable WITHOUT any human action.
> Every criterion is verifiable by running a command or checking file existence.

### Test Decision
- **Infrastructure exists**: NO (config-only repo)
- **Automated tests**: None (agent QA only)
- **Framework**: N/A

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

Verification tools by deliverable type:

| Type | Tool | How Agent Verifies |
|------|------|-------------------|
| Vault folders/files | Bash (ls, test -f) | Check existence, content |
| Skill YAML frontmatter | Bash (grep, python) | Parse and validate fields |
| Mem0 API | Bash (curl) | Send requests, parse JSON |
| Obsidian REST API | Bash (curl) | Read notes, check frontmatter |
| MCP server | Bash (npx) | Test server startup |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately — no dependencies):
├── Task 1: CODEX vault memory infrastructure (folders, template, tags)
└── Task 3: Obsidian MCP server config documentation

Wave 2 (After Wave 1 — depends on vault structure existing):
├── Task 2: CODEX vault documentation updates (AGENTS.md, README.md)
├── Task 4: Create core memory skill (skills/memory/SKILL.md)
├── Task 5: Update Mem0 memory skill
└── Task 6: Update Obsidian skill

Wave 3 (After Wave 2 — depends on skill content for prompt/profile):
├── Task 7: Update Apollo agent prompt
└── Task 8: Update user context profile

Wave 4 (After all — final validation):
└── Task 9: End-to-end validation

Critical Path: Task 1 → Task 4 → Task 9
Parallel Speedup: ~50% faster than sequential
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | 2, 4, 5, 6 | 3 |
| 2 | 1 | 9 | 4, 5, 6 |
| 3 | None | 4 | 1 |
| 4 | 1, 3 | 7, 8, 9 | 5, 6 |
| 5 | 1 | 9 | 4, 6 |
| 6 | 1 | 9 | 4, 5 |
| 7 | 4 | 9 | 8 |
| 8 | 4 | 9 | 7 |
| 9 | ALL | None | None (final) |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|------|-------|-------------------|
| 1 | 1, 3 | task(category="quick", load_skills=["obsidian"], run_in_background=false) |
| 2 | 2, 4, 5, 6 | dispatch parallel: task(category="unspecified-high") for Task 4; task(category="quick") for 2, 5, 6 |
| 3 | 7, 8 | task(category="quick", run_in_background=false) |
| 4 | 9 | task(category="unspecified-low", run_in_background=false) |

---

## TODOs

- [x] 1. CODEX Vault Memory Infrastructure

  **What to do**:
  - Create `80-memory/` folder with 5 subfolders: `preferences/`, `facts/`, `decisions/`, `entities/`, `other/`
  - Create each subfolder with a `.gitkeep` file so git tracks empty directories
  - Create `templates/memory.md` — memory note template with frontmatter:
    ```yaml
    ---
    type: memory
    category:        # preference | fact | decision | entity | other
    mem0_id:         # Mem0 memory ID (e.g., "mem_abc123")
    source: explicit # explicit | auto-capture
    importance:      # critical | high | medium | low
    created: <% tp.date.now("YYYY-MM-DD") %>
    updated: <% tp.date.now("YYYY-MM-DD") %>
    tags:
      - memory
    sync_targets: []
    ---
    
    # Memory Title
    
    ## Content
    <!-- The actual memory content -->
    
    ## Context
    <!-- When/where this was learned, conversation context -->
    
    ## Related
    <!-- Wiki links to related notes -->
    ```
  - Update `tag-taxonomy.md` — add `#memory` tag category with subtags:
    ```
    #memory
    ├── #memory/preference
    ├── #memory/fact
    ├── #memory/decision
    ├── #memory/entity
    └── #memory/other
    ```
    Include usage examples and definitions for each category

  **Must NOT do**:
  - Do NOT create subfolders inside 50-zettelkasten/ or 70-tasks/
  - Do NOT modify existing templates (only ADD memory.md)
  - Do NOT use Templater syntax that doesn't match existing templates

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Simple file creation, no complex logic
  - **Skills**: [`obsidian`]
    - `obsidian`: Vault conventions, frontmatter patterns, template structure

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 3)
  - **Blocks**: Tasks 2, 4, 5, 6
  - **Blocked By**: None

  **References**:
  
  **Pattern References**:
  - `/home/m3tam3re/CODEX/30-resources/` — Subfolder-by-type pattern to follow (bookmarks/, literature/, meetings/, people/, recipes/)
  - `/home/m3tam3re/CODEX/templates/task.md` — Template frontmatter pattern (type, status, created, updated, tags, sync_targets)
  - `/home/m3tam3re/CODEX/templates/bookmark.md` — Simpler template example

  **Documentation References**:
  - `/home/m3tam3re/CODEX/AGENTS.md:22-27` — Frontmatter conventions (required fields: type, created, updated)
  - `/home/m3tam3re/CODEX/AGENTS.md:163-176` — Template locations table (add memory row)
  - `/home/m3tam3re/CODEX/tag-taxonomy.md:1-18` — Tag structure rules (max 3 levels, kebab-case)

  **WHY Each Reference Matters**:
  - `30-resources/` shows that subfolders-by-type is the established vault pattern for categorized content
  - `task.md` template shows the exact frontmatter field set expected by the vault
  - `tag-taxonomy.md` rules show the 3-level max hierarchy constraint for new tags

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Verify 80-memory folder structure
    Tool: Bash
    Steps:
      1. test -d /home/m3tam3re/CODEX/80-memory/preferences
      2. test -d /home/m3tam3re/CODEX/80-memory/facts
      3. test -d /home/m3tam3re/CODEX/80-memory/decisions
      4. test -d /home/m3tam3re/CODEX/80-memory/entities
      5. test -d /home/m3tam3re/CODEX/80-memory/other
    Expected Result: All 5 directories exist (exit code 0 for each)
    Evidence: Shell output captured

  Scenario: Verify memory template exists with correct frontmatter
    Tool: Bash
    Steps:
      1. test -f /home/m3tam3re/CODEX/templates/memory.md
      2. grep "type: memory" /home/m3tam3re/CODEX/templates/memory.md
      3. grep "category:" /home/m3tam3re/CODEX/templates/memory.md
      4. grep "mem0_id:" /home/m3tam3re/CODEX/templates/memory.md
    Expected Result: File exists and contains required frontmatter fields
    Evidence: grep output captured

  Scenario: Verify tag-taxonomy updated with memory tags
    Tool: Bash
    Steps:
      1. grep "#memory" /home/m3tam3re/CODEX/tag-taxonomy.md
      2. grep "#memory/preference" /home/m3tam3re/CODEX/tag-taxonomy.md
      3. grep "#memory/fact" /home/m3tam3re/CODEX/tag-taxonomy.md
    Expected Result: All memory tags present in taxonomy
    Evidence: grep output captured
  ```

  **Commit**: YES
  - Message: `feat(vault): add 80-memory folder structure and memory template`
  - Files: `80-memory/`, `templates/memory.md`, `tag-taxonomy.md`
  - Repo: `~/CODEX`

---

- [x] 2. CODEX Vault Documentation Updates

  **What to do**:
  - Update `AGENTS.md`:
    - Add `80-memory/` row to Folder Structure table (line ~11)
    - Add `#### 80-memory` section in Folder Details (after 70-tasks section, ~line 161)
    - Update Folder Decision Tree to include memory branch: `Is it a memory/learned fact? → YES → 80-memory/`
    - Add Memory template row to Template Locations table (line ~165)
    - Add Memory Workflows section (after Sync Workflow): create memory, retrieve memory, dual-layer sync
  - Update `README.md`:
    - Add `80-memory/` to folder structure diagram with subfolders
    - Add `80-memory/` row to Folder Details section
    - Add memory template to Templates table

  **Must NOT do**:
  - Do NOT rewrite existing sections — only ADD new content
  - Do NOT remove any existing folder/template documentation

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Documentation additions to existing files, following established patterns
  - **Skills**: [`obsidian`]
    - `obsidian`: Vault documentation conventions

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 4, 5, 6)
  - **Blocks**: Task 9
  - **Blocked By**: Task 1 (needs folder structure to reference)

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/CODEX/AGENTS.md:110-161` — Existing Folder Details sections to follow pattern
  - `/home/m3tam3re/CODEX/AGENTS.md:75-108` — Folder Decision Tree format
  - `/home/m3tam3re/CODEX/README.md` — Folder structure diagram format

  **WHY Each Reference Matters**:
  - AGENTS.md folder details show the exact format: Purpose, Structure (flat/subfolders), Key trait, When to use, Naming convention
  - Decision tree shows the exact `├─ YES →` format to follow

  **Acceptance Criteria**:

  ```
  Scenario: Verify AGENTS.md has 80-memory documentation
    Tool: Bash
    Steps:
      1. grep "80-memory" /home/m3tam3re/CODEX/AGENTS.md
      2. grep "Is it a memory" /home/m3tam3re/CODEX/AGENTS.md
      3. grep "templates/memory.md" /home/m3tam3re/CODEX/AGENTS.md
    Expected Result: All three patterns found
    Evidence: grep output

  Scenario: Verify README.md has 80-memory in structure
    Tool: Bash
    Steps:
      1. grep "80-memory" /home/m3tam3re/CODEX/README.md
      2. grep "preferences/" /home/m3tam3re/CODEX/README.md
    Expected Result: Folder and subfolder documented
    Evidence: grep output
  ```

  **Commit**: YES
  - Message: `docs(vault): add 80-memory documentation to AGENTS.md and README.md`
  - Files: `AGENTS.md`, `README.md`
  - Repo: `~/CODEX`

---

- [x] 3. Obsidian MCP Server Configuration Documentation

  **What to do**:
  - Create `skills/memory/references/mcp-config.md` documenting:
    - cyanheads/obsidian-mcp-server configuration for opencode.json
    - Required environment variables: `OBSIDIAN_API_KEY`, `OBSIDIAN_BASE_URL`, `OBSIDIAN_VERIFY_SSL`, `OBSIDIAN_ENABLE_CACHE`
    - opencode.json MCP section snippet:
      ```json
      "Obsidian-Vault": {
        "command": ["npx", "obsidian-mcp-server"],
        "environment": {
          "OBSIDIAN_API_KEY": "<your-api-key>",
          "OBSIDIAN_BASE_URL": "http://127.0.0.1:27123",
          "OBSIDIAN_VERIFY_SSL": "false",
          "OBSIDIAN_ENABLE_CACHE": "true"
        },
        "enabled": true,
        "type": "local"
      }
      ```
    - Nix home-manager snippet showing how to add to `programs.opencode.settings.mcp`
    - Note that this requires `home-manager switch` after adding
    - Available MCP tools list: obsidian_read_note, obsidian_update_note, obsidian_global_search, obsidian_manage_frontmatter, obsidian_manage_tags, obsidian_list_notes, obsidian_delete_note, obsidian_search_replace
    - How to get the API key from Obsidian: Settings → Local REST API plugin

  **Must NOT do**:
  - Do NOT directly modify `~/.config/opencode/opencode.json` (Nix-managed)
  - Do NOT modify `agents/agents.json`

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Creating a single reference doc
  - **Skills**: [`obsidian`]
    - `obsidian`: Obsidian REST API configuration knowledge

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 1)
  - **Blocks**: Task 4
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/AGENTS/skills/mem0-memory/SKILL.md:156-166` — Existing API reference pattern
  - `/home/m3tam3re/.config/opencode/opencode.json:77-127` — Current MCP config format (Exa, Basecamp, etc.)

  **External References**:
  - GitHub: `https://github.com/cyanheads/obsidian-mcp-server` — Config docs, env vars, tool list
  - npm: `npx obsidian-mcp-server` — Installation method

  **WHY Each Reference Matters**:
  - opencode.json MCP section shows exact JSON format needed (command array, environment, enabled, type)
  - cyanheads repo shows required env vars and their defaults

  **Acceptance Criteria**:

  ```
  Scenario: Verify MCP config reference file exists
    Tool: Bash
    Steps:
      1. test -f /home/m3tam3re/p/AI/AGENTS/skills/memory/references/mcp-config.md
      2. grep "obsidian-mcp-server" /home/m3tam3re/p/AI/AGENTS/skills/memory/references/mcp-config.md
      3. grep "OBSIDIAN_API_KEY" /home/m3tam3re/p/AI/AGENTS/skills/memory/references/mcp-config.md
      4. grep "home-manager" /home/m3tam3re/p/AI/AGENTS/skills/memory/references/mcp-config.md
    Expected Result: File exists with MCP config, env vars, and Nix instructions
    Evidence: grep output
  ```

  **Commit**: YES (groups with Task 4)
  - Message: `feat(memory): add core memory skill and MCP config reference`
  - Files: `skills/memory/SKILL.md`, `skills/memory/references/mcp-config.md`
  - Repo: `~/p/AI/AGENTS`

---

- [x] 4. Create Core Memory Skill

  **What to do**:
  - Create `skills/memory/SKILL.md` — the central orchestration skill for the dual-layer memory system
  - YAML frontmatter:
    ```yaml
    ---
    name: memory
    description: "Dual-layer memory system (Mem0 + Obsidian CODEX). Use when: (1) storing information for future recall ('remember this'), (2) auto-capturing session insights, (3) recalling past decisions/preferences/facts, (4) injecting relevant context before tasks. Triggers: 'remember', 'recall', 'what do I know about', 'memory', session end."
    compatibility: opencode
    ---
    ```
  - Sections to include:
    1. **Overview** — Dual-layer architecture (Mem0 operational + Obsidian documented)
    2. **Prerequisites** — Mem0 running at localhost:8000, Obsidian MCP configured (reference mcp-config.md)
    3. **Memory Categories** — 5 categories with definitions and examples:
       - preference: Personal preferences (UI, workflow, communication style)
       - fact: Objective information about user/work (role, tech stack, constraints)
       - decision: Architectural/tool choices made (with rationale)
       - entity: People, organizations, systems, concepts
       - other: Everything else
    4. **Workflow 1: Store Memory (Explicit)** — User says "remember X":
       - Classify category
       - POST to Mem0 `/memories` with user_id, metadata (category, source: "explicit")
       - Create Obsidian note in `80-memory/<category>/` using memory template
       - Cross-reference: mem0_id in Obsidian frontmatter, obsidian_ref in Mem0 metadata
    5. **Workflow 2: Recall Memory** — User asks "what do I know about X":
       - POST to Mem0 `/search` with query
       - Return results with Obsidian note paths for reference
    6. **Workflow 3: Auto-Capture (Session End)** — Automatic extraction:
       - Scan conversation for memory-worthy content (preferences stated, decisions made, important facts)
       - Select top 3 highest-value memories
       - For each: store in Mem0 AND create Obsidian note (source: "auto-capture")
       - Present to user: "I captured these memories: [list]. Confirm or reject?"
    7. **Workflow 4: Auto-Recall (Session Start)** — Context injection:
       - On session start, search Mem0 with user's first message
       - If relevant memories found (score > 0.7), inject as `<relevant-memories>` context
       - Limit to top 5 most relevant
    8. **Error Handling** — Graceful degradation:
       - Mem0 unavailable: `curl http://localhost:8000/health` fails → skip all memory ops, warn user
       - Obsidian unavailable: Store in Mem0 only, log that Obsidian sync failed
       - Both unavailable: Skip memory entirely, continue without memory features
    9. **Integration** — How other skills/agents use memory:
       - Load `memory` skill to access memory workflows
       - Apollo is primary memory specialist
       - Any agent can search/store via Mem0 REST API patterns in `mem0-memory` skill

  **Must NOT do**:
  - Do NOT implement citation-based verification
  - Do NOT implement memory deletion/forget
  - Do NOT add memory expiration logic
  - Do NOT create dashboards or search UI

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Core deliverable requiring careful architecture documentation, must be comprehensive
  - **Skills**: [`obsidian`, `mem0-memory`]
    - `obsidian`: Vault conventions, template patterns, frontmatter standards
    - `mem0-memory`: Mem0 REST API patterns, endpoint details

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2, 5, 6)
  - **Blocks**: Tasks 7, 8, 9
  - **Blocked By**: Tasks 1, 3

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/AGENTS/skills/mem0-memory/SKILL.md` — Full file: Mem0 REST API patterns, endpoint table, identity scopes, workflow patterns
  - `/home/m3tam3re/p/AI/AGENTS/skills/obsidian/SKILL.md` — Full file: Obsidian REST API patterns, create/read/update note workflows, frontmatter conventions
  - `/home/m3tam3re/p/AI/AGENTS/skills/reflection/SKILL.md` — Skill structure pattern (overview, workflows, integration)

  **API References**:
  - `/home/m3tam3re/p/AI/AGENTS/skills/mem0-memory/SKILL.md:13-21` — Quick Reference endpoint table
  - `/home/m3tam3re/p/AI/AGENTS/skills/mem0-memory/SKILL.md:90-109` — Identity scopes (user_id, agent_id, run_id)

  **Documentation References**:
  - `/home/m3tam3re/CODEX/AGENTS.md:22-27` — Frontmatter conventions for vault notes
  - `/home/m3tam3re/p/AI/AGENTS/skills/memory/references/mcp-config.md` — MCP server config (created in Task 3)

  **External References**:
  - OpenClaw reference: `/home/m3tam3re/p/AI/openclaw/extensions/memory-lancedb/index.ts` — Auto-capture regex patterns, auto-recall injection, importance scoring (use as inspiration, not copy)

  **WHY Each Reference Matters**:
  - mem0-memory SKILL.md provides the exact API endpoints and patterns to reference in dual-layer sync workflows
  - obsidian SKILL.md provides the vault file creation patterns (curl commands, path encoding)
  - openclaw memory-lancedb shows the auto-capture/auto-recall architecture to adapt

  **Acceptance Criteria**:

  ```
  Scenario: Validate skill YAML frontmatter
    Tool: Bash
    Steps:
      1. test -f /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
      2. grep "^name: memory$" /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
      3. grep "^compatibility: opencode$" /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
      4. grep "description:" /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
    Expected Result: Valid YAML frontmatter with name, description, compatibility
    Evidence: grep output

  Scenario: Verify skill contains all required workflows
    Tool: Bash
    Steps:
      1. grep -c "## Workflow" /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
      2. grep "Auto-Capture" /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
      3. grep "Auto-Recall" /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
      4. grep "Error Handling" /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
      5. grep "preference" /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
    Expected Result: At least 4 workflow sections, auto-capture, auto-recall, error handling, categories
    Evidence: grep output

  Scenario: Verify dual-layer sync pattern documented
    Tool: Bash
    Steps:
      1. grep "mem0_id" /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
      2. grep "obsidian_ref" /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
      3. grep "localhost:8000" /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
      4. grep "80-memory" /home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md
    Expected Result: Cross-reference IDs and both layer endpoints documented
    Evidence: grep output
  ```

  **Commit**: YES (groups with Task 3)
  - Message: `feat(memory): add core memory skill and MCP config reference`
  - Files: `skills/memory/SKILL.md`, `skills/memory/references/mcp-config.md`
  - Repo: `~/p/AI/AGENTS`

---

- [x] 5. Update Mem0 Memory Skill

  **What to do**:
  - Add "Memory Categories" section after Identity Scopes (line ~109):
    - Table: category name, definition, Obsidian path, example
    - Metadata pattern for categories: `{"category": "preference", "source": "explicit|auto-capture"}`
  - Add "Dual-Layer Sync" section after Workflow Patterns:
    - After storing to Mem0, also create Obsidian note in `80-memory/<category>/`
    - Include mem0_id from response in Obsidian note frontmatter
    - Include obsidian_ref path in Mem0 metadata via update
  - Add "Health Check" workflow: Check `/health` before any memory operations
  - Add "Error Handling" section: What to do when Mem0 is unavailable

  **Must NOT do**:
  - Do NOT delete existing content
  - Do NOT change the YAML frontmatter description (triggers)
  - Do NOT change existing API endpoint documentation

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Adding sections to existing well-structured file
  - **Skills**: [`mem0-memory`]
    - `mem0-memory`: Existing skill patterns to extend

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2, 4, 6)
  - **Blocks**: Task 9
  - **Blocked By**: Task 1

  **References**:

  - `/home/m3tam3re/p/AI/AGENTS/skills/mem0-memory/SKILL.md` — Full file: current content to extend (preserve ALL existing content)

  **Acceptance Criteria**:

  ```
  Scenario: Verify categories added to mem0-memory skill
    Tool: Bash
    Steps:
      1. grep "Memory Categories" /home/m3tam3re/p/AI/AGENTS/skills/mem0-memory/SKILL.md
      2. grep "preference" /home/m3tam3re/p/AI/AGENTS/skills/mem0-memory/SKILL.md
      3. grep "Dual-Layer" /home/m3tam3re/p/AI/AGENTS/skills/mem0-memory/SKILL.md
      4. grep "80-memory" /home/m3tam3re/p/AI/AGENTS/skills/mem0-memory/SKILL.md
    Expected Result: New sections present alongside existing content
    Evidence: grep output
  ```

  **Commit**: YES
  - Message: `feat(mem0-memory): add memory categories and dual-layer sync patterns`
  - Files: `skills/mem0-memory/SKILL.md`
  - Repo: `~/p/AI/AGENTS`

---

- [x] 6. Update Obsidian Skill

  **What to do**:
  - Add "Memory Folder Conventions" section (after Best Practices, ~line 228):
    - Document `80-memory/` structure with 5 subfolders
    - Memory note naming: kebab-case (e.g., `prefers-dark-mode.md`)
    - Required frontmatter fields for memory notes (type, category, mem0_id, etc.)
  - Add "Memory Note Workflows" section:
    - Create memory note: POST to vault REST API with memory template content
    - Read memory note: GET with path encoding for `80-memory/` paths
    - Search memories: Search within `80-memory/` path filter
  - Update Integration table to include memory skill handoff

  **Must NOT do**:
  - Do NOT change existing content or workflows
  - Do NOT modify the YAML frontmatter

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: [`obsidian`]

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 9
  - **Blocked By**: Task 1

  **References**:
  - `/home/m3tam3re/p/AI/AGENTS/skills/obsidian/SKILL.md` — Full file: current content to extend

  **Acceptance Criteria**:

  ```
  Scenario: Verify memory conventions added to obsidian skill
    Tool: Bash
    Steps:
      1. grep "Memory Folder" /home/m3tam3re/p/AI/AGENTS/skills/obsidian/SKILL.md
      2. grep "80-memory" /home/m3tam3re/p/AI/AGENTS/skills/obsidian/SKILL.md
      3. grep "mem0_id" /home/m3tam3re/p/AI/AGENTS/skills/obsidian/SKILL.md
    Expected Result: Memory folder docs and frontmatter patterns present
    Evidence: grep output
  ```

  **Commit**: YES
  - Message: `feat(obsidian): add memory folder conventions and workflows`
  - Files: `skills/obsidian/SKILL.md`
  - Repo: `~/p/AI/AGENTS`

---

- [x] 7. Update Apollo Agent Prompt

  **What to do**:
  - Add "Memory Management" to Core Responsibilities list (after item 4):
    - Store memories in dual-layer system (Mem0 + Obsidian CODEX)
    - Retrieve memories via semantic search (Mem0)
    - Auto-capture session insights at session end (max 3, confirm with user)
    - Handle explicit "remember this" requests
    - Inject relevant memories into context on session start
  - Add memory-related tools to Tool Usage section
  - Add memory error handling to Edge Cases

  **Must NOT do**:
  - Do NOT remove existing responsibilities
  - Do NOT change Apollo's identity or boundaries

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Task 8)
  - **Blocks**: Task 9
  - **Blocked By**: Task 4

  **References**:
  - `/home/m3tam3re/p/AI/AGENTS/prompts/apollo.txt` — Full file (47 lines): current prompt to extend

  **Acceptance Criteria**:

  ```
  Scenario: Verify memory management added to Apollo prompt
    Tool: Bash
    Steps:
      1. grep -i "memory" /home/m3tam3re/p/AI/AGENTS/prompts/apollo.txt | wc -l
      2. grep "Mem0" /home/m3tam3re/p/AI/AGENTS/prompts/apollo.txt
      3. grep "auto-capture" /home/m3tam3re/p/AI/AGENTS/prompts/apollo.txt
    Expected Result: Multiple memory references, Mem0 mentioned, auto-capture documented
    Evidence: grep output
  ```

  **Commit**: YES (groups with Task 8)
  - Message: `feat(agents): add memory management to Apollo prompt and user profile`
  - Files: `prompts/apollo.txt`, `context/profile.md`
  - Repo: `~/p/AI/AGENTS`

---

- [x] 8. Update User Context Profile

  **What to do**:
  - Add "Memory System" section to `context/profile.md`:
    - Mem0 endpoint: `http://localhost:8000`
    - Mem0 user_id: `m3tam3re` (or whatever the user's ID should be)
    - Obsidian vault path: `~/CODEX`
    - Memory folder: `80-memory/`
    - Auto-capture: enabled, max 3 per session
    - Auto-recall: enabled, top 5 results, score threshold 0.7
    - Memory categories: preference, fact, decision, entity, other
    - Obsidian MCP server: cyanheads/obsidian-mcp-server (see skills/memory/references/mcp-config.md)

  **Must NOT do**:
  - Do NOT remove existing profile content

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Task 7)
  - **Blocks**: Task 9
  - **Blocked By**: Task 4

  **References**:
  - `/home/m3tam3re/p/AI/AGENTS/context/profile.md` — Current profile to extend

  **Acceptance Criteria**:

  ```
  Scenario: Verify memory config in profile
    Tool: Bash
    Steps:
      1. grep "Memory System" /home/m3tam3re/p/AI/AGENTS/context/profile.md
      2. grep "localhost:8000" /home/m3tam3re/p/AI/AGENTS/context/profile.md
      3. grep "80-memory" /home/m3tam3re/p/AI/AGENTS/context/profile.md
      4. grep "auto-capture" /home/m3tam3re/p/AI/AGENTS/context/profile.md
    Expected Result: Memory system section with all config values
    Evidence: grep output
  ```

  **Commit**: YES (groups with Task 7)
  - Message: `feat(agents): add memory management to Apollo prompt and user profile`
  - Files: `prompts/apollo.txt`, `context/profile.md`
  - Repo: `~/p/AI/AGENTS`

---

- [x] 9. End-to-End Validation

  **What to do**:
  - Verify ALL files exist and contain expected content
  - Run skill validation: `./scripts/test-skill.sh memory`
  - Test Mem0 availability: `curl http://localhost:8000/health`
  - Test Obsidian REST API: `curl http://127.0.0.1:27124/vault-info`
  - Verify CODEX vault structure: `ls -la ~/CODEX/80-memory/`
  - Verify template: `cat ~/CODEX/templates/memory.md | head -20`
  - Check all YAML frontmatter valid across new/updated skill files

  **Must NOT do**:
  - Do NOT create automated test infrastructure
  - Do NOT modify any files — validation only

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
    - Reason: Verification only, running commands and checking outputs
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 4 (final, sequential)
  - **Blocks**: None (final task)
  - **Blocked By**: ALL tasks (1-8)

  **Acceptance Criteria**:

  ```
  Scenario: Full file existence check
    Tool: Bash
    Steps:
      1. test -f ~/p/AI/AGENTS/skills/memory/SKILL.md
      2. test -f ~/p/AI/AGENTS/skills/memory/references/mcp-config.md
      3. test -d ~/CODEX/80-memory/preferences
      4. test -f ~/CODEX/templates/memory.md
      5. grep "80-memory" ~/CODEX/AGENTS.md
      6. grep "#memory" ~/CODEX/tag-taxonomy.md
      7. grep "80-memory" ~/CODEX/README.md
      8. grep -i "memory" ~/p/AI/AGENTS/prompts/apollo.txt
      9. grep "Memory System" ~/p/AI/AGENTS/context/profile.md
    Expected Result: All checks pass (exit code 0)
    Evidence: Shell output captured

  Scenario: Mem0 health check
    Tool: Bash
    Preconditions: Mem0 server must be running
    Steps:
      1. curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health
    Expected Result: HTTP 200
    Evidence: Status code captured
    Note: If Mem0 not running, this test will fail — spin up Mem0 first

  Scenario: Obsidian REST API check
    Tool: Bash
    Preconditions: Obsidian desktop app must be running with Local REST API plugin
    Steps:
      1. curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:27124/vault-info
    Expected Result: HTTP 200
    Evidence: Status code captured
    Note: Requires Obsidian desktop app to be open

  Scenario: Skill validation
    Tool: Bash
    Steps:
      1. cd ~/p/AI/AGENTS && ./scripts/test-skill.sh memory
    Expected Result: Validation passes (no errors)
    Evidence: Script output captured
  ```

  **Commit**: NO (validation only, no file changes)

---

## Commit Strategy

| After Task | Message | Files | Repo | Verification |
|------------|---------|-------|------|--------------|
| 1 | `feat(vault): add 80-memory folder structure and memory template` | 80-memory/, templates/memory.md, tag-taxonomy.md | ~/CODEX | ls + grep |
| 2 | `docs(vault): add 80-memory documentation to AGENTS.md and README.md` | AGENTS.md, README.md | ~/CODEX | grep |
| 3+4 | `feat(memory): add core memory skill and MCP config reference` | skills/memory/SKILL.md, skills/memory/references/mcp-config.md | ~/p/AI/AGENTS | test-skill.sh |
| 5 | `feat(mem0-memory): add memory categories and dual-layer sync patterns` | skills/mem0-memory/SKILL.md | ~/p/AI/AGENTS | grep |
| 6 | `feat(obsidian): add memory folder conventions and workflows` | skills/obsidian/SKILL.md | ~/p/AI/AGENTS | grep |
| 7+8 | `feat(agents): add memory management to Apollo prompt and user profile` | prompts/apollo.txt, context/profile.md | ~/p/AI/AGENTS | grep |

**Note**: Two different git repos! CODEX and AGENTS commits are independent.

---

## Success Criteria

### Verification Commands
```bash
# CODEX vault structure
ls ~/CODEX/80-memory/                     # Expected: preferences/ facts/ decisions/ entities/ other/
cat ~/CODEX/templates/memory.md | head -5 # Expected: ---\ntype: memory
grep "#memory" ~/CODEX/tag-taxonomy.md    # Expected: #memory/* tags

# AGENTS skill validation
cd ~/p/AI/AGENTS && ./scripts/test-skill.sh memory  # Expected: pass

# Infrastructure (requires services running)
curl -s http://localhost:8000/health           # Expected: 200
curl -s http://127.0.0.1:27124/vault-info     # Expected: 200
```

### Final Checklist
- [x] All "Must Have" present (dual-layer, auto-capture, auto-recall, categories, health checks, error handling)
- [x] All "Must NOT Have" absent (no citation system, no deletion, no dashboards, no unit tests)
- [x] CODEX commits pushed (vault structure + docs)
- [x] AGENTS commits pushed (skills + prompts + profile)
- [x] User reminded to add Obsidian MCP to Nix config and run `home-manager switch`
- [x] User reminded to spin up Mem0 server before using memory features
