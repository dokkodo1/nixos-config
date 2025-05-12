{ config, pkgs, ... }:

{
  imports = [
	./../../modules/user/git.nix
	./../../modules/darwin/zsh.nix
  ];

  home.username = "callummcdonald";
  home.homeDirectory = "/Users/callummcdonald";

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;

  home.file = {
    ".vimrc".source = ./../../modules/user/vim/vimrc;
  };
  
  home.sessionVariables = {

  };

  home.stateVersion = "24.11";  
}