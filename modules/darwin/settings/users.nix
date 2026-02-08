{ pkgs, hostVars, ... }:

{
  users.users.${hostVars.username} = {
    home = "/Users/${hostVars.username}";
    shell = pkgs.zsh;
  };
}
