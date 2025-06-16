{ config, pkgs, lib, inputs, userSettings, ... }:

{
  imports = [
    ./hardware-configuration.nix
      #System
    ./../../modules/system/security.nix
      #Programs
    ./../../modules/system/programs/systemPackages.nix
      #Settings
    ./../../modules/system/settings/users.nix
    ./../../modules/system/settings/nixSettings.nix
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
    #kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      grub.enable = true;
      grub.device = "/dev/disk/by-id/wwn-0x50014ee6b030602b";
    };
  };

 security = {
    polkit = {
      enable = true;
      debug = true;
    };
  };

  environment.variables = {
    EDITOR = "vim";
  };


}

