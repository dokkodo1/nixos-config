{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
      #Overlay
    ./../../modules/nixos/desktop.nix
      #System
    ./../../modules/nixos/security.nix
      #Programs
    ./../../modules/nixos/gaming.nix
    ./../../modules/nixos/desktop-essentials.nix
    ./../../modules/nixos/audio.nix
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
    EDITOR = "kate";
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

