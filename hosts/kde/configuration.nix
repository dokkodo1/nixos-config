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
    ./../../modules/nixos/neovim.nix
  ];

  networking.hostName = "kde";


  fileSystems."/mnt/sata1" = {
    device = "/dev/disk/by-uuid/3a472f59-0607-46f1-9885-4140a3314895";
    fsType = "ext4";
    options = [ "noatime" "lazytime" "x-systemd.automount" "nofail" ];
  };  

  systemd.tmpfiles.rules = [
    "d /mnt/sata1 0775 dokkodo users - -"
  ];

  users.users.dokkodo = {
    extraGroups = [ "users" ];
  };


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

    konsave
    parted
    bitwarden-desktop
    bottles
    qbittorrent
    dropbox
    syncthing
    tree
    appimage-run

    # comms
    discord
    telegram-desktop
    whatsapp-for-linux
    vlc
    brave
    zoom-us

    # editors
    vscode
    reaper
    yabridge
    yabridgectl

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

