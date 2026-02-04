{ pkgs, userVars, ... }:

let
  actualUsername = if pkgs.stdenv.isDarwin && userVars.darwinUsername != null
    then userVars.darwinUsername
    else userVars.username;
in
{
  home-manager.users.${actualUsername} = {
    programs.qutebrowser = {
      enable = true;
      extraConfig = builtins.readFile ./config.py;
    };
  };
}
