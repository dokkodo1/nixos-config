{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.firmware = [ pkgs.linux-firmware ];
  fileSystems."/mnt/sata1" = {
    device = "/dev/disk/by-uuid/3a472f59-0607-46f1-9885-4140a3314895";
    fsType = "ext4";
    options = [ "noatime" "lazytime" "x-systemd.automount" "nofail" ];
  };  
  systemd.tmpfiles.rules = [
    "d /mnt/sata1 0775 dokkodo users - -"
  ];

  control = {
    audio.enable = true;
    audio.pavucontrol.enable = true;
    audio.audioShare.enable = false;
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
  programs.firefox.enable = true;
  services.displayManager.sddm.enable = false;

  environment.systemPackages = with pkgs; [
    teamspeak6-client
    claude-code
    bitwarden-desktop
  ];

  environment.sessionVariables.XKB_DEFAULT_OPTIONS = "caps:swapescape";
}

