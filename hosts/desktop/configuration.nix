{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.firmware = [ pkgs.linux-firmware ];
  fileSystems."/mnt/sata1" = {
    device = "/dev/disk/by-uuid/3a472f59-0607-46f1-9885-4140a3314895";
    fsType = "ext4";
    options = [ "noatime" "lazytime" "x-systemd.automount" "nofail" ];
  };  
  systemd.tmpfiles.rules = [
    "d /mnt/sata1 0775 dokkodo users - -"
  ];

  nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ]; # failed build, probably temporary fix. didn't feel like searching for which package broke it...

  control = {
    remoteBuilders.enable = true;
    remoteBuilders.serveAsBuilder = true;
    audio.enable = true;
    audio.pavucontrol.enable = true;
    audio.proAudio.enable = true;
    audio.proAudio.reaper.enable = true;
    audio.audioShare.enable = false;
    gpuVendor = "amd";
    display.kde.enable = true;
    display.dwl.enable = true;
    gaming.enable = true;
    # gaming.gamescope = true;
    gaming.starCitizen.enable = true;
    gaming.launchers.lutris.enable = true;
    gaming.extras.openrgb.enable = true;
    tailscale.enable = true;
    distributedBackup.allowIncoming = true;
    # monitoring.agent = {
    #   enable = false;
    #   # lokiUrl = "http://hpl-tower:3100";
    # };
  };

  programs.nix-ld.enable = true;
  programs.firefox.enable = true;
  services.displayManager.sddm.enable = false;

  environment.systemPackages = with pkgs; [
    zoom-us
    vlc
    deluge
    teamspeak6-client
    bitwarden-desktop
    zapzap
    telegram-desktop
  ];

  environment.sessionVariables.XKB_DEFAULT_OPTIONS = "caps:swapescape";
}

