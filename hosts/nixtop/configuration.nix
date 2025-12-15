{ pkgs, modPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
    modPath
  ];

  control.display.dwl.enable = true;
  control.audio.enable = true;
  control.audio.pavucontrol.enable = true;

  control.gaming.enable = true;
  control.gaming.launchers.lutris.enable = true;


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
  ];
  boot.loader = {
    grub.enable = true;
    grub.device = "/dev/sda";
    grub.configurationLimit = 6;
    grub.efiSupport = false;
  };

  hardware.uinput.enable = true;
  environment.systemPackages = with pkgs; [
    deluge
    bottles
    wineWowPackages.waylandFull
    winetricks
    wine64
    wine
    qbittorrent
    claude-code
    discord
    bitwarden
    mesa
    glxinfo
    mpv
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiIntel
      libva
    ];
  };
}
