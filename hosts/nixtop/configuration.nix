{ modPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (modPath + "/system")
#    inputs.home-manager.nixosModules.default <<< Home-manager as a module. Comment out if using standalone
  ];

  boot.kernelModules = [ "b43" ];

  networking.hostName = "nixtop";
  system.stateVersion = "24.11"; # DO NOT TOUCH <<<

#  nixpkgs.config.permittedInsecurePackages = [
#    "broadcom-sta-6.30.223.271-57-6.12.41"
#  ];
#  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

# <<< Home-manager as module >>>

#  home-manager = {
#	  extraSpecialArgs = {inherit inputs; };
#	  users = {
#	    "dokkodo" = import ./home.nix;
#	  };
#    backupFileExtension = "backup";
#  };

# ^^^ Comment out if using hm standalone ^^^


#  let
#    pkgsKernel161237 = import inputs.nixpkgs-kernel161237 {
#      system = "x86_64-linux";
#      config = {
#        allowUnfree = true;
#
#    }
#  in {
#    boot.kernelPackages = pkgsKernel161237.linuxPackages_6_12;
#  }

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
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

