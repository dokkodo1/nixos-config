{ config, lib, pkgs, inputs, ... }:


{
  imports = [
    ./hardware-configuration.nix
  ];

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
    #dropbox
    user.services.dropbox = {
      description = "Dropbox";
      wantedBy = [ "graphical-session.target" ];
      environment = {
        QT_PLUGIN_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix;
        QML2_IMPORT_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtQmlPrefix;
      };
      serviceConfig = {
        ExecStart = "${lib.getBin pkgs.dropbox}/bin/dropbox";
        ExecReload = "${lib.getBin pkgs.coreutils}/bin/kill -HUP $MAINPID";
        KillMode = "control-group"; # upstream recommends process
        Restart = "on-failure";
        PrivateTmp = true;
        ProtectSystem = "full";
        Nice = 10;
      };      
    };
  };
  
  nixpkgs.config = {
    allowUnfree = true;
    debugInfo = true;
  };

  nix = {
    settings = {
      allowed-users = [ "@wheel" "@builder" "dokkodo" ];
      experimental-features = ["nix-command" "flakes"];
      ### STAR CITIZEN STUFF
      substituters = ["https://nix-citizen.cachix.org"];
      trusted-public-keys = ["nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="];
      ### ^^^^^
    };
  };
  ### STAR CITIZEN STUFF
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };  
  ### ^^^^^

  security.rtkit.enable = true; # For real-time tasks 


  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall = {
      #dropbox
      allowedTCPPorts = [ 17500 ];
      allowedUDPPorts = [ 17500 ];
    };
  };


  hardware = {

    graphics = {
      enable = true;
      enable32Bit = true;
      #extraPackages = with pkgs; [ amdvlk ];
    };

    amdgpu.amdvlk = {
      enable = false;
      support32Bit.enable = false;
    };

    enableAllFirmware = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
	        Experimental = false;
        };
      };
    };
    steam-hardware.enable = true;
  };
  services = {

    xserver = {
      enable = true;
      videoDrivers = [ "modesetting" "amdgpu" ];
      xkb.layout = "us";
      xkb.variant = "";
      desktopManager.plasma5.enable = true;
    };
    
    displayManager = {
      sddm.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    journald = {
      storage = "persistent";
      extraConfig = ''
        Compress=true
      '';
    };


  };

  users = {
    defaultUserShell = pkgs.bash;
    users = {
      root.shell = pkgs.bash;
      dokkodo = {
        isNormalUser = true;
        description = "dokkodo";
        extraGroups = [ "wheel" "networkmanager" "cpu" "video" "gamemode" ];
        shell = pkgs.bash;
      };
    };
  };


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

    nano = {
      enable = true;
      nanorc = ''
        set autoindent
        set linenumbers
        set mouse
      '';
      syntaxHighlight = true;
    };    
  };  

  environment = {
    shells = with pkgs; [ bash ];
    systemPackages = with pkgs; [

      wget
      bitwarden
      reaper
      dropbox-cli

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
      protonup-qt
      steam
      gamemode
      mangohud
      lact
      lutris
      wine
      #wine64Packages.unstable
      #winetricks
      inputs.nix-citizen.packages."x86_64-linux".star-citizen
      lug-helper
    ];
  };


  system.stateVersion = "24.11"; # NEVER CHANGE THIS
}
