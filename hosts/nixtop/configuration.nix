{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
      #Programs
    ./../../modules/system/programs/systemPackages.nix
    ./../../modules/system/programs/minimalX.nix
      #Settings
    ./../../modules/system/settings/users.nix
    ./../../modules/system/settings/nixSettings.nix
      #Services
    ./../../modules/system/services/networking.nix
    ./../../modules/system/services/ssh.nix
    ./../../modules/system/services/sound.nix
    ./../../modules/system/services/bluetooth.nix
    
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


  let
    pkgsKernel161237 = import inputs.nixpkgs-kernel161237 {
      system = "x86_64-linux";
      config = {
        allowUnfree = true;

    }
  in {
    boot.kernelPackages = pkgsKernel161237.linuxPackages_6_12;
  }

  #boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;
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

