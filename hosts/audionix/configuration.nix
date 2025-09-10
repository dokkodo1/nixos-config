{ modPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (modPath + "/system")
    (modPath + "/system/display/kde.nix")
    (modPath + "/system/programs/desktopEssentials.nix")
    (modPath + "/system/programs/audio.nix")
    (modPath + "/system/programs/musnix.nix")
    (modPath + "/system/settings/keyboardLayout.nix")
#    inputs.home-manager.nixosModules.default <<< Home-manager as a module. Comment out if using standalone
  ];

  boot.kernelModules = [ ];

  networking.hostName = "audionix";
  system.stateVersion = "24.11"; # DO NOT TOUCH <<<

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  security.polkit = {
    enable = true;
    debug = true;
  };

  environment.variables = {
    EDITOR = "vim";
  };

  programs.firefox.enable = true;

# <<< Home-manager as module >>>
#  home-manager = {
#	  extraSpecialArgs = {inherit inputs; };
#	  users = {
#	    "dokkodo" = import ./home.nix;
#	  };
#    backupFileExtension = "backup";
#  };
# ^^^ Comment out if using hm standalone ^^^

}

