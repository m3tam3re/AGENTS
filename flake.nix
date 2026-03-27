{
  description = "Opencode Agent Skills — development environment & runtime";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      inherit (nixpkgs) lib;
    in {

      # ── Skill composition library ──────────────────────────────────
      #
      # Merges custom skills with external skills.sh sources into a
      # single directory suitable for ~/.config/opencode/skills or
      # .agents/skills in project flakes.
      #
      # Usage (home-manager):
      #   xdg.configFile."opencode/skills".source =
      #     inputs.agents.lib.mkOpencodeSkills {
      #       pkgs = nixpkgs.legacyPackages.${system};
      #       customSkills = "${inputs.agents}/skills";
      #       externalSkills = [
      #         { src = inputs.skills-anthropic; }
      #         { src = inputs.skills-vercel; selectSkills = [ "find-skills" ]; }
      #       ];
      #     };
      #
      # Usage (project flake — project-level skills):
      #   ".agents/skills".source =
      #     inputs.agents.lib.mkOpencodeSkills {
      #       pkgs = nixpkgs.legacyPackages.${system};
      #       externalSkills = [
      #         { src = inputs.skills-anthropic; selectSkills = [ "mcp-builder" ]; }
      #       ];
      #     };
      #
      # Parameters:
      #   pkgs           — nixpkgs package set (required)
      #   customSkills   — path to a directory of skill subdirectories (optional)
      #   externalSkills — list of external skill sources (optional, default [])
      #     Each element is an attrset:
      #       src          — path to repo root (flake input or local path)
      #       skillsDir    — subdirectory containing skills (default "skills")
      #       selectSkills — list of skill names to include (default: all)
      #
      # Collision handling:
      #   Custom skills always take priority over external ones.
      #   Among external sources, earlier entries in the list take priority.

      lib.mkOpencodeSkills =
        { pkgs
        , customSkills ? null
        , externalSkills ? []
        }:
        let
          # Resolve a single external source into a list of { name, path } entries.
          resolveExternal = entry:
            let
              skillsRoot = "${entry.src}/${entry.skillsDir or "skills"}";
              # List skill subdirectories (each must contain SKILL.md).
              allSkillDirs = lib.pipe (builtins.readDir skillsRoot) [
                (lib.filterAttrs (_: type: type == "directory"))
                (dirs: lib.attrNames dirs)
              ];
              selected =
                if entry ? selectSkills
                then builtins.filter (name: builtins.elem name entry.selectSkills) allSkillDirs
                else allSkillDirs;
            in
              map (name: { inherit name; path = "${skillsRoot}/${name}"; }) selected;

          # Collect all external skills, flattened.
          allExternal = lib.concatMap resolveExternal externalSkills;

          # Collect custom skill names for collision detection.
          customSkillNames =
            if customSkills != null
            then lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir customSkills))
            else [];

          # Filter out external skills that collide with custom ones.
          # Among externals, keep first occurrence (earlier sources win).
          filterExternals = externals:
            let
              go = acc: remaining:
                if remaining == []
                then acc.result
                else
                  let
                    head = builtins.head remaining;
                    tail = builtins.tail remaining;
                    isDuplicate = builtins.elem head.name acc.seen;
                  in
                    if isDuplicate
                    then go acc tail
                    else go {
                      seen = acc.seen ++ [ head.name ];
                      result = acc.result ++ [ head ];
                    } tail;
            in
              go { seen = customSkillNames; result = []; } externals;

          filteredExternal = filterExternals allExternal;

          # Build a linkFarm entry for each external skill.
          externalLinks = map (skill: {
            name = skill.name;
            path = skill.path;
          }) filteredExternal;

          # Build a linkFarm entry for each custom skill.
          customLinks =
            if customSkills != null
            then map (name: {
              inherit name;
              path = "${customSkills}/${name}";
            }) customSkillNames
            else [];

        in
          pkgs.linkFarm "opencode-skills" (customLinks ++ externalLinks);

      # ── Composable runtime ─────────────────────────────────────────
      #
      # Runtime dependencies for skill scripts (Python packages, system
      # tools). Include in home.packages or project devShells.
      #
      # Usage:
      #   home.packages = [ inputs.agents.packages.${system}.skills-runtime ];
      #   devShells.default = pkgs.mkShell {
      #     packages = [ inputs.agents.packages.${system}.skills-runtime ];
      #   };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          pythonEnv = pkgs.python3.withPackages (ps:
            with ps; [
              # skill-creator: quick_validate.py
              pyyaml

              # xlsx: recalc.py
              openpyxl

              # prompt-engineering-patterns: optimize-prompt.py
              numpy

              # pdf: multiple scripts
              pypdf
              pillow # PIL
              pdf2image

              # excalidraw: render_excalidraw.py
              playwright
            ]);
        in {
          skills-runtime = pkgs.buildEnv {
            name = "opencode-skills-runtime";
            paths = [
              pythonEnv
              pkgs.poppler-utils # pdf: pdftoppm/pdfinfo
              pkgs.jq            # shell scripts
              pkgs.playwright-driver.browsers  # excalidraw: chromium for rendering
            ];
          };
        });

      # ── Dev shell ──────────────────────────────────────────────────

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = [ self.packages.${system}.skills-runtime ];

            env.PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";

            shellHook = ''
              echo "🔧 AGENTS dev shell active — Python $(python3 --version 2>&1 | cut -d' ' -f2), $(jq --version)"
            '';
          };
        });
    };
}
