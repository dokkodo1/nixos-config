{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
      #Overlay
    ./../../modules/system/kde.nix
      #System
    ./../../modules/system/security.nix
      #Programs
    ./../../modules/system/programs/gaming.nix
    ./../../modules/system/programs/desktop-essentials.nix
    ./../../modules/system/programs/audio.nix
      #Settings
    ./../../modules/system/settings/users.nix
    ./../../modules/system/settings/locale.nix
    ./../../modules/system/settings/hardware.nix
    ./../../modules/system/settings/keyboard-layout.nix
      #Services
    ./../../modules/system/services/bluetooth.nix
    ./../../modules/system/services/networking.nix
    ./../../modules/system/services/sound.nix
    ./../../modules/system/services/ssh.nix
      #Development
    ./../../modules/system/development/llm.nix
    ./../../modules/system/development/tools.nix
    
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
    bottles
    home-manager # <<< remove if using home-manager as module

  ];
}

