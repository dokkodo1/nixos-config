{ pkgs, modPath, inputs, username, hostname, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (modPath + "/system")
  ];

  control.display.dwl.enable = true;
  control.audio.enable = true;


  networking.hostName = "nixtop";
  system.stateVersion = "24.11"; # DO NOT TOUCH <<<
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTR{name}=="AT Translated Set 2 keyboard", ATTR{power/control}="on"
    '';

  hardware.enableAllFirmware = true;
  boot.kernelModules = [ "b43" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader = {
    grub.enable = true;
    grub.device = "/dev/sda";
    grub.configurationLimit = 6;
    grub.efiSupport = false;
  };

  security = {
    polkit = {
      enable = true;
      debug = true;
    };
  };

  environment.variables = {
    EDITOR = "nvim";
  };

  programs.neovim.enable = true;

  environment.systemPackages = with pkgs; [
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

  home-manager = {
	  extraSpecialArgs = { inherit inputs username hostname; };
    backupFileExtension = "backup";
    useGlobalPkgs = true;
  };
}

