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
    packages = with pkgs; [
      
    ];

  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
