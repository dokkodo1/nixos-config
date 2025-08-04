{ config, pkgs, modPath, ... }:

{
  imports = [
    (modPath + "/user")
	  (modPath + "/user/terminal/kitty.nix")
    (modPath + "/user/userPrograms")
  ];

  home.username = "dokkodo";
  home.homeDirectory = "/home/dokkodo";

  home.sessionVariables = {

  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
