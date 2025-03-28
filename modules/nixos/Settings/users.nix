{ config, pkgs, lib, ... }:

{
  users.users.evan = {
    description = "evan";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "gamemode" "video" "cpu" ];
    packages = with pkgs; [
      
    ];
  };
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
