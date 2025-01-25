{ config, lib, pkgs, ... }:


{
  # Import hardware configuration
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader configuration (systemd-boot for EFI)
  boot.loader = {
    grub.memtest86.enable = true;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  systemd = {
    packages = with pkgs; [ lact ];
    services = {
      lactd.wantedBy = ["multi-user.target"];
      systemd-journal-upload.enable = true;
    };
  };

  # persistent logging
  services.journald = {
    storage = "persistent";
    compress = true;
  };

  # shell
  users.users.root.shell = pkgs.bash; # Root shell configuration
  environment.shells = with pkgs; [ bash ];
  users.defaultUserShell = pkgs.bash;
  

  nixpkgs.config.allowUnfree = true;  
  nix.settings.experimental-features = ["nix-command" "flakes"];
  security.rtkit.enable = true; # For real-time tasks 

  # Hostname and networking settings
  networking.hostName = "nixos"; 
  time.timeZone = "Africa/Johannesburg"; # Set time zone
  i18n.defaultLocale = "en_US.UTF-8";  # Set locale
  networking.networkmanager.enable = true;

  # Enable bluetooth 
  hardware.bluetooth = {

    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
	      Experimental = false;
      };
    };
  };


  hardware = {
    # graphics driver
    graphics = {
      enable = true;
      enable32Bit = true;
      #extraPackages = with pkgs; [ amdvlk ];
    };
    # graphics driver
    amdgpu.amdvlk = {
      enable = false;
      support32Bit.enable = false;
    };

    enableAllFirmware = true;

  };

  # Enable x11 with video drivers and configure keymap
  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" "amdgpu" ];
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable KDE Plasma Desktop
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;


  # audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User configuration
  users.users.dokkodo = {
    isNormalUser = true;
    description = "dokkodo";
    extraGroups = [ "wheel" "networkmanager" "cpu" "video" "gamemode" ];
    shell = pkgs.bash;
  };

  nix.settings.allowed-users = [ "@wheel" "@builder" "dokkodo" ];

  programs = {

    gamemode = {
      enable = true;
    };

    gamescope = {
      enable = true;
      capSysNice = true;
    };

    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
  };  


  # System packages
  environment.systemPackages = with pkgs; [
    
    wget
    bitwarden
    reaper
    
    # comms
    brave
    firefox
    discord
    qbittorrent
    telegram-desktop
    mc
    neofetch

    # dev
    vscode
    python3
    git
    nixos-generators
    gnumake
    speedtest-cli

    # monitoring
    htop
    btop
    radeontop
    tree
    traceroute

    pciutils
    lshw
    lsof
    dmidecode
    sysstat  # System performance monitoring tools
    stress-ng  # Stress testing
    iotop    # I/O monitoring

    
    # office
    libreoffice
    vim
    vlc

    # gaming
    steam
    gamemode
    mangohud
    lact
    lutris
    wine
    #wine64Packages.unstable
    #inetricks
  ];

  
  # controller support
  hardware.steam-hardware.enable = true;




  # System state version (important for upgrades)
  system.stateVersion = "24.11";

}
