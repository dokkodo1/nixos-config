{ pkgs, lib, config, ... }: {
  programs.tmux = {
    enable = true;
    extraConfig = ''
      source-file ${./tmux.conf}
    '';
  };

  home.packages = with pkgs; lib.optionals (config.networking.hostName != "nixtop") [
    wl-clipboard
  ];
}