# Opencode Rules Usage

Add AI coding rules to your project via `mkOpencodeRules`.

## flake.nix Setup

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    m3ta-nixpkgs.url = "git+https://code.m3ta.dev/m3tam3re/nixpkgs";
    agents = {
      url = "git+https://code.m3ta.dev/m3tam3re/AGENTS";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, m3ta-nixpkgs, agents, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      m3taLib = m3ta-nixpkgs.lib.${system};
    in {
      devShells.${system}.default = let
        rules = m3taLib.opencode-rules.mkOpencodeRules {
          inherit agents;
          languages = [ "python" "typescript" ];
          frameworks = [ "n8n" ];
        };
      in pkgs.mkShell {
        shellHook = rules.shellHook;
      };
    };
}
```

## Parameters

- `agents` (required): Path to AGENTS repo flake input
- `languages` (optional): List of language names (e.g., `["python" "typescript"]`)
- `concerns` (optional): Rule categories (default: all standard concerns)
- `frameworks` (optional): List of framework names (e.g., `["n8n" "django"]`)
- `extraInstructions` (optional): Additional instruction file paths

## .gitignore

Add to your project's `.gitignore`:
```
.opencode-rules
opencode.json
```

## Project Overrides

Create `AGENTS.md` in your project root to override central rules. OpenCode applies project-level rules with precedence over central ones.

## Updating Rules

When central rules are updated:
```bash
nix flake update agents
```
