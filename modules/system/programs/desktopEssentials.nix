{ pkgs, lib, ... }:

{

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    qbittorrent
    dropbox
    telegram-desktop
    whatsapp-for-linux
    zoom-us
    vlc
    ungoogled-chromium
    gimp3
    teamspeak6-client
  ];
}
