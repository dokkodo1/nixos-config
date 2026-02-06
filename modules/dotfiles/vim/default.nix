{ hostVars, ... }:

{
  home-manager.users.${hostVars.username}.programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ./vimrc;
  };
}
