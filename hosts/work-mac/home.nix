{ config, pkgs, ... }:

{
  imports = [
	./../../modules/home-manager/git.nix
	./../../modules/home-manager/zsh.nix
	./../../modules/home-manager/Terminals/kitty.nix
	./../../modules/home-manager/neovim/neovim.nix
  ];

  home.username = "callummcdonald";
  home.homeDirectory = "/Users/callummcdonald";

  home.packages = with pkgs; [

  ];

  home.file = {

  };
  
  home.sessionVariables = {

  };

  home.stateVersion = "24.11";  
}