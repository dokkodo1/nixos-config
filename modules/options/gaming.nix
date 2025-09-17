{ pkgs, lib, config, inputs, ... }:

with lib;
let
  cfg = config.dokkodo.gaming;
  
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

  finalPackages = builtins.filter 
    (pkg: !(builtins.elem pkg cfg.excludedPackages)) 
    gamingPackages;

in {
  options.dokkodo.gaming = {
    enable = lib.mkEnableOption "Enable gaming suite with steam and related tools";
    
    excludedPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of packages to exclude from the default gaming package set";
      example = literalExpression "[ pkgs.discord pkgs.openrgb-with-all-plugins ]";
    };

    discord = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Discord";
      };
    };

    openrgb = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable OpenRGB for RGB lighting control";
      };
    };

    heroic = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Heroic Games Launcher";
      };
    };

    mangohud = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable MangoHud for performance overlay";
      };
    };

    wine = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Wine packages";
      };
    };

    dxvk = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable DXVK";
      };
    };

    protonup = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ProtonUp-Qt";
      };
    };

    steam = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Steam";
      };
      gamescopeSession = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Steam Gamescope session";
      };
    };

    gamescope = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Gamescope";
      };
    };

    gamemode = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Gamemode";
      };
    };

    appimage = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable AppImage support";
      };
    };

    starCitizen = {
      enable = lib.mkEnableOption "Enable Star Citizen, LUG-helper, and Lutris";
    };
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
