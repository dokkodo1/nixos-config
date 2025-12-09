{ pkgs, username, darwinUsername ? null, ... }:

let
  actualUsername = if pkgs.stdenv.isDarwin && darwinUsername != null
    then darwinUsername
    else username;
in
{
  home-manager.users.${actualUsername}.programs.qutebrowser = {
    enable = true;
    extraConfig = builtins.readFile ./config.py;
  };
}
