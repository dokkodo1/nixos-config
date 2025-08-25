{ pkgs, modPath, ... }:

{
  imports = [
    (modPath + "/user")
  ];

  home.username = "callummcdonald";
  home.homeDirectory = "/Users/callummcdonald";

  home.packages = with pkgs; [
    #nerd-fonts.jetbrains-mono
    yewtube
  ];

  fonts.fontconfig.enable = true;
  
  home.sessionVariables = {

  };

  home.stateVersion = "24.11";  
}
