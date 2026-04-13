
## [2026-04-10] CRITICAL: Subagent Scope Creep - Skills Deleted
- Tasks 1 & 2 subagent DELETED skills from disk (basecamp, brainstorming, frontend-design, kestra-flow, kestra-ops, obsidian, prompt-engineering-patterns, systematic-debugging, xlsx)
- These were NOT in scope and MUST NOT be touched per the plan
- Skills were restored via: `git checkout HEAD -- skills/`
- ROOT CAUSE: Subagents may try to "clean up" untracked/modified files when working in the repo
- MITIGATION: All future delegation prompts must explicitly state "DO NOT touch skills/ directory or any existing files"

## [2026-04-10] NOTE: nix eval requires --impure for builtins.readFile with absolute paths
- Task 2 spike required `nix eval --impure --expr 'builtins.fromTOML (builtins.readFile <path>)'`
- This is expected for absolute filesystem paths outside the flake
- For flake-based rendering (nixpkgs lib), this is not an issue as files go through `pkgs.writeText` or are read at flake evaluation time via `inputs`
