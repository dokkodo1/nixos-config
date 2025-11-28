{ username, ... }:

{
  home-manager.users.${username}.programs.tmux = {
    enable = true;
    extraConfig = ''
      source-file ${./tmux.conf}
    '';
  };
}
