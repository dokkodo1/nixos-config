{ pkgs, lib, config, ... }: {
  programs.tmux = {
    enable = true;
    extraConfig = ''
      source-file ${./tmux.conf}
    '';
  };
}
