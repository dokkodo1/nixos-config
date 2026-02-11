{ pkgs, ... }:

{
  imports = [
    # ./disko-simple.nix
    ./hardware-configuration.nix
  ];

  control.tailscale.enable = true;
  control.gitlab.enable = true;
  control.remoteBuilders.enable = true;
  control.remoteBuilders.serveAsBuilder = true;
  control.teamspeak6 = {
    enable = true;
    acceptLicense = true;
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
