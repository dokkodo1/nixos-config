{ config, pkgs, lib, ... }:

{
  #Hard drives

  fileSystems."/mnt/sata1" = {
    device = "/dev/disk/by-uuid/3a472f59-0607-46f1-9885-4140a3314895";
    fsType = "ext4";
    options = [ "noatime" "lazytime" "x-systemd.automount" "nofail" ];
  };  
  systemd.tmpfiles.rules = [
    "d /mnt/sata1 0775 dokkodo users - -"
  ];

  #Grapics card
  
  environment.systemPackages = [ pkgs.lact ];
  systemd = {
    packages = [ pkgs.lact ];
    services.lactd.wantedBy = [ "multi-user.target" ];
  };

  hardware.graphics = {
    # NixOS enables Vulkan through Mesa RADV by default
    # https://nixos.org/manual/nixos/unstable/index.html#sec-gpu-accel-vulkan

    # openGL / Mesa
    enable = true;
    enable32Bit = true;

    # AMDVLK  
    extraPackages = [ pkgs.amdvlk ];
    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };
}
