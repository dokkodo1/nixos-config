{ config, lib, pkgs, modPath, ... }:

{
  imports = map (file: modPath + "/user/" + file) [
	  "terminal/zsh.nix"
    "terminal/git.nix"
    "nvim/nvim.nix"
    "vim/vim.nix"
    "tmux/tmux.nix"
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