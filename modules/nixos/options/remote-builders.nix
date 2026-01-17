{ config, lib, ... }:

let
  cfg = config.control.remoteBuilders;
in
{
  options.control.remoteBuilders = {
    enable = lib.mkEnableOption "remote build infrastructure";

    # Explicit list of remote builders this host should use
    useBuilders = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          hostName = lib.mkOption {
            type = lib.types.str;
            description = "Hostname or IP of the remote builder";
          };

          systems = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Systems this builder can build for";
            example = [ "x86_64-linux" "aarch64-linux" ];
          };

          sshUser = lib.mkOption {
            type = lib.types.str;
            default = "builder";
            description = "SSH user for remote builds";
          };

          maxJobs = lib.mkOption {
            type = lib.types.int;
            default = 4;
            description = "Maximum parallel jobs on this builder";
          };

          speedFactor = lib.mkOption {
            type = lib.types.int;
            default = 1;
            description = "Relative speed compared to local builds (higher = faster)";
          };

          supportedFeatures = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "nixos-test" "benchmark" "big-parallel" ];
            description = "Features supported by this builder";
          };

          protocol = lib.mkOption {
            type = lib.types.str;
            default = "ssh-ng";
            description = "Protocol for remote builds (ssh or ssh-ng)";
          };
        };
      });
      default = [];
      description = "Remote builders this host should use for builds";
    };

    # Whether this host should serve as a builder for others
    serveAsBuilder = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Configure this host to serve as a remote builder.
        Sets up SSH access and nix-serve for other machines.
      '';
    };

    # SSH configuration for builder access
    builderUser = lib.mkOption {
      type = lib.types.str;
      default = "builder";
      description = "Username for remote builder SSH access";
    };

    # Placeholder for SSH key path (will use sops secrets when configured)
    sshKeyPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to SSH private key for authenticating to remote builders.

        When using sops-nix, this will be set to:
        config.sops.secrets."''${config.networking.hostName}_builder_ssh_key".path

        For now, can be manually set or left null for testing.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Common configuration for all hosts using remote builders
    {
      nix.distributedBuilds = lib.mkIf (cfg.useBuilders != []) true;

      # Build machines configuration
      nix.buildMachines = map (builder: {
        inherit (builder) hostName systems sshUser maxJobs speedFactor supportedFeatures protocol;

        # SSH key configuration - placeholder for sops integration
        # TODO: When sops secrets are configured, this will automatically use:
        # sshKey = config.sops.secrets."${config.networking.hostName}_builder_ssh_key".path;
        sshKey = cfg.sshKeyPath;

        # Public host key verification (optional, improves security)
        # TODO: Add public keys for each builder host here
        # publicHostKey = "ssh-ed25519 AAAA...";
      }) cfg.useBuilders;

      # Prefer remote builders for supported systems
      nix.settings = {
        builders-use-substitutes = true;
      };
    }

    # Configuration for hosts that serve as builders
    (lib.mkIf cfg.serveAsBuilder {
      # Create builder user for SSH access
      users.users.${cfg.builderUser} = {
        isSystemUser = true;
        group = "builders";
        description = "Nix remote builder user";

        # TODO: Add authorized SSH public keys from other hosts
        # openssh.authorizedKeys.keys = [
        #   "ssh-ed25519 AAAA... nixtop-builder"
        #   "ssh-ed25519 AAAA... hpl-tower-builder"
        # ];
      };

      users.groups.builders = {};

      # Grant builder user access to nix daemon
      nix.settings.trusted-users = [ cfg.builderUser ];

      # Ensure SSH is enabled for builder access
      # Note: Actual SSH service configuration should be in host-specific config
    })
  ]);
}
