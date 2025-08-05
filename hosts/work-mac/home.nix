{ config, lib, pkgs, modPath, ... }:

{
  imports = [
	  ./../../modules/user/terminal/zsh.nix
    ./../../modules/user/terminal/git.nix
    ./../../modules/user/nvim/nvim.nix
    ./../../modules/user/vim/vim.nix
    ./../../modules/user/tmux/tmux.nix
  ];

  home.username = "callummcdonald";
  home.homeDirectory = "/Users/callummcdonald";

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    yewtube
  ];

  fonts.fontconfig.enable = true;
  
  home.sessionVariables = {

  };

  home.stateVersion = "24.11";  
}