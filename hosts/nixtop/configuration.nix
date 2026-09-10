{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Clamshell
  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandleRebootKey = "ignore";
    HandleSuspendKey = "ignore";
    HandleHibernateKey = "ignore";
    HandleLidSwitch = "ignore";
  };

  control.vaultwarden = {
    enable = true;
    domain = "vault.dokkodo.me";
    signupsAllowed = false;
    adminToken.enable = true;
    backup.enable = true;
  };

  control.searxng = {
    enable = true;
    domain = "search.dokkodo.me";
    publicAccess = true;
    instance.name = "Dokkodo Search";
  };

  control.tailscale.enable = true;
  # control.distributedBackup.allowIncoming = true;
  # control.distributedBackup = {
  #   enable = true;
  #   targets = [ "latitude" "desktop" "hpl-tower" ];
  # };
  # control.monitoring.agent = {
  #   enable = true;
  #   lokiUrl = "http://hpl-tower:3100";
  # };
  control.remoteBuilders = {
    enable = true;
    useBuilders = [
      {
        hostName = "desktop";
        maxJobs = 8;
        speedFactor = 3;
      }
      {
        hostName = "hpl-tower";
        maxJobs = 8;
        speedFactor = 2;
      }
    ];
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
    grub.configurationLimit = 3;
    grub.efiSupport = false;
  };

  hardware.uinput.enable = true;
  environment.systemPackages = with pkgs; [
    deluge
  ];

  programs.nix-ld.enable = true;

  # xdg.mime.defaultApplications = {
  #   "text/html" = "qutebrowser.desktop";
  #   "x-scheme-handler/http" = "qutebrowser.desktop";
  #   "x-scheme-handler/https" = "qutebrowser.desktop";
  #   "x-scheme-handler/about" = "qutebrowser.desktop";
  #   "x-scheme-handler/unknown" = "qutebrowser.desktop";
  # };

  environment.sessionVariables = {
    XKB_DEFAULT_OPTIONS = "caps:swapescape";
  };
}
