{ lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Basic required configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Minimal filesystems (no disko)
  fileSystems."/" =
    { device = "/dev/sdc2";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/sdc1";
      fsType = "vfat";
    };

  system.stateVersion = "24.11";
}