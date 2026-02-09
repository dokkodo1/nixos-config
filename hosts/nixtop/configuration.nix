{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  control.display.dwl.enable = true;
  control.audio.enable = true;
  control.audio.pavucontrol.enable = true;
  control.tailscale.enable = true;
  control.gaming.enable = true;
  control.remoteBuilders = {
    enable = true;
    useBuilders = [{
      hostName = "hpl-tower";
      maxJobs = 8;
      speedFactor = 2;
    }];
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTR{name}=="AT Translated Set 2 keyboard", ATTR{power/control}="on"
    '';

  powerManagement.cpuFreqGovernor = "performance";
  hardware.enableAllFirmware = true;
  boot.kernelModules = [ "b43" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "threadirqs"
    "preempt=full"
    "i915.modeset=1"
    "i8042.nopnp=1"
    "8042.reset=1"
  ];

  services.resolved.enable = true;
  networking.networkmanager.dns = "systemd-resolved";

  boot.loader = {
    grub.enable = true;
    grub.device = "/dev/sda";
    grub.configurationLimit = 6;
    grub.efiSupport = false;
  };

  hardware.uinput.enable = true;
  environment.systemPackages = with pkgs; [
    deluge
    wineWowPackages.waylandFull
    winetricks
    wine64
    wine
    claude-code
    discord
    bitwarden-desktop
    mesa
    mesa-demos
    mpv
  ];

  programs.nix-ld.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libva-vdpau-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-vaapi-driver
      libva
    ];
  };

  # Default applications for URL opening
  xdg.mime.defaultApplications = {
    "text/html" = "qutebrowser.desktop";
    "x-scheme-handler/http" = "qutebrowser.desktop";
    "x-scheme-handler/https" = "qutebrowser.desktop";
    "x-scheme-handler/about" = "qutebrowser.desktop";
    "x-scheme-handler/unknown" = "qutebrowser.desktop";
  };

  environment.sessionVariables = {
    XKB_DEFAULT_OPTIONS = "caps:swapescape";
  };
}
