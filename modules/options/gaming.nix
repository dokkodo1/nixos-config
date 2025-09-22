{ pkgs, lib, config, inputs, ... }:

with lib;
let
  cfg = config.dokkodo.gaming;

	mkBoolOpt = desc: mkOption {
    type = types.bool;
    default = true;
		description = desc;
	};
  
  gamingPackages = with pkgs; [
    gamemode
  ] ++ 
  (optional cfg.openrgb.enable openrgb-with-all-plugins) ++
  (optional cfg.discord.enable discord) ++
  (optional cfg.heroic.enable heroic-unwrapped) ++
  (optional cfg.mangohud.enable mangohud) ++
  (optionals cfg.wine.enable [
    wineWowPackages.waylandFull
    wineWowPackages.staging
    winetricks
  ]) ++
  (optional cfg.dxvk.enable dxvk) ++
  (optional cfg.protonup.enable protonup-qt);

  finalPackages = lib.subtractLists cfg.excludedPackages gamingPackages; 

in {
  options.dokkodo.gaming = {
    enable = lib.mkEnableOption "Enable gaming suite with steam and related tools";
    
    excludedPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of packages to exclude from the default gaming package set";
      example = literalExpression "[ pkgs.discord pkgs.openrgb-with-all-plugins ]";
    };
    discord.enable = mkBoolOpt "Enable Discord";
    openrgb.enable = mkBoolOpt "Enable OpenRGB for RGB lighting control";
    heroic.enable = mkBoolOpt "Enable Heroic Games Launcher";
    mangohud.enable = mkBoolOpt "Enable MangoHud for performance overlay";
    wine.enable = mkBoolOpt "Enable Wine packages";
    dxvk.enable = mkBoolOpt "Enable DXVK";
    protonup.enable = mkBoolOpt "Enable ProtonUp-Qt";
    steam.enable = mkBoolOpt "Enable Steam";
    steam.gamescopeSession = mkBoolOpt "Enable Steam Gamescope session";
    gamescope.enable = mkBoolOpt "Enable Gamescope";
    gamemode.enable = mkBoolOpt "Enable Gamemode";
    appimage.enable = mkBoolOpt "Enable AppImage support";
    starCitizen.enable = lib.mkEnableOption "Enable Star Citizen, LUG-helper, and Lutris";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.systemPackages = finalPackages;

      programs = mkMerge [
        (mkIf cfg.steam.enable {
          steam.enable = true;
          steam.gamescopeSession.enable = cfg.steam.gamescopeSession;
        })
        (mkIf cfg.gamemode.enable {
          gamemode.enable = true;
        })
        (mkIf cfg.gamescope.enable {
          gamescope.enable = true;
        })
        (mkIf cfg.appimage.enable {
          appimage.enable = true;
          appimage.binfmt = true;
          appimage.package = pkgs.appimage-run.override { extraPkgs = pkgs: [ ]; };
        })
      ];
    })

    (lib.mkIf cfg.starCitizen.enable {
      environment.systemPackages = with pkgs; [
        lug-helper
        inputs.nix-citizen.packages."x86_64-linux".star-citizen
        lutris
      ];
      boot.kernel.sysctl = { 
        "vm.max_map_count" = 16777216; 
        "fs.file-max" = 524288; 
      };
      nix.settings = {
        substituters = [ "https://nix-citizen.cachix.org" ];
        trusted-public-keys = [ "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo=" ];
      };
    })
  ];
}
