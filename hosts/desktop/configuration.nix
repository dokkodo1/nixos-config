{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
      #Overlay
    ./../../modules/nixos/kde.nix
      #System
    ./../../modules/nixos/security.nix
      #Programs
    ./../../modules/nixos/programs/gaming.nix
    ./../../modules/nixos/programs/desktop-essentials.nix
    ./../../modules/nixos/programs/audio.nix
      #Settings
    ./../../modules/nixos/settings/users.nix
    ./../../modules/nixos/settings/time.nix
    ./../../modules/nixos/settings/hardware.nix
    ./../../modules/nixos/settings/keyboard-layout.nix
      #Services
    ./../../modules/nixos/services/bluetooth.nix
    ./../../modules/nixos/services/networking.nix
    ./../../modules/nixos/services/sound.nix
	  ./../../modules/nixos/services/ssh.nix
      #Development
    ./../../modules/nixos/development/llm.nix
    ./../../modules/nixos/development/tools.nix
    
#    inputs.home-manager.nixosModules.default <<< Home-manager as a module. Comment out if using standalone
  ];

  networking.hostName = "desktop";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11"; # DO NOT TOUCH <<<


# <<< Home-manager as module >>>

#  home-manager = {
#	  extraSpecialArgs = {inherit inputs; };
#	  users = {
#	    "dokkodo" = import ./home.nix;
#	  };
#    backupFileExtension = "backup";
#  };

# ^^^ Comment out if using hm standalone ^^^


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
    bottles
    home-manager # <<< remove if using home-manager as module

  ];
}

