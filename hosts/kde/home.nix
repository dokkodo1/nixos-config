{ config, pkgs, ... }:

{
  imports = [
	./../../modules/home-manager/git.nix
	./../../modules/home-manager/zsh.nix
	./../../modules/home-manager/Terminals/kitty.nix
        ./../../modules/home-manager/fastfetch.nix
  ];

  home.username = "dokkodo";
  home.homeDirectory = "/home/dokkodo";
  nixpkgs.config.allowUnfree = true;
  home.packages = [

  ];

  home.file = {

  };
  
  home.sessionVariables = {

  };


  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
