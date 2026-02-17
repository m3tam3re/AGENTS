# Centralized Rules & Per-Project Context Injection System

## TL;DR

> **Quick Summary**: Create a `rules/` directory in the AGENTS repository containing modular AI coding rules (per-concern + per-language), deployed centrally via Home Manager. A `mkOpencodeRules` Nix helper function lives in the nixpkgs repo (following the existing `ports.nix` → `mkPortHelpers` pattern), generating per-project `opencode.json` via devShell activation.
>
> **Deliverables**:
> - 6 concern rule files (coding-style, naming, documentation, testing, git-workflow, project-structure)
> - 5 language/framework rule files (python, typescript, nix, shell, n8n)
> - `lib/opencode-rules.nix` in nixpkgs repo — `mkOpencodeRules` helper function
> - Updated `lib/default.nix` in nixpkgs repo — imports opencode-rules
> - Updated `opencode.nix` in nixos-config — deploys rules/ alongside existing skills
> - `rules/USAGE.md` — per-project adoption documentation
>
> **Repos Touched**: 3 (AGENTS, nixpkgs, nixos-config)
> **Estimated Effort**: Medium (11 rule files + 3 nix changes + 1 doc)
> **Parallel Execution**: YES — 4 waves
> **Critical Path**: T1-T3 (foundation) → T6-T16 (content) → T17 (verification)

---

## Context

### Original Request
User wants to streamline their Agent workflow by centrally managing language-specific and framework-specific coding rules in the AGENTS repository, while allowing project-specific overrides. Rules should be injected per-project using Nix flakes + direnv.

### Interview Summary
**Key Discussions**:
- **Loading strategy**: Always loaded (not lazy) — rules always in context when project activates
- **Composition mechanism**: Nix flake devShell — each project declares languages/frameworks needed
- **Rule granularity**: Per concern with separate language files for deep patterns
- **Override strategy**: Project-level AGENTS.md overrides central rules (OpenCode's native precedence)
- **opencode.json**: No project-specific one exists yet — devShell generates it entirely
- **Nix helper location**: Lives in `m3ta-nixpkgs` repo at `lib/opencode-rules.nix` (follows `ports.nix` pattern)
- **AGENTS repo stays pure content**: No Nix code — only markdown rule files

**Research Findings**:
- OpenCode `instructions` field in `opencode.json` loads external .md files as always-on context
- Anthropic guide: progressive disclosure, composability, 500-line max, use TOCs for long files
- Best practices: 100-200 lines per file, imperative language, micro-examples (correct/incorrect)
- Rule files benefit from sandwich principle: critical constraints at START and END

### Metis Review
**Identified Gaps** (addressed):
- **Rule update strategy**: When rules change in AGENTS repo, projects run `nix flake update agents`. Standard Nix flow.
- **Multi-language projects**: `mkOpencodeRules { languages = [ "python" "typescript" ]; }` — list multiple.
- **Context window budget**: ~800-1300 lines total. Well under 1500-line budget.
- **Empty rules selection**: `mkOpencodeRules {}` loads only concern files (defaults to all 6).

### Architecture Decision: Nix Helper Location
**Decision**: `mkOpencodeRules` lives in **nixpkgs repo** (`/home/m3tam3re/p/NIX/nixpkgs/lib/opencode-rules.nix`), NOT in AGENTS repo.

**Rationale**:
- nixpkgs already has `lib/ports.nix` → `mkPortHelpers` as an identical pattern
- nixpkgs is already consumed by all configs: `inputs.m3ta-nixpkgs.lib.${system}`
- AGENTS repo stays pure content (markdown + configs), no Nix code
- Projects already have `m3ta-nixpkgs` as a flake input — no new input needed for the helper

**Consumption pattern** (per-project):
```nix
let
  m3taLib = inputs.m3ta-nixpkgs.lib.${system};
  rules = m3taLib.opencode-rules.mkOpencodeRules {
    agents = inputs.agents;          # Non-flake input with rule content
    languages = [ "python" ];
  };
in pkgs.mkShell { shellHook = rules.shellHook; }
```

---

## Work Objectives

### Core Objective
Create a centralized, modular AI coding rules system managed in the AGENTS repo, with a Nix helper in nixpkgs for per-project injection via devShell + direnv.

### Concrete Deliverables
- `rules/concerns/{coding-style,naming,documentation,testing,git-workflow,project-structure}.md` — in AGENTS repo
- `rules/languages/{python,typescript,nix,shell}.md` — in AGENTS repo
- `rules/frameworks/n8n.md` — in AGENTS repo
- `rules/USAGE.md` — adoption documentation in AGENTS repo
- `lib/opencode-rules.nix` — in nixpkgs repo (`/home/m3tam3re/p/NIX/nixpkgs/`)
- Updated `lib/default.nix` — in nixpkgs repo (add import)
- Updated `opencode.nix` — in nixos-config repo (`/home/m3tam3re/p/NIX/nixos-config/home/features/coding/`)

### Definition of Done
- [ ] All 11 rule files exist and are under 250 lines each
- [ ] `lib/opencode-rules.nix` in nixpkgs exports `mkOpencodeRules` following `ports.nix` pattern
- [ ] `opencode.nix` deploys `rules/` to `~/.config/opencode/rules/`
- [ ] A project can use `m3taLib.opencode-rules.mkOpencodeRules` in devShell

### Must Have
- All rule files use imperative language ("Always use...", "Never...")
- Every rule includes micro-examples (correct vs incorrect, 2-3 lines each)
- Concern files are language-agnostic; language subsections are brief pointers
- Language files go deep into toolchain, idioms, anti-patterns
- `mkOpencodeRules` accepts: `{ agents, languages ? [], concerns ? [...], frameworks ? [], extraInstructions ? [] }`
- `mkOpencodeRules` follows `ports.nix` pattern: `{lib}: { mkOpencodeRules = ...}`
- shellHook creates `.opencode-rules` symlink + generates `opencode.json`
- Both `.opencode-rules` and `opencode.json` must be gitignored (documented in USAGE.md)

### Must NOT Have (Guardrails)
- Rule files MUST NOT exceed 250 lines
- Total loaded rules MUST NOT exceed 1500 lines for any realistic config
- Concern files MUST NOT contain language-specific implementation details
- MUST NOT put Nix code in AGENTS repo — AGENTS stays pure content
- MUST NOT add rule versioning, testing framework, or generator CLI
- MUST NOT create rules for docker, k8s, terraform — out of scope
- MUST NOT modify existing skills, agents, prompts, or commands
- MUST NOT use generic advice ("write clean code", "follow best practices")

---

## Verification Strategy (MANDATORY)

> **ZERO HUMAN INTERVENTION** — ALL verification is agent-executed. No exceptions.

### Test Decision
- **Infrastructure exists**: NO (config/documentation repos)
- **Automated tests**: NO
- **Framework**: none

### QA Policy
Every task MUST include agent-executed QA scenarios.
Evidence saved to `.sisyphus/evidence/task-{N}-{scenario-slug}.{ext}`.

| Deliverable Type | Verification Tool | Method |
|------------------|-------------------|--------|
| Markdown rule files | Bash (wc, grep) | Line count, micro-examples, imperative language |
| Nix expressions | Bash (nix eval) | Evaluate, check errors |
| Shell integration | Bash | Verify symlink + opencode.json generated |
| Cross-repo | Bash (grep) | Verify entries in correct files |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Foundation — 5 tasks, all parallel):
├── Task 1: Create rules/ directory structure in AGENTS repo [quick]
├── Task 2: Create lib/opencode-rules.nix in nixpkgs repo [quick]
├── Task 3: Update lib/default.nix in nixpkgs repo [quick]
├── Task 4: Update opencode.nix in nixos-config repo [quick]
└── Task 5: Create rules/USAGE.md in AGENTS repo [quick]

Wave 2 (Content — 11 rule files, all parallel):
├── Task 6: concerns/coding-style.md [writing]
├── Task 7: concerns/naming.md [writing]
├── Task 8: concerns/documentation.md [writing]
├── Task 9: concerns/testing.md [writing]
├── Task 10: concerns/git-workflow.md [writing]
├── Task 11: concerns/project-structure.md [writing]
├── Task 12: languages/python.md [writing]
├── Task 13: languages/typescript.md [writing]
├── Task 14: languages/nix.md [writing]
├── Task 15: languages/shell.md [writing]
└── Task 16: frameworks/n8n.md [writing]

Wave 3 (Verification):
└── Task 17: End-to-end integration test [deep]

Wave FINAL (Review — 4 parallel):
├── Task F1: Plan compliance audit (oracle)
├── Task F2: Code quality review (unspecified-high)
├── Task F3: Real manual QA (unspecified-high)
└── Task F4: Scope fidelity check (deep)

Critical Path: T1-T3 → T6-T16 (parallel) → T17 → F1-F4
Max Concurrent: 11 (Wave 2)
```

### Dependency Matrix

| Task | Depends On | Blocks | Wave |
|------|------------|--------|------|
| 1 | — | 5, 6-16, 17 | 1 |
| 2, 3 | — | 17 | 1 |
| 4 | — | 17 | 1 |
| 5 | 1, 2 | 17 | 1 |
| 6-16 | 1 | 17 | 2 |
| 17 | 2-5, 6-16 | F1-F4 | 3 |
| F1-F4 | 17 | — | FINAL |

### Agent Dispatch Summary

| Wave | # Parallel | Tasks and Agent Category |
|------|------------|------------------------|
| 1 | **5** | T1-T5 → `quick` |
| 2 | **11** | T6-T16 → `writing` |
| 3 | **1** | T17 → `deep` |
| FINAL | **4** | F1 → `oracle`, F2,F3 → `unspecified-high`, F4 → `deep` |

---

## TODOs

- [x] 1. Create rules/ directory structure in AGENTS repo

  **What to do**:
  - Create directory structure in `/home/m3tam3re/p/AI/AGENTS/`: `rules/concerns/`, `rules/languages/`, `rules/frameworks/`
  - Add `.gitkeep` files to each directory so they're tracked before content is added
  - This is the CONTENT repo only — NO Nix code goes here

  **Must NOT do**:
  - Do not create any Nix files in AGENTS repo
  - Do not create rule content files (those are Wave 2)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 2-5)
  - **Blocks**: Tasks 5, 6-16, 17
  - **Blocked By**: None

  **References**:
  - `/home/m3tam3re/p/AI/AGENTS/skills/` — existing directory structure pattern

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: Directory structure exists
    Tool: Bash
    Preconditions: None
    Steps:
      1. Run `ls /home/m3tam3re/p/AI/AGENTS/rules/concerns/.gitkeep /home/m3tam3re/p/AI/AGENTS/rules/languages/.gitkeep /home/m3tam3re/p/AI/AGENTS/rules/frameworks/.gitkeep`
    Expected Result: All 3 .gitkeep files exist
    Failure Indicators: "No such file or directory"
    Evidence: .sisyphus/evidence/task-1-dirs.txt

  Scenario: No Nix files in AGENTS repo rules/
    Tool: Bash
    Preconditions: Dirs created
    Steps:
      1. Run `find /home/m3tam3re/p/AI/AGENTS/rules/ -name '*.nix' | wc -l`
    Expected Result: Count is 0
    Failure Indicators: Count > 0
    Evidence: .sisyphus/evidence/task-1-no-nix.txt
  ```

  **Commit**: YES
  - Message: `feat(rules): add rules directory structure`
  - Files: `rules/concerns/.gitkeep`, `rules/languages/.gitkeep`, `rules/frameworks/.gitkeep`

---

- [x] 2. Create `lib/opencode-rules.nix` in nixpkgs repo

  **What to do**:
  - Create `/home/m3tam3re/p/NIX/nixpkgs/lib/opencode-rules.nix`
  - Follow the EXACT pattern of `lib/ports.nix`: `{lib}: { mkOpencodeRules = ...; }`
  - The function must accept: `{ agents, languages ? [], concerns ? [ "coding-style" "naming" "documentation" "testing" "git-workflow" "project-structure" ], frameworks ? [], extraInstructions ? [] }`
  - `agents` parameter = the non-flake input (path to AGENTS repo in Nix store)
  - It must return: `{ shellHook = "..."; instructions = [...]; }`
  - `shellHook` must: (a) create `.opencode-rules` symlink to `${agents}/rules`, (b) generate `opencode.json` with `$schema` and `instructions` fields using `builtins.toJSON`
  - `instructions` = list of paths relative to project root via `.opencode-rules/` symlink
  - Include comprehensive Nix doc comments (matching ports.nix style)

  **Must NOT do**:
  - Do not deviate from ports.nix pattern
  - Do not put any code in AGENTS repo

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: One Nix file following established pattern
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 3-5)
  - **Blocks**: Tasks 5, 17
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `/home/m3tam3re/p/NIX/nixpkgs/lib/ports.nix` — MUST follow this exact pattern: `{lib}: { mkPortHelpers = portsConfig: let ... in { ... }; }`
  - `/home/m3tam3re/p/NIX/nixpkgs/lib/default.nix` — shows how lib modules are imported: `import ./ports.nix {inherit lib;}`
  - `/home/m3tam3re/p/NIX/nixpkgs/flake.nix:73-77` — shows how lib is exposed: `lib = forAllSystems (system: ... import ./lib {lib = pkgs.lib;});`

  **External References**:
  - OpenCode rules docs: `https://opencode.ai/docs/rules/` — `instructions` field accepts relative paths

  **WHY Each Reference Matters**:
  - `ports.nix` is the canonical pattern for lib functions in this repo — `{lib}:` signature, doc comments, nested `let ... in`
  - `default.nix` shows how the new module gets wired in
  - `flake.nix` confirms how consumers access it: `m3ta-nixpkgs.lib.${system}.opencode-rules.mkOpencodeRules`

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: opencode-rules.nix evaluates without errors
    Tool: Bash
    Preconditions: File created
    Steps:
      1. Run `nix eval --impure --expr 'let pkgs = import <nixpkgs> {}; lib = (import /home/m3tam3re/p/NIX/nixpkgs/lib/opencode-rules.nix {lib = pkgs.lib;}); in builtins.attrNames lib' 2>&1`
    Expected Result: Output contains "mkOpencodeRules"
    Failure Indicators: "error:" in output
    Evidence: .sisyphus/evidence/task-2-eval.txt

  Scenario: mkOpencodeRules generates correct paths
    Tool: Bash
    Preconditions: File created
    Steps:
      1. Run `nix eval --impure --json --expr 'let pkgs = import <nixpkgs> {}; lib = (import /home/m3tam3re/p/NIX/nixpkgs/lib/opencode-rules.nix {lib = pkgs.lib;}); in (lib.mkOpencodeRules { agents = /home/m3tam3re/p/AI/AGENTS; languages = ["python" "typescript"]; frameworks = ["n8n"]; }).instructions'`
    Expected Result: JSON array with 9 paths (6 concerns + 2 languages + 1 framework), all starting with ".opencode-rules/"
    Failure Indicators: Wrong count, wrong prefix, error
    Evidence: .sisyphus/evidence/task-2-paths.txt

  Scenario: Default (empty languages) works
    Tool: Bash
    Preconditions: File created
    Steps:
      1. Run `nix eval --impure --json --expr 'let pkgs = import <nixpkgs> {}; lib = (import /home/m3tam3re/p/NIX/nixpkgs/lib/opencode-rules.nix {lib = pkgs.lib;}); in (lib.mkOpencodeRules { agents = /home/m3tam3re/p/AI/AGENTS; }).instructions'`
    Expected Result: JSON array with 6 paths (concerns only)
    Failure Indicators: Extra paths, error
    Evidence: .sisyphus/evidence/task-2-defaults.txt

  Scenario: shellHook generates valid JSON
    Tool: Bash
    Preconditions: File created
    Steps:
      1. Run `nix eval --impure --raw --expr 'let pkgs = import <nixpkgs> {}; lib = (import /home/m3tam3re/p/NIX/nixpkgs/lib/opencode-rules.nix {lib = pkgs.lib;}); in (lib.mkOpencodeRules { agents = /home/m3tam3re/p/AI/AGENTS; languages = ["python"]; }).shellHook' | sh -c 'eval "$(cat)"' && python3 -m json.tool opencode.json`
    Expected Result: Valid JSON output with "$schema" and "instructions" fields
    Failure Indicators: JSON parse error, missing fields
    Evidence: .sisyphus/evidence/task-2-json.txt
  ```

  **Commit**: YES
  - Message: `feat(lib): add opencode-rules helper for per-project rule injection`
  - Files: `lib/opencode-rules.nix`
  - Pre-commit: `nix eval --impure --expr '...'`

---

- [x] 3. Update `lib/default.nix` in nixpkgs repo

  **What to do**:
  - Add one line to `/home/m3tam3re/p/NIX/nixpkgs/lib/default.nix` to import opencode-rules:
    `opencode-rules = import ./opencode-rules.nix {inherit lib;};`
  - Place it after the existing `ports = import ./ports.nix {inherit lib;};` line
  - Update the comment at line 10 to remove it (it's a placeholder)

  **Must NOT do**:
  - Do not modify the ports import
  - Do not change the function signature `{lib}:`

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (but logically pairs with Task 2)
  - **Parallel Group**: Wave 1
  - **Blocks**: Task 17
  - **Blocked By**: Task 2 (opencode-rules.nix must exist first)

  **References**:
  - `/home/m3tam3re/p/NIX/nixpkgs/lib/default.nix:6-12` — current file content, add after line 8

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: default.nix imports opencode-rules
    Tool: Bash
    Preconditions: Both files updated
    Steps:
      1. Run `grep 'opencode-rules' /home/m3tam3re/p/NIX/nixpkgs/lib/default.nix`
    Expected Result: Line shows `opencode-rules = import ./opencode-rules.nix {inherit lib;};`
    Failure Indicators: No match
    Evidence: .sisyphus/evidence/task-3-import.txt

  Scenario: Full lib evaluates
    Tool: Bash
    Preconditions: Both files updated
    Steps:
      1. Run `nix eval --impure --expr 'let pkgs = import <nixpkgs> {}; m3taLib = import /home/m3tam3re/p/NIX/nixpkgs/lib {lib = pkgs.lib;}; in builtins.attrNames m3taLib' 2>&1`
    Expected Result: Output includes both "ports" and "opencode-rules"
    Failure Indicators: Missing "opencode-rules" or error
    Evidence: .sisyphus/evidence/task-3-full-lib.txt
  ```

  **Commit**: YES (groups with Task 2)
  - Message: `feat(lib): add opencode-rules helper for per-project rule injection`
  - Files: `lib/default.nix`, `lib/opencode-rules.nix`

---

- [x] 4. Update opencode.nix in nixos-config repo

  **What to do**:
  - Add `rules/` deployment to `xdg.configFile` in `/home/m3tam3re/p/NIX/nixos-config/home/features/coding/opencode.nix`
  - Add entry: `"opencode/rules" = { source = "${inputs.agents}/rules"; recursive = true; };`
  - Place it alongside existing entries for commands, context, prompts, skills (lines 2-18)

  **Must NOT do**:
  - Do not modify any existing entries
  - Do not change agents, MCP, providers, or oh-my-opencode config
  - Do not run `home-manager switch`

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: Task 17
  - **Blocked By**: None

  **References**:
  - `/home/m3tam3re/p/NIX/nixos-config/home/features/coding/opencode.nix:2-18` — existing xdg.configFile entries

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: opencode.nix contains rules entry
    Tool: Bash
    Preconditions: File updated
    Steps:
      1. Run `grep -c 'opencode/rules' /home/m3tam3re/p/NIX/nixos-config/home/features/coding/opencode.nix`
      2. Run `grep -c 'opencode/commands\|opencode/context\|opencode/prompts\|opencode/skills' /home/m3tam3re/p/NIX/nixos-config/home/features/coding/opencode.nix`
    Expected Result: Rules count is 1, existing count is 4 (all preserved)
    Failure Indicators: Count mismatch
    Evidence: .sisyphus/evidence/task-4-opencode-nix.txt
  ```

  **Commit**: YES
  - Message: `feat(opencode): deploy rules/ to ~/.config/opencode/rules/ via home-manager`
  - Files: `opencode.nix`

---

- [x] 5. Create `rules/USAGE.md` in AGENTS repo

  **What to do**:
  - Document how to use `mkOpencodeRules` in a project's `flake.nix`
  - Show the nixpkgs consumption pattern: `m3taLib.opencode-rules.mkOpencodeRules { agents = inputs.agents; languages = ["python"]; }`
  - Complete example `flake.nix` devShell snippet showing: `inputs.agents` + `inputs.m3ta-nixpkgs` + `mkOpencodeRules` + `shellHook`
  - Document `.gitignore` additions: `.opencode-rules` and `opencode.json`
  - Explain project-level `AGENTS.md` overrides
  - Explain update flow: `nix flake update agents`
  - Keep concise: max 100 lines

  **Must NOT do**:
  - Do not create a README.md (repo anti-pattern)
  - Do not reference `rules/default.nix` — the helper lives in nixpkgs, not AGENTS

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: Task 17
  - **Blocked By**: Tasks 1, 2 (needs to reference both structures)

  **References**:
  - `/home/m3tam3re/p/AI/AGENTS/AGENTS.md` — repo documentation style (concise, code-heavy)
  - `/home/m3tam3re/p/NIX/nixpkgs/lib/ports.nix:1-42` — the doc comment style used for lib functions
  - OpenCode rules docs: `https://opencode.ai/docs/rules/` — `instructions` field

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: USAGE.md has required content
    Tool: Bash
    Preconditions: File created
    Steps:
      1. Run `wc -l /home/m3tam3re/p/AI/AGENTS/rules/USAGE.md`
      2. Run `grep -c 'm3ta-nixpkgs\|mkOpencodeRules\|gitignore\|AGENTS.md\|nix flake update' /home/m3tam3re/p/AI/AGENTS/rules/USAGE.md`
    Expected Result: Under 100 lines, key terms >= 5
    Failure Indicators: Over 100 lines or missing key concepts
    Evidence: .sisyphus/evidence/task-5-usage.txt
  ```

  **Commit**: YES (groups with T1)
  - Message: `feat(rules): add rules directory structure and usage documentation`
  - Files: `rules/USAGE.md`, `rules/concerns/.gitkeep`, `rules/languages/.gitkeep`, `rules/frameworks/.gitkeep`

---

- [ ] 6. Create `rules/concerns/coding-style.md`

  **What to do**:
  - Write coding style rules: code formatting, patterns/anti-patterns, error handling, type safety, function design, DRY/SOLID
  - Imperative language ("Always...", "Never...", "Prefer..."), micro-examples (`Correct:` / `Incorrect:`)
  - Keep under 200 lines, sandwich principle (critical rules at start and end)

  **Must NOT do**: No language-specific toolchain details, no generic advice ("write clean code"), max 200 lines

  **Recommended Agent Profile**: `writing`, Skills: []
  **Parallelization**: Wave 2, parallel with T7-T16. Blocks T17. Blocked by T1.

  **References**:
  - `/home/m3tam3re/p/AI/AGENTS/skills/skill-creator/SKILL.md` — documentation density example
  - Awesome Cursorrules: `https://github.com/PatrickJS/awesome-cursorrules`

  **Acceptance Criteria**:
  ```
  Scenario: Quality check
    Tool: Bash
    Steps:
      1. `wc -l` → under 200
      2. `grep -c 'Correct:\|Incorrect:\|Always\|Never\|Prefer'` → >= 10
      3. `grep -c '```'` → >= 6 (3+ example pairs)
      4. `grep -ic 'write clean code\|follow best practices'` → 0
    Evidence: .sisyphus/evidence/task-6-coding-style.txt
  ```
  **Commit**: NO (groups with Wave 2 commit in T17)

---

- [ ] 7. Create `rules/concerns/naming.md`

  **What to do**:
  - Naming conventions: files, variables, functions, classes, modules, constants
  - Per-language table (Python=snake_case, TS=camelCase, Nix=camelCase, Shell=UPPER_SNAKE)
  - Keep under 150 lines

  **Must NOT do**: No toolchain details, max 150 lines

  **Recommended Agent Profile**: `writing`, Skills: []
  **Parallelization**: Wave 2. Blocks T17. Blocked by T1.

  **References**: `/home/m3tam3re/p/AI/AGENTS/AGENTS.md:58-62` — existing naming conventions

  **Acceptance Criteria**:
  ```
  Scenario: `wc -l` → under 150, `grep -c 'snake_case\|camelCase\|PascalCase\|UPPER_SNAKE'` → >= 4
    Evidence: .sisyphus/evidence/task-7-naming.txt
  ```
  **Commit**: NO

---

- [ ] 8. Create `rules/concerns/documentation.md`

  **What to do**: When to document, docstring formats, inline comment philosophy (WHY not WHAT), README standards. Under 150 lines.
  **Recommended Agent Profile**: `writing`
  **Parallelization**: Wave 2. Blocked by T1.
  **References**: `/home/m3tam3re/p/AI/AGENTS/AGENTS.md` — repo's own style
  **Acceptance Criteria**: `wc -l` < 150, `grep -c 'WHY\|WHAT\|Correct:\|Incorrect:'` >= 4
  **Commit**: NO

---

- [ ] 9. Create `rules/concerns/testing.md`

  **What to do**: Arrange-act-assert, behavior vs implementation testing, mocking philosophy, coverage, TDD. Under 200 lines.
  **Recommended Agent Profile**: `writing`
  **Parallelization**: Wave 2. Blocked by T1.
  **References**: `/home/m3tam3re/p/AI/AGENTS/AGENTS.md:73-82` — existing test philosophy
  **Acceptance Criteria**: `wc -l` < 200, `grep -ic 'arrange\|act\|assert\|mock\|behavior'` >= 4
  **Commit**: NO

---

- [ ] 10. Create `rules/concerns/git-workflow.md`

  **What to do**: Conventional commits, branch naming, PR descriptions, squash vs merge. Under 120 lines.
  **Recommended Agent Profile**: `writing`, Skills: [`git-master`]
  **Parallelization**: Wave 2. Blocked by T1.
  **References**: `https://www.conventionalcommits.org/en/v1.0.0/`
  **Acceptance Criteria**: `wc -l` < 120, `grep -c 'feat\|fix\|refactor\|docs\|chore'` >= 5
  **Commit**: NO

---

- [ ] 11. Create `rules/concerns/project-structure.md`

  **What to do**: Directory layout, module organization, entry points, config placement. Per-type: Python (src layout), TS (src/), Nix (modules/). Under 120 lines.
  **Recommended Agent Profile**: `writing`
  **Parallelization**: Wave 2. Blocked by T1.
  **References**: `/home/m3tam3re/p/AI/AGENTS/AGENTS.md:24-38` — repo structure
  **Acceptance Criteria**: `wc -l` < 120
  **Commit**: NO

---

- [ ] 12. Create `rules/languages/python.md`

  **What to do**:
  - Deep Python patterns: `uv` (pkg mgmt), `ruff` (lint/fmt), `pyright` (types), `pytest` + `hypothesis`, Pydantic for data boundaries
  - Idioms: comprehensions, context managers, generators, f-strings
  - Anti-patterns: bare except, mutable defaults, global state, star imports
  - Project setup: `pyproject.toml`, src layout
  - Under 250 lines with micro-examples

  **Must NOT do**: No general coding style (covered in concerns/), no Django/Flask/FastAPI, max 250 lines

  **Recommended Agent Profile**: `writing`
  **Parallelization**: Wave 2. Blocked by T1.

  **References**:
  - `/home/m3tam3re/p/AI/AGENTS/AGENTS.md:60` — existing Python conventions (shebang, docstrings)
  - Ruff docs: `https://docs.astral.sh/ruff/`, uv docs: `https://docs.astral.sh/uv/`

  **Acceptance Criteria**: `wc -l` < 250, `grep -c 'ruff\|uv\|pytest\|pydantic\|pyright'` >= 4, `grep -c '```python'` >= 5, no "pythonic"/"best practice"
  **Commit**: NO

---

- [ ] 13. Create `rules/languages/typescript.md`

  **What to do**:
  - Strict mode (`strict: true`, `noUncheckedIndexedAccess`), discriminated unions, branded types, `satisfies`, `as const`
  - Modern: `using`, `Promise.withResolvers()`, `Object.groupBy()`
  - Toolchain: `bun`/`tsx`, `biome`/`eslint`
  - Anti-patterns: `as any`, `@ts-ignore`, `!` assertion, `enum` (prefer union)
  - Under 250 lines

  **Must NOT do**: No React/Next.js, max 250 lines

  **Recommended Agent Profile**: `writing`
  **Parallelization**: Wave 2. Blocked by T1.
  **Acceptance Criteria**: `wc -l` < 250, `grep -c 'strict\|as any\|ts-ignore\|discriminated\|satisfies'` >= 4, `grep -c '```ts'` >= 5
  **Commit**: NO

---

- [ ] 14. Create `rules/languages/nix.md`

  **What to do**:
  - Flake structure, module patterns (`{ config, lib, pkgs, ... }:`), `mkIf`/`mkMerge`
  - Formatting: `alejandra`, naming: camelCase
  - Anti-patterns: `with pkgs;`, `builtins.fetchTarball`, impure ops
  - Home Manager patterns, overlays
  - Under 200 lines

  **Recommended Agent Profile**: `writing`
  **Parallelization**: Wave 2. Blocked by T1.

  **References**:
  - `/home/m3tam3re/p/NIX/nixos-config/home/features/coding/opencode.nix` — user's actual Nix style
  - `/home/m3tam3re/p/NIX/nixpkgs/lib/ports.nix` — well-structured Nix code example

  **Acceptance Criteria**: `wc -l` < 200, `grep -c 'flake\|mkShell\|alejandra\|with pkgs\|overlay'` >= 4
  **Commit**: NO

---

- [ ] 15. Create `rules/languages/shell.md`

  **What to do**: `set -euo pipefail`, shellcheck, quoting, local vars, POSIX portability, `#!/usr/bin/env bash`. Under 120 lines.
  **Recommended Agent Profile**: `writing`
  **Parallelization**: Wave 2. Blocked by T1.
  **References**: `/home/m3tam3re/p/AI/AGENTS/AGENTS.md:61`, `/home/m3tam3re/p/AI/AGENTS/scripts/test-skill.sh`
  **Acceptance Criteria**: `wc -l` < 120, `grep -c 'set -euo pipefail\|shellcheck\|#!/usr/bin/env'` >= 2
  **Commit**: NO

---

- [ ] 16. Create `rules/frameworks/n8n.md`

  **What to do**: Workflow design, node patterns, naming, Error Trigger, data patterns, security. Under 120 lines.
  **Recommended Agent Profile**: `writing`
  **Parallelization**: Wave 2. Blocked by T1.
  **References**: n8n docs: `https://docs.n8n.io/`
  **Acceptance Criteria**: `wc -l` < 120, `grep -c 'workflow\|node\|Error Trigger\|webhook\|credential'` >= 4
  **Commit**: NO

---

- [ ] 17. End-to-end integration test + commits

  **What to do**:
  1. Verify all 11 rule files exist and meet line count limits
  2. Verify `lib/opencode-rules.nix` in nixpkgs evaluates correctly for: empty, single-lang, multi-lang, with-frameworks
  3. Verify full lib import works: `m3taLib.opencode-rules.mkOpencodeRules`
  4. Verify generated `opencode.json` is valid JSON with correct `instructions` paths
  5. Verify all instruction paths resolve to real files in AGENTS repo rules/
  6. Verify total context budget: all concerns + 1 language < 1500 lines
  7. Verify `opencode.nix` has the rules deployment entry
  8. Commit all Wave 2 rule files as a single commit in AGENTS repo

  **Must NOT do**: Do not run `home-manager switch`, do not modify files, do not create test projects

  **Recommended Agent Profile**: `deep`, Skills: [`git-master`]
  **Parallelization**: Wave 3 (sequential). Blocks F1-F4. Blocked by T2-T5, T6-T16.

  **References**:
  - `/home/m3tam3re/p/NIX/nixpkgs/lib/opencode-rules.nix` — Nix helper to evaluate
  - `/home/m3tam3re/p/NIX/nixos-config/home/features/coding/opencode.nix` — deployment config

  **Acceptance Criteria**:

  **QA Scenarios (MANDATORY):**

  ```
  Scenario: All rule files exist and meet limits
    Tool: Bash
    Steps:
      1. For each of 11 files: `wc -l` and verify under limit
    Expected Result: All 11 files present, all under limits
    Evidence: .sisyphus/evidence/task-17-inventory.txt

  Scenario: Full lib integration
    Tool: Bash
    Steps:
      1. Run `nix eval --impure --json --expr 'let pkgs = import <nixpkgs> {}; m3taLib = import /home/m3tam3re/p/NIX/nixpkgs/lib {lib = pkgs.lib;}; in (m3taLib.opencode-rules.mkOpencodeRules { agents = /home/m3tam3re/p/AI/AGENTS; languages = ["python" "typescript" "nix" "shell"]; frameworks = ["n8n"]; }).instructions'`
    Expected Result: JSON array with 11 paths (6 concerns + 4 langs + 1 framework)
    Failure Indicators: Wrong count, error
    Evidence: .sisyphus/evidence/task-17-full-integration.txt

  Scenario: All paths resolve to real files
    Tool: Bash
    Steps:
      1. For each path in instructions output: verify the corresponding file exists under `rules/`
    Expected Result: All paths resolve, none missing
    Evidence: .sisyphus/evidence/task-17-paths-resolve.txt

  Scenario: Total context budget
    Tool: Bash
    Steps:
      1. `cat /home/m3tam3re/p/AI/AGENTS/rules/concerns/*.md | wc -l`
      2. `wc -l < /home/m3tam3re/p/AI/AGENTS/rules/languages/python.md`
      3. Sum must be < 1500
    Expected Result: Total under 1500
    Evidence: .sisyphus/evidence/task-17-budget.txt
  ```

  **Commit**: YES
  - Message: `feat(rules): add initial rule files for all concerns, languages, and frameworks`
  - Files: all `rules/**/*.md` files (11 total)
  - Repo: AGENTS

---

## Final Verification Wave (MANDATORY — after ALL implementation tasks)

> 4 review agents run in PARALLEL. ALL must APPROVE. Rejection → fix → re-run.

- [ ] F1. **Plan Compliance Audit** — `oracle`
  For each "Must Have": verify implementation exists. For each "Must NOT Have": search for violations. Check evidence files. Compare deliverables across all 3 repos.
  Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT`

- [ ] F2. **Code Quality Review** — `unspecified-high`
  Rule files: no generic advice, has examples, consistent tone, under limits. Nix: valid syntax, correct paths, edge cases. USAGE.md: accurate.
  Output: `Files [N clean/N issues] | VERDICT`

- [ ] F3. **Real Manual QA** — `unspecified-high`
  Run `nix eval` on opencode-rules.nix via full lib import with various configs. Verify JSON. Check rule content quality. Save to `.sisyphus/evidence/final-qa/`.
  Output: `Scenarios [N/N pass] | VERDICT`

- [ ] F4. **Scope Fidelity Check** — `deep`
  For each task: "What to do" vs actual file. 1:1 match. No creep. Check "Must NOT do". Flag unaccounted changes across all 3 repos.
  Output: `Tasks [N/N compliant] | Unaccounted [CLEAN/N files] | VERDICT`

---

## Commit Strategy

| After Task(s) | Repo | Message | Files |
|---------------|------|---------|-------|
| 1, 5 | AGENTS | `feat(rules): add rules directory structure and usage documentation` | `rules/USAGE.md`, `rules/{concerns,languages,frameworks}/.gitkeep` |
| 2, 3 | nixpkgs | `feat(lib): add opencode-rules helper for per-project rule injection` | `lib/opencode-rules.nix`, `lib/default.nix` |
| 4 | nixos-config | `feat(opencode): deploy rules/ to ~/.config/opencode/rules/` | `opencode.nix` |
| 17 | AGENTS | `feat(rules): add initial rule files for concerns, languages, and frameworks` | all `rules/**/*.md` (11 files) |

---

## Success Criteria

### Verification Commands
```bash
# All rule files exist (AGENTS repo)
ls rules/concerns/*.md rules/languages/*.md rules/frameworks/*.md

# Context budget
cat rules/concerns/*.md rules/languages/python.md | wc -l  # Expected: < 1500

# Nix helper via full lib (nixpkgs)
nix eval --impure --json --expr 'let pkgs = import <nixpkgs> {}; m3taLib = import /path/to/nixpkgs/lib {lib = pkgs.lib;}; in (m3taLib.opencode-rules.mkOpencodeRules { agents = /path/to/AGENTS; languages = ["python"]; }).instructions'

# opencode.nix has rules entry (nixos-config)
grep 'opencode/rules' /home/m3tam3re/p/NIX/nixos-config/home/features/coding/opencode.nix
```

### Final Checklist
- [ ] All 11 rule files present and under line limits
- [ ] All rule files use imperative language with micro-examples
- [ ] `lib/opencode-rules.nix` in nixpkgs follows ports.nix pattern exactly
- [ ] `lib/default.nix` imports opencode-rules
- [ ] `opencode.nix` deploys rules/ alongside skills/commands/context/prompts
- [ ] `rules/USAGE.md` documents nixpkgs consumption pattern correctly
- [ ] No Nix code in AGENTS repo
- [ ] No existing files modified (except lib/default.nix +1 line, opencode.nix +3 lines)
- [ ] Total loaded context under 1500 lines for any realistic configuration
