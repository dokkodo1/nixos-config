{ config, pkgs, ... }:

{
  imports = [
    # ...
    
  ];

  home.homeDirectory = "/home/dokkodo";
  home.username = "dokkodo";
  home.stateVersion = "24.11"; # Please read the comment before changing.
  home.sessionPath = [ "$HOME/bin" ];

  home.packages = [

    pkgs.neovim

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

    git = {
      enable = true;
      userName = "dokkodo1";
      userEmail = "callum.dokkodo@gmail.com";
      extraConfig = {
        init.defaultBranch = "main";
        safe.directory = "/etc/nixos";
      };
    };
  };
}
