{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
      #Settings
    ./../../modules/nixos/Settings/users.nix
    ./../../modules/nixos/Settings/time.nix
    ./../../modules/nixos/Settings/hardware.nix
    ./../../modules/nixos/Settings/keyboard-layout.nix
      #Services
    ./../../modules/nixos/Services/bluetooth.nix
    ./../../modules/nixos/Services/networking.nix
    ./../../modules/nixos/Services/sound.nix
    ];

  networking.hostName = "kde";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Star Citizen stuff
    kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "fs.file-max" = 524288;
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

  security = {
    polkit = {
      enable = true;
      debug = true;
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
  };

  home-manager = {
	  extraSpecialArgs = {inherit inputs; };
	  users = {
	    "dokkodo" = import ./home.nix;
	  };
    backupFileExtension = "backup";
  };

  
  programs = {

    vim = {
      enable = true;
    };

    firefox = {
      enable = true;
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    gamemode = {
      enable = true;
    };

    gamescope = {
      enable = true;
    };


  };

  environment.systemPackages = with pkgs; [

    alacritty
    bitwarden-desktop
    qbittorrent

    # comms
    discord
    telegram-desktop
    whatsapp-for-linux
    vlc
    brave
    zoom-us

    # editors
    vscode

    # hardware/monitoring
    lact
    btop

    # gaming
    mangohud
    lug-helper
    inputs.nix-citizen.packages."x86_64-linux".star-citizen
    
    ### really just winging it here, huh?
    protonup-qt
    dxvk
    lutris
    #wine
    wineWowPackages.waylandFull
    wineWowPackages.staging
    winetricks

  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    elisa
  ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11"; # DO NOT TOUCH <<<
}

