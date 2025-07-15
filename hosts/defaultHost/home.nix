{ config, pkgs, ... }:

{
  imports = [
    ./../../defaultModules/user/common
  ];

  home.username = "dokkodo";
  home.homeDirectory = "/home/dokkodo";
  nixpkgs.config.allowUnfree = true;
  
  home.sessionVariables = {

  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
