{ config, pkgs, ... }:

{
  imports = [
    ./../../modules/user
  ];

  home.username = "dokkodo";
  home.homeDirectory = "/home/dokkodo";
  
  home.sessionVariables = {

  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
