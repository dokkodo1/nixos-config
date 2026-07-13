{ config, lib, pkgs, inputs, hostVars, ... }:

with lib;
let
  cfg = config.control.gaming;

  # gamescope-start = pkgs.writeShellScriptBin "gamescope-start" ''
  #   GAMESCOPE_ARGS="-f -W 1920 -H 1080 -r 144 --expose-wayland"
  #   export XDG_SESSION_TYPE=wayland
  #   export SDL_VIDEODRIVER=wayland
  #   if [ $# -eq 0 ]; then
  #       echo "No target program specified. Launching Steam Big Picture Mode..."
  #       exec gamescope $GAMESCOPE_ARGS -- steam -gamepadui
  #   else
  #       # Trick Gamescope into rendering standard apps without a black screen
  #       export STEAM_GAME=769
  #       echo "Launching '$*' inside Gamescope..."
  #       exec gamescope $GAMESCOPE_ARGS -- "$@"
  #   fi
  # '';
  #
  # gamescope-stop = pkgs.writeShellScriptBin "gamescope-stop" ''
  #   echo "Terminating all running Gamescope sessions..."
  #   pkill -f gamescope
  # '';

in {
  options.control.gaming = {
    enable = mkEnableOption "Enable gaming suite with Steam, etc.";
    # gamescope.enable = mkEnableOption "Enable Steam Gamescope compositor" // { default = false; };
    launchers = {
      heroic.enable = mkEnableOption "Enable Heroic Games Launcher" // { default = true; };
      lutris.enable = mkEnableOption "Enable Lutris";
    };
    
    extras = {
      discord.enable = mkEnableOption "Enable Discord" // { default = true; };
      openrgb.enable = mkEnableOption "Enable OpenRGB for RGB lighting control" // { default = false; };
      ratbagd.enable = mkEnableOption "Enable ratbagd for gaming mice" // { default = false; };
    };
    
    starCitizen.enable = mkEnableOption "Enable Star Citizen with LUG-helper";
  };

  config = mkIf cfg.enable {

    users.users.${hostVars.username} = {
      extraGroups = [
        "gamemode"
        "audio"
        "video"
        "cpu"
      ];
    };

    environment.systemPackages = with pkgs; [
      gamemode
      mangohud
      dxvk
      protonup-qt
      wineWow64Packages.waylandFull
      winetricks
    ] 
    ++ optional cfg.extras.discord.enable discord-ptb
    ++ optional cfg.extras.openrgb.enable openrgb-with-all-plugins
    ++ optional cfg.launchers.heroic.enable heroic-unwrapped
    ++ optional cfg.launchers.lutris.enable lutris
    ++ optionals cfg.starCitizen.enable [
      lug-helper
      inputs.nix-citizen.packages."x86_64-linux".rsi-launcher
    # ]
    # ++ optionals cfg.gamescope.enable [
    #   gamescope-start
    #   gamescope-stop
    ];

    programs = mkMerge [
      {
        steam.enable = lib.mkDefault true;
        gamemode.enable = lib.mkDefault true;
        appimage = {
          enable = lib.mkDefault true;
          binfmt = true;
          package = pkgs.appimage-run.override { extraPkgs = pkgs: [ ]; };
        };
      }
      # (mkIf cfg.gamescope.enable {
      #   gamescope = {
      #     enable = true;
      #     capSysNice = true;
      #   };
      #   steam.gamescopeSession.enable = true;
      # })
    ];

    services.ratbagd.enable = cfg.extras.ratbagd.enable;
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
