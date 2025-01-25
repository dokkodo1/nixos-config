{ config, pkgs, ... }:

{
  imports = [
    # ...
    
  ];

  home.homeDirectory = "/home/dokkodo";
  home.username = "dokkodo";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  home.packages = [

  ];


  home.file = {

  };

  home.sessionVariables = {
    EDITOR = "nano";
  };


  programs = {

    home-manager.enable = true;

    bash = {
      enable = true;
      shellAliases = {
        ".." = "cd ..";
      };
    };
  };
}
