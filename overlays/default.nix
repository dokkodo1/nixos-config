{ inputs }:

[
  inputs.neovim-nightly-overlay.overlays.default
  (import ./doxpkgs.nix)
  (import ./dwl.nix { inherit inputs; })
]
