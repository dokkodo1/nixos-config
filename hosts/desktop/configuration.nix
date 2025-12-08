{ pkgs, modPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
    modPath
  ];

  control = {
    audio.enable = true;
    audio.pavucontrol.enable = true;
    gpuVendor = "amd";
    gaming.enable = true;
    gaming.starCitizen.enable = true;
    gaming.launchers.lutris.enable = true;
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.firmware = [ pkgs.linux-firmware ];

  fileSystems."/mnt/sata1" = {
    device = "/dev/disk/by-uuid/3a472f59-0607-46f1-9885-4140a3314895";
    fsType = "ext4";
    options = [ "noatime" "lazytime" "x-systemd.automount" "nofail" ];
  };  
  systemd.tmpfiles.rules = [
    "d /mnt/sata1 0775 dokkodo users - -"
  ];

  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
  };

  programs.firefox.enable = true;
}

