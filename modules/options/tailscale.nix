{ config, pkgs, lib, ... }:

let
  cfg = config.control.tailscale;
in
{
  options.control.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";

    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to file containing Tailscale auth key for automatic authentication";
    };

    exitNode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable this machine as a Tailscale exit node";
    };

    ssh = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Tailscale SSH";
    };
  };

  config = lib.mkIf cfg.enable ({
    # sops secret configuration - just declare the secret (defaultSopsFile handled in base/sops.nix)
    sops.secrets.tailscale_auth_key = {};

    # Common package for both platforms
    environment.systemPackages = [ pkgs.tailscale ];

    # Tailscale service configuration (cross-platform)
    services.tailscale = {
      enable = true;
    } // (lib.optionalAttrs pkgs.stdenv.isLinux {
      authKeyFile = cfg.authKeyFile or "/run/secrets/tailscale_auth_key";
      useRoutingFeatures = lib.mkIf cfg.exitNode "server";
      extraUpFlags = lib.flatten [
        (lib.optional cfg.ssh "--ssh")
        (lib.optional cfg.exitNode "--advertise-exit-node")
        ["--accept-routes"]
      ];
    });
  } // lib.optionalAttrs pkgs.stdenv.isLinux {
    # NixOS-only configuration
    networking.firewall = {
      enable = true;
      checkReversePath = "loose";  # Required for exit nodes
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ 41641 ];  # Tailscale default UDP port
    };

    # Enable IP forwarding for exit nodes
    boot.kernel.sysctl = lib.mkIf cfg.exitNode {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  });
}
