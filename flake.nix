{
  description = "Gleam dev environment for Entomologist";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (_: {

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt-tree;
          devShells.default = pkgs.mkShell {
            shellHook = ''
              export AOC_COOKIE="[REDACTED]"
            '';
            buildInputs = with pkgs; [
              # -- DEVENV --
              # Gleam compiler and tooling
              gleam


              # Erlang stuff
              beamMinimal27Packages.erlang
              beamMinimal27Packages.rebar3
              beamMinimal27Packages.erlfmt
              erlang-language-platform

              # Executes a command when a file change is detected
              watchexec

              # Pre-commit hook helper
              pre-commit

            ]
            ++ lib.optional stdenv.isLinux inotify-tools;
          };
        };

    });
}
