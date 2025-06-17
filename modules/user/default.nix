{ pkgs, lib, config, ... }:

{
  imports = [
    ./terminal/git.nix
    ./terminal/zsh.nix
    ./tmux/tmux.nix
    ./vim/vim.nix
  ];
}
