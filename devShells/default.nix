{ inputs, lib }:

let
  allSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  linuxSystems = [ "x86_64-linux" "aarch64-linux" ];

  # Shell templates - all take pkgs, return a shell
  templates = {
    c = pkgs: import ./c.nix { inherit pkgs; };
    rust = pkgs: import ./rust.nix { inherit pkgs; };
    haskell = pkgs: import ./haskell.nix { inherit pkgs; };
  };

  mkShellsForSystem = system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      isLinux = builtins.elem system linuxSystems;
    in lib.filterAttrs (_: v: v != null) {
      # Linux-only (use glibc or wayland)
      c = if isLinux then templates.c pkgs else null;

      # Cross-platform
      rust = templates.rust pkgs;
      haskell = templates.haskell pkgs;
    };

in {
  shells = lib.genAttrs allSystems mkShellsForSystem;
  inherit templates;
}
