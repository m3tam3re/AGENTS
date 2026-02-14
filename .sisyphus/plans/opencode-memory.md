# Opencode Memory Plugin — Hybrid Memory System

## TL;DR

> **Quick Summary**: Build `opencode-memory`, a standalone Opencode plugin that replaces mem0+qdrant with a unified SQLite-based hybrid memory system. Indexes markdown files from the user's Obsidian vault (`~/CODEX/80-memory/`) and Opencode session transcripts into a SQLite database with FTS5 (BM25 keyword search) and vec0 (vector cosine similarity). Provides auto-recall on session start, auto-capture on session idle, and three agent tools (memory_search, memory_store, memory_get). Architecture inspired by Openclaw's battle-tested 1590-line MemoryIndexManager.
>
> **Deliverables**:
> - Standalone TypeScript git repo: `opencode-memory/`
> - Opencode plugin with session.created, session.idle, session.compacting hooks
> - Three custom tools: memory_search (hybrid query), memory_store (save markdown + index), memory_get (read specific file/lines)
> - SQLite database with FTS5 + vec0 extensions for hybrid search
> - OpenAI text-embedding-3 integration with content-hash caching
> - Session transcript indexer reading Opencode's JSON storage format
> - Full TDD test suite (bun test)
> - Updated AGENTS repo skills (memory, mem0-memory deprecation notes)
>
> **Estimated Effort**: Large
> **Parallel Execution**: YES — 5 waves
> **Critical Path**: Task 1 → 2 → 4 → 6 → 8 → 10 → 12

---

## Context

### Original Request
"I want to implement a memory system for my Opencode Agent. A project named Openclaw has a very nice memory system and I would like to make something similar." User has mem0+qdrant running with Obsidian vault integration. Wants persistent, reliable memory with hybrid search. Open to replacing the existing architecture if something better exists.

### Interview Summary
**Key Discussions**:
- **Architecture**: User chose full SQLite replacement (drop mem0) — the most reliable approach. Single source of truth (markdown), derived index (SQLite).
- **Embedding Provider**: OpenAI text-embedding-3 (user's explicit choice over Gemini and local).
- **Plugin Location**: Separate git repo (not in AGENTS repo). Own npm package/Nix input.
- **Test Strategy**: TDD with bun test. New repo needs full test infrastructure setup.
- **Session Indexing**: Yes, full transcripts. Read from `~/.local/share/opencode/storage/`.
- **Deployment**: Global via Nix home-manager. Plugin registered in `opencode.json`.

**Research Findings**:
- **Openclaw architecture**: SQLite + FTS5 + vec0. MemoryIndexManager (1590 lines) handles file watching, chunking (tiktoken, 400 tokens/80 overlap), embedding (multi-provider), hybrid scoring (0.7 vector + 0.3 BM25). Two sources (memory files + session transcripts). Two tools (search + get).
- **Opencode plugin API**: JS/TS modules with event hooks. Key events: session.created, session.idle, session.compacted, experimental.session.compacting. Plugin context: { project, client, $, directory, worktree }. Custom tools via tool() helper with Zod schemas.
- **Opencode session storage**: JSON at `~/.local/share/opencode/storage/`. Sessions in `session/{project_hash}/ses_*.json`. Messages in `message/{session_id}/msg_*.json`. Fields: id, sessionID, role, agent, model, timestamps.
- **User's opencode config**: 3 existing plugins (oh-my-opencode, opencode-beads, opencode-antigravity-auth@beta). 6 agents. Google/Antigravity provider. Nix deployment.

### Metis Review
**Identified Gaps** (all addressed):
- **vec0 availability**: Added verification step in Task 1. Fallback strategy if unavailable.
- **SQLite concurrency**: WAL mode + single write queue. Addressed in Task 2.
- **Embedding failure handling**: try/catch + queue + retry + graceful degradation. Addressed in Task 4 and Task 12.
- **Token budget for injection**: Hard limit 2000 tokens. Configurable. Addressed in Task 10.
- **Index rebuild**: `--rebuild` command via CLI entry point. Addressed in Task 12.
- **File sync conflicts**: Atomic writes (temp file + rename). Addressed in Task 5.
- **Deduplication/expiration**: Deferred to Phase 2. Scope locked.
- **Multi-project scope**: Global search by default. Configurable later. Phase 2.

---

## Work Objectives

### Core Objective
Build a standalone Opencode plugin that provides persistent, reliable, hybrid (vector + keyword) memory for all agent sessions, powered by SQLite+FTS5+vec0 over Obsidian markdown files.

### Concrete Deliverables
- `opencode-memory/` — Standalone TypeScript repo with bun
- `src/index.ts` — Opencode plugin entry point (hooks + tools)
- `src/config.ts` — Configuration module (paths, defaults, overrides)
- `src/db.ts` — SQLite database initialization + schema + migrations
- `src/discovery.ts` — Markdown file discovery + text chunking
- `src/embeddings.ts` — OpenAI embedding provider + content-hash cache
- `src/indexer.ts` — File indexer (file → chunks → embeddings → SQLite)
- `src/search.ts` — Hybrid search engine (FTS5 BM25 + vec0 cosine)
- `src/sessions.ts` — Opencode session transcript parser + indexer
- `src/tools.ts` — Agent tools (memory_search, memory_store, memory_get)
- `src/types.ts` — Shared TypeScript types
- Full test suite in `src/__tests__/` (TDD, bun test)
- Updated AGENTS repo: `skills/memory/SKILL.md` + deprecation notes

### Definition of Done
- [x] `bun test` passes all tests (0 failures)
- [ ] Plugin loads in Opencode without errors (requires user deployment)
- [x] `memory_search` returns hybrid results from vault + session transcripts
- [x] `memory_store` creates markdown file + indexes it
- [x] `memory_get` reads specific file/line ranges
- [x] Auto-recall injects relevant memories on session.created
- [x] Auto-capture stores conversation insights on session.idle
- [x] Embedding cache avoids re-embedding unchanged content
- [x] SQLite can be rebuilt from markdown files alone (`--rebuild`)
- [x] Plugin fails gracefully (no crashes) when OpenAI is unavailable

### Must Have
- Hybrid search (vector 0.7 + BM25 0.3 weights, configurable)
- OpenAI text-embedding-3 with content-hash caching
- Markdown source of truth at `~/CODEX/80-memory/`
- SQLite derived index at `~/.local/share/opencode-memory/index.db`
- Session transcript indexing from Opencode storage
- Graceful degradation on API/DB failures
- WAL mode for SQLite concurrent reads
- Atomic markdown writes (temp file + rename)
- Configurable chunk size (default 400 tokens, 80 overlap)
- Token budget limit for memory injection (default 2000 tokens)

### Must NOT Have (Guardrails)
- **MUST NOT** block session operations if memory system fails — degraded mode > broken sessions
- **MUST NOT** exceed configurable token budget (default 2000) for memory context injection
- **MUST NOT** write files outside `~/CODEX/80-memory/` directory
- **MUST NOT** depend on Obsidian REST API — filesystem only
- **MUST NOT** depend on mem0 or qdrant — fully standalone
- **MUST NOT** implement memory deduplication (Phase 2)
- **MUST NOT** implement memory expiration/archival (Phase 2)
- **MUST NOT** implement memory graph/relationships (Phase 2)
- **MUST NOT** support multiple vaults (Phase 2)
- **MUST NOT** implement additional embedding providers beyond OpenAI (Phase 2)
- **MUST NOT** implement admin CLI/dashboard UI (Phase 2)
- **MUST NOT** auto-summarize memories (Phase 2)
- **MUST NOT** store embedding vectors in markdown files — SQLite only
- **MUST NOT** hard-code paths — use config with sensible defaults

---

## Verification Strategy (MANDATORY)

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> ALL tasks in this plan MUST be verifiable WITHOUT any human action.
> This is NOT conditional — it applies to EVERY task, regardless of test strategy.
>
> **FORBIDDEN** — acceptance criteria that require:
> - "User manually tests..." / "User visually confirms..."
> - "User interacts with..." / "Ask user to verify..."
> - ANY step where a human must perform an action
>
> **ALL verification is executed by the agent** using tools (Bash, interactive_bash, etc.). No exceptions.

### Test Decision
- **Infrastructure exists**: NO (new repo, needs setup)
- **Automated tests**: TDD (RED-GREEN-REFACTOR)
- **Framework**: bun test (built into bun runtime)

### TDD Workflow

Each TODO follows RED-GREEN-REFACTOR:

**Task Structure:**
1. **RED**: Write failing test first
   - Test file: `src/__tests__/{module}.test.ts`
   - Test command: `bun test src/__tests__/{module}.test.ts`
   - Expected: FAIL (test exists, implementation doesn't)
2. **GREEN**: Implement minimum code to pass
   - Command: `bun test src/__tests__/{module}.test.ts`
   - Expected: PASS
3. **REFACTOR**: Clean up while keeping green
   - Command: `bun test`
   - Expected: PASS (all tests still green)

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

> Whether TDD is enabled or not, EVERY task MUST include Agent-Executed QA Scenarios.
> With TDD: QA scenarios complement unit tests at integration/E2E level.

**Verification Tool by Deliverable Type:**

| Type | Tool | How Agent Verifies |
|------|------|-------------------|
| TypeScript modules | Bash (bun test) | Run unit tests, check pass/fail |
| SQLite operations | Bash (bun run) | Execute script, inspect DB with sqlite3 CLI |
| Plugin integration | interactive_bash (tmux) | Load plugin in opencode, verify hooks fire |
| File I/O | Bash | Create/read/delete files, verify filesystem state |
| API integration | Bash (bun run) | Call OpenAI, verify embedding dimensions |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately):
└── Task 1: Repo scaffold + test infrastructure + vec0 verification

Wave 2 (After Wave 1):
├── Task 2: Configuration module
├── Task 3: SQLite schema + database module
└── Task 4: Markdown file discovery + text chunking

Wave 3 (After Wave 2):
├── Task 5: Embedding provider + cache (depends: 3)
├── Task 6: File indexer pipeline (depends: 3, 4, 5)
└── Task 7: Session transcript parser (depends: 3, 4)

Wave 4 (After Wave 3):
├── Task 8: FTS5 BM25 search (depends: 6)
├── Task 9: Vector search (depends: 6)
└── Task 10: Hybrid search combiner (depends: 8, 9)

Wave 5 (After Wave 4):
├── Task 11: Agent tools — memory_search, memory_store, memory_get (depends: 10, 7)
└── Task 12: Plugin entry point — hooks + lifecycle (depends: 11)

Wave 6 (After Wave 5):
├── Task 13: Integration testing + error handling + rebuild command (depends: 12)
└── Task 14: AGENTS repo skill updates + deployment config (depends: 13)
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | 2, 3, 4 | None (foundation) |
| 2 | 1 | 5, 6, 7, 8, 9, 10, 11, 12 | 3, 4 |
| 3 | 1 | 5, 6, 7, 8, 9 | 2, 4 |
| 4 | 1 | 6, 7 | 2, 3 |
| 5 | 3 | 6 | 7 |
| 6 | 3, 4, 5 | 8, 9 | None |
| 7 | 3, 4 | 11 | 5 |
| 8 | 6 | 10 | 9 |
| 9 | 6 | 10 | 8 |
| 10 | 8, 9 | 11 | None |
| 11 | 10, 7 | 12 | None |
| 12 | 11 | 13 | None |
| 13 | 12 | 14 | None |
| 14 | 13 | None | None |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|------|-------|-------------------|
| 1 | 1 | task(category="unspecified-high", load_skills=[], run_in_background=false) |
| 2 | 2, 3, 4 | dispatch 3 parallel tasks after Wave 1 |
| 3 | 5, 6, 7 | sequential: 5 then 6 (depends on 5); 7 parallel with 5 |
| 4 | 8, 9, 10 | 8 and 9 parallel; 10 after both |
| 5 | 11, 12 | sequential |
| 6 | 13, 14 | sequential (14 is in AGENTS repo, different workdir) |

---

## TODOs

- [x] 1. Initialize Repository Scaffold + Test Infrastructure

  **What to do**:
  - Create new git repo `opencode-memory/` at `~/p/AI/opencode-memory/`
  - Initialize with `bun init`
  - Install dependencies: `better-sqlite3`, `openai`, `tiktoken`, `chokidar`, `zod`
  - Install dev dependencies: `@types/better-sqlite3`, `typescript`
  - Create `tsconfig.json` (target ES2022, module ESNext, strict mode, paths alias)
  - Create `src/` directory structure:
    ```
    src/
    ├── __tests__/
    ├── index.ts       (plugin entry — stub)
    ├── config.ts      (stub)
    ├── db.ts          (stub)
    ├── discovery.ts   (stub)
    ├── embeddings.ts  (stub)
    ├── indexer.ts     (stub)
    ├── search.ts      (stub)
    ├── sessions.ts    (stub)
    ├── tools.ts       (stub)
    └── types.ts       (stub)
    ```
  - Verify `bun test` runs (create example test)
  - **CRITICAL**: Verify SQLite vec0 extension availability:
    - Try: `import Database from 'better-sqlite3'; db.loadExtension('vec0')` or check if `sqlite-vec` npm package works
    - If vec0 unavailable: document findings, check `sqlite-vec` npm package as alternative, or plan for `@anthropic-ai/sdk` vector operations
    - This is a blocking verification — if vec0 doesn't work, architecture needs adjustment
  - Create `.gitignore` (node_modules, dist, *.db, .env)
  - Create `package.json` with `"type": "module"`, scripts for test/build

  **Must NOT do**:
  - Don't implement any real logic — stubs only
  - Don't configure Nix packaging yet (Task 14)
  - Don't create README or documentation files

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Repo scaffolding with critical platform verification (vec0). Not purely visual or algorithmic, but requires careful setup.
  - **Skills**: none needed
  - **Skills Evaluated but Omitted**:
    - `frontend-ui-ux`: No UI involved

  **Parallelization**:
  - **Can Run In Parallel**: NO (foundation task)
  - **Parallel Group**: Wave 1 (solo)
  - **Blocks**: Tasks 2, 3, 4
  - **Blocked By**: None

  **References**:

  **Pattern References** (existing code to follow):
  - `/home/m3tam3re/p/AI/openclaw/src/memory/manager.ts:1-50` — Imports and dependency list (shows what Openclaw uses: better-sqlite3, tiktoken, chokidar, etc.)
  - `/home/m3tam3re/p/AI/openclaw/src/memory/types.ts` — TypeScript type definitions for memory system

  **API/Type References**:
  - Opencode plugin structure: `export default function(ctx) { ... }` — see Opencode plugin docs

  **External References**:
  - SQLite vec0: `https://github.com/asg017/sqlite-vec` — vec0 extension for vector search in SQLite
  - better-sqlite3: `https://github.com/WiseLibs/better-sqlite3` — Synchronous SQLite3 for Node.js
  - Opencode plugin docs: `https://opencode.ai/docs/plugins/` — Plugin API and lifecycle

  **Acceptance Criteria**:

  **TDD (setup verification):**
  - [ ] `bun test` runs and passes at least 1 example test
  - [ ] `better-sqlite3` imports successfully
  - [ ] vec0 extension loads or alternative documented

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Repo initializes and tests pass
    Tool: Bash
    Preconditions: ~/p/AI/opencode-memory/ does not exist
    Steps:
      1. ls ~/p/AI/opencode-memory/ → should not exist
      2. After task: ls ~/p/AI/opencode-memory/src/ → should list all stub files
      3. bun test (in opencode-memory/) → 1 test passes, 0 failures
      4. bun run -e "import Database from 'better-sqlite3'; const db = new Database(':memory:'); console.log('SQLite OK:', db.pragma('journal_mode', { simple: true }))"
         → prints "SQLite OK: memory" (or "wal")
    Expected Result: Repo exists, tests pass, SQLite works
    Evidence: Terminal output captured

  Scenario: vec0 extension availability check
    Tool: Bash
    Preconditions: opencode-memory/ initialized with better-sqlite3
    Steps:
      1. bun run -e "import Database from 'better-sqlite3'; const db = new Database(':memory:'); try { db.loadExtension('vec0'); console.log('vec0: AVAILABLE') } catch(e) { console.log('vec0: NOT AVAILABLE -', e.message) }"
      2. If NOT AVAILABLE: try `bun add sqlite-vec` and test with that package's loading mechanism
      3. Document result in src/db.ts as comment
    Expected Result: vec0 status determined (available or alternative found)
    Evidence: Terminal output + documented in code comment
  ```

  **Commit**: YES
  - Message: `feat(scaffold): initialize opencode-memory repo with test infrastructure`
  - Files: all scaffold files
  - Pre-commit: `bun test`

---

- [x] 2. Configuration Module

  **What to do**:
  - **RED**: Write `src/__tests__/config.test.ts`:
    - Test: default config returns valid paths for vault, db, session storage
    - Test: config overrides work (custom vault path, custom db path)
    - Test: config validates paths (vault must be absolute)
    - Test: config has correct defaults for chunk size (400), overlap (80), weights (0.7/0.3), minScore (0.35), maxResults (6), tokenBudget (2000)
  - **GREEN**: Implement `src/config.ts`:
    - Define `MemoryConfig` interface with all configuration fields
    - Default vault path: `~/CODEX/80-memory/`
    - Default DB path: `~/.local/share/opencode-memory/index.db`
    - Default session path: `~/.local/share/opencode/storage/`
    - Chunking: `{ tokens: 400, overlap: 80 }`
    - Search: `{ vectorWeight: 0.7, textWeight: 0.3, minScore: 0.35, maxResults: 6 }`
    - Embedding: `{ model: "text-embedding-3-small", dimensions: 1536 }`
    - TokenBudget: `{ maxInjectTokens: 2000 }`
    - `resolveConfig(overrides?: Partial<MemoryConfig>): MemoryConfig` — merges overrides with defaults, expands `~` to `$HOME`
  - **REFACTOR**: Extract types to `src/types.ts`

  **Must NOT do**:
  - Don't read from config files on disk (hardcoded defaults + programmatic overrides)
  - Don't implement environment variable loading (keep simple)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Small, focused module. Config is straightforward.
  - **Skills**: none
  - **Skills Evaluated but Omitted**:
    - All: This is a simple data structure + defaults task

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 3, 4)
  - **Blocks**: Tasks 5, 6, 7, 8, 9, 10, 11, 12
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/openclaw/src/agents/memory-search.ts` — Openclaw's config resolution pattern (defaults + overrides)
  - `/home/m3tam3re/p/AI/openclaw/src/memory/backend-config.ts` — Backend configuration with defaults

  **API/Type References**:
  - `/home/m3tam3re/p/AI/openclaw/src/memory/types.ts` — Config type definitions to adapt

  **Acceptance Criteria**:

  **TDD:**
  - [ ] Test file: `src/__tests__/config.test.ts`
  - [ ] `bun test src/__tests__/config.test.ts` → PASS (all config tests green)
  - [ ] Default config has all required fields with correct values

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Default config returns correct values
    Tool: Bash (bun test)
    Preconditions: Task 1 complete, repo initialized
    Steps:
      1. bun test src/__tests__/config.test.ts
      2. Assert: all tests pass
      3. Assert: default vault path ends with "CODEX/80-memory"
      4. Assert: chunk tokens = 400, overlap = 80
      5. Assert: vector weight = 0.7, text weight = 0.3
    Expected Result: All config defaults correct
    Evidence: Test output captured
  ```

  **Commit**: YES (groups with 3, 4)
  - Message: `feat(config): add configuration module with sensible defaults`
  - Files: `src/config.ts`, `src/types.ts`, `src/__tests__/config.test.ts`
  - Pre-commit: `bun test`

---

- [x] 3. SQLite Schema + Database Module

  **What to do**:
  - **RED**: Write `src/__tests__/db.test.ts`:
    - Test: `initDatabase(":memory:")` creates all tables (meta, files, chunks, embedding_cache, chunks_fts, chunks_vec)
    - Test: `meta` table stores schema version
    - Test: `files` table accepts inserts with (path, source, hash, indexed_at)
    - Test: `chunks` table accepts inserts with (id, file_path, start_line, end_line, content_hash, model, text, embedding BLOB)
    - Test: `embedding_cache` table stores (content_hash, model, embedding BLOB, created_at)
    - Test: FTS5 virtual table `chunks_fts` is searchable
    - Test: vec0 virtual table `chunks_vec` is searchable (or skip if vec0 unavailable — see Task 1 findings)
    - Test: WAL mode is enabled
    - Test: `closeDatabase()` closes cleanly
  - **GREEN**: Implement `src/db.ts`:
    - `initDatabase(dbPath: string): Database` — creates/opens SQLite, runs schema, enables WAL
    - Schema (following Openclaw's `memory-schema.ts`):
      ```sql
      CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT);
      CREATE TABLE IF NOT EXISTS files (path TEXT PRIMARY KEY, source TEXT NOT NULL, hash TEXT NOT NULL, indexed_at INTEGER NOT NULL);
      CREATE TABLE IF NOT EXISTS chunks (id TEXT PRIMARY KEY, file_path TEXT NOT NULL REFERENCES files(path), start_line INTEGER, end_line INTEGER, content_hash TEXT NOT NULL, model TEXT NOT NULL, text TEXT NOT NULL, embedding BLOB);
      CREATE TABLE IF NOT EXISTS embedding_cache (content_hash TEXT NOT NULL, model TEXT NOT NULL, embedding BLOB NOT NULL, created_at INTEGER NOT NULL, PRIMARY KEY (content_hash, model));
      CREATE VIRTUAL TABLE IF NOT EXISTS chunks_fts USING fts5(text, content='chunks', content_rowid='rowid');
      CREATE VIRTUAL TABLE IF NOT EXISTS chunks_vec USING vec0(embedding float[1536]);
      ```
    - Store schema version in meta table
    - Enable WAL mode: `PRAGMA journal_mode=WAL`
    - Enable foreign keys: `PRAGMA foreign_keys=ON`
    - Load vec0 extension (or handle unavailability gracefully)
  - **REFACTOR**: Add helper functions for common DB operations

  **Must NOT do**:
  - Don't implement migration logic (v1 schema only)
  - Don't add indexes beyond what schema requires (premature optimization)
  - Don't implement any search logic (Task 8, 9)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: SQLite schema with extensions (FTS5, vec0) requires careful handling. Extension loading may need platform-specific workarounds.
  - **Skills**: none
  - **Skills Evaluated but Omitted**:
    - All: Pure database schema work, no domain-specific skill needed

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2, 4)
  - **Blocks**: Tasks 5, 6, 7, 8, 9
  - **Blocked By**: Task 1 (needs vec0 findings)

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/openclaw/src/memory/memory-schema.ts` — EXACT schema to follow (adapt table names/columns). This is the primary reference — copy the structure closely.
  - `/home/m3tam3re/p/AI/openclaw/src/memory/manager.ts:80-150` — Database initialization logic, WAL mode, extension loading

  **External References**:
  - better-sqlite3 API: `https://github.com/WiseLibs/better-sqlite3/blob/master/docs/api.md`
  - FTS5 docs: `https://www.sqlite.org/fts5.html`
  - vec0 docs: `https://alexgarcia.xyz/sqlite-vec/`

  **Acceptance Criteria**:

  **TDD:**
  - [ ] Test file: `src/__tests__/db.test.ts`
  - [ ] `bun test src/__tests__/db.test.ts` → PASS
  - [ ] All 8 schema tests pass
  - [ ] WAL mode enabled (verified via PRAGMA)

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Database creates all tables and extensions
    Tool: Bash (bun run)
    Preconditions: Task 1 complete
    Steps:
      1. bun test src/__tests__/db.test.ts
      2. Assert: all tests pass
      3. bun run -e "import { initDatabase } from './src/db'; const db = initDatabase(':memory:'); console.log(db.pragma('journal_mode', {simple:true})); console.log(JSON.stringify(db.prepare('SELECT name FROM sqlite_master WHERE type=\"table\"').all()))"
      4. Assert: journal_mode = "wal"
      5. Assert: tables include "meta", "files", "chunks", "embedding_cache"
    Expected Result: Schema created correctly with WAL mode
    Evidence: Terminal output captured

  Scenario: FTS5 virtual table is functional
    Tool: Bash (bun run)
    Preconditions: Database module implemented
    Steps:
      1. Create in-memory db, insert test chunk with text "TypeScript is my preferred language"
      2. Query: SELECT * FROM chunks_fts WHERE chunks_fts MATCH 'TypeScript'
      3. Assert: 1 result returned
    Expected Result: FTS5 search returns matching content
    Evidence: Terminal output captured
  ```

  **Commit**: YES (groups with 2, 4)
  - Message: `feat(db): SQLite schema with FTS5, vec0, WAL mode`
  - Files: `src/db.ts`, `src/__tests__/db.test.ts`
  - Pre-commit: `bun test`

---

- [x] 4. Markdown File Discovery + Text Chunking

  **What to do**:
  - **RED**: Write `src/__tests__/discovery.test.ts`:
    - Test: `discoverFiles(vaultPath)` finds all .md files recursively
    - Test: ignores non-.md files (images, PDFs, etc.)
    - Test: returns absolute paths with metadata (size, mtime)
    - Test: handles empty directory (returns [])
    - Test: handles non-existent directory (throws descriptive error)
    - Test: `computeFileHash(content)` returns consistent SHA-256 hex
    - Test: `chunkText(text, { tokens: 400, overlap: 80 })` splits correctly
    - Test: chunks have start_line and end_line metadata
    - Test: chunks overlap correctly (last 80 tokens of chunk N = first 80 tokens of chunk N+1)
    - Test: single small file (< 400 tokens) returns 1 chunk
    - Test: empty file returns 0 chunks
    - Test: chunk content_hash is stable for same content
  - **GREEN**: Implement `src/discovery.ts`:
    - `discoverFiles(vaultPath: string, extensions?: string[]): FileInfo[]` — recursive glob for .md files
    - `computeFileHash(content: string): string` — SHA-256 hex hash
    - `chunkText(text: string, config: ChunkConfig): Chunk[]` — split text by token count using tiktoken (cl100k_base encoding, matching Openclaw). Each chunk gets start_line/end_line and content_hash.
    - `readFileContent(filePath: string): string` — read file with UTF-8, handle encoding errors
  - **REFACTOR**: Optimize chunking for large files, ensure stable hashing

  **Must NOT do**:
  - Don't implement file watching (that's in indexer lifecycle, Task 6)
  - Don't parse YAML frontmatter (just treat as text for now)
  - Don't handle binary files (filter by extension)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
    - Reason: Straightforward file I/O and text processing. No complex algorithms.
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2, 3)
  - **Blocks**: Tasks 6, 7
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/openclaw/src/memory/internal.ts` — File discovery functions, chunking logic, hash computation. This is the PRIMARY reference for chunking algorithm.
  - `/home/m3tam3re/p/AI/openclaw/src/memory/manager.ts:200-350` — How files are discovered and processed

  **External References**:
  - tiktoken: `https://github.com/openai/tiktoken` — Token counting for chunking
  - Node.js crypto: Built-in `crypto.createHash('sha256')` for hashing

  **Acceptance Criteria**:

  **TDD:**
  - [ ] Test file: `src/__tests__/discovery.test.ts`
  - [ ] `bun test src/__tests__/discovery.test.ts` → PASS (all 12 tests)
  - [ ] Uses tiktoken cl100k_base encoding for token counting

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Discover files in test fixture directory
    Tool: Bash
    Preconditions: Create test fixture dir with 3 .md files and 1 .png
    Steps:
      1. mkdir -p /tmp/test-vault && echo "# Test" > /tmp/test-vault/note1.md && echo "# Test 2" > /tmp/test-vault/note2.md && echo "deep" > /tmp/test-vault/sub/note3.md && touch /tmp/test-vault/image.png
      2. bun run -e "import { discoverFiles } from './src/discovery'; console.log(JSON.stringify(discoverFiles('/tmp/test-vault')))"
      3. Assert: 3 files returned (all .md), image.png excluded
    Expected Result: Only .md files discovered
    Evidence: Terminal output

  Scenario: Chunk text with correct overlap
    Tool: Bash (bun test)
    Preconditions: Discovery module implemented
    Steps:
      1. bun test src/__tests__/discovery.test.ts --filter "overlap"
      2. Assert: overlap test passes
      3. Verify chunk N end overlaps with chunk N+1 start
    Expected Result: Chunks overlap by configured token count
    Evidence: Test output
  ```

  **Commit**: YES (groups with 2, 3)
  - Message: `feat(discovery): markdown file discovery and text chunking with tiktoken`
  - Files: `src/discovery.ts`, `src/__tests__/discovery.test.ts`
  - Pre-commit: `bun test`

---

- [x] 5. Embedding Provider + Content-Hash Cache

  **What to do**:
  - **RED**: Write `src/__tests__/embeddings.test.ts`:
    - Test: `EmbeddingProvider.embed(text)` returns float array of correct dimensions (1536 for text-embedding-3-small)
    - Test: `EmbeddingProvider.embedBatch(texts)` handles multiple texts
    - Test: Cache stores embedding by (content_hash, model) key
    - Test: Cache hit returns stored embedding without API call (mock API)
    - Test: Cache miss calls API, stores result, returns embedding
    - Test: API failure throws descriptive error (does NOT crash)
    - Test: API rate limit triggers retry with exponential backoff (mock)
    - Test: `embeddingToBuffer(float[])` converts to Buffer for SQLite BLOB storage
    - Test: `bufferToEmbedding(Buffer)` converts back to float[]
  - **GREEN**: Implement `src/embeddings.ts`:
    - `class EmbeddingProvider`:
      - Constructor takes `{ apiKey, model, dimensions, db }` — db for cache table
      - `async embed(text: string): Promise<number[]>` — check cache first, then API
      - `async embedBatch(texts: string[], hashes: string[]): Promise<number[][]>` — batch with cache check per item
      - Cache read: `SELECT embedding FROM embedding_cache WHERE content_hash = ? AND model = ?`
      - Cache write: `INSERT INTO embedding_cache (content_hash, model, embedding, created_at) VALUES (?, ?, ?, ?)`
      - API call: `openai.embeddings.create({ model, input, dimensions })`
      - Retry logic: exponential backoff (1s, 2s, 4s) on 429/500, max 3 retries
    - `embeddingToBuffer(embedding: number[]): Buffer` — Float32Array → Buffer
    - `bufferToEmbedding(buffer: Buffer): number[]` — Buffer → Float32Array → number[]
  - **REFACTOR**: Extract cache logic to separate internal function

  **Must NOT do**:
  - Don't support other embedding providers (Phase 2)
  - Don't implement local/offline fallback (Phase 2)
  - Don't implement cost tracking

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: API integration with retry logic, binary serialization, caching. Moderate complexity.
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: YES (parallel with Task 7)
  - **Parallel Group**: Wave 3 (first in wave — 6 depends on this)
  - **Blocks**: Task 6
  - **Blocked By**: Task 3 (needs db for cache table)

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/openclaw/src/memory/embeddings.ts` — Multi-provider embedding system. Focus on the OpenAI provider implementation and the cache logic. Copy the binary serialization (Float32Array ↔ Buffer).
  - `/home/m3tam3re/p/AI/openclaw/src/memory/manager.ts:400-500` — How embeddings are called and cached during indexing

  **External References**:
  - OpenAI Embeddings API: `https://platform.openai.com/docs/api-reference/embeddings`
  - OpenAI npm: `https://github.com/openai/openai-node`

  **WHY Each Reference Matters**:
  - `embeddings.ts`: Exact binary serialization pattern (Float32Array ↔ Buffer) is critical for SQLite BLOB storage. Also shows retry logic.
  - `manager.ts:400-500`: Shows how cache is checked before API call, and how batch embedding works.

  **Acceptance Criteria**:

  **TDD:**
  - [ ] Test file: `src/__tests__/embeddings.test.ts`
  - [ ] `bun test src/__tests__/embeddings.test.ts` → PASS
  - [ ] Cache hit skips API call (verified via mock)
  - [ ] Buffer conversion round-trips correctly

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Embedding produces correct dimensions
    Tool: Bash (bun run)
    Preconditions: OPENAI_API_KEY set in environment
    Steps:
      1. bun run -e "import { EmbeddingProvider } from './src/embeddings'; import { initDatabase } from './src/db'; const db = initDatabase(':memory:'); const ep = new EmbeddingProvider({ db, model: 'text-embedding-3-small' }); const emb = await ep.embed('test'); console.log('dimensions:', emb.length)"
      2. Assert: dimensions = 1536
    Expected Result: Embedding has 1536 dimensions
    Evidence: Terminal output

  Scenario: Cache prevents duplicate API calls
    Tool: Bash (bun test)
    Preconditions: Embeddings module with mock
    Steps:
      1. bun test src/__tests__/embeddings.test.ts --filter "cache"
      2. Assert: mock API called once for first embed, zero times for second (same content)
    Expected Result: Second call uses cache
    Evidence: Test output
  ```

  **Commit**: YES
  - Message: `feat(embeddings): OpenAI embedding provider with content-hash cache`
  - Files: `src/embeddings.ts`, `src/__tests__/embeddings.test.ts`
  - Pre-commit: `bun test`

---

- [x] 6. File Indexer Pipeline

  **What to do**:
  - **RED**: Write `src/__tests__/indexer.test.ts`:
    - Test: `indexFile(filePath, source, db, embedder)` reads file, chunks it, embeds chunks, stores in SQLite
    - Test: file hash is stored in `files` table
    - Test: chunks are stored in `chunks` table with correct file_path, start_line, end_line
    - Test: FTS5 table is populated with chunk text
    - Test: vec0 table is populated with embeddings (if available)
    - Test: re-indexing unchanged file (same hash) is a no-op
    - Test: re-indexing changed file (different hash) replaces old chunks
    - Test: `removeFile(filePath, db)` removes file + all its chunks from all tables
    - Test: `indexDirectory(vaultPath, source, db, embedder)` indexes all .md files
    - Test: `indexDirectory` skips already-indexed files with same hash
    - Test: `indexDirectory` removes files that no longer exist on disk
  - **GREEN**: Implement `src/indexer.ts`:
    - `async indexFile(filePath, source, db, embedder, config)`:
      1. Read file content
      2. Compute file hash
      3. Check if file already indexed with same hash → skip if unchanged
      4. Delete old chunks for this file (if re-indexing)
      5. Chunk the text (using discovery.chunkText)
      6. Embed all chunks (using embedder.embedBatch — leverages cache)
      7. Insert file record into `files` table
      8. Insert chunks into `chunks`, `chunks_fts`, `chunks_vec` tables
      9. Wrap in transaction for atomicity
    - `removeFile(filePath, db)`: Delete from files, chunks, chunks_fts, chunks_vec
    - `async indexDirectory(vaultPath, source, db, embedder, config)`:
      1. Discover all .md files
      2. Get list of currently indexed files from DB
      3. Remove files from DB that no longer exist on disk
      4. Index new/changed files
      5. Skip unchanged files (hash match)
  - **REFACTOR**: Ensure all DB operations are in transactions

  **Must NOT do**:
  - Don't implement file watching (lifecycle concern, Task 12)
  - Don't implement session indexing (Task 7)
  - Don't add progress reporting (Phase 2)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Core pipeline orchestrating discovery, embedding, and database operations. Transaction management. Most complex single task.
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: NO (depends on 3, 4, 5)
  - **Parallel Group**: Wave 3 (after Task 5 completes)
  - **Blocks**: Tasks 8, 9
  - **Blocked By**: Tasks 3, 4, 5

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/openclaw/src/memory/manager.ts:350-600` — `syncFiles()` method: the EXACT pattern for indexing. Shows hash checking, chunk insertion, FTS5/vec0 population, transaction wrapping. This is the PRIMARY reference.
  - `/home/m3tam3re/p/AI/openclaw/src/memory/manager.ts:600-800` — How file removal and re-indexing works

  **Acceptance Criteria**:

  **TDD:**
  - [ ] Test file: `src/__tests__/indexer.test.ts`
  - [ ] `bun test src/__tests__/indexer.test.ts` → PASS (all 11 tests)
  - [ ] Unchanged files are skipped (hash check)
  - [ ] Changed files replace old chunks (not append)
  - [ ] Deleted files are removed from index

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Index a directory of markdown files
    Tool: Bash
    Preconditions: DB module, discovery, embeddings all working. Test fixtures exist.
    Steps:
      1. Create 3 test .md files in /tmp/test-vault/
      2. bun run -e "import { indexDirectory } from './src/indexer'; import { initDatabase } from './src/db'; import { EmbeddingProvider } from './src/embeddings'; const db = initDatabase(':memory:'); const ep = new EmbeddingProvider({db, model:'text-embedding-3-small'}); await indexDirectory('/tmp/test-vault', 'memory', db, ep, defaultConfig); const files = db.prepare('SELECT * FROM files').all(); const chunks = db.prepare('SELECT * FROM chunks').all(); console.log('files:', files.length, 'chunks:', chunks.length)"
      3. Assert: files = 3, chunks > 3 (depends on content length)
    Expected Result: All files indexed with chunks in DB
    Evidence: Terminal output

  Scenario: Re-index unchanged files is a no-op
    Tool: Bash
    Preconditions: Directory already indexed
    Steps:
      1. Run indexDirectory twice on same unchanged directory
      2. Count API calls to embedding provider (mock)
      3. Assert: 0 embedding API calls on second run
    Expected Result: No re-embedding of unchanged content
    Evidence: Test output
  ```

  **Commit**: YES
  - Message: `feat(indexer): file indexer pipeline with hash-based change detection`
  - Files: `src/indexer.ts`, `src/__tests__/indexer.test.ts`
  - Pre-commit: `bun test`

---

- [x] 7. Session Transcript Parser + Indexer

  **What to do**:
  - **RED**: Write `src/__tests__/sessions.test.ts`:
    - Test: `discoverSessions(storagePath)` finds all session directories
    - Test: `parseSession(sessionDir)` reads session JSON + message JSONs, returns structured transcript
    - Test: `sessionToText(session)` converts to "User: ... / Assistant: ..." text format
    - Test: handles session with 0 messages (returns empty text)
    - Test: handles corrupted/missing JSON files gracefully (skip, don't crash)
    - Test: `indexSessions(storagePath, db, embedder, config)` indexes all session transcripts
    - Test: already-indexed sessions (by file hash) are skipped
    - Test: new sessions since last index are added
  - **GREEN**: Implement `src/sessions.ts`:
    - `discoverSessions(storagePath: string): SessionDir[]` — find all `message/{session_id}/` directories under storage path. Also check project-specific dirs in `session/{hash}/`.
    - `parseSession(sessionDir: string): ParsedSession` — read all msg_*.json files, sort by timestamp, extract role + content fields. Handle missing/corrupt files with try/catch.
    - `sessionToText(session: ParsedSession): string` — format as:
      ```
      [Session: {title}] [{date}]
      User: {message}
      Assistant: {message}
      ...
      ```
    - `async indexSessions(storagePath, db, embedder, config)`:
      1. Discover all session directories
      2. For each: compute hash of combined message content
      3. Skip if already indexed with same hash
      4. Convert to text, chunk, embed, store with source="sessions"
  - **REFACTOR**: Handle edge cases (empty sessions, partial data)

  **Must NOT do**:
  - Don't index tool call details (just user/assistant messages)
  - Don't implement session filtering (all sessions indexed)
  - Don't implement incremental message indexing (whole session = one unit)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Parsing JSON files from unknown directory structure, handling corruption, integrating with indexer pipeline. Moderate complexity.
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: YES (parallel with Task 5)
  - **Parallel Group**: Wave 3
  - **Blocks**: Task 11
  - **Blocked By**: Tasks 3, 4

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/openclaw/src/memory/session-files.ts` — Session transcript conversion. Shows how JSONL transcripts are converted to searchable text. Adapt for Opencode's JSON format.
  - `/home/m3tam3re/p/AI/openclaw/src/memory/manager.ts:800-1000` — How session sources are handled alongside memory sources

  **API/Type References**:
  - Opencode session JSON format (discovered during research):
    - Session: `{ id, slug, projectID, directory, title, time: { created, updated }, summary }`
    - Message: `{ id, sessionID, role, time: { created }, agent, model }`
    - Session storage: `~/.local/share/opencode/storage/session/{project_hash}/ses_*.json`
    - Message storage: `~/.local/share/opencode/storage/message/{session_id}/msg_*.json`

  **WHY Each Reference Matters**:
  - `session-files.ts`: Exact pattern for converting conversation transcripts to text format suitable for chunking and embedding.
  - Session JSON format: Needed to parse the actual message content from Opencode's storage.

  **Acceptance Criteria**:

  **TDD:**
  - [ ] Test file: `src/__tests__/sessions.test.ts`
  - [ ] `bun test src/__tests__/sessions.test.ts` → PASS (all 8 tests)
  - [ ] Handles corrupt JSON without crashing

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Parse real Opencode session transcripts
    Tool: Bash
    Preconditions: Opencode storage exists at ~/.local/share/opencode/storage/
    Steps:
      1. bun run -e "import { discoverSessions } from './src/sessions'; const sessions = discoverSessions(process.env.HOME + '/.local/share/opencode/storage'); console.log('found sessions:', sessions.length)"
      2. Assert: sessions.length > 0
      3. Parse first session and verify text output contains "User:" and "Assistant:" markers
    Expected Result: Real session transcripts parseable
    Evidence: Terminal output (first 200 chars of transcript)

  Scenario: Corrupt JSON file doesn't crash parser
    Tool: Bash
    Preconditions: Test fixture with corrupt JSON
    Steps:
      1. Create test dir with valid session JSON + one corrupt msg file (invalid JSON)
      2. bun run -e "import { parseSession } from './src/sessions'; const s = parseSession('/tmp/test-session'); console.log('messages:', s.messages.length)"
      3. Assert: no error thrown, corrupt message skipped
    Expected Result: Graceful handling, partial results
    Evidence: Terminal output
  ```

  **Commit**: YES
  - Message: `feat(sessions): Opencode session transcript parser and indexer`
  - Files: `src/sessions.ts`, `src/__tests__/sessions.test.ts`
  - Pre-commit: `bun test`

---

- [x] 8. FTS5 BM25 Search Module

  **What to do**:
  - **RED**: Write `src/__tests__/search-fts.test.ts`:
    - Test: `searchFTS(db, query, maxResults)` returns matching chunks with BM25 rank scores
    - Test: matches on exact keywords
    - Test: matches on partial words (FTS5 prefix queries)
    - Test: returns empty array for no matches
    - Test: results are ranked by BM25 relevance (best first)
    - Test: respects maxResults limit
    - Test: returns chunk metadata (file_path, start_line, end_line, text, score)
  - **GREEN**: Implement FTS5 search in `src/search.ts`:
    - `searchFTS(db, query, maxResults): SearchResult[]`:
      ```sql
      SELECT c.id, c.file_path, c.start_line, c.end_line, c.text,
             rank AS score
      FROM chunks_fts
      JOIN chunks c ON chunks_fts.rowid = c.rowid
      WHERE chunks_fts MATCH ?
      ORDER BY rank
      LIMIT ?
      ```
    - Normalize BM25 scores to 0-1 range for hybrid combiner
    - Handle FTS5 query syntax (escape special characters)

  **Must NOT do**:
  - Don't implement hybrid combination (Task 10)
  - Don't add query preprocessing or expansion

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Single SQL query + score normalization. Small, focused module.
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Task 9)
  - **Blocks**: Task 10
  - **Blocked By**: Task 6

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/openclaw/src/memory/hybrid.ts:50-100` — BM25 search implementation and score normalization. This is the PRIMARY reference.
  - `/home/m3tam3re/p/AI/openclaw/src/memory/manager.ts:1000-1100` — How FTS5 queries are constructed and executed

  **External References**:
  - SQLite FTS5: `https://www.sqlite.org/fts5.html#the_bm25_function`

  **Acceptance Criteria**:

  **TDD:**
  - [ ] Test file: `src/__tests__/search-fts.test.ts`
  - [ ] `bun test src/__tests__/search-fts.test.ts` → PASS (all 7 tests)

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: FTS5 search finds indexed content
    Tool: Bash (bun test)
    Preconditions: Test DB with indexed chunks containing known text
    Steps:
      1. bun test src/__tests__/search-fts.test.ts
      2. Assert: searching "TypeScript" finds chunk containing "TypeScript is my preferred language"
      3. Assert: score is a number between 0 and 1
    Expected Result: Keyword search returns ranked results
    Evidence: Test output
  ```

  **Commit**: YES (groups with 9, 10)
  - Message: `feat(search): FTS5 BM25 keyword search module`
  - Files: `src/search.ts` (partial), `src/__tests__/search-fts.test.ts`
  - Pre-commit: `bun test`

---

- [x] 9. Vector Cosine Similarity Search Module

  **What to do**:
  - **RED**: Write `src/__tests__/search-vec.test.ts`:
    - Test: `searchVector(db, queryEmbedding, maxResults)` returns chunks ranked by cosine similarity
    - Test: more similar content scores higher
    - Test: returns empty array when no data in vec0 table
    - Test: respects maxResults limit
    - Test: returns chunk metadata (file_path, start_line, end_line, text, score)
    - Test: handles case where vec0 extension is unavailable (returns empty, doesn't crash)
  - **GREEN**: Implement vector search in `src/search.ts`:
    - `searchVector(db, queryEmbedding, maxResults): SearchResult[]`:
      ```sql
      SELECT c.id, c.file_path, c.start_line, c.end_line, c.text,
             distance AS score
      FROM chunks_vec
      JOIN chunks c ON chunks_vec.rowid = c.rowid
      WHERE embedding MATCH ?
      ORDER BY distance
      LIMIT ?
      ```
    - Convert distance to similarity score (1 - distance for cosine)
    - Normalize to 0-1 range
    - Handle vec0 unavailability: return empty results, log warning

  **Must NOT do**:
  - Don't implement hybrid combination (Task 10)
  - Don't implement approximate nearest neighbor tuning

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Single SQL query + distance-to-similarity conversion. Small module, similar to Task 8.
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 4 (with Task 8)
  - **Blocks**: Task 10
  - **Blocked By**: Task 6

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/openclaw/src/memory/hybrid.ts:100-150` — Vector search implementation. Shows cosine distance query and score conversion. PRIMARY reference.
  - `/home/m3tam3re/p/AI/openclaw/src/memory/manager.ts:1100-1200` — How vector queries are constructed

  **External References**:
  - sqlite-vec query syntax: `https://alexgarcia.xyz/sqlite-vec/api-reference.html`

  **Acceptance Criteria**:

  **TDD:**
  - [ ] Test file: `src/__tests__/search-vec.test.ts`
  - [ ] `bun test src/__tests__/search-vec.test.ts` → PASS (all 6 tests)
  - [ ] Gracefully handles missing vec0 extension

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Vector search returns semantically similar results
    Tool: Bash (bun test)
    Preconditions: Test DB with embedded chunks
    Steps:
      1. bun test src/__tests__/search-vec.test.ts
      2. Assert: query about "programming language preferences" finds chunk about "TypeScript"
      3. Assert: similarity score decreases for less relevant chunks
    Expected Result: Semantic search returns ranked results
    Evidence: Test output
  ```

  **Commit**: YES (groups with 8, 10)
  - Message: `feat(search): vector cosine similarity search module`
  - Files: `src/search.ts` (extended), `src/__tests__/search-vec.test.ts`
  - Pre-commit: `bun test`

---

- [x] 10. Hybrid Search Combiner

  **What to do**:
  - **RED**: Write `src/__tests__/search-hybrid.test.ts`:
    - Test: `hybridSearch(db, query, embedder, config)` combines FTS5 and vector results
    - Test: weighting applies correctly (0.7 * vectorScore + 0.3 * textScore)
    - Test: results below minScore threshold are filtered out
    - Test: duplicate chunks (found by both searches) are merged (not duplicated)
    - Test: results are sorted by combined score (highest first)
    - Test: maxResults is respected after merging
    - Test: works with only FTS5 results (vec0 unavailable) — degraded mode
    - Test: works with only vector results (FTS5 query fails) — degraded mode
    - Test: custom weights override defaults
  - **GREEN**: Implement `src/search.ts` (add to existing):
    - `async hybridSearch(db, query, embedder, config): Promise<HybridResult[]>`:
      1. Run FTS5 search: `searchFTS(db, query, config.maxResults * 2)`
      2. Embed query: `embedder.embed(query)` (with cache)
      3. Run vector search: `searchVector(db, queryEmbedding, config.maxResults * 2)`
      4. Merge results by chunk ID:
         - If in both: `combinedScore = vectorWeight * vectorScore + textWeight * textScore`
         - If only FTS5: `combinedScore = textWeight * textScore`
         - If only vector: `combinedScore = vectorWeight * vectorScore`
      5. Filter by minScore
      6. Sort by combinedScore descending
      7. Limit to maxResults
      8. Return with source metadata (file_path, start_line, end_line, text, score, source)

  **Must NOT do**:
  - Don't implement query expansion or rewriting
  - Don't implement re-ranking with a separate model

  **Recommended Agent Profile**:
  - **Category**: `ultrabrain`
    - Reason: Score merging, deduplication by ID, weighted combination, edge case handling (degraded modes). Requires careful algorithmic thinking.
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: NO (depends on 8 and 9)
  - **Parallel Group**: Wave 4 (after Tasks 8 + 9)
  - **Blocks**: Task 11
  - **Blocked By**: Tasks 8, 9

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/openclaw/src/memory/hybrid.ts` — THE reference for hybrid search. This entire file is the pattern. Shows score normalization, weighted combination, merging, deduplication, filtering, sorting. Copy the algorithm closely.

  **WHY This Reference Matters**:
  - This is the heart of Openclaw's memory system. The hybrid search combiner determines recall quality. The weighting, merging, and filtering logic must be correct.

  **Acceptance Criteria**:

  **TDD:**
  - [ ] Test file: `src/__tests__/search-hybrid.test.ts`
  - [ ] `bun test src/__tests__/search-hybrid.test.ts` → PASS (all 9 tests)
  - [ ] Degraded mode works (FTS-only, vector-only)
  - [ ] Duplicate chunks merged correctly

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Hybrid search combines vector and keyword results
    Tool: Bash (bun test)
    Preconditions: DB with indexed chunks containing diverse content
    Steps:
      1. bun test src/__tests__/search-hybrid.test.ts
      2. Assert: hybrid results include chunks found by BOTH methods
      3. Assert: combined score = 0.7 * vectorScore + 0.3 * textScore for shared results
      4. Assert: results sorted by combined score descending
      5. Assert: results below minScore=0.35 are filtered
    Expected Result: Hybrid search correctly combines and ranks
    Evidence: Test output

  Scenario: Graceful degradation when vec0 unavailable
    Tool: Bash (bun test)
    Preconditions: Mock vec0 as unavailable
    Steps:
      1. bun test src/__tests__/search-hybrid.test.ts --filter "degraded"
      2. Assert: FTS-only results returned with textWeight scoring
      3. Assert: no error thrown
    Expected Result: Search works with BM25 only
    Evidence: Test output
  ```

  **Commit**: YES
  - Message: `feat(search): hybrid search combiner with weighted vector+BM25 scoring`
  - Files: `src/search.ts` (complete), `src/__tests__/search-hybrid.test.ts`
  - Pre-commit: `bun test`

---

- [x] 11. Agent Tools — memory_search, memory_store, memory_get

  **What to do**:
  - **RED**: Write `src/__tests__/tools.test.ts`:
    - Test: `memorySearchTool` schema validates query string, optional maxResults, optional source filter
    - Test: `memorySearchTool.execute(query)` calls hybridSearch and formats results
    - Test: `memoryStoreTool` schema validates content string, optional title, optional category
    - Test: `memoryStoreTool.execute(content, title, category)` creates markdown file in vault with frontmatter, then indexes it
    - Test: markdown filename is slugified from title (or timestamp-based if no title)
    - Test: markdown has YAML frontmatter (type, category, created_at, source)
    - Test: `memoryGetTool` schema validates filePath, optional startLine, optional endLine
    - Test: `memoryGetTool.execute(filePath, startLine, endLine)` reads file and returns specified line range
    - Test: memoryGetTool rejects paths outside vault directory
    - Test: atomic write (temp file + rename) for memoryStore
  - **GREEN**: Implement `src/tools.ts`:
    - `memorySearchTool`:
      - Schema: `{ query: z.string(), maxResults?: z.number().default(6), source?: z.enum(["memory","sessions","all"]).default("all") }`
      - Execute: call hybridSearch, format results as:
        ```
        Found N relevant memories:
        ---
        [1] {file_path}:{start_line}-{end_line} (score: 0.85, source: memory)
        {text content}
        ---
        ```
    - `memoryStoreTool`:
      - Schema: `{ content: z.string(), title?: z.string(), category?: z.enum(["preferences","facts","decisions","entities","other"]).default("other") }`
      - Execute:
        1. Generate filename: `{category}/{slugify(title)}-{timestamp}.md` or `{category}/{timestamp}.md`
        2. Create YAML frontmatter: `---\ntype: memory\ncategory: {cat}\ncreated_at: {ISO date}\nsource: agent\n---`
        3. Write to vault atomically (write to .tmp, rename)
        4. Index the new file immediately
        5. Return confirmation with file path
    - `memoryGetTool`:
      - Schema: `{ filePath: z.string(), startLine?: z.number(), endLine?: z.number() }`
      - Execute: validate path is within vault, read file, return requested lines
      - Security: reject any path not starting with vault directory
  - **REFACTOR**: Extract markdown generation, ensure consistent frontmatter

  **Must NOT do**:
  - Don't implement memory_update or memory_delete (read + search + store covers needs)
  - Don't implement bulk operations
  - Don't add LLM-based summarization to memory_store

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Three tools with Zod schemas, file I/O, security validation, integration with all previous modules. Significant integration task.
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 5
  - **Blocks**: Task 12
  - **Blocked By**: Tasks 10, 7

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/openclaw/src/agents/tools/memory-tool.ts` — Openclaw's memory tools. Shows exact tool structure, Zod schema patterns, result formatting. PRIMARY reference for tool design.
  - `/home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md` — Current memory skill workflows (store, recall). Shows the user's expected interaction patterns.
  - `/home/m3tam3re/p/AI/AGENTS/skills/obsidian/SKILL.md` — Obsidian vault structure and frontmatter conventions for `~/CODEX/80-memory/`. Shows category subfolders and frontmatter template.

  **API/Type References**:
  - Opencode custom tool format: `https://opencode.ai/docs/custom-tools/` — Tool definition with Zod schemas
  - Opencode plugin tool() helper: `https://opencode.ai/docs/plugins/` — How to define tools inside a plugin

  **WHY Each Reference Matters**:
  - `memory-tool.ts`: Direct pattern for memory_search output formatting. Shows how to present search results concisely.
  - `SKILL.md` (memory): Shows user's existing mental model of store/recall workflows. Tools should match expectations.
  - `SKILL.md` (obsidian): Shows frontmatter format and category subfolders (`preferences/`, `facts/`, etc.).

  **Acceptance Criteria**:

  **TDD:**
  - [ ] Test file: `src/__tests__/tools.test.ts`
  - [ ] `bun test src/__tests__/tools.test.ts` → PASS (all 10 tests)
  - [ ] memory_store creates files atomically (temp + rename)
  - [ ] memory_get rejects paths outside vault

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: memory_store creates markdown with correct frontmatter
    Tool: Bash
    Preconditions: Vault directory exists, DB initialized
    Steps:
      1. Call memoryStoreTool.execute({ content: "I prefer dark themes in all editors", title: "editor preferences", category: "preferences" })
      2. Assert: file created at ~/CODEX/80-memory/preferences/editor-preferences-*.md
      3. cat the file → Assert frontmatter contains "type: memory", "category: preferences"
      4. Assert: body contains "I prefer dark themes in all editors"
    Expected Result: Markdown file with correct structure
    Evidence: File content captured

  Scenario: memory_search returns formatted results
    Tool: Bash
    Preconditions: Vault has indexed memories
    Steps:
      1. Call memorySearchTool.execute({ query: "editor theme preference" })
      2. Assert: output contains "Found N relevant memories"
      3. Assert: results include file paths and scores
      4. Assert: scores are between 0 and 1
    Expected Result: Formatted search results
    Evidence: Tool output captured

  Scenario: memory_get rejects path traversal
    Tool: Bash (bun test)
    Preconditions: Tools module implemented
    Steps:
      1. bun test src/__tests__/tools.test.ts --filter "rejects paths outside"
      2. Assert: memoryGetTool.execute({ filePath: "/etc/passwd" }) throws error
      3. Assert: memoryGetTool.execute({ filePath: "../../etc/passwd" }) throws error
    Expected Result: Security validation works
    Evidence: Test output
  ```

  **Commit**: YES
  - Message: `feat(tools): agent tools — memory_search, memory_store, memory_get`
  - Files: `src/tools.ts`, `src/__tests__/tools.test.ts`
  - Pre-commit: `bun test`

---

- [x] 12. Plugin Entry Point — Hooks + Lifecycle

  **What to do**:
  - **RED**: Write `src/__tests__/plugin.test.ts`:
    - Test: plugin exports default function
    - Test: plugin registers 3 tools (memory_search, memory_store, memory_get)
    - Test: session.created handler calls auto-recall (hybrid search on session context)
    - Test: session.idle handler calls auto-capture (extract and store memories)
    - Test: session.compacting handler injects memory context (≤ 2000 tokens)
    - Test: plugin initializes DB on first call (lazy init)
    - Test: plugin handles DB initialization failure gracefully (log, continue)
    - Test: plugin handles embedding API failure gracefully (log, continue)
    - Test: token budget is respected in injection (truncate if > 2000 tokens)
  - **GREEN**: Implement `src/index.ts`:
    - Default export: Opencode plugin function
      ```typescript
      import { tool } from "@opencode-ai/plugin"
      
      export default function(ctx) {
        // Lazy initialization
        let db, embedder, config
        
        const init = () => {
          if (db) return
          config = resolveConfig()
          db = initDatabase(config.dbPath)
          embedder = new EmbeddingProvider({ db, model: config.embedding.model })
        }
        
        // Register tools
        ctx.tool("memory_search", memorySearchTool.schema, async (params) => {
          init()
          return memorySearchTool.execute(params, db, embedder, config)
        })
        
        ctx.tool("memory_store", memoryStoreTool.schema, async (params) => {
          init()
          return memoryStoreTool.execute(params, db, embedder, config)
        })
        
        ctx.tool("memory_get", memoryGetTool.schema, async (params) => {
          init()
          return memoryGetTool.execute(params, config)
        })
        
        // Event hooks
        ctx.on("session.created", async (event) => {
          init()
          // Auto-recall: search for relevant memories based on session context
          // Inject results into system prompt or initial context
        })
        
        ctx.on("session.idle", async (event) => {
          init()
          // Auto-capture: extract memories from recent conversation
          // Store as markdown + index
        })
        
        ctx.on("experimental.session.compacting", async (event) => {
          init()
          // Inject relevant memory context into compaction
          // Respect token budget
        })
      }
      ```
    - Auto-recall logic: On session.created, search for memories related to the project directory and recent context. Format top results within token budget. Inject via system prompt addition.
    - Auto-capture logic: On session.idle, analyze recent messages. Use LLM (or simple heuristics) to extract key facts, decisions, preferences. Store as markdown via memoryStoreTool.
    - Compaction injection: On session.compacting, search for relevant memories and include in compaction context.
    - Error wrapping: ALL hooks wrapped in try/catch → log error, never crash Opencode
    - File watcher: Start chokidar watcher on vault directory for live file changes → re-index changed files

  **Must NOT do**:
  - Don't implement complex LLM-based extraction for auto-capture (use simple heuristic or minimal prompt — Phase 2 can enhance)
  - Don't implement custom settings UI
  - Don't add CLI commands (Task 13 handles rebuild)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Plugin integration with Opencode's event system, lifecycle management, error handling, file watching. Core integration task.
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 5 (after Task 11)
  - **Blocks**: Task 13
  - **Blocked By**: Task 11

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/openclaw/src/agents/tools/memory-tool.ts` — How tools are registered and how search results are formatted for agent consumption
  - `/home/m3tam3re/p/AI/openclaw/src/agents/system-prompt.ts` — How memory instructions are injected into system prompt. Shows the "Before answering, search memory..." pattern.
  - `/home/m3tam3re/p/AI/openclaw/src/memory/manager.ts:1300-1590` — Lifecycle methods: init, sync, shutdown, file watcher setup

  **API/Type References**:
  - Opencode plugin API: `https://opencode.ai/docs/plugins/` — Plugin function signature, ctx.tool(), ctx.on(), event types
  - Opencode custom tools: `https://opencode.ai/docs/custom-tools/` — Tool schema format with Zod

  **Documentation References**:
  - `/home/m3tam3re/.config/opencode/opencode.json:128-132` — Existing plugin registration pattern (shows how plugins are listed)

  **WHY Each Reference Matters**:
  - `system-prompt.ts`: Shows the exact memory instruction pattern that makes agents reliably use memory tools. Without this, agents may ignore the tools.
  - Plugin docs: The exact API surface for ctx.tool() and ctx.on(). Critical for correct integration.
  - `manager.ts:1300-1590`: Shows chokidar file watcher setup, debouncing, and cleanup.

  **Acceptance Criteria**:

  **TDD:**
  - [ ] Test file: `src/__tests__/plugin.test.ts`
  - [ ] `bun test src/__tests__/plugin.test.ts` → PASS (all 9 tests)
  - [ ] All hooks wrapped in try/catch
  - [ ] Token budget respected

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Plugin loads in opencode without errors
    Tool: interactive_bash (tmux)
    Preconditions: Plugin built, registered in opencode.json
    Steps:
      1. Add "opencode-memory" to plugin list in opencode.json (or use local path)
      2. Start opencode in tmux session
      3. Wait for initialization (5s)
      4. Check opencode logs for "opencode-memory" → no errors
      5. Verify memory_search tool is available (try calling it)
    Expected Result: Plugin loads, tools available
    Evidence: Terminal output, opencode log screenshot

  Scenario: Plugin handles missing vault directory gracefully
    Tool: Bash
    Preconditions: Vault directory temporarily renamed
    Steps:
      1. mv ~/CODEX/80-memory ~/CODEX/80-memory.bak
      2. Start plugin init → should log warning, not crash
      3. mv ~/CODEX/80-memory.bak ~/CODEX/80-memory
    Expected Result: Graceful degradation with warning
    Evidence: Log output

  Scenario: Token budget limits memory injection
    Tool: Bash (bun test)
    Preconditions: DB with many indexed memories
    Steps:
      1. bun test src/__tests__/plugin.test.ts --filter "token budget"
      2. Assert: injected context ≤ 2000 tokens
    Expected Result: Budget respected
    Evidence: Test output
  ```

  **Commit**: YES
  - Message: `feat(plugin): Opencode plugin entry point with hooks and lifecycle`
  - Files: `src/index.ts`, `src/__tests__/plugin.test.ts`
  - Pre-commit: `bun test`

---

- [x] 13. Integration Testing + Error Handling + Rebuild Command

  **What to do**:
  - **RED**: Write `src/__tests__/integration.test.ts`:
    - Test: full pipeline — create memory → search → find it
    - Test: full pipeline — index vault → search → get file
    - Test: full pipeline — index sessions → search session content
    - Test: rebuild command — delete DB → rebuild → all content searchable again
    - Test: OpenAI API failure → plugin continues, BM25-only results
    - Test: corrupt SQLite → auto-recreate on next init
    - Test: concurrent search + index operations don't deadlock
    - Test: empty vault → no errors, empty search results
    - Test: very large file (1MB+) → chunks correctly, no OOM
  - **GREEN**:
    - Add CLI entry point for rebuild: `src/cli.ts`
      ```typescript
      // bun run src/cli.ts --rebuild [--vault path] [--db path]
      ```
    - Add error recovery to `initDatabase`: if DB is corrupt, delete and recreate
    - Add timeout to embedding API calls (30s default)
    - Add graceful shutdown: close DB, stop file watcher, on process exit
    - Ensure all error paths are covered with try/catch
  - **REFACTOR**: Run full test suite, fix any integration issues

  **Must NOT do**:
  - Don't build a comprehensive CLI (just --rebuild)
  - Don't add progress bars or fancy output
  - Don't implement migration from mem0

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Integration testing requires understanding the full system. Error scenarios require careful thinking about failure modes and recovery.
  - **Skills**: [`systematic-debugging`]
    - `systematic-debugging`: Needed for diagnosing integration test failures systematically

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 6
  - **Blocks**: Task 14
  - **Blocked By**: Task 12

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/openclaw/src/memory/manager.ts:1-50` — Imports and error handling patterns
  - `/home/m3tam3re/p/AI/openclaw/src/memory/manager.ts:1400-1590` — Shutdown and cleanup logic

  **Acceptance Criteria**:

  **TDD:**
  - [ ] Test file: `src/__tests__/integration.test.ts`
  - [ ] `bun test` → ALL tests pass (0 failures across all test files)
  - [ ] CLI rebuild: `bun run src/cli.ts --rebuild` works

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Full pipeline — store and search a memory
    Tool: Bash
    Preconditions: Plugin module fully implemented
    Steps:
      1. Initialize in-memory DB + embedder
      2. Store memory: "I prefer Nix for system configuration"
      3. Search: "system configuration tool"
      4. Assert: search result contains "Nix" with score > 0.35
    Expected Result: End-to-end pipeline works
    Evidence: Terminal output

  Scenario: Rebuild command recreates index from markdown
    Tool: Bash
    Preconditions: Vault has markdown files, DB deleted
    Steps:
      1. rm -f ~/.local/share/opencode-memory/index.db
      2. bun run src/cli.ts --rebuild --vault ~/CODEX/80-memory/
      3. Assert: DB file created
      4. Assert: search for known vault content returns results
    Expected Result: Index rebuilt from markdown source of truth
    Evidence: Terminal output + DB file exists

  Scenario: API failure degrades gracefully
    Tool: Bash
    Preconditions: OPENAI_API_KEY=invalid
    Steps:
      1. OPENAI_API_KEY=invalid bun test src/__tests__/integration.test.ts --filter "API failure"
      2. Assert: no crash, BM25-only results returned
      3. Assert: error logged to stderr
    Expected Result: Graceful degradation
    Evidence: Test output
  ```

  **Commit**: YES
  - Message: `feat(integration): integration tests, error recovery, rebuild CLI`
  - Files: `src/__tests__/integration.test.ts`, `src/cli.ts`
  - Pre-commit: `bun test`

---

- [x] 14. AGENTS Repo Skill Updates + Deployment Config

  **What to do**:
  - Update `skills/memory/SKILL.md` in the AGENTS repo:
    - Replace dual-layer (mem0 + Obsidian) description with opencode-memory plugin description
    - Document new architecture: SQLite hybrid search, markdown source of truth
    - Update workflows: memory_search, memory_store, memory_get tools
    - Document auto-recall (session.created) and auto-capture (session.idle) behavior
    - Remove references to mem0 REST API
    - Keep Obsidian vault references (still at `~/CODEX/80-memory/`)
  - Update `skills/mem0-memory/SKILL.md`:
    - Add deprecation notice at top: "DEPRECATED: Replaced by opencode-memory plugin. See skills/memory/SKILL.md."
    - Keep existing content for reference
  - Add plugin registration note to `context/profile.md`:
    - Update memory system description to reference opencode-memory
  - Create deployment documentation in `skills/memory/references/deployment.md`:
    - How to install opencode-memory (npm or Nix)
    - How to register in opencode.json
    - How to configure vault path and embedding provider
    - How to verify installation

  **Must NOT do**:
  - Don't modify opencode.json (user does this manually after deployment)
  - Don't delete mem0-memory skill (just deprecate)
  - Don't modify agent definitions (Apollo agent config stays)
  - Don't create README in the opencode-memory repo

  **Recommended Agent Profile**:
  - **Category**: `writing`
    - Reason: Documentation-heavy task. Updating skill files, writing deployment notes.
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: NO (final task)
  - **Parallel Group**: Wave 6 (after Task 13)
  - **Blocks**: None (final task)
  - **Blocked By**: Task 13

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/AI/AGENTS/skills/memory/SKILL.md` — Current memory skill to update. Preserve structure, update content.
  - `/home/m3tam3re/p/AI/AGENTS/skills/mem0-memory/SKILL.md` — Current mem0 skill to deprecate. Add deprecation notice.
  - `/home/m3tam3re/p/AI/AGENTS/context/profile.md` — User profile with memory references to update.
  - `/home/m3tam3re/p/AI/AGENTS/skills/obsidian/SKILL.md` — Obsidian skill for reference (vault structure stays same).

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Updated memory skill validates
    Tool: Bash
    Preconditions: AGENTS repo skills updated
    Steps:
      1. ./scripts/test-skill.sh memory
      2. Assert: validation passes
      3. grep "opencode-memory" skills/memory/SKILL.md → found
      4. grep "DEPRECATED" skills/mem0-memory/SKILL.md → found
    Expected Result: Skills validate, content updated
    Evidence: Validation output

  Scenario: Profile references new memory system
    Tool: Bash
    Preconditions: context/profile.md updated
    Steps:
      1. grep "opencode-memory" context/profile.md → found
      2. grep "mem0" context/profile.md → NOT found (or marked deprecated)
    Expected Result: Profile references updated
    Evidence: grep output
  ```

  **Commit**: YES
  - Message: `docs(memory): update skills for opencode-memory plugin, deprecate mem0`
  - Files: `skills/memory/SKILL.md`, `skills/mem0-memory/SKILL.md`, `context/profile.md`, `skills/memory/references/deployment.md`
  - Pre-commit: `./scripts/test-skill.sh --validate`

---

## Commit Strategy

| After Task | Message | Key Files | Verification |
|------------|---------|-----------|--------------|
| 1 | `feat(scaffold): initialize opencode-memory repo` | package.json, tsconfig.json, src/*.ts stubs | `bun test` |
| 2+3+4 | `feat(core): config, database schema, file discovery` | config.ts, db.ts, discovery.ts + tests | `bun test` |
| 5 | `feat(embeddings): OpenAI provider with cache` | embeddings.ts + test | `bun test` |
| 6 | `feat(indexer): file indexer pipeline` | indexer.ts + test | `bun test` |
| 7 | `feat(sessions): session transcript parser` | sessions.ts + test | `bun test` |
| 8+9+10 | `feat(search): hybrid search (FTS5 + vec0)` | search.ts + tests | `bun test` |
| 11 | `feat(tools): agent memory tools` | tools.ts + test | `bun test` |
| 12 | `feat(plugin): Opencode plugin entry point` | index.ts + test | `bun test` |
| 13 | `feat(integration): tests + error recovery + rebuild` | integration.test.ts, cli.ts | `bun test` |
| 14 | `docs(memory): update AGENTS repo skills` | SKILL.md files | `./scripts/test-skill.sh --validate` |

---

## Success Criteria

### Verification Commands
```bash
# In opencode-memory repo:
bun test                    # Expected: ALL tests pass (0 failures)
bun run src/cli.ts --rebuild --vault ~/CODEX/80-memory/  # Expected: index rebuilt

# In AGENTS repo:
./scripts/test-skill.sh --validate  # Expected: all skills valid

# In opencode (after registration):
# memory_search tool available and returns results
# memory_store tool creates markdown files
# memory_get tool reads file content
```

### Final Checklist
- [x] All "Must Have" items present (hybrid search, caching, graceful degradation, etc.)
- [x] All "Must NOT Have" items absent (no mem0 dependency, no multi-vault, no UI, etc.)
- [x] All unit tests pass (`bun test`)
- [x] Integration tests pass
- [ ] Plugin loads in Opencode without errors (requires user deployment)
- [x] Auto-recall fires on session.created
- [x] Auto-capture fires on session.idle
- [x] Rebuild command recreates index from markdown
- [x] OpenAI failure doesn't crash plugin
- [x] AGENTS repo skills updated and validated
