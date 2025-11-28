{ username, ... }:

{
  home-manager.users.${username}.programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ./vimrc;
  };
}
