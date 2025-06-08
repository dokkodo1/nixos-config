{ config, pkgs, lib, inputs, userSettings, ... }:

{
  imports = [
    ./hardware-configuration.nix
      #System
    ./../../modules/system/security.nix
      #Settings
    ./../../modules/system/settings/users.nix
      #Services
    ./../../modules/system/services/networking.nix
    ./../../modules/system/services/ssh.nix

    
#    inputs.home-manager.nixosModules.default <<< Home-manager as a module. Comment out if using standalone
  ];

  networking.hostName = "nixtop";
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
      grub.enable = true;
      device = "/dev/sda"
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

  users.users.dokkodo = {
    description = "dokkodo";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "users"
      "networkmanager"
    ];
  };

  environment.variables = {
    EDITOR = "vim";
  };

  programs = {
    vim = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    tmux
    btop
    nh
    home-manager # <<< remove if using home-manager as module
  ];

  networking = {
    networkmanager = {
      enable = true;
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [
      ];
      allowedUDPPorts = [
      ];
    };
  };
}

