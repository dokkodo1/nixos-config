{ pkgs, modPath, username, hostname, ... }:

{
  imports = [
    ./hardware-configuration.nix
    modPath
  ];

  control = {
    audio.enable = true;
    audio.pavucontrol.enable = true;
    gpuVendor = "amd";
    gaming.enable = true;
    gaming.starCitizen.enable = true;
    gaming.launchers.lutris.enable = true;
  };

  networking.hostName = "${hostname}";
  system.stateVersion = "24.11"; # DO NOT TOUCH <<<

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

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
    EDITOR = "nvim";
  };
        
  programs.neovim.enable = true;
  programs.firefox.enable = true;
}

