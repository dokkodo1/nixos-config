{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      source-file ${./tmux.conf}
    '';
  };
}
