{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/alacritty.nix
  ];

  home = {
    stateVersion = "24.11"; # DO NOT TOUCH THIS
    homeDirectory = "/home/dokkodo";
    username = "dokkodo";
    sessionPath = [ "/home/dokkodo/bin" ];
    sessionVariables = {
      EDITOR = "nano";
      BROWSER = "firefox";
      TERMINAL = "alacritty";
    };

    packages = with pkgs; [
      # ...
    ];

    file = {
      # ...
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
