{ inputs }:

[
  inputs.neovim-nightly-overlay.overlays.default
  (import ./doxpkgs.nix)
]
