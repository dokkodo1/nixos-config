{ pkgs, ... }:

{
  imports = [
    # ./disko-simple.nix
    ./hardware-configuration.nix
  ];

  control.tailscale.enable = true;
  control.gitlab.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.enableAllFirmware = true;

  environment.systemPackages = with pkgs; [
    claude-code
  ];
}
