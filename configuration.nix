{ config, lib, pkgs, inputs, ... }:

let

system = "x86_64-linux";
username = "dokkodo";
host = "nixos";

in

{
  imports = [
      ./hardware-configuration.nix
    ];


  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;      # home

  users.users.dokkodo = {
    description = "dokkodo";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "gamemode" "video" "cpu" ];
    packages = with pkgs; [
      # ...
    ];
  };

  boot = {

    kernelPackages = pkgs.linuxPackages_latest;

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
      videoDrivers = [ "modesetting" ];
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

    git = {             # home
      enable = true;
    };

    vim = {
      enable = true;
    };

    firefox = {         # home
      enable = true;
    };

    steam = {           # home
      enable = true;
      gamescopeSession.enable = true;
    };

    gamemode = {        # home
      enable = true;
    };

    gamescope = {       # home
      enable = true;
    };


  };

  environment.systemPackages = with pkgs; [

    alacritty
    bitwarden-desktop             # home
    qbittorrent                   # home

    # comms         
    discord         
    telegram-desktop              # home
    whatsapp-for-linux            # home
    vlc                           # home
    brave                         # home
    zoom-us                       # home

    # editors         
    vscode                        # home

    # hardware/monitoring
    lact
    btop

    # gaming
    mangohud                      # home
    lug-helper                    # home
    inputs.nix-citizen.packages."x86_64-linux".star-citizen    # home
    
    ### really just winging it here, huh?
    protonup-qt                   # home
    dxvk                          # home
    lutris                        # home
    #wine
    wineWowPackages.waylandFull   # home
    wineWowPackages.staging       # home
    winetricks                    # home

  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    elisa
  ];

  environment.shellAliases = {
    nixup = "sudo nixos-rebuild switch --flake /home/dokkodo/configurations/.#nixos";
    nixedit = "sudo vim /home/dokkodo/configurations/configuration.nix";
    nixhwedit = "sudo vim /home/dokkodo/configurations/hardware-configuration.nix";

  };

  system.stateVersion = "24.11"; # DO NOT TOUCH <<<

}

