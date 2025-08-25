{ pkgs, ... }:

{
  services.qbittorrent = {
    enable = true;
    package = pkgs.qbittorrent-nox;
    profileDir = "/var/lib/qbittorrent";
    webuiPort = 8080;
    torrentPort = 58999;
    openFirewall = true;
    serverConfig = {
      "Preferences\\WebUI\\Address" = "127.0.0.1";
      "Preferences\\WebUI\\Port" = 8080;
      "Preferences\\WebUI\\CSRFProtection" = true;      
      "Preferences\\WebUI\\HostHeaderValidation" = true;

      "Preferences\\Downloads\\SavePath" = "/srv/torrents/completed/"
      "Preferences\\Downloads\\TempPathEnabled" = true;
      "Preferences\\Downloads\\TempPath" = "/srv/torrents/incomplete/";

      "Preferences\\Connection\\PortRangeMin" = 58999;
      "Preferences\\Connection\\UPnP" = true;

      "Preferences\\Downloads\\RunExternalProgramEnabled" = false;

      "Preferences\\WubUI\\Username" = "admin";
      "Preferences\\WebUI\\Password_PBKDF2 = "fRUvEZMeV";
      };
    };
  systemd.tmpfiles.rules = [
    "d /var/lib/qbittorrent 0750 qbittorrent qbittorrent - -"
    "d /srv/torrents 0770 qbittorrent qbittorrent - -"
    "d /srv/torrents/complete 0770 qbittorrent qbittorrent - -"
    "d /srv/torrents/incomplete 0770 qbittorrent qbittorrent - -"
  ];
}
