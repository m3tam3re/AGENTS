# Nix Code Conventions

## Formatting

- Use `alejandra` for formatting
- camelCase for variables, `PascalCase` for types
- 2 space indentation (alejandra default)
- No trailing whitespace

## Flake Structure

```nix
{
  description = "Description here";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.hello;
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.hello ];
        };
      }
    );
}
```

## Module Patterns

Standard module function signature:

```nix
{ config, lib, pkgs, ... }:
{
  options.myService.enable = lib.mkEnableOption "my service";
  config = lib.mkIf config.myService.enable {
    services.myService.enable = true;
  };
}
```

## Conditionals and Merging

- Use `mkIf` for conditional config
- Use `mkMerge` to combine multiple config sets
- Use `mkOptionDefault` for defaults that can be overridden

```nix
config = lib.mkMerge [
  (lib.mkIf cfg.enable { ... })
  (lib.mkIf cfg.extraConfig { ... })
];
```

## Anti-Patterns (AVOID)

### `with pkgs;`
Bad: Pollutes namespace, hard to trace origins
```nix
{ pkgs, ... }:
{
  packages = with pkgs; [ vim git ];
}
```

Good: Explicit references
```nix
{ pkgs, ... }:
{
  packages = [ pkgs.vim pkgs.git ];
}
```

### `builtins.fetchTarball`
Use flake inputs instead. `fetchTarball` is non-reproducible.

### Impure operations
Avoid `import <nixpkgs>` in flakes. Always use inputs.

### `builtins.getAttr` / `builtins.hasAttr`
Use `lib.attrByPath` or `lib.optionalAttrs` instead.

## Home Manager Patterns

```nix
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [ ripgrep fd ];
  programs.zsh.enable = true;
  xdg.configFile."myapp/config".text = "...";
}
```

## Overlays

```nix
{ config, lib, pkgs, ... }:
let
  myOverlay = final: prev: {
    myPackage = prev.myPackage.overrideAttrs (old: { ... });
  };
in
{
  nixpkgs.overlays = [ myOverlay ];
}
```

## Imports and References

- Use flake inputs for dependencies
- `lib` is always available in modules
- Reference packages via `pkgs.packageName`
- Use `callPackage` for complex package definitions

## File Organization

```
flake.nix              # Entry point
modules/               # NixOS modules
  services/
    my-service.nix
overlays/              # Package overrides
  default.nix
```
