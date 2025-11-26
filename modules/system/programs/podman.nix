{ pkgs, ... }:

{
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [
          "--filter=until=24h"
          "--filter=label!=important"
        ];
      };
      defaultNetwork.settings.dns_enabled = true;
    };
    oci-containers.containers."teamspeak6-server" = {
      image = "teamspeaksystems/teamspeak6-server";
      extraOptions = [];
      ports = ["5678:5678"];
    };
  };
  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
