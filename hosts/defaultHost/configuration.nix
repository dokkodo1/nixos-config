{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./../../defaultModules/system/common

#    inputs.home-manager.nixosModules.default <<< Home-manager as a module. Comment out if using standalone
  ];

  networking.hostName = "defaultHost";
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


  
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader = {
    grub.enable = true;
    grub.device = "/dev/disk/by-id/wwn-0x50014ee6b030602b";
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

