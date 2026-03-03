{
  description = "Opencode Agent Skills — development environment & runtime";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      # Composable runtime for project flakes and home-manager.
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

      # Dev shell for working on this repo (wraps skills-runtime).
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
