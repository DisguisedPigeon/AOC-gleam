{
  description = "Gleam dev shell";
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
          buildInputs =
            with pkgs;
            (
              [
                watchexec
                gleam
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
