# Learnings

## [2026-04-10] Session Initialized

- Plan: harness-agnostic-migration (21 tasks + 4 final)
- AGENTS repo: /home/m3tam3re/p/AI/AGENTS
- nixpkgs repo: /home/m3tam3re/p/NIX/nixpkgs
- TOML chosen as canonical format (builtins.fromTOML, no IFD)
- Renderers belong in nixpkgs, not AGENTS repo
- 6 agents: chiron, chiron-forge, hermes, athena, apollo, calliope
- OpenCode: file-based agents (.opencode/agent/\*.md) NOT config.json embedding
- Pi: no subagents — renders AGENTS.md + SYSTEM.md only
- Claude Code: name must be [a-z0-9-]+ (slugified)
- No model in agent.toml (per-machine via home-manager)
- No MCP in agent.toml (tool-specific infrastructure)
- No YAML files as canonical source
- Permission model: two-level — intent (allow/deny/ask) + rules array "pattern:action"
- mkOpencodeRules → mkCodingRules (backward-compat alias)
- lib.mkSkills stays unchanged

## [2026-04-10] Task 1: Capture Golden File Baseline

### Golden File Created

- **Path**: `.sisyphus/evidence/agents-golden.json`
- **Method**: `jq --sort-keys . agents/agents.json`
- **Status**: ✓ Valid JSON, parseable, verified

### Agent Count

- **Total**: 6 agents
- **Verification**: `jq 'keys | length'` → 6 ✓

### Agent Names (Alphabetically Sorted)

1. Apollo (Knowledge Management) — subagent, private knowledge specialist
2. Athena (Researcher) — subagent, work knowledge specialist
3. Calliope (Writer) — subagent, writing specialist
4. Chiron (Assistant) — primary agent, plan mode
5. Chiron Forge (Builder) — primary agent, build mode
6. Hermes (Communication) — subagent, communication specialist

### Agent Object Structure

Every agent has 5 top-level keys:

- `description` (string) — agent purpose and capabilities
- `mode` (string) — "primary" or "subagent"
- `model` (string) — LLM model ID (all use "zai-coding-plan/glm-5")
- `prompt` (string) — reference to prompt file via `{file:./prompts/...}`
- `permission` (object) — capability matrix with granular controls

### Permission Structure

All agents have 6 permission categories:

- `question` → "allow" | "deny" | "ask"
- `webfetch` → "allow" | "deny" | "ask"
- `websearch` → "allow" | "deny" | "ask" (not all agents)
- `edit` → nested rules (allow/deny per path pattern)
- `bash` → nested rules (allow/deny per command pattern)
- `external_directory` → nested rules (allow/deny per path pattern)

### Baseline Purpose

This golden file serves as the **canonical reference** for backward-compat verification in Task 8.
It will be compared against output from the harness-agnostic bridge to ensure config integrity.

### Next Steps

- Task 8 will generate a comparable JSON from the bridge
- Diff will be computed: `jq --sort-keys . bridge_output.json > bridge-output.json && diff agents-golden.json bridge-output.json`
- Any structural or content changes will be flagged

## [2026-04-10] Task 2: TOML Feasibility Spike

**Result: ✅ PASS**

### Test Execution

- Full Chiron-Forge TOML (16 lines, 5 permission sections, 15 bash rules, 4 external_directory rules): **PARSED SUCCESSFULLY**
- Minimal TOML (2 lines, name + description only): **PARSED SUCCESSFULLY**
- Parser: `nix eval --impure --expr 'builtins.fromTOML (builtins.readFile <path>)' --json`

### Glob Patterns Verified

All complex patterns preserved exactly:

- `rm -rf *` → intact (wildcard in rule)
- `git reset --hard*` → intact (pattern suffix)
- `git push*` → intact (pattern suffix)
- `git push --force*` → intact (flag + pattern)
- `git push -f *` → intact (short flag + wildcard)
- `~/p/**` → intact (recursive glob)
- `~/.config/opencode/**` → intact (home + recursive)
- `/run/agenix/**` → intact (absolute + recursive)
- `/tmp/**` → intact (absolute + recursive)

### Special Handling

- TOML arrays of strings work perfectly for `rules` list
- Two-level structure (`intent` + `rules`) maps cleanly from JSON nested objects
- No datetime fields used (confirmed limitation is not a blocker for permissions schema)
- No multi-line inline tables needed (flat key-value structure only)

### Conclusion

**✅ TOML is suitable for agent permission config.** The proposed two-level model (`intent = "allow"|"deny"|"ask"` + `rules = [...]` array) is:

- **Parseable**: `builtins.fromTOML` handles it perfectly with `--impure` flag
- **Pattern-safe**: All glob patterns (wildcards, recursion, flags) preserved exactly
- **Backward-compatible**: Maps cleanly from existing JSON nested object format

### Evidence Files

- `/home/m3tam3re/p/AI/AGENTS/.sisyphus/evidence/task-2-toml-spike.json` (full Chiron-Forge parsed result)
- `/home/m3tam3re/p/AI/AGENTS/.sisyphus/evidence/task-2-toml-minimal.json` (minimal test parsed result)

### Next Steps

No workarounds needed. Ready to implement full harness with TOML permission loader.

## [2026-04-10] Task 3: Canonical Schema Designed

- SCHEMA.md created at agents/SCHEMA.md
- Required fields: name, description
- Optional: display_name, mode, tags, max_turns, skills, context, rules
- Permissions: [permissions.TOOL] with intent + rules[]
- Supported tools: bash, edit, webfetch, websearch, question, external_directory
- Per-renderer matrix: documented
- Sample TOML parses: YES
- Evidence: .sisyphus/evidence/task-3-schema-sample.toml (TOML source)
- Evidence: .sisyphus/evidence/task-3-schema-sample-parsed.json (Nix parse result)

## [2026-04-10] Task 4: OpenCode File-Based Agent Format

### File Location

- **Per-project**: `.opencode/agents/`
- **Global**: `~/.config/opencode/agents/`
- Per-project agents override global agents with same name

### Agent Naming

- **Filename determines agent name** — no `name` field in frontmatter
- Example: `review.md` → agent named `review`
- Naming convention: `[a-z0-9-]+` (lowercase, hyphens)

### YAML Frontmatter Structure

- **Required**: `description` (string)
- **Optional**: `mode` (`primary`|`subagent`|`all`), `model`, `temperature`, `top_p`, `steps`, `disable`, `hidden`, `color`, `permission`, `task`
- Provider-specific fields pass through to LLM (e.g., `reasoningEffort` for OpenAI)

### Permission Format in Markdown

```yaml
permission:
  edit:
    "*": allow
    "/sensitive/**": deny
  bash:
    "*": ask
    "git push": deny
    "git log*": allow
  webfetch: allow
  question: allow
  websearch: allow
  external_directory:
    "*": ask
    "~/p/**": allow
```

- Actions: `allow` | `ask` | `deny`
- Nested rules support glob patterns (`*`, `**`, wildcards)
- Last matching rule wins

### Mode Field Values

- `primary` — available via Tab switching
- `subagent` — invoked via @mention or by other agents
- `all` — flexible, can be used both ways

### System Prompt Delivery

- Markdown body (after frontmatter) IS the system prompt
- No `{file:...}` syntax in markdown (unlike JSON config)
- Direct markdown content → sent to LLM

### Default Behaviors

- `mode` → `all` (if omitted)
- `model` → global config (primary agents) or parent's model (subagents)
- `temperature` → model-specific default (0 for most, 0.55 for Qwen)
- `permission` → full access (if omitted, all tools enabled)

### Interaction with config.json

- **Both** JSON and markdown agents are loaded
- Markdown agents **override** JSON agents with same name
- No conflict; complementary

### KEY ADVANTAGE: Prompt Changes Don't Require home-manager switch

- File changes → OpenCode reloads on next startup
- NO home-manager switch needed
- This is the primary motivation for file-based migration

### Limitations

- **No subdirectories**: only root level of `.opencode/agents/` scanned
- **No name field**: filename is authoritative
- **Filename must be valid**: [a-z0-9-]+ convention

### Evidence File

- `/home/m3tam3re/p/AI/AGENTS/.sisyphus/evidence/task-4-opencode-agent-format.md`
- Complete spec with examples, frontmatter reference, permission format, YAML/JSON comparison

### Confirmed Answers

- Directory: `agents/` (both global and per-project) ✅
- File naming: Filename determines agent name ✅
- Required fields: `description` only ✅
- Permission format: Nested objects like JSON ✅
- Mode values: `primary` | `subagent` | `all` ✅
- System prompt: Markdown body after frontmatter ✅
- Requires HM switch for prompt changes: **NO** ✅
- Frontmatter needs `name` field: **NO** ✅

### Sources

- https://opencode.ai/docs/agents (official documentation)
- /home/m3tam3re/p/NIX/nixpkgs/modules/home-manager/coding/opencode.nix (current deployment)
- /home/m3tam3re/p/AI/AGENTS/agents/agents.json (current 6 agents)
- /home/m3tam3re/p/AI/AGENTS/AGENTS.md (repo documentation)

## [2026-04-10] Task 4: Key Finding — OpenCode Permission Rule Precedence

- OpenCode uses LAST-MATCHING-RULE-WINS (not first-match!)
- This matters for renderer: when translating `rules[]` array, order must be preserved
- The wildcard `"*"` rule becomes the fallback (keep it first in YAML output, others after)
- OpenCode directory is `.opencode/agents/` (PLURAL), not `.opencode/agent/`
- Global agents: `~/.config/opencode/agents/` (PLURAL too)
- `description` is the only REQUIRED frontmatter field
- Agent name is derived from filename (no `name` field in frontmatter)
- Supported tools: edit, bash, webfetch, question, websearch, external_directory, task
- `task` permission controls which subagents can be invoked (glob patterns)

## [2026-04-10] Task 4: OpenCode Permission YAML Format

The granular format is nested YAML objects, NOT a rule array:

```yaml
permission:
  bash:
    "*": ask # This is the intent/default
    "git status*": allow # These are the rules
    "git push*": deny
```

The renderer must convert from canonical `intent + rules[]` format to this nested YAML format.
The `"*"` key always goes FIRST (as the fallback), then specific rules after it.

## [2026-04-10] Task 5: All 6 agent.toml Files Created

- Directories: agents/{chiron,chiron-forge,hermes,athena,apollo,calliope}/
- Each has: agent.toml + system-prompt.md
- All TOML parse: YES (6/6 verified via `nix eval --impure`)
- Prompt diffs: all zero (6/6 byte-identical)
- Chiron mode: primary
- Chiron-Forge mode: primary
- Other 4 mode: subagent
- Commit: 7a8dd52 (12 files, 543 insertions)
- Permission translation notes:
  - JSON `"*"` key → TOML `intent` field (straightforward)
  - JSON non-`"*"` keys → TOML `rules` array as `"pattern:action"` strings
  - Simple string permissions (e.g., `"question": "allow"`) → `intent` only, no rules array
  - Description trailing periods stripped per SCHEMA.md constraint ("no trailing period")
  - `td *` and `bd *` bash rules in chiron preserved (custom tool aliases)
  - No model field, no prompt field per schema exclusion rules

## [2026-04-10] Task 6: loadAgents + agentsJson Bridge Complete

- Fix applied: description = agent.description + "." (SCHEMA.md has no trailing period; golden file does)
- All 6 agents load correctly via lib.loadAgents
- agentsJson bridge matches golden file exactly (zero diff)
- nix flake check: PASS
- alejandra formatting: PASS
- Commit: a81e178 feat: export loadAgents and backward-compat agentsJson from flake
