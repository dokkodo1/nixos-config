{ config, pkgs, lib, inputs, modPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (modPath + "/system")
  ] ++ map (file: modPath + "/system/" + file) [
    "display/kde.nix"
    "programs/gaming.nix"
    "programs/desktopEssentials.nix"
    "programs/audio.nix"
    "settings/hardware.nix"
    "settings/keyboardLayout.nix"
    "development/llm.nix"
    "development/tools.nix"
#    inputs.home-manager.nixosModules.default <<< Home-manager as a module. Comment out if using standalone
  ];

  networking.hostName = "desktop";
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


  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

 security.polkit = {
    enable = true;
    debug = true;
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
  };

  environment.variables = {
    EDITOR = "vim";
  };

  programs.vim.enable = true;
  programs.firefox.enable = true;

}

