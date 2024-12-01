{
  description = "Gleam dev shell for all supported systems";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    systems.url = "github:nix-systems/default";
  };
  outputs =
    { systems, nixpkgs, ... }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          shellHook = ''
            export DATABASE_URL=postgres://postgres:postgres@localhost:5432/pigeon_post;
          '';
          buildInputs =
            with pkgs;
            (
              [
                gleam
                erlang-ls
                rebar3
                beam.interpreters.erlang_27
                nixd
              ]
              ++ lib.optional stdenv.isLinux inotify-tools
            );
        };
      });
    };
}
