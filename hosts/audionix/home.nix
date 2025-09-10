{ modPath, ... }:

{
  imports = [
    (modPath + "/user")
    (modPath + "/user/terminal/kitty.nix")
  ];

  home.username = "dokkodo";
  home.homeDirectory = "/home/dokkodo";
  
  home.sessionVariables = {

  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
