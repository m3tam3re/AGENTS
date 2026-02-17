# Rules System - Learnings

## 2026-02-17T17:50 Session Start

### Architecture Pattern
- Nix helper lives in nixpkgs repo (not AGENTS) - follows ports.nix pattern
- AGENTS repo stays pure content (markdown rule files only)
- Pattern: `{lib}: { mkOpencodeRules = ...; }`

### Key Files
- nixpkgs: `/home/m3tam3re/p/NIX/nixpkgs/lib/ports.nix` (reference pattern)
- nixos-config: `/home/m3tam3re/p/NIX/nixos-config/home/features/coding/opencode.nix` (deployment)
- AGENTS: `rules/` directory (content)

### mkOpencodeRules Signature
```nix
mkOpencodeRules {
  agents = inputs.agents;  # Non-flake input path
  languages = [ "python" "typescript" ];
  concerns ? [ "coding-style" "naming" "documentation" "testing" "git-workflow" "project-structure" ];
  frameworks ? [ "n8n" ];
  extraInstructions ? [];
}
```

### Consumption Pattern
```nix
let
  m3taLib = inputs.m3ta-nixpkgs.lib.${system};
  rules = m3taLib.opencode-rules.mkOpencodeRules {
    agents = inputs.agents;
    languages = [ "python" ];
  };
in pkgs.mkShell { shellHook = rules.shellHook; }
```

### Wave 1: Directory Structure (2026-02-17T18:54)
- Successfully created rules/ directory with subdirectories: concerns/, languages/, frameworks/
- Added .gitkeep files to each subdirectory (git needs at least one file to track empty directories)
- Pattern reference: followed skills/ directory structure convention
- USAGE.md already existed in rules/ (created by previous wave)
- AGENTS repo stays pure content - no Nix files added (as planned)
- Verification: ls confirms all three .gitkeep files exist in proper locations

### Wave 2: Nix Helper Implementation (2026-02-17T19:02)
- Successfully created `/home/m3tam3re/p/NIX/nixpkgs/lib/opencode-rules.nix`
- Followed ports.nix pattern EXACTLY: `{lib}: { mkOpencodeRules = ...; }`
- Function signature: `{ agents, languages ? [], concerns ? [...], frameworks ? [], extraInstructions ? [] }`
- Returns: `{ shellHook, instructions }`
- Instructions list built using map functions for each category (concerns, languages, frameworks, extra)
- ShellHook creates symlink `.opencode-rules` → `${agents}/rules` and generates `opencode.json` with `$schema`
- JSON generation uses `builtins.toJSON opencodeConfig` where opencodeConfig = `{ "$schema" = "..."; inherit instructions; }`
- Comprehensive doc comments added matching ports.nix style (multi-line comments with usage examples)
- All paths relative to project root via `.opencode-rules/` prefix
- Verification passed:
  - `nix eval --impure` shows file loads and exposes `mkOpencodeRules`
  - Function returns `{ instructions, shellHook }`
  - Instructions list builds correctly (concerns + languages + frameworks + extra)
  - `nix-instantiate --parse` validates syntax is correct
- ShellHook contains both symlink creation and JSON generation (heredoc pattern)
