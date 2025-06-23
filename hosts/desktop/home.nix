{ config, pkgs, ... }:

{
  imports = [
    ./../../modules/user
	  ./../../modules/user/terminal/kitty.nix
    ./../../modules/user/terminal/fastfetch.nix
    ./../../modules/user/userPrograms
  ];

  home.username = "dokkodo";
  home.homeDirectory = "/home/dokkodo";
  nixpkgs.config.allowUnfree = true;

  home.sessionVariables = {

  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
