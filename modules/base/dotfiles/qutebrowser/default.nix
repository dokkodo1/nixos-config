{ username, ... }:

{
  home-manager.users.${username}.programs.qutebrowser = {
    enable = true;
    extraConfig = builtins.readFile ./config.py;
  };
}
