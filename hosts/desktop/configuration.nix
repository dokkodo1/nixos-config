{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  control = {
    audio.enable = true;
    audio.pavucontrol.enable = true;
    gpuVendor = "amd";
    display.kde.enable = true;
    display.dwl.enable = true;
    gaming.enable = true;
    gaming.starCitizen.enable = true;
    gaming.launchers.lutris.enable = true;
    tailscale.enable = true;
    distributedBackup.allowIncoming = true;
  };

  programs.nix-ld.enable = true;

  environment.sessionVariables = {
    XKB_DEFAULT_OPTIONS = "caps:swapescape";
  };

  environment.systemPackages = with pkgs; [
    teamspeak6-client
    claude-code
    bitwarden-desktop
  ];

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

  services.displayManager.sddm.enable = false;

  programs.firefox.enable = true;
}

