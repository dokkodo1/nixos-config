{ config, pkgs, lib, ... }:

{
  users.users.tjey = {
    isNormalUser = true;
    description = "TJey";
    extraGroups = [ "networkmanager" "wheel" "plugdev" ];
    packages = with pkgs; [];
  };
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
