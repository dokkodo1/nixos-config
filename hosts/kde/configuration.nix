{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
      #Overlay
    ./../../modules/nixos/kde.nix
      #System
    #./../../modules/nixos/security.nix
    #./../../modules/nixos/fonts.nix
      #Programs
    ./../../modules/nixos/gaming.nix
    ./../../modules/nixos/desktop-essentials.nix
      #Settings
    ./../../modules/nixos/Settings/users.nix
    ./../../modules/nixos/Settings/time.nix
    ./../../modules/nixos/Settings/hardware.nix
    ./../../modules/nixos/Settings/keyboard-layout.nix
      #Services
    ./../../modules/nixos/Services/bluetooth.nix
    ./../../modules/nixos/Services/networking.nix
    ./../../modules/nixos/Services/sound.nix
	  ./../../modules/nixos/Services/ssh.nix
      #Development
    ./../../modules/nixos/Development/llm.nix
    ./../../modules/nixos/Development/tools.nix
  ];

  networking.hostName = "kde";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11"; # DO NOT TOUCH <<<

  home-manager = {
	  extraSpecialArgs = {inherit inputs; };
	  users = {
	    "dokkodo" = import ./home.nix;
	  };
    backupFileExtension = "backup";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
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
  };

  environment.variables = {
    EDITOR = "vim";
  };

  programs = {
    vim = {
      enable = true;
    };

    firefox = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    btop
    nh
    vscode
    reaper
    bottles
  ];
}

