{ config, pkgs, lib, inputs, modPath, ... }:

{
  imports = [
    #./hardware-configuration.nix
    (modPath + "/system")
#    inputs.home-manager.nixosModules.default <<< Home-manager as a module. Comment out if using standalone
  ];

  networking.hostName = "hpls1";
  system.stateVersion = "24.11"; # DO NOT TOUCH <<<

#  nixpkgs.config.permittedInsecurePackages = [
#    "broadcom-sta-6.30.223.271-57-6.12.40"
#  ];
#  hardware.enableRedistributableFirmware = true;

# <<< Home-manager as module >>>

#  home-manager = {
#	  extraSpecialArgs = {inherit inputs; };
#	  users = {
#	    "dokkodo" = import ./home.nix;
#	  };
#    backupFileExtension = "backup";
#  };

# ^^^ Comment out if using hm standalone ^^^

  boot.loader = {
    grub.enable = true;
#    grub.device = "/dev/disk/by-id/wwn-0x50014ee6b030602b";
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

