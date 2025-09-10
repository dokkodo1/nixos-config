{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    vscode
    bitwarden-desktop
    qbittorrent
    dropbox
    telegram-desktop
    whatsapp-for-linux
    zoom-us
    vlc
    ungoogled-chromium
    gimp3
  ];
}
