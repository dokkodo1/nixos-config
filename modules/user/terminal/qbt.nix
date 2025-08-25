{ pkgs, ... }:
{
  home.packages = with pkgs; [
    qbittorrent-cli
    urlview
    lynx
    curl
  ];

  xdg.configFile."qbt/.qbt.toml".text = ''
    [qbittorrent]
    addr      = "http://127.0.0.1:8080"
    login     = "admin"
    password  = "somepassword"
    [rules]
    enable = true
    max_active_downloads = 2
  '';
}
