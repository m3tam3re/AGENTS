# Harness-Agnostic Agent Migration

## TL;DR

> **Quick Summary**: Migrate AGENTS repo from OpenCode-specific agents.json to a tool-agnostic canonical format (agent.toml + system-prompt.md per agent). Build Nix rendering pipeline in m3ta-nixpkgs that generates tool-specific configs for OpenCode, Claude Code, and Pi. Support system-level (home-manager) and project-level (flake.nix + direnv).
> 
> **Deliverables**:
> - 6 canonical agent definitions in AGENTS repo (TOML + Markdown)
> - 3 tool renderers in m3ta-nixpkgs (OpenCode, Claude Code, Pi)
> - Home-manager modules per tool replacing current opencode.nix
> - Project-level lib functions for flake.nix + direnv usage
> - Backward-compatible bridge during migration
> 
> **Estimated Effort**: Large
> **Parallel Execution**: YES — 4 waves
> **Critical Path**: TOML spike → canonical agents → lib/agents.nix → per-tool HM modules → golden file verification

---

## Context

### Original Request
Restructure AGENTS repo to be harness-agnostic so the same agent definitions, skills, prompts work across OpenCode, Claude Code, Codex, Pi, and future coding agents. Build corresponding Nix infrastructure in m3ta-nixpkgs for system-level and project-level consumption.

### Interview Summary
**Key Discussions**:
- YAML rejected for canonical format — TOML chosen (native `builtins.fromTOML`, no IFD)
- Renderers belong in m3ta-nixpkgs, not AGENTS repo (AGENTS stays pure data)
- OpenCode + Claude Code + Pi renderers now; Codex/Aider later on demand
- Two-level permission model: simple intent + optional rules array for glob patterns
- mkOpencodeRules renamed to mkCodingRules (backward-compat alias)
- All 6 agents migrated to canonical TOML format
- opencode.nix replaced by new per-tool modules (but non-agent OpenCode config kept separate)
- Verification: nix flake check + rendered OpenCode output must match golden file
- Project-level: lib functions returning derivations, usable via shellHook in devShells

**Research Findings**:
- **OpenCode**: Now supports file-based agents (`.opencode/agent/*.md` with YAML frontmatter) — modern path, avoids config.json embedding
- **Claude Code**: Subagents require `name` (kebab-case) + `description` as mandatory frontmatter fields
- **Pi**: No subagent concept. Uses AGENTS.md/CLAUDE.md for instructions, SYSTEM.md for prompt override, same SKILL.md format as OpenCode
- **Codex**: config.toml + AGENTS.md only, no agent definitions — single-agent tool
- **Aider**: .aider.conf.yml + read: lists, no agents/permissions/skills
- **TOML in Nix**: `builtins.fromTOML` supports TOML 1.0.0 strict. No datetime fields, no multi-line inline tables.

### Metis Review
**Identified Gaps** (addressed):
- **oh-my-opencode.json ownership**: Non-agent OpenCode config stays in slimmed opencode.nix (not in agents.nix)
- **Pi has no subagents**: Pi renderer produces AGENTS.md + SYSTEM.md from primary agent only. Subagents skipped.
- **Claude Code name format**: Renderer must slugify to `[a-z0-9-]+`
- **Model string formats differ**: Need mapping table (canonical → tool-specific)
- **OpenCode file-based agents**: Modern path via `.opencode/agent/*.md` preferred over config.json embedding
- **TOML feasibility risk**: Must test Chiron-Forge's 15+ bash glob patterns FIRST
- **Phase boundary enforced**: agents only (no skills/rules/MCP migration in this plan)
- **Backward-compat bridge**: `lib.agentsJson` in AGENTS repo produces old JSON during transition
- **Partial migration hazard**: Version check in nixpkgs to handle old AGENTS input gracefully

---

## Work Objectives

### Core Objective
Transform the AGENTS repository into a tool-agnostic data repository and build a Nix rendering pipeline that generates tool-specific configurations for multiple coding agents.

### Concrete Deliverables
- `AGENTS/agents/{chiron,chiron-forge,hermes,athena,apollo,calliope}/agent.toml` — 6 canonical agent definitions
- `AGENTS/agents/{name}/system-prompt.md` — 6 system prompts (byte-identical to current .txt files)
- `AGENTS/flake.nix` — Updated with `lib.loadAgents` and backward-compat `lib.agentsJson`
- `nixpkgs/lib/agents.nix` — `loadCanonical` + 3 renderer functions
- `nixpkgs/modules/home-manager/coding/agents/opencode.nix` — OpenCode HM sub-module
- `nixpkgs/modules/home-manager/coding/agents/claude-code.nix` — Claude Code HM sub-module
- `nixpkgs/modules/home-manager/coding/agents/pi.nix` — Pi HM sub-module
- `nixpkgs/modules/home-manager/coding/opencode.nix` — Slimmed (non-agent config only)
- `nixpkgs/lib/coding-rules.nix` — Renamed from opencode-rules.nix with backward-compat alias

### Definition of Done
- [ ] `nix flake check` passes on both repos
- [ ] Rendered OpenCode agent output is semantically equivalent to current agents.json (golden file diff = 0)
- [ ] All 6 agents parse successfully via `builtins.fromTOML`
- [ ] Claude Code renderer produces valid MD files with required frontmatter
- [ ] Pi renderer produces valid AGENTS.md + optional settings.json
- [ ] System prompt content is byte-identical to current .txt files
- [ ] `nix fmt` (alejandra) produces no changes
- [ ] `lib.mkOpencodeSkills` still works unchanged

### Must Have
- All 6 agents in canonical TOML format with system-prompt.md
- OpenCode renderer producing `.opencode/agent/*.md` file-based agents
- Claude Code renderer producing `.claude/agents/*.md` with valid YAML frontmatter
- Pi renderer producing AGENTS.md + SYSTEM.md from primary agent
- Per-machine model overrides via home-manager
- Backward-compatible bridge (`lib.agentsJson`) during transition
- Project-level `renderForTool` lib function for flake.nix + direnv

### Must NOT Have (Guardrails)
- No YAML files as canonical source (TOML only — no IFD)
- No renderer code in AGENTS repo (renderers live in nixpkgs)
- No Codex or Aider renderers (design for extensibility, implement only 3)
- No MCP configuration in agent.toml (MCP is tool-specific infrastructure)
- No prompt content changes during migration (byte-identical rename only)
- No skills/rules/context migration in this plan (separate concern)
- No `mkOpencodeSkills` changes (stays as-is)
- No datetime fields in TOML schema (requires experimental Nix flag)
- No multi-line inline tables in TOML (not supported by Nix's TOML 1.0.0)
- No generic permission translation DSL (each renderer hard-codes its own mapping)
- No monolithic home-manager module (separate sub-module per tool)

---

## Verification Strategy (MANDATORY)

> **ZERO HUMAN INTERVENTION** — ALL verification is agent-executed. No exceptions.

### Test Decision
- **Infrastructure exists**: YES — Nix evaluation + alejandra formatter
- **Automated tests**: Nix eval comparison (golden file diff)
- **Framework**: `nix eval`, `jq --sort-keys`, `diff`, `python3` for YAML validation

### QA Policy
Every task MUST include agent-executed QA scenarios.
Evidence saved to `.sisyphus/evidence/task-{N}-{scenario-slug}.{ext}`.

- **Nix evaluation**: Use Bash (nix eval) — Evaluate expressions, compare outputs
- **File validation**: Use Bash (python3/jq) — Parse YAML frontmatter, validate JSON
- **Content comparison**: Use Bash (diff) — Byte-identical prompt verification
- **Formatting**: Use Bash (alejandra --check) — No formatting drift

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately — foundation + spike):
├── Task 1: Capture golden file baseline [quick]
├── Task 2: TOML feasibility spike with Chiron-Forge [quick]
├── Task 3: Design canonical agent.toml schema [deep]
└── Task 4: Research OpenCode file-based agent frontmatter [quick]

Wave 2 (After Wave 1 — AGENTS repo migration):
├── Task 5: Create all 6 agent.toml + system-prompt.md files [unspecified-high]
├── Task 6: Update AGENTS flake.nix with loadAgents + agentsJson [deep]
├── Task 7: Create lib/agents.nix in nixpkgs with loadCanonical [deep]
└── Task 8: Verify backward-compat bridge produces golden file match [quick]

Wave 3 (After Wave 2 — renderers + HM modules, MAX PARALLEL):
├── Task 9: Implement OpenCode renderer in lib/agents.nix [deep]
├── Task 10: Implement Claude Code renderer in lib/agents.nix [deep]
├── Task 11: Implement Pi renderer in lib/agents.nix [unspecified-high]
├── Task 12: Create HM sub-module for OpenCode (agents/opencode.nix) [unspecified-high]
├── Task 13: Create HM sub-module for Claude Code (agents/claude-code.nix) [unspecified-high]
├── Task 14: Create HM sub-module for Pi (agents/pi.nix) [unspecified-high]
├── Task 15: Slim down existing opencode.nix to non-agent config only [quick]
└── Task 16: Rename mkOpencodeRules to mkCodingRules + backward-compat alias [quick]

Wave 4 (After Wave 3 — integration + project-level + cleanup):
├── Task 17: Add project-level renderForTool lib function [deep]
├── Task 18: Update nixpkgs flake.nix exports + aggregator imports [quick]
├── Task 19: Update AGENTS.md documentation [quick]
├── Task 20: Remove legacy agents.json + prompts/*.txt from AGENTS repo [quick]
└── Task 21: End-to-end integration test across both repos [unspecified-high]

Wave FINAL (After ALL tasks — 4 parallel reviews, then user okay):
├── Task F1: Plan compliance audit (oracle)
├── Task F2: Code quality review (unspecified-high)
├── Task F3: Real manual QA (unspecified-high)
└── Task F4: Scope fidelity check (deep)
-> Present results -> Get explicit user okay
```

### Dependency Matrix

| Task | Depends On | Blocks | Wave |
|------|-----------|--------|------|
| 1 | — | 8, 21 | 1 |
| 2 | — | 3, 5 | 1 |
| 3 | 2 | 5, 6, 7 | 1 |
| 4 | — | 9, 12 | 1 |
| 5 | 2, 3 | 6, 8, 9, 10, 11 | 2 |
| 6 | 3, 5 | 8, 17 | 2 |
| 7 | 3 | 9, 10, 11, 12, 13, 14, 17 | 2 |
| 8 | 1, 5, 6 | 20 | 2 |
| 9 | 4, 5, 7 | 12 | 3 |
| 10 | 5, 7 | 13 | 3 |
| 11 | 5, 7 | 14 | 3 |
| 12 | 9 | 18, 21 | 3 |
| 13 | 10 | 18, 21 | 3 |
| 14 | 11 | 18, 21 | 3 |
| 15 | — | 18 | 3 |
| 16 | — | 18 | 3 |
| 17 | 6, 7 | 21 | 4 |
| 18 | 12, 13, 14, 15, 16 | 21 | 4 |
| 19 | 5 | — | 4 |
| 20 | 8 | — | 4 |
| 21 | 1, 12, 13, 14, 17, 18 | F1-F4 | 4 |

### Agent Dispatch Summary

- **Wave 1**: **4** — T1 → `quick`, T2 → `quick`, T3 → `deep`, T4 → `quick`
- **Wave 2**: **4** — T5 → `unspecified-high`, T6 → `deep`, T7 → `deep`, T8 → `quick`
- **Wave 3**: **8** — T9 → `deep`, T10 → `deep`, T11 → `unspecified-high`, T12-T14 → `unspecified-high`, T15-T16 → `quick`
- **Wave 4**: **5** — T17 → `deep`, T18 → `quick`, T19 → `quick`, T20 → `quick`, T21 → `unspecified-high`
- **FINAL**: **4** — F1 → `oracle`, F2 → `unspecified-high`, F3 → `unspecified-high`, F4 → `deep`

---

## TODOs

- [x] 1. Capture Golden File Baseline

  **What to do**:
  - On the machine where home-manager is configured, capture the current rendered OpenCode agent config:
    ```bash
    nix eval --json '.#homeConfigurations.sk.config.programs.opencode.settings.agent' | jq --sort-keys . > /tmp/agents-golden.json
    ```
  - Also capture the raw agents.json for direct comparison:
    ```bash
    jq --sort-keys . /home/m3tam3re/p/AI/AGENTS/agents/agents.json > /tmp/agents-json-golden.json
    ```
  - Store both golden files in `.sisyphus/evidence/` for later use by other tasks
  - Note: If home-manager eval isn't available, use direct file comparison as fallback

  **Must NOT do**:
  - Modify any source files
  - Change agents.json content

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 2, 3, 4)
  - **Blocks**: Tasks 8, 21
  - **Blocked By**: None

  **References**:
  - `agents/agents.json` — Current source of truth (173 lines, 6 agents)
  - `modules/home-manager/coding/opencode.nix:148-149` in nixpkgs — Where agents.json gets embedded via `builtins.fromJSON (builtins.readFile ...)`

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Golden file captured and parseable
    Tool: Bash
    Preconditions: AGENTS repo at /home/m3tam3re/p/AI/AGENTS
    Steps:
      1. Run: jq --sort-keys . /home/m3tam3re/p/AI/AGENTS/agents/agents.json > .sisyphus/evidence/agents-golden.json
      2. Run: jq 'keys | length' .sisyphus/evidence/agents-golden.json
      3. Assert output is exactly "6" (6 agents)
      4. Run: jq 'keys' .sisyphus/evidence/agents-golden.json
      5. Assert output contains "Chiron (Assistant)", "Chiron Forge (Builder)", "Hermes (Communication)", "Athena (Researcher)", "Apollo (Knowledge Management)", "Calliope (Writer)"
    Expected Result: Golden file exists, contains 6 agents, valid JSON
    Failure Indicators: jq parse error, agent count != 6, missing agent names
    Evidence: .sisyphus/evidence/agents-golden.json
  ```

  **Commit**: NO (evidence only, no source changes)

---

- [x] 2. TOML Feasibility Spike — Chiron-Forge Permission Matrix

  **What to do**:
  - Write a test `agent.toml` for Chiron-Forge (the most complex agent — 2 primary modes, 15+ bash permission patterns with globs, wildcards, and special characters)
  - Test it parses correctly with `nix eval --expr 'builtins.fromTOML (builtins.readFile ./test.toml)'`
  - Specifically verify these tricky patterns parse in TOML strings:
    - `"rm -rf *"` (glob with spaces)
    - `"git reset --hard*"` (double-dash + glob)
    - `"git push --force*"` (double-dash + glob)
    - `"git push -f *"` (short flag + glob)
    - `"~/p/**"` (home dir + double glob)
    - `"/run/agenix/**"` (absolute path + double glob)
  - Test the two-level permission schema: simple intent + rules array
  - Write the test file to a temporary location, NOT in agents/ yet
  - If parsing FAILS: document exactly what fails and propose schema workaround

  **Must NOT do**:
  - Create permanent files in agents/ directory (this is a spike)
  - Modify flake.nix

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 3, 4)
  - **Blocks**: Tasks 3, 5
  - **Blocked By**: None

  **References**:
  - `agents/agents.json:40-68` — Chiron Forge's full permission matrix (the most complex agent)
  - `agents/agents.json:1-38` — Chiron's permission matrix (read-only agent with extensive bash allowlist)
  - Nix TOML docs: `builtins.fromTOML` supports TOML 1.0.0 strict (toml11 v4). No datetime, no multi-line inline tables.

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: TOML parses all permission patterns correctly
    Tool: Bash
    Preconditions: Nix available with builtins.fromTOML
    Steps:
      1. Write test agent.toml with Chiron-Forge's full permission set to /tmp/test-agent.toml
      2. Run: nix eval --expr 'builtins.fromTOML (builtins.readFile /tmp/test-agent.toml)' --json
      3. Pipe output to jq and verify:
         - .name == "chiron-forge"
         - .permissions.bash.intent == "allow"
         - .permissions.bash.rules | length >= 4 (deny rules)
         - .permissions.edit.intent == "allow"
         - .permissions.external_directory.rules | length >= 4
      4. Verify each deny pattern string is preserved exactly (no escaping issues)
    Expected Result: All fields parse, all glob patterns preserved, all special characters intact
    Failure Indicators: Nix eval error, missing fields, mangled glob patterns, escape issues
    Evidence: .sisyphus/evidence/task-2-toml-spike.json

  Scenario: TOML handles edge cases (empty rules, minimal agent)
    Tool: Bash
    Preconditions: Nix available
    Steps:
      1. Write minimal agent.toml with only name + description to /tmp/test-minimal.toml
      2. Run: nix eval --expr 'builtins.fromTOML (builtins.readFile /tmp/test-minimal.toml)' --json
      3. Assert parse succeeds with only required fields
    Expected Result: Minimal TOML parses without error
    Failure Indicators: Nix eval error on missing optional fields
    Evidence: .sisyphus/evidence/task-2-toml-minimal.json
  ```

  **Commit**: NO (spike only, temporary files)

---

- [x] 3. Design Canonical agent.toml Schema

  **What to do**:
  - Based on TOML spike results (Task 2) and research findings, define the final canonical schema
  - Create `agents/SCHEMA.md` documenting the canonical format with:
    - All required fields: `name` (string, kebab-case), `description` (string)
    - All optional fields: `mode`, `tags`, `max_turns`
    - Permission schema: `[permissions.TOOL]` tables with `intent` (allow/deny/ask) + `rules` (array of "pattern:action" strings)
    - Skill references: `skills` array of skill names
    - Context references: `context` array of file paths
    - Rule references: `rules` array of rule paths (e.g. "languages/nix")
    - NO `model` field (model is per-machine via home-manager)
    - NO `prompt` field (prompt lives in system-prompt.md, not in TOML)
    - NO MCP configuration (tool-specific)
    - NO datetime fields (Nix limitation)
  - Schema must be a SUPERSET: renderers silently drop fields they can't map
  - Document per-renderer field support matrix in SCHEMA.md

  **Must NOT do**:
  - Include model configuration (per-machine concern)
  - Include MCP server config (tool-specific infrastructure)
  - Include hooks (Claude Code exclusive, not canonical)
  - Use datetime TOML types
  - Use multi-line inline tables

  **Recommended Agent Profile**:
  - **Category**: `deep`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (but should incorporate Task 2 results if available)
  - **Parallel Group**: Wave 1 (with Tasks 1, 2, 4)
  - **Blocks**: Tasks 5, 6, 7
  - **Blocked By**: Task 2 (TOML feasibility must pass first)

  **References**:
  - Task 2's TOML spike results — Confirms which TOML patterns work
  - `agents/agents.json` — Current field set to preserve (all 6 agents)
  - Claude Code sub-agents docs — Required frontmatter fields: `name` (kebab-case), `description`
  - OpenCode agent schema — Supports: name, description, mode, model, temperature, top_p, steps, permission[], color, hidden, disable
  - Pi README — No agent schema. Uses AGENTS.md + SYSTEM.md + settings.json

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Schema document is complete and internally consistent
    Tool: Bash
    Preconditions: agents/SCHEMA.md created
    Steps:
      1. Read agents/SCHEMA.md
      2. Verify it documents: required fields, optional fields, permission schema, skill references, context references
      3. Verify it explicitly lists: fields NOT included (model, prompt, mcp, hooks, datetime)
      4. Verify it includes a per-renderer support matrix table
      5. Write a sample agent.toml following the schema and parse it with builtins.fromTOML
    Expected Result: Schema is complete, sample TOML parses successfully
    Failure Indicators: Missing field documentation, sample TOML fails to parse
    Evidence: .sisyphus/evidence/task-3-schema-sample.toml
  ```

  **Commit**: YES
  - Message: `docs: add canonical agent.toml schema definition`
  - Files: `agents/SCHEMA.md`
  - Pre-commit: `nix eval --expr 'builtins.fromTOML (builtins.readFile ./evidence-sample.toml)' --json`

---

- [x] 4. Research OpenCode File-Based Agent Frontmatter

  **What to do**:
  - Verify OpenCode's `.opencode/agent/*.md` file-based agent format by reading source code or docs
  - Document the exact YAML frontmatter fields supported:
    - Which fields map from canonical agent.toml?
    - What is the permission format in frontmatter?
    - How does `mode: primary | subagent | all` work?
    - What is the default behavior for omitted fields?
    - How does file-based agent discovery interact with config.json `agent` key?
  - Confirm that file-based agents DON'T require `home-manager switch` for prompt changes (key advantage over config.json embedding)
  - Save findings to `.sisyphus/evidence/task-4-opencode-agent-format.md`

  **Must NOT do**:
  - Modify any files
  - Create agent files yet (that's Task 5)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 2, 3)
  - **Blocks**: Tasks 9, 12
  - **Blocked By**: None

  **References**:
  - OpenCode GitHub: `github.com/sst/opencode` (or `anomalyco/opencode`) — search for agent loading logic
  - OpenCode docs on file-based agents: `.opencode/agent/*.md` with YAML frontmatter
  - Current opencode.nix:148 in nixpkgs — Shows config.json embedding approach (what we're moving away from)

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: OpenCode file-based agent format documented
    Tool: Bash
    Preconditions: Research complete
    Steps:
      1. Read .sisyphus/evidence/task-4-opencode-agent-format.md
      2. Verify it documents: supported frontmatter fields, permission format, mode values, default behaviors
      3. Verify it confirms or denies: file-based agents don't need home-manager switch
    Expected Result: Complete format documentation with concrete examples
    Failure Indicators: Missing field documentation, unresolved questions about discovery behavior
    Evidence: .sisyphus/evidence/task-4-opencode-agent-format.md
  ```

  **Commit**: NO (research only)

- [x] 5. Create All 6 agent.toml + system-prompt.md Files

  **What to do**:
  - For each of the 6 agents, create `agents/{name}/agent.toml` following the schema from Task 3
  - For each agent, copy (byte-identical!) the system prompt from `prompts/{name}.txt` to `agents/{name}/system-prompt.md`
  - Agent directories to create: `chiron`, `chiron-forge`, `hermes`, `athena`, `apollo`, `calliope`
  - Translate current JSON fields to TOML:
    - `"Chiron (Assistant)"` → `name = "chiron"`, `display_name = "Chiron (Assistant)"`
    - `"mode": "primary"` → `mode = "primary"`
    - `"description": "..."` → `description = "..."`
    - Permission objects → two-level `[permissions.TOOL]` tables
  - Translate OpenCode's nested bash permission objects:
    ```json
    "bash": { "*": "ask", "git status*": "allow", ... }
    ```
    Into TOML:
    ```toml
    [permissions.bash]
    intent = "ask"
    rules = ["git status*:allow", "git log*:allow", ...]
    ```
  - Translate external_directory permissions similarly
  - Skills, rules, context references per existing agent capabilities
  - Verify EVERY toml file parses with `builtins.fromTOML`

  **Must NOT do**:
  - Change prompt content (byte-identical copy only)
  - Include `model` field in agent.toml (per-machine concern)
  - Delete old agents.json or prompts/ yet (Task 20)
  - Add MCP config to agent.toml

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO (depends on schema from Task 3)
  - **Parallel Group**: Wave 2
  - **Blocks**: Tasks 6, 8, 9, 10, 11, 19
  - **Blocked By**: Tasks 2, 3

  **References**:
  - `agents/agents.json` — Source data for all 6 agents (173 lines)
  - `prompts/chiron.txt` through `prompts/calliope.txt` — System prompts to copy
  - `agents/SCHEMA.md` (from Task 3) — Canonical schema to follow
  - Task 2 results — Confirmed TOML parsing patterns

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: All 6 agent.toml files parse without error
    Tool: Bash
    Preconditions: All agents/*/agent.toml created
    Steps:
      1. for f in agents/*/agent.toml; do nix eval --expr "builtins.fromTOML (builtins.readFile ./$f)" --json > /dev/null && echo "OK: $f" || echo "FAIL: $f"; done
      2. Assert all 6 print "OK"
      3. Verify each has required fields: nix eval --expr '(builtins.fromTOML (builtins.readFile ./agents/chiron/agent.toml)).name' → "chiron"
    Expected Result: All 6 TOML files parse, all have name + description
    Failure Indicators: Any nix eval error, missing required fields
    Evidence: .sisyphus/evidence/task-5-toml-parse-all.txt

  Scenario: System prompts are byte-identical to originals
    Tool: Bash
    Preconditions: All agents/*/system-prompt.md created
    Steps:
      1. diff prompts/chiron.txt agents/chiron/system-prompt.md
      2. diff prompts/chiron-forge.txt agents/chiron-forge/system-prompt.md
      3. diff prompts/hermes.txt agents/hermes/system-prompt.md
      4. diff prompts/athena.txt agents/athena/system-prompt.md
      5. diff prompts/apollo.txt agents/apollo/system-prompt.md
      6. diff prompts/calliope.txt agents/calliope/system-prompt.md
      7. All diffs must exit with code 0 (no differences)
    Expected Result: Zero differences across all 6 files
    Failure Indicators: Any diff showing changes
    Evidence: .sisyphus/evidence/task-5-prompt-diff.txt

  Scenario: Permission patterns preserved exactly
    Tool: Bash
    Preconditions: agents/chiron-forge/agent.toml exists
    Steps:
      1. nix eval --expr '(builtins.fromTOML (builtins.readFile ./agents/chiron-forge/agent.toml)).permissions.bash.rules' --json
      2. Assert result contains: "rm -rf *:ask", "git reset --hard*:ask", "git push --force*:deny", "git push -f *:deny"
      3. nix eval --expr '(builtins.fromTOML (builtins.readFile ./agents/chiron/agent.toml)).permissions.bash.rules' --json
      4. Assert result contains at least 12 allow rules (git status*, git log*, etc.)
    Expected Result: All glob patterns preserved with correct actions
    Failure Indicators: Missing patterns, wrong action types, escaping issues
    Evidence: .sisyphus/evidence/task-5-permissions.json
  ```

  **Commit**: YES
  - Message: `feat: add canonical agent.toml definitions for all 6 agents`
  - Files: `agents/*/agent.toml`, `agents/*/system-prompt.md`
  - Pre-commit: `for f in agents/*/agent.toml; do nix eval --expr "builtins.fromTOML (builtins.readFile ./$f)" --json > /dev/null; done`

---

- [x] 6. Update AGENTS flake.nix with loadAgents + agentsJson Bridge

  **What to do**:
  - Add `lib.loadAgents` function to AGENTS repo's flake.nix:
    - Reads all `agents/*/agent.toml` via `builtins.fromTOML (builtins.readFile ...)`
    - Reads corresponding `system-prompt.md` via `builtins.readFile`
    - Returns an attrset: `{ chiron = { name; description; mode; permissions; ...; systemPrompt = "..."; }; ... }`
    - Discovery: reads `agents/` directory, filters for subdirs containing `agent.toml`
  - Add `lib.agentsJson` backward-compat bridge function:
    - Calls `loadAgents`, transforms back to current agents.json shape
    - Maps canonical permission format back to OpenCode's nested objects
    - Maps `systemPrompt` back to `"prompt": "{file:./prompts/chiron.txt}"` format (or inline)
    - Adds `model` field from a configurable default (since agent.toml has no model)
  - Keep ALL existing exports unchanged: `lib.mkOpencodeSkills`, `packages.skills-runtime`, `devShells.default`
  - `lib` export must be system-independent (no `forAllSystems` wrapper — pure functions)

  **Must NOT do**:
  - Change mkOpencodeSkills
  - Remove any existing exports
  - Add renderer logic (that goes in nixpkgs)
  - Hardcode machine-specific model assignments

  **Recommended Agent Profile**:
  - **Category**: `deep`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Task 7)
  - **Parallel Group**: Wave 2
  - **Blocks**: Tasks 8, 17
  - **Blocked By**: Tasks 3, 5

  **References**:
  - `flake.nix` — Current AGENTS flake (188 lines). Keep structure, add to `lib` section.
  - `flake.nix:52-123` — `lib.mkOpencodeSkills` pattern (linkFarm approach)
  - `agents/agents.json` — Target output shape for agentsJson bridge function
  - `agents/SCHEMA.md` (from Task 3) — Canonical schema definition

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: loadAgents returns all 6 agents with correct structure
    Tool: Bash
    Preconditions: Task 5 complete, flake.nix updated
    Steps:
      1. nix eval --json '.#lib.loadAgents' | jq 'keys | length'
      2. Assert output is 6
      3. nix eval --json '.#lib.loadAgents' | jq '.chiron.name'
      4. Assert output is "chiron"
      5. nix eval --json '.#lib.loadAgents' | jq '.["chiron-forge"].permissions.bash.intent'
      6. Assert output is "allow"
    Expected Result: 6 agents loaded, all fields present
    Failure Indicators: Eval error, wrong agent count, missing fields
    Evidence: .sisyphus/evidence/task-6-loadagents.json

  Scenario: agentsJson bridge matches golden file
    Tool: Bash
    Preconditions: Golden file from Task 1 available
    Steps:
      1. nix eval --json '.#lib.agentsJson' | jq --sort-keys . > /tmp/agents-bridge-output.json
      2. diff /tmp/agents-bridge-output.json .sisyphus/evidence/agents-golden.json
      3. Exit code must be 0
    Expected Result: Bridge output is semantically identical to original agents.json
    Failure Indicators: Any diff (key ordering differences are OK if using jq --sort-keys)
    Evidence: .sisyphus/evidence/task-6-bridge-diff.txt
  ```

  **Commit**: YES
  - Message: `feat: export loadAgents and backward-compat agentsJson from flake`
  - Files: `flake.nix`
  - Pre-commit: `nix flake check && nix eval --json '.#lib.loadAgents' > /dev/null`

---

- [x] 7. Create lib/agents.nix in nixpkgs with loadCanonical

  **What to do**:
  - Create `/home/m3tam3re/p/NIX/nixpkgs/lib/agents.nix` with:
    - `loadCanonical { agentsInput }` — reads canonical agents from the AGENTS flake input
      - Calls `agentsInput.lib.loadAgents` (from Task 6) to get canonical attrset
      - Returns the canonical attrset (or wraps/validates it)
    - Stub functions for renderers (to be implemented in Tasks 9-11):
      - `renderForOpencode { canonical; modelOverrides ? {}; }` → derivation placeholder
      - `renderForClaudeCode { canonical; modelOverrides ? {}; }` → derivation placeholder  
      - `renderForPi { canonical; }` → derivation placeholder
      - `renderForTool { agentsInput; tool; modelOverrides ? {}; }` → dispatcher
  - Wire into `lib/default.nix` alongside existing `ports` and `opencode-rules`
  - Follow existing lib patterns: `{lib}: { ... }` function signature

  **Must NOT do**:
  - Implement actual renderers yet (stubs only — Tasks 9-11)
  - Import pkgs at lib level (renderers need pkgs, but the interface should accept it as argument)
  - Modify existing lib functions

  **Recommended Agent Profile**:
  - **Category**: `deep`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Task 6)
  - **Parallel Group**: Wave 2
  - **Blocks**: Tasks 9, 10, 11, 12, 13, 14, 17
  - **Blocked By**: Task 3

  **References**:
  - `lib/default.nix` in nixpkgs — Current lib exports (ports, opencode-rules). Add agents here.
  - `lib/opencode-rules.nix` in nixpkgs — Pattern reference for lib function structure (116 lines)
  - Task 3 SCHEMA.md — Defines the canonical attrset shape

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: lib/agents.nix loads and stub functions exist
    Tool: Bash
    Preconditions: lib/agents.nix created, lib/default.nix updated
    Steps:
      1. nix eval --expr '(import ./lib { lib = (import <nixpkgs> {}).lib; }).agents' --json
      2. Assert result contains keys: loadCanonical, renderForOpencode, renderForClaudeCode, renderForPi, renderForTool
      3. nix flake check /home/m3tam3re/p/NIX/nixpkgs
      4. Assert exit code 0
    Expected Result: All stub functions exist, flake check passes
    Failure Indicators: Import error, missing function names, flake check failure
    Evidence: .sisyphus/evidence/task-7-lib-agents.json
  ```

  **Commit**: YES
  - Message: `feat(lib): add agents.nix with loadCanonical and renderer stubs`
  - Files: `lib/agents.nix`, `lib/default.nix`
  - Pre-commit: `nix flake check`

---

- [x] 8. Verify Backward-Compat Bridge Produces Golden File Match

  **What to do**:
  - With Tasks 1, 5, 6 complete, run the full backward-compat verification:
    ```bash
    nix eval --json '.#lib.agentsJson' | jq --sort-keys . > /tmp/bridge-output.json
    diff /tmp/bridge-output.json .sisyphus/evidence/agents-golden.json
    ```
  - If diff shows differences, debug and fix in Task 6's `agentsJson` function
  - This is a GATE: do NOT proceed to Wave 3 until this passes
  - Document any semantic differences that are acceptable (e.g., key ordering)

  **Must NOT do**:
  - Modify the golden file
  - Accept content differences as "close enough"

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO (gate task)
  - **Parallel Group**: Wave 2 (runs last in wave)
  - **Blocks**: Task 20
  - **Blocked By**: Tasks 1, 5, 6

  **References**:
  - `.sisyphus/evidence/agents-golden.json` — Golden file from Task 1
  - Task 6's `lib.agentsJson` — Bridge function to verify

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Bridge output matches golden file exactly
    Tool: Bash
    Preconditions: Tasks 1, 5, 6 complete
    Steps:
      1. cd /home/m3tam3re/p/AI/AGENTS
      2. nix eval --json '.#lib.agentsJson' | jq --sort-keys . > /tmp/bridge-verify.json
      3. diff /tmp/bridge-verify.json .sisyphus/evidence/agents-golden.json
      4. Assert exit code 0 (zero differences)
    Expected Result: Byte-identical output after jq normalization
    Failure Indicators: Any diff output, non-zero exit code
    Evidence: .sisyphus/evidence/task-8-bridge-verify.txt
  ```

  **Commit**: NO (verification only)

- [x] 9. Implement OpenCode Renderer in lib/agents.nix

  **What to do**:
  - Replace the `renderForOpencode` stub in `lib/agents.nix` with full implementation
  - Renderer produces a derivation containing `.opencode/agent/*.md` files (file-based agents)
  - For each agent in canonical attrset, generate a markdown file with YAML frontmatter:
    - `name`: from canonical `name`
    - `description`: from canonical `description`
    - `mode`: from canonical `mode` (primary/subagent) — MUST set explicitly (OpenCode defaults to "all")
    - `model`: from `modelOverrides.{name}` if present, otherwise omit (let OpenCode use its default)
    - `permission`: translate canonical two-level permissions to OpenCode's rule array format:
      ```yaml
      permission:
        - permission: bash
          pattern: "git status*"
          action: allow
        - permission: bash
          pattern: "*"
          action: ask
      ```
    - `steps`: from canonical `max_turns` if present
  - Body of markdown = content of `system-prompt.md`
  - Use `pkgs.writeText` or `pkgs.runCommand` to generate each file, then `pkgs.linkFarm` or `pkgs.symlinkJoin` to combine
  - Handle edge case: agent with no permission rules (omit permission key entirely)

  **Must NOT do**:
  - Embed agents in config.json (use file-based agent path)
  - Include oh-my-opencode.json or plugin config (that stays in opencode.nix)
  - Hard-code model values

  **Recommended Agent Profile**:
  - **Category**: `deep`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Tasks 10, 11, 15, 16)
  - **Parallel Group**: Wave 3
  - **Blocks**: Task 12
  - **Blocked By**: Tasks 4, 5, 7

  **References**:
  - Task 4 evidence — OpenCode file-based agent frontmatter format
  - `agents/agents.json` — Current permission format (for output comparison)
  - `lib/agents.nix` stubs from Task 7 — Replace renderForOpencode
  - OpenCode source: agent file discovery logic

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Rendered OpenCode agents have correct frontmatter
    Tool: Bash
    Preconditions: Renderer implemented, AGENTS repo with canonical agents
    Steps:
      1. Build rendered output: nix eval --raw '.#lib.x86_64-linux.agents.renderForOpencode { canonical = inputs.agents.lib.loadAgents; }'
      2. List files in rendered output: expect 6 .md files
      3. For chiron.md: extract YAML frontmatter, verify name="chiron", mode="primary", description present
      4. For chiron-forge.md: verify permission rules contain bash deny patterns for "rm -rf *", "git push --force*"
      5. For hermes.md: verify mode="subagent"
    Expected Result: 6 agent files, correct frontmatter, correct permissions
    Failure Indicators: Missing files, wrong mode, missing permissions
    Evidence: .sisyphus/evidence/task-9-opencode-render.txt

  Scenario: System prompts appear as markdown body
    Tool: Bash
    Preconditions: Rendered output available
    Steps:
      1. Extract body (after frontmatter) from rendered chiron.md
      2. Compare with agents/chiron/system-prompt.md
      3. Assert byte-identical
    Expected Result: Prompt content unchanged through rendering
    Failure Indicators: Any content difference
    Evidence: .sisyphus/evidence/task-9-prompt-body.txt
  ```

  **Commit**: YES (groups with N1)
  - Message: `feat(lib): implement OpenCode renderer in agents.nix`
  - Files: `lib/agents.nix`
  - Pre-commit: `nix flake check`

---

- [ ] 10. Implement Claude Code Renderer in lib/agents.nix

  **What to do**:
  - Replace `renderForClaudeCode` stub with full implementation
  - Renderer produces a derivation containing `.claude/agents/*.md` files AND `.claude/settings.json` fragment
  - For each agent, generate markdown with YAML frontmatter:
    - `name`: slugify canonical name to `[a-z0-9-]+` (e.g., "chiron-forge" stays, "Chiron" → "chiron")
    - `description`: from canonical `description` (REQUIRED by Claude Code)
    - `model`: from `modelOverrides.{name}` → map to Claude Code alias (sonnet/opus/haiku) or full ID
    - `tools`: from canonical permissions — collect tool names where intent=allow into allowlist
    - `disallowedTools`: from canonical permissions — collect tool names where intent=deny
    - `permissionMode`: default to "default" unless canonical specifies
    - `maxTurns`: from canonical `max_turns`
    - `skills`: from canonical `skills` array
  - Generate `.claude/settings.json` with permission rules translated to Claude Code DSL:
    - Canonical `bash: { rules: ["git push*:deny"] }` → `permissions.deny: ["Bash(git push*)"]`
    - Canonical `edit: { intent: "allow" }` → `permissions.allow: ["Edit"]`
  - Body of markdown = content of `system-prompt.md`
  - Handle subagent-only agents: Claude Code agents are always subagents (no "primary" mode)

  **Must NOT do**:
  - Include MCP server config in settings.json
  - Include hooks (Claude Code exclusive concept, not in canonical)
  - Use non-kebab-case names (Claude Code requires [a-z0-9-]+)

  **Recommended Agent Profile**:
  - **Category**: `deep`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Tasks 9, 11, 15, 16)
  - **Parallel Group**: Wave 3
  - **Blocks**: Task 13
  - **Blocked By**: Tasks 5, 7

  **References**:
  - Claude Code sub-agents docs (indexed) — Frontmatter fields, tool names, permission syntax
  - Claude Code settings docs (indexed) — Permission rule DSL: `"Bash(git diff *)"`, `"Read(./.env)"`
  - `lib/agents.nix` stubs from Task 7
  - Claude Code tool names: `Bash`, `Read`, `Edit`, `Write`, `Glob`, `Grep`, `WebFetch`, `Agent(type)`, `MCP(server::tool)`

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: All Claude Code agent files have valid YAML frontmatter
    Tool: Bash
    Preconditions: Renderer implemented
    Steps:
      1. Build rendered output for claude-code
      2. For each .md file in .claude/agents/:
         python3 -c "
         import yaml, sys
         content = open(sys.argv[1]).read()
         parts = content.split('---', 2)
         fm = yaml.safe_load(parts[1])
         assert 'name' in fm, 'Missing name'
         assert 'description' in fm, 'Missing description'
         assert fm['name'].replace('-','').isalnum(), f'Invalid name: {fm[\"name\"]}'
         print(f'OK: {fm[\"name\"]}')
         " file.md
      3. Assert all 6 files pass
    Expected Result: All frontmatter valid, names in kebab-case
    Failure Indicators: YAML parse error, missing required fields, invalid name format
    Evidence: .sisyphus/evidence/task-10-claude-frontmatter.txt

  Scenario: Permission DSL correctly translated
    Tool: Bash
    Preconditions: Rendered .claude/settings.json exists
    Steps:
      1. Read rendered .claude/settings.json
      2. Verify permissions.deny contains patterns like "Bash(rm -rf *)" for chiron-forge deny rules
      3. Verify permissions.allow contains patterns like "Bash(git status*)" for chiron allow rules
    Expected Result: Permission rules correctly translated to Claude Code DSL
    Failure Indicators: Missing rules, wrong DSL format, lost patterns
    Evidence: .sisyphus/evidence/task-10-claude-permissions.json
  ```

  **Commit**: YES (groups with N1)
  - Message: `feat(lib): implement Claude Code renderer in agents.nix`
  - Files: `lib/agents.nix`
  - Pre-commit: `nix flake check`

---

- [ ] 11. Implement Pi Renderer in lib/agents.nix

  **What to do**:
  - Replace `renderForPi` stub with full implementation
  - Pi has NO subagent concept — renderer produces DIFFERENT outputs than OpenCode/Claude Code:
    - `AGENTS.md` — Concatenation of all agent descriptions + primary agent's instructions
    - `~/.pi/agent/SYSTEM.md` or `.pi/SYSTEM.md` — Primary agent's system prompt (replaces Pi's default prompt)
    - `.pi/settings.json` fragment — Optional: tools list, model config
    - Skill symlinks — Pi uses same SKILL.md dirs at `~/.pi/agent/skills/` or `.agents/skills/`
  - Only PRIMARY agents render to SYSTEM.md. Subagent prompts get embedded as sections in AGENTS.md.
  - Generate AGENTS.md with sections per agent:
    ```markdown
    # Agent Instructions
    
    ## Chiron (Assistant)
    Primary assistant for read-only analysis...
    
    ## Available Specialists
    - Hermes: Work communication (Basecamp, Outlook, Teams)
    - Athena: Work knowledge (Outline wiki)
    ...
    ```
  - Pi's tools config: `--tools read,bash,edit,write` maps from canonical permissions
  - Handle: Pi has no permission granularity — only tool enable/disable

  **Must NOT do**:
  - Create agent files (Pi doesn't have them)
  - Try to render subagents as separate entities
  - Include MCP config (Pi uses extensions instead)
  - Create TS extensions (out of scope)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Tasks 9, 10, 15, 16)
  - **Parallel Group**: Wave 3
  - **Blocks**: Task 14
  - **Blocked By**: Tasks 5, 7

  **References**:
  - Pi README (indexed) — AGENTS.md loaded at startup, SYSTEM.md replaces default prompt, APPEND_SYSTEM.md appends
  - Pi README skills section — `~/.pi/agent/skills/`, `.pi/skills/`, `~/.agents/skills/`, `.agents/skills/`
  - Pi README settings — `~/.pi/agent/settings.json` (global), `.pi/settings.json` (project)
  - Pi README tools — `--tools read,bash,edit,write` (default built-in tools)

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Pi renderer produces valid AGENTS.md
    Tool: Bash
    Preconditions: Renderer implemented
    Steps:
      1. Build rendered output for pi
      2. Assert AGENTS.md exists in output
      3. Assert AGENTS.md contains "Chiron" and agent descriptions
      4. Assert AGENTS.md contains specialist listing
      5. Verify AGENTS.md is valid Markdown (no TOML/JSON artifacts)
    Expected Result: AGENTS.md exists with readable agent instructions
    Failure Indicators: File missing, contains raw TOML/JSON, empty content
    Evidence: .sisyphus/evidence/task-11-pi-agents-md.txt

  Scenario: Pi renderer produces valid SYSTEM.md from primary agent
    Tool: Bash
    Preconditions: Rendered output available
    Steps:
      1. Assert SYSTEM.md or .pi/SYSTEM.md exists in output
      2. Content should be the primary agent's system prompt
      3. Verify it matches agents/chiron/system-prompt.md content
    Expected Result: SYSTEM.md exists with primary agent's prompt
    Failure Indicators: Missing file, wrong content, subagent prompt instead
    Evidence: .sisyphus/evidence/task-11-pi-system-md.txt
  ```

  **Commit**: YES (groups with N1)
  - Message: `feat(lib): implement Pi renderer in agents.nix`
  - Files: `lib/agents.nix`
  - Pre-commit: `nix flake check`

---

- [ ] 12. Create HM Sub-Module for OpenCode (agents/opencode.nix)

  **What to do**:
  - Create `modules/home-manager/coding/agents/opencode.nix` in nixpkgs
  - Options under `coding.agents.opencode`:
    - `enable` — mkEnableOption
    - `agentsInput` — flake input pointing to AGENTS repo
    - `modelOverrides` — attrset mapping agent name → model string (e.g., `{ chiron = "anthropic/claude-sonnet-4"; }`)
  - Config (mkIf enabled):
    - Call `lib.agents.renderForOpencode { canonical; modelOverrides; }` to get rendered derivation
    - Symlink rendered `.opencode/agent/` dir via `xdg.configFile` or `home.file`
    - Symlink skills via existing `mkOpencodeSkills` (if agentsInput set)
    - Symlink context/ and commands/ from AGENTS input
  - Create `modules/home-manager/coding/agents/default.nix` aggregator importing opencode.nix, claude-code.nix, pi.nix
  - Update `modules/home-manager/coding/default.nix` to import `./agents` subdir

  **Must NOT do**:
  - Handle oh-my-opencode.json, plugins, formatters (stays in slimmed opencode.nix)
  - Embed agents in config.json (use file-based agents)
  - Include MCP config

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO (depends on Task 9)
  - **Parallel Group**: Wave 3 (after Task 9)
  - **Blocks**: Tasks 18, 21
  - **Blocked By**: Task 9

  **References**:
  - `modules/home-manager/coding/opencode.nix` in nixpkgs — Current module to learn from (168 lines)
  - Task 9's renderer — Produces the derivation this module consumes
  - `modules/home-manager/AGENTS.md` in nixpkgs — Module conventions doc

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Module options type-check
    Tool: Bash
    Preconditions: Module created
    Steps:
      1. nix flake check /home/m3tam3re/p/NIX/nixpkgs
      2. Assert exit code 0 (no type errors in module options)
    Expected Result: Flake check passes
    Failure Indicators: Type error in options, missing import
    Evidence: .sisyphus/evidence/task-12-flake-check.txt
  ```

  **Commit**: YES (groups with N2)
  - Message: `feat(hm): add OpenCode agent sub-module`
  - Files: `modules/home-manager/coding/agents/opencode.nix`, `modules/home-manager/coding/agents/default.nix`
  - Pre-commit: `nix flake check`

---

- [ ] 13. Create HM Sub-Module for Claude Code (agents/claude-code.nix)

  **What to do**:
  - Create `modules/home-manager/coding/agents/claude-code.nix` in nixpkgs
  - Options under `coding.agents.claude-code`:
    - `enable` — mkEnableOption
    - `agentsInput` — flake input pointing to AGENTS repo
    - `modelOverrides` — attrset mapping agent name → model alias or ID
  - Config (mkIf enabled):
    - Call `lib.agents.renderForClaudeCode { canonical; modelOverrides; }` to get rendered derivation
    - Symlink rendered `.claude/agents/` via `home.file`
    - Generate `.claude/settings.json` with rendered permission rules
    - Symlink skills from AGENTS repo to `~/.claude/skills/` (if skills exist)
  - Handle: Claude Code's `CLAUDE.md` — optionally generate from agent instructions

  **Must NOT do**:
  - Manage Claude Code's MCP config (.claude.json)
  - Configure Claude Code API keys or auth
  - Include hooks in settings.json

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO (depends on Task 10)
  - **Parallel Group**: Wave 3 (after Task 10)
  - **Blocks**: Tasks 18, 21
  - **Blocked By**: Task 10

  **References**:
  - Claude Code settings docs (indexed) — `.claude/` directory structure, settings.json scopes
  - Task 10's renderer — Produces the derivation this module consumes

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Module type-checks and creates expected file paths
    Tool: Bash
    Preconditions: Module created
    Steps:
      1. nix flake check /home/m3tam3re/p/NIX/nixpkgs
      2. Assert exit code 0
    Expected Result: Flake check passes
    Failure Indicators: Type error, missing import
    Evidence: .sisyphus/evidence/task-13-flake-check.txt
  ```

  **Commit**: YES (groups with N2)
  - Message: `feat(hm): add Claude Code agent sub-module`
  - Files: `modules/home-manager/coding/agents/claude-code.nix`
  - Pre-commit: `nix flake check`

---

- [ ] 14. Create HM Sub-Module for Pi (agents/pi.nix)

  **What to do**:
  - Create `modules/home-manager/coding/agents/pi.nix` in nixpkgs
  - Options under `coding.agents.pi`:
    - `enable` — mkEnableOption
    - `agentsInput` — flake input pointing to AGENTS repo
  - Config (mkIf enabled):
    - Call `lib.agents.renderForPi { canonical; }` to get rendered derivation
    - Place AGENTS.md at `~/.pi/agent/AGENTS.md` via `home.file`
    - Place SYSTEM.md at `~/.pi/agent/SYSTEM.md` via `home.file`
    - Symlink skills from AGENTS repo to `~/.pi/agent/skills/`
    - Optionally symlink prompts from AGENTS repo to `~/.pi/agent/prompts/` (Pi's prompt templates)

  **Must NOT do**:
  - Create fake agent files (Pi has no subagents)
  - Configure Pi extensions (TypeScript, out of scope)
  - Manage Pi's package system

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO (depends on Task 11)
  - **Parallel Group**: Wave 3 (after Task 11)
  - **Blocks**: Tasks 18, 21
  - **Blocked By**: Task 11

  **References**:
  - Pi README (indexed) — `~/.pi/agent/` directory structure, skill paths, prompt template paths
  - Task 11's renderer — Produces the derivation this module consumes

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Module type-checks
    Tool: Bash
    Preconditions: Module created
    Steps:
      1. nix flake check /home/m3tam3re/p/NIX/nixpkgs
      2. Assert exit code 0
    Expected Result: Flake check passes
    Failure Indicators: Type error, missing import
    Evidence: .sisyphus/evidence/task-14-flake-check.txt
  ```

  **Commit**: YES (groups with N2)
  - Message: `feat(hm): add Pi agent sub-module`
  - Files: `modules/home-manager/coding/agents/pi.nix`
  - Pre-commit: `nix flake check`

---

- [ ] 15. Slim Down opencode.nix to Non-Agent Config Only

  **What to do**:
  - Edit existing `modules/home-manager/coding/opencode.nix` in nixpkgs
  - REMOVE: `agentsInput` option (moved to agents/opencode.nix)
  - REMOVE: `externalSkills` option (moved to agents/opencode.nix)
  - REMOVE: Skills linkFarm generation (moved to agents/opencode.nix)
  - REMOVE: Context/commands/prompts symlinks (moved to agents/opencode.nix)
  - REMOVE: agents.json embedding (`builtins.fromJSON (builtins.readFile ...)`) (replaced by file-based agents)
  - KEEP: `programs.opencode.enable` + `enableMcpIntegration`
  - KEEP: `programs.opencode.settings` with theme, formatter, plugin array
  - KEEP: `ohMyOpencodeSettings` → `oh-my-opencode.json` generation
  - KEEP: `extraSettings` for provider/machine-specific config
  - KEEP: `extraPlugins`
  - Result: opencode.nix handles ONLY tool-specific, non-agent config

  **Must NOT do**:
  - Delete opencode.nix entirely (it still handles non-agent concerns)
  - Move oh-my-opencode.json to agents module
  - Change option names that other configs depend on (check consumers first)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Tasks 9-14, 16)
  - **Parallel Group**: Wave 3
  - **Blocks**: Task 18
  - **Blocked By**: None (but coordinate with Task 12 for import order)

  **References**:
  - `modules/home-manager/coding/opencode.nix` in nixpkgs — Current module (168 lines, will shrink to ~70)
  - Task 12 — New agents/opencode.nix takes over agent concerns

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Slimmed opencode.nix still manages non-agent config
    Tool: Bash
    Preconditions: opencode.nix edited
    Steps:
      1. Verify opencode.nix still has: ohMyOpencodeSettings, extraSettings, extraPlugins options
      2. Verify opencode.nix does NOT have: agentsInput, externalSkills options
      3. nix flake check /home/m3tam3re/p/NIX/nixpkgs
      4. Assert exit code 0
    Expected Result: Module compiles, non-agent options preserved, agent options removed
    Failure Indicators: Missing options that should stay, leftover agent options
    Evidence: .sisyphus/evidence/task-15-opencode-slim.txt
  ```

  **Commit**: YES (groups with N3)
  - Message: `refactor(hm): slim opencode.nix to non-agent config only`
  - Files: `modules/home-manager/coding/opencode.nix`
  - Pre-commit: `nix flake check`

---

- [ ] 16. Rename mkOpencodeRules to mkCodingRules with Backward-Compat Alias

  **What to do**:
  - In `lib/opencode-rules.nix`: rename the main function to `mkCodingRules`
  - Add backward-compat alias: `mkOpencodeRules = builtins.trace "m3ta-nixpkgs: mkOpencodeRules is deprecated, use mkCodingRules" mkCodingRules;`
  - Rename file: `lib/opencode-rules.nix` → `lib/coding-rules.nix`
  - Update `lib/default.nix`: expose both `coding-rules.mkCodingRules` and `opencode-rules.mkOpencodeRules` (alias)
  - For now, the function body stays identical — tool-agnostic rule rendering is a future enhancement

  **Must NOT do**:
  - Change the function's behavior or output
  - Remove the old name entirely (backward compat)
  - Add multi-tool rendering logic yet

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Tasks 9-15)
  - **Parallel Group**: Wave 3
  - **Blocks**: Task 18
  - **Blocked By**: None

  **References**:
  - `lib/opencode-rules.nix` in nixpkgs — Current file (116 lines)
  - `lib/default.nix` in nixpkgs — Current exports

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Both old and new names work
    Tool: Bash
    Preconditions: Rename complete
    Steps:
      1. nix eval --expr '(import ./lib { lib = (import <nixpkgs> {}).lib; }).coding-rules.mkCodingRules' --json
      2. Assert function exists (no error)
      3. nix eval --expr '(import ./lib { lib = (import <nixpkgs> {}).lib; }).opencode-rules.mkOpencodeRules' --json
      4. Assert function exists (backward compat, may show deprecation trace)
    Expected Result: Both names resolve to the same function
    Failure Indicators: Either name fails, function behavior changed
    Evidence: .sisyphus/evidence/task-16-rules-rename.txt
  ```

  **Commit**: YES (groups with N5)
  - Message: `refactor(lib): rename mkOpencodeRules to mkCodingRules with compat alias`
  - Files: `lib/coding-rules.nix`, `lib/default.nix`
  - Pre-commit: `nix flake check`

- [ ] 17. Add Project-Level renderForTool Lib Function

  **What to do**:
  - Implement `renderForTool` dispatcher in `lib/agents.nix`:
    ```nix
    renderForTool = { pkgs, agentsInput, tool, modelOverrides ? {} }:
      let
        canonical = agentsInput.lib.loadAgents;
        renderers = {
          opencode = renderForOpencode { inherit pkgs canonical modelOverrides; };
          claude-code = renderForClaudeCode { inherit pkgs canonical modelOverrides; };
          pi = renderForPi { inherit pkgs canonical; };
        };
      in renderers.${tool} or (throw "Unknown tool: ${tool}");
    ```
  - Add `shellHookForTool` helper that generates a shellHook placing rendered files in project dir:
    - For OpenCode: symlinks `.opencode/agent/` → rendered derivation
    - For Claude Code: symlinks `.claude/agents/` and `.claude/settings.json` → rendered
    - For Pi: symlinks `.pi/SYSTEM.md` and `AGENTS.md` → rendered
    - All shellHooks add appropriate entries to `.gitignore` if not already present
  - Export via `lib.agents.renderForTool` and `lib.agents.shellHookForTool`
  - Usage in project flake.nix:
    ```nix
    devShells.default = pkgs.mkShell {
      shellHook = m3taLib.agents.shellHookForTool {
        inherit pkgs;
        agentsInput = inputs.agents;
        tool = "opencode";
        modelOverrides = { chiron = "anthropic/claude-sonnet-4"; };
      };
    };
    ```

  **Must NOT do**:
  - Write files imperatively (use symlinks to Nix store paths)
  - Assume tool from environment (require explicit `tool` argument)

  **Recommended Agent Profile**:
  - **Category**: `deep`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 4
  - **Blocks**: Task 21
  - **Blocked By**: Tasks 6, 7 (and implicitly 9-11)

  **References**:
  - `lib/opencode-rules.nix:106-114` in nixpkgs — shellHook pattern reference (ln -sfn + cat > file)
  - Task 9-11 renderers — Functions this dispatcher calls

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: renderForTool dispatches correctly
    Tool: Bash
    Preconditions: All renderers implemented
    Steps:
      1. nix eval --raw '.#lib.x86_64-linux.agents.renderForTool { pkgs = import <nixpkgs> {}; agentsInput = inputs.agents; tool = "opencode"; }'
      2. Assert output is a valid store path
      3. List contents — expect .opencode/agent/*.md files
      4. Repeat for tool = "claude-code" — expect .claude/agents/*.md
      5. Repeat for tool = "pi" — expect AGENTS.md + SYSTEM.md
    Expected Result: Each tool produces correct output structure
    Failure Indicators: Eval error, wrong output structure, unknown tool error
    Evidence: .sisyphus/evidence/task-17-renderForTool.txt
  ```

  **Commit**: YES (groups with N4)
  - Message: `feat(lib): add project-level renderForTool function`
  - Files: `lib/agents.nix`
  - Pre-commit: `nix flake check`

---

- [ ] 18. Update nixpkgs flake.nix Exports + Aggregator Imports

  **What to do**:
  - Update `modules/home-manager/coding/default.nix` to import `./agents` subdir:
    ```nix
    imports = [
      ./editors.nix
      ./opencode.nix
      ./agents
    ];
    ```
  - Update `flake.nix` homeManagerModules exports:
    - Keep: `default`, `ports`, `zellij-ps`
    - Keep: `opencode` (slimmed version)
    - Add: `agents` pointing to `./modules/home-manager/coding/agents`
    - Remove or deprecate old `opencode` if fully replaced
  - Update `lib/default.nix` to export agents module:
    ```nix
    agents = import ./agents.nix { inherit lib; };
    coding-rules = import ./coding-rules.nix { inherit lib; };
    opencode-rules = import ./coding-rules.nix { inherit lib; }; # backward compat
    ```
  - Run `nix fmt` (alejandra) on all changed files
  - Run `nix flake check`

  **Must NOT do**:
  - Remove `opencode` export without backward compat
  - Change export names that external configs depend on

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO (depends on all Wave 3 tasks)
  - **Parallel Group**: Wave 4
  - **Blocks**: Task 21
  - **Blocked By**: Tasks 12, 13, 14, 15, 16

  **References**:
  - `flake.nix` in nixpkgs — Current exports (lines 78-83)
  - `modules/home-manager/coding/default.nix` — Current aggregator
  - `lib/default.nix` — Current lib exports

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: All exports resolve without error
    Tool: Bash
    Preconditions: All modules and lib functions created
    Steps:
      1. nix flake check /home/m3tam3re/p/NIX/nixpkgs
      2. nix eval '.#homeManagerModules' --json | jq 'keys'
      3. Assert keys include: "default", "opencode", "agents", "ports", "zellij-ps"
      4. nix fmt --check /home/m3tam3re/p/NIX/nixpkgs
      5. Assert no formatting changes needed
    Expected Result: All exports work, formatting clean
    Failure Indicators: Missing export, eval error, formatting drift
    Evidence: .sisyphus/evidence/task-18-exports.txt
  ```

  **Commit**: YES (groups with N6)
  - Message: `chore: update flake exports and aggregator imports`
  - Files: `flake.nix`, `modules/home-manager/coding/default.nix`, `lib/default.nix`
  - Pre-commit: `nix flake check && nix fmt --check`

---

- [ ] 19. Update AGENTS.md Documentation

  **What to do**:
  - Update `/home/m3tam3re/p/AI/AGENTS/AGENTS.md` to reflect new directory structure
  - Document:
    - New `agents/{name}/agent.toml` + `system-prompt.md` structure
    - The canonical TOML schema (reference SCHEMA.md)
    - How renderers work (live in nixpkgs, not here)
    - How to add a new agent
    - How project-level usage works (flake.nix + direnv)
    - Backward-compat bridge (`lib.agentsJson`) — note as temporary
  - Update directory tree diagram
  - Remove references to `agents/agents.json` as canonical source
  - Keep references to skills/, rules/, context/, commands/ unchanged

  **Must NOT do**:
  - Create README.md (update existing AGENTS.md)
  - Document nixpkgs internals (that's nixpkgs's AGENTS.md responsibility)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Tasks 17, 18, 20)
  - **Parallel Group**: Wave 4
  - **Blocks**: None
  - **Blocked By**: Task 5

  **References**:
  - `/home/m3tam3re/p/AI/AGENTS/AGENTS.md` — Current documentation
  - Task 3's SCHEMA.md — Schema to reference

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: AGENTS.md reflects new structure
    Tool: Bash
    Preconditions: AGENTS.md updated
    Steps:
      1. grep "agent.toml" AGENTS.md — assert found
      2. grep "system-prompt.md" AGENTS.md — assert found
      3. grep "agents.json" AGENTS.md — should NOT appear as "canonical" or "source of truth"
    Expected Result: Documentation reflects canonical TOML format
    Failure Indicators: References to old agents.json as primary, missing new structure docs
    Evidence: .sisyphus/evidence/task-19-docs-check.txt
  ```

  **Commit**: YES (groups with A4)
  - Message: `docs: update AGENTS.md for canonical agent format`
  - Files: `AGENTS.md`

---

- [ ] 20. Remove Legacy agents.json + prompts/*.txt from AGENTS Repo

  **What to do**:
  - ONLY after Task 8 confirms backward-compat bridge works
  - ONLY after nixpkgs modules consume new canonical format (Tasks 12-14 complete)
  - Delete `agents/agents.json`
  - Delete `prompts/chiron.txt`, `prompts/chiron-forge.txt`, `prompts/hermes.txt`, `prompts/athena.txt`, `prompts/apollo.txt`, `prompts/calliope.txt`
  - Delete `prompts/` directory if empty
  - Remove `lib.agentsJson` backward-compat function from flake.nix
  - Verify `nix flake check` still passes after removal

  **Must NOT do**:
  - Remove before nixpkgs consumers are updated
  - Remove system-prompt.md files (those are the NEW canonical prompts)
  - Remove skills/, rules/, context/, commands/

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Tasks 17, 18, 19)
  - **Parallel Group**: Wave 4
  - **Blocks**: None
  - **Blocked By**: Task 8 (golden file match confirmed)

  **References**:
  - `agents/agents.json` — File to delete
  - `prompts/*.txt` — Files to delete

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Legacy files removed, canonical files remain
    Tool: Bash
    Preconditions: Tasks 8, 12-14 confirmed complete
    Steps:
      1. test ! -f agents/agents.json — assert file does NOT exist
      2. test ! -d prompts/ — assert directory does NOT exist (or is empty)
      3. for d in agents/chiron agents/chiron-forge agents/hermes agents/athena agents/apollo agents/calliope; do
           test -f "$d/agent.toml" && test -f "$d/system-prompt.md" && echo "OK: $d"
         done
      4. Assert all 6 directories have both files
      5. nix flake check — assert passes
    Expected Result: Legacy removed, canonical intact, flake passes
    Failure Indicators: Legacy files still present, canonical files missing, flake error
    Evidence: .sisyphus/evidence/task-20-cleanup.txt
  ```

  **Commit**: YES (groups with A3)
  - Message: `chore: remove legacy agents.json and prompts/*.txt`
  - Files: `agents/agents.json` (deleted), `prompts/*.txt` (deleted), `flake.nix` (remove agentsJson)

---

- [ ] 21. End-to-End Integration Test Across Both Repos

  **What to do**:
  - Full cross-repo integration verification:
    1. In AGENTS repo: `nix eval --json '.#lib.loadAgents'` → verify 6 agents with all fields
    2. In nixpkgs: simulate home-manager eval with agents input:
       - OpenCode: rendered agents dir contains 6 .md files with correct frontmatter
       - Claude Code: rendered .claude/agents/ contains 6 .md files with valid YAML + required fields
       - Pi: rendered output contains AGENTS.md + SYSTEM.md
    3. Project-level: test `renderForTool` for each tool
    4. Skills: verify `mkOpencodeSkills` still produces correct output
    5. Formatting: `nix fmt --check` on both repos
    6. Flake checks: `nix flake check` on both repos
  - Document all results in evidence files

  **Must NOT do**:
  - Modify any source files (verification only)
  - Skip any tool's verification

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO (integration gate)
  - **Parallel Group**: Wave 4 (runs last)
  - **Blocks**: F1-F4
  - **Blocked By**: Tasks 1, 12, 13, 14, 17, 18

  **References**:
  - All previous task evidence files
  - Both repo flake.nix files

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Full pipeline works end-to-end
    Tool: Bash
    Preconditions: All tasks 1-20 complete
    Steps:
      1. cd /home/m3tam3re/p/AI/AGENTS && nix flake check && echo "AGENTS: OK"
      2. cd /home/m3tam3re/p/NIX/nixpkgs && nix flake check && echo "nixpkgs: OK"
      3. nix eval --json '/home/m3tam3re/p/AI/AGENTS#lib.loadAgents' | jq 'keys | length' — assert 6
      4. Test each renderer produces output without error
      5. nix fmt --check /home/m3tam3re/p/AI/AGENTS — assert clean
      6. nix fmt --check /home/m3tam3re/p/NIX/nixpkgs — assert clean
    Expected Result: Both repos pass all checks, all renderers produce output
    Failure Indicators: Any flake check failure, renderer error, format drift
    Evidence: .sisyphus/evidence/task-21-e2e.txt

  Scenario: Skills composition unchanged
    Tool: Bash
    Preconditions: mkOpencodeSkills not modified
    Steps:
      1. nix eval --raw '/home/m3tam3re/p/AI/AGENTS#lib.mkOpencodeSkills { pkgs = import <nixpkgs> {}; customSkills = ./skills; }'
      2. List contents of output directory
      3. Assert contains all active skill directories
    Expected Result: Skills output identical to before migration
    Failure Indicators: Missing skills, broken linkFarm
    Evidence: .sisyphus/evidence/task-21-skills.txt
  ```

  **Commit**: NO (verification only)

---

## Final Verification Wave (MANDATORY — after ALL implementation tasks)

> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
>
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**

- [ ] F1. **Plan Compliance Audit** — `oracle`
  Read the plan end-to-end. For each "Must Have": verify implementation exists (read file, nix eval, diff). For each "Must NOT Have": search codebase for forbidden patterns — reject with file:line if found. Check evidence files exist in .sisyphus/evidence/. Compare deliverables against plan.
  Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT: APPROVE/REJECT`

- [ ] F2. **Code Quality Review** — `unspecified-high`
  Run `nix flake check` on both repos. Run `nix fmt --check` (alejandra). Review all .nix files for: unused variables, hardcoded paths, missing mkIf guards, type errors. Check TOML files parse without error. Verify no AI slop: no excessive comments, no placeholder values, no TODO markers in production code.
  Output: `Flake Check [PASS/FAIL] | Format [PASS/FAIL] | Nix Quality [N clean/N issues] | TOML Parse [N/N] | VERDICT`

- [ ] F3. **Real Manual QA** — `unspecified-high`
  Execute EVERY QA scenario from EVERY task. Capture evidence. Test cross-task integration: AGENTS repo `lib.loadAgents` → nixpkgs `loadCanonical` → each renderer → home-manager module output. Test edge cases: agent with many permission rules, agent with minimal config, model override. Save to `.sisyphus/evidence/final-qa/`.
  Output: `Scenarios [N/N pass] | Integration [N/N] | Edge Cases [N tested] | VERDICT`

- [ ] F4. **Scope Fidelity Check** — `deep`
  For each task: read "What to do", read actual changes. Verify 1:1 — everything in spec was built (no missing), nothing beyond spec was built (no creep). Check "Must NOT do" compliance. Detect: skills/rules changes (forbidden), MCP in agent.toml (forbidden), Codex/Aider renderers (forbidden), prompt content changes (forbidden). Flag unaccounted changes.
  Output: `Tasks [N/N compliant] | Scope [CLEAN/N issues] | Forbidden Patterns [CLEAN/N found] | VERDICT`

---

## Commit Strategy

### AGENTS Repo
- **Commit A1**: `feat: add canonical agent.toml definitions for all 6 agents` — agents/*/agent.toml + system-prompt.md
- **Commit A2**: `feat: export loadAgents and backward-compat agentsJson from flake` — flake.nix updates
- **Commit A3** (after nixpkgs consuming): `chore: remove legacy agents.json and prompts/*.txt`
- **Commit A4**: `docs: update AGENTS.md for canonical agent format`

### m3ta-nixpkgs
- **Commit N1**: `feat(lib): add agents.nix with loadCanonical and 3 tool renderers`
- **Commit N2**: `feat(hm): add per-tool agent HM sub-modules (opencode, claude-code, pi)`
- **Commit N3**: `refactor(hm): slim opencode.nix to non-agent config only`
- **Commit N4**: `feat(lib): add project-level renderForTool function`
- **Commit N5**: `refactor(lib): rename mkOpencodeRules to mkCodingRules with compat alias`
- **Commit N6**: `chore: update flake exports and aggregator imports`

---

## Success Criteria

### Verification Commands
```bash
# AGENTS repo: all TOML files parse
for f in agents/*/agent.toml; do nix eval --expr "builtins.fromTOML (builtins.readFile ./$f)" --json > /dev/null; done

# AGENTS repo: backward compat bridge
diff <(nix eval --json '.#lib.x86_64-linux.agentsJson' | jq --sort-keys .) /tmp/agents-golden.json

# AGENTS repo: prompts unchanged
for agent in chiron chiron-forge hermes athena apollo calliope; do diff "prompts/$agent.txt" "agents/$agent/system-prompt.md"; done

# nixpkgs: flake check
nix flake check /home/m3tam3re/p/NIX/nixpkgs

# nixpkgs: formatting
nix fmt --check /home/m3tam3re/p/NIX/nixpkgs

# nixpkgs: OpenCode golden file match
diff <(nix eval --json '.#homeConfigurations.sk.config.xdg.configFile."opencode/agents"' | jq --sort-keys .) /tmp/opencode-agents-golden.json
```

### Final Checklist
- [ ] All 6 agents have both `agent.toml` and `system-prompt.md`
- [ ] All "Must Have" items present and verified
- [ ] All "Must NOT Have" items absent
- [ ] `nix flake check` passes on both repos
- [ ] `nix fmt` produces no changes on both repos
- [ ] Golden file comparison passes (OpenCode output unchanged)
- [ ] Claude Code frontmatter valid (name + description present, kebab-case)
- [ ] Pi output valid (AGENTS.md exists, optional JSON valid)
- [ ] `lib.mkOpencodeSkills` unchanged and functional
- [ ] Prompt content byte-identical to originals
