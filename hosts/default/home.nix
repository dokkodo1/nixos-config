{ config, pkgs, ... }:

{
  imports = [
	./../../modules/home-manager/git.nix
  ];

  home.username = "dokkodo";
  home.homeDirectory = "/home/dokkodo";


  home.packages = [

  ];

  home.file = {

  };
  
  home.sessionVariables = {

  };


  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
