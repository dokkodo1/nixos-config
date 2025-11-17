{ pkgs, modPath, inputs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./control.nix
    (modPath + "/system")
    (modPath + "/system/display/kde.nix")
    (modPath + "/system/programs/gaming.nix")
    (modPath + "/system/programs/desktopApps.nix")
    (modPath + "/system/services/flatpak.nix")
    (modPath + "/system/settings/keyboardLayout.nix")
  ];

  networking.hostName = "gaming";
  system.stateVersion = "24.11"; # DO NOT TOUCH <<<

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.firmware = [ pkgs.linux-firmware ];

  security.polkit = {
    enable = true;
    debug = true;
  };

  users.users.${username}.extraGroups = [
    "gamemode"
    "audio"
    "video"
    "input"
    "cpu"
  ];

  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
  };

  environment.variables = {
    EDITOR = "kate";
  };
        
  programs.neovim.enable = true;
  programs.firefox.enable = true;

  home-manager = {
	  extraSpecialArgs = { inherit inputs username; };
    backupFileExtension = "backup";
    useGlobalPkgs = true;
  };

}

