{ config, lib, ... }:

let
  cfg = config.control.remoteBuilders;
in
{
  options.control.remoteBuilders = {
    enable = lib.mkEnableOption "remote build infrastructure";

    enableLinuxBuilder = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    useBuilders = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          hostName = lib.mkOption {
            type = lib.types.str;
          };

          systems = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "x86_64-linux" ];
          };

          sshUser = lib.mkOption {
            type = lib.types.str;
            default = "builder";
          };

          maxJobs = lib.mkOption {
            type = lib.types.int;
            default = 4;
          };

          speedFactor = lib.mkOption {
            type = lib.types.int;
            default = 1;
          };

          supportedFeatures = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
          };

          protocol = lib.mkOption {
            type = lib.types.str;
            default = "ssh-ng";
          };

          sshKey = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
          };
        };
      });
      default = [];
    };

    serveAsBuilder = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    builderUser = lib.mkOption {
      type = lib.types.str;
      default = "builder";
    };

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (cfg.useBuilders != []) {
      nix.distributedBuilds = true;

      nix.buildMachines = map (builder: {
        inherit (builder) hostName systems sshUser maxJobs speedFactor supportedFeatures protocol sshKey;
      }) cfg.useBuilders;

      nix.settings.builders-use-substitutes = true;
    })

    (lib.mkIf cfg.enableLinuxBuilder {
      nix.linux-builder = {
        enable = true;
        config = {
          virtualisation = {
            darwin-builder = {
              diskSize = 40 * 1024;
              memorySize = 8 * 1024;
            };
            cores = 6;
          };
        };
      };
    })

    (lib.mkIf cfg.serveAsBuilder {
      users.users.${cfg.builderUser} = {
        name = cfg.builderUser;
        home = "/Users/${cfg.builderUser}";
      };

      nix.settings.trusted-users = [ cfg.builderUser ];
    })
  ]);
}
