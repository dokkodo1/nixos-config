{ config, lib, pkgs, inputs, username, ... }:

with lib;
let
  cfg = config.control.gaming;
in {
  options.control.gaming = {
    enable = mkEnableOption "Enable gaming suite with Steam, etc.";
    
    launchers = {
      heroic.enable = mkEnableOption "Enable Heroic Games Launcher" // { default = true; };
      lutris.enable = mkEnableOption "Enable Lutris" // { default = false; };
    };
    
    extras = {
      discord.enable = mkEnableOption "Enable Discord" // { default = true; };
      openrgb.enable = mkEnableOption "Enable OpenRGB for RGB lighting control" // { default = true; };
      ratbagd.enable = mkEnableOption "Enable ratbagd for gaming mice" // { default = true; };
    };
    
    starCitizen.enable = mkEnableOption "Enable Star Citizen with LUG-helper";
  };

  config = mkIf cfg.enable {

    users.users.${username} = {
      extraGroups = [
        "gamemode"
        "audio"
        "video"
        "cpu"
      ];
    };

    environment.systemPackages = with pkgs; [
      # Performance and compatibility layers
      gamemode
      mangohud
      dxvk
      protonup-qt
      
      # just keep them all, they work
      wineWowPackages.waylandFull
      wineWowPackages.staging
      winetricks
    ] 
    ++ optional cfg.extras.discord.enable discord
    ++ optional cfg.extras.openrgb.enable openrgb-with-all-plugins
    ++ optional cfg.launchers.heroic.enable heroic-unwrapped
    ++ optional cfg.launchers.lutris.enable lutris
    ++ optionals cfg.starCitizen.enable [
      lug-helper
      inputs.nix-citizen.packages."x86_64-linux".star-citizen
    ];

    programs = {
      steam.enable = true;
      steam.gamescopeSession.enable = true;
      gamemode.enable = true;
      gamescope.enable = true;
      appimage = {
        enable = true;
        binfmt = true;
        package = pkgs.appimage-run.override { extraPkgs = pkgs: [ ]; };
      };
    };

    services.ratbagd.enable = cfg.extras.ratbagd.enable;

    # Star Citizen specific configuration
    boot.kernel.sysctl = mkIf cfg.starCitizen.enable {
      "vm.max_map_count" = 16777216;
      "fs.file-max" = 524288;
    };
    
    nix.settings = mkIf cfg.starCitizen.enable {
      substituters = [ "https://nix-citizen.cachix.org" ];
      trusted-public-keys = [ "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo=" ];
    };
  };
}
