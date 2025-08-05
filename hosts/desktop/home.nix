{ config, pkgs, modPath, ... }:

{
  imports = [
    (modPath + "/user")
  ] ++ map (file: modPath + "/user/" + file) [
	  "terminal/kitty.nix"
    "userPrograms"
  ];

  home.username = "dokkodo";
  home.homeDirectory = "/home/dokkodo";

  home.sessionVariables = {

  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
