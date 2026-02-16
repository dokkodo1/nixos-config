{ pkgs, ... }:

{
  imports = [
    # ./disko-simple.nix
    ./hardware-configuration.nix
  ];

  control.remoteBuilders.enable = true;
  control.remoteBuilders.serveAsBuilder = true;
  control.tailscale.enable = true;
  control.gitlab.enable = true;
  control.teamspeak6 = {
    enable = true;
    acceptLicense = true;
  };

  control.vaultwarden = {
    enable = true;
    domain = "vault.dokkodo.me";
    signupsAllowed = false;
    adminToken.enable = true;
    backup.enable = true;
  };

  control.matrix = {
    enable = true;
    baseDomain = "dokkodo.me";
    mediaRetention = {
      enable = true;
      remoteMediaLifetimeDays = 90;
    };
  };

  control.distributedBackup = {
    enable = true;
    targets = [ "nixtop" "desktop" ];
  };

  control.monitoring = {
    enable = true;
    grafana.domain = "grafana.dokkodo.me";
    prometheus.remoteTargets = [ "nixtop" "desktop" ];

    alertmanager = {
      enable = true;
      matrix = {
        enable = true;
        roomId = "!jYHruqewzLjIDOBihd:dokkodo.me";
      };
    };
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.enableAllFirmware = true;

  environment.systemPackages = with pkgs; [
    claude-code
  ];
}
