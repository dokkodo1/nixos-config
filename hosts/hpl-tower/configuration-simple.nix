{ pkgs, modPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-simple.nix
    modPath
  ];

  # Boot configuration for EFI
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Hardware-specific settings
  hardware.enableAllFirmware = true;
  
  # Create storage directories
  systemd.tmpfiles.rules = [
    "d /storage 0755 dokkodo users"
    "d /storage/projects 0755 dokkodo users"
    "d /storage/media 0755 dokkodo users"
    "d /storage/disk1 0755 dokkodo users"
    "d /storage/disk2 0755 dokkodo users"
  ];
}