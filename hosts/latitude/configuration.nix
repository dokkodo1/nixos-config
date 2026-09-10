{ pkgs, hostVars, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [ "electron-39.8.10" ]; # failed build, probably temporary fix. didn't feel like searching for which package broke it...
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.firmware = [ pkgs.linux-firmware ];

  control = {
    audio.enable = true;
    audio.pavucontrol.enable = true;
    audio.audioShare.enable = false;
    gpuVendor = "amd";
    display.kde.enable = true;
    display.dwl.enable = true;
    gaming.enable = true;
    gaming.launchers.lutris.enable = true;
    tailscale.enable = true;
    distributedBackup.allowIncoming = true;
  };

  programs.nix-ld.enable = true;
  programs.firefox.enable = true;
  services.displayManager.sddm.enable = false;
  home-manager.users.${hostVars.username} = {
    # services.emacs.enable = true;
    # programs.emacs = {
    #   enable = true;
    #   extraConfig = ''
    #     source-file ${./init.el}
    #   '';
    # };
  };

  environment.systemPackages = with pkgs; [
    zathura
    ghc
    python3
    vlc
    reaper
    deluge
    teamspeak6-client
    bitwarden-desktop
    zapzap
    telegram-desktop
  ];

  environment.sessionVariables.XKB_DEFAULT_OPTIONS = "caps:swapescape";
}

