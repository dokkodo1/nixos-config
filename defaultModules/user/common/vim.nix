{ pkgs, lib, config, ... }:
{
#  programs.vim.enable = true;
  home.file = { ".vimrc".source = ./vimrc; };
}
