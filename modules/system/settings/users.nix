{ config, pkgs, lib, ... }:

{
  users.users.dokkodo = {
    description = "dokkodo";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "gamemode"
      "video"
      "cpu"
      "users"
      ];
    packages = with pkgs; [
      
    ];
  };
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
