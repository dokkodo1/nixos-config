{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
      #Settings
    ./../../modules/nixos/Settings/users.nix
    ./../../modules/nixos/Settings/time.nix
    ./../../modules/nixos/Settings/hardware.nix # may need to be edited
    ./../../modules/nixos/Settings/keyboard-layout.nix
      #Services
    ./../../modules/nixos/Services/bluetooth.nix
    ./../../modules/nixos/Services/networking.nix
    ./../../modules/nixos/Services/sound.nix
  ];

  networking.hostName = "kde";

  users.users.evan = {
    extraGroups = [ "users" ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
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
	    "evan" = import ./home.nix;
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

    konsave
    parted
    bitwarden-desktop
    qbittorrent


    # comms
    discord
    whatsapp-for-linux
    vlc
    brave
    zoom-us

    # hardware/monitoring
    lact
    btop
    tree

    # gaming
    mangohud
    bottles
    appimage-run

    ### really just winging it here, huh?
    protonup-qt
    dxvk
    lutris
    wineWowPackages.waylandFull
    wineWowPackages.staging
    winetricks

  ];
  
  environment.variables = {
    EDITOR = "kate";
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    elisa
  ];

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11"; # DO NOT TOUCH <<<
}

