{ hostVars, ... }:

{
  home-manager.users.${hostVars.username} = {
    programs.qutebrowser = {
      enable = true;
      extraConfig = builtins.readFile ./config.py;
    };
  };
}
