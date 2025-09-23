{ pkgs, modPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (modPath + "/system")
    (modPath + "/system/display/kde.nix")
    (modPath + "/system/programs/gaming.nix")
    (modPath + "/system/programs/desktopApps.nix")
    (modPath + "/system/programs/proAudio.nix")
    (modPath + "/system/settings/amdgpu.nix")
    (modPath + "/system/services/flatpak.nix")
    (modPath + "/system/settings/keyboardLayout.nix")
    (modPath + "/system/development/llm.nix")
    (modPath + "/system/development/tools.nix")
    (modPath + "/system/development/podman.nix")
  ];

  networking.hostName = "desktop";
  system.stateVersion = "24.11"; # DO NOT TOUCH <<<

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

#  boot.kernelModules = [ "iwlwifi" ];
  hardware.firmware = [ pkgs.linux-firmware ];

  #Hard drives
  fileSystems."/mnt/sata1" = {
    device = "/dev/disk/by-uuid/3a472f59-0607-46f1-9885-4140a3314895";
    fsType = "ext4";
    options = [ "noatime" "lazytime" "x-systemd.automount" "nofail" ];
  };  
  systemd.tmpfiles.rules = [
    "d /mnt/sata1 0775 dokkodo users - -"
  ];

  security.polkit = {
    enable = true;
    debug = true;
  };

  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
  };

  environment.variables = {
    EDITOR = "nvim";
  };
        
  programs.vim.enable = true;
  programs.nvim.enable = true;
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

