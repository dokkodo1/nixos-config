{ config, pkgs, ... }:

{
  imports = [
	./../../modules/home-manager/git.nix
	./../../modules/home-manager/zsh.nix
	./../../modules/home-manager/Terminals/kitty.nix
	./../../modules/home-manager/neovim/neovim.nix
  ];

  home.packages = with pkgs; [

  ];

  home.file = {

  };
  
  home.sessionVariables = {

  };

  
}