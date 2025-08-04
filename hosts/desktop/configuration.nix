{ config, pkgs, lib, inputs, modPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (modPath + "/system")
    (modPath + "/system/display/kde.nix")
    (modPath + "/system/programs/gaming.nix")
    (modPath + "/system/programs/desktopEssentials.nix")
    (modPath + "/system/programs/audio.nix")
    (modPath + "/system/settings/hardware.nix")
    (modPath + "/system/settings/keyboardLayout.nix")
    (modPath + "/system/development/llm.nix")
    (modPath + "/system/development/tools.nix")
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

