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
  # Mandatory
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_ALL = "en_US.UTF-8"; 

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
