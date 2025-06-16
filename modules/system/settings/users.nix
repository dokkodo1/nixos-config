{ config, pkgs, lib, ... }:

{
  users.users.dokkodo = {
    description = "dokkodo";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "users"
      "networkmanager"
      "gamemode"
      "video"
      "cpu"
    ];
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
