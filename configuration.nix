{ config, lib, pkgs, inputs, ... }:


{
  imports = [
      ./hardware-configuration.nix
    ];

  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;

  users.users.dokkodo = {
    description = "dokkodo";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "gamemode" "video" "cpu" ];
    packages = with pkgs; [
      # ...
    ];
  };

  boot = {

    kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "fs.file-max" = 524288;
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };


  systemd = {

    packages = with pkgs; [
      lact
    ];

    services = {
      lactd.wantedBy = ["multi-user.target"];
    };

  };

  networking = {

    hostName = "nixos";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [

      ];
    };
  };

  security = {
    
    polkit = {
      enable = true;
      debug = true;

    };
  };

  services = {

    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];
    };

    displayManager = {
      #defaultSession = "plasmax11"; # display server toggle. default is Wayland
      sddm.enable = true;
      sddm.wayland.enable = true;
    };

    desktopManager = {
      plasma6.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

  };

  hardware = {
    
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };

    bluetooth = {
      enable = true;
    };

  };

  nix = {

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "@wheel" ];
      substituters = ["https://nix-citizen.cachix.org"];
      trusted-public-keys = ["nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="];
    };

    gc = {
      automatic = true;
      dates = "weekly";
    };

  };

  programs = {

    git = {
      enable = true;
    };

    vim = {
      enable = true;
    };

    yazi = {
      enable = true;
    };

    firefox = {
      enable = true;
    };

    steam = {
      enable = true;
    };

    gamemode = {
      enable = true;
    };


  };

  environment.systemPackages = with pkgs; [

    alacritty
    bitwarden-desktop

    # comms
    discord
    telegram-desktop

    # editors
    vscode
    sublime

    # hardware/monitoring
    lact
    btop

    # gaming
    mangohud
    lug-helper
    inputs.nix-citizen.packages."x86_64-linux".star-citizen
    protonup-qt
    dxvk

  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    elisa
  ];



  system.stateVersion = "24.11"; # DO NOT TOUCH <<<

}

