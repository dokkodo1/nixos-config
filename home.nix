{ config, pkgs, inputs, ... }:

{
  imports = [
    #./nix-citizen.nix
    
  ];

  home = {
    stateVersion = "24.11"; # DO NOT TOUCH THIS
    homeDirectory = "/home/dokkodo";
    username = "dokkodo";
    sessionPath = [ "/home/dokkodo/bin" ];
    sessionVariables = {
      EDITOR = "nano";
    };

    packages = with pkgs; [
      neovim
    ];

    file = {
    };
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
