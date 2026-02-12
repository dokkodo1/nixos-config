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

  control.distributedBackup = {
    enable = true;
    targets = [ "nixtop" "desktop" ];
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
