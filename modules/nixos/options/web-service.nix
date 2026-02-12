{ config, lib, ... }:

let
  cfg = config.control.webService;

  webServiceOpts = { name, ... }: {
    options = {
      enable = lib.mkEnableOption "web service ${name}";

      domain = lib.mkOption {
        type = lib.types.str;
        description = "Domain name for this service";
      };

      upstream = lib.mkOption {
        type = lib.types.str;
        description = "Upstream URL (e.g., http://127.0.0.1:8080 or http://unix:/run/foo.socket)";
      };

      useTunnel = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Use Cloudflare Tunnel for external access.
          When true, listens on 127.0.0.1:80 only and adds X-Forwarded-Proto headers.
          When false, enables ACME and opens firewall ports.
        '';
      };

      websockets = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable WebSocket proxying";
      };

      extraNginxConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Extra nginx location configuration";
      };

      acmeEmail = lib.mkOption {
        type = lib.types.str;
        default = "acme@dokkodo.me";
        description = "Email for ACME certificate notifications (when not using tunnel)";
      };
    };
  };

  enabledServices = lib.filterAttrs (n: v: v.enable) cfg;
  anyUseTunnel = lib.any (s: s.useTunnel) (lib.attrValues enabledServices);
  anyUseAcme = lib.any (s: !s.useTunnel) (lib.attrValues enabledServices);
in
{
  options.control.webService = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule webServiceOpts);
    default = {};
    description = "Web services to expose via nginx reverse proxy";
  };

  config = lib.mkIf (enabledServices != {}) {
    control.cloudflareTunnel.enable = lib.mkIf anyUseTunnel true;

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = lib.mapAttrs' (name: serviceCfg: lib.nameValuePair serviceCfg.domain {
        enableACME = !serviceCfg.useTunnel;
        forceSSL = !serviceCfg.useTunnel;

        listen = lib.mkIf serviceCfg.useTunnel [
          { addr = "127.0.0.1"; port = 80; }
        ];

        locations."/" = {
          proxyPass = serviceCfg.upstream;
          proxyWebsockets = serviceCfg.websockets;
          extraConfig = lib.concatStringsSep "\n" (lib.filter (s: s != "") [
            (lib.optionalString serviceCfg.useTunnel ''
              proxy_set_header X-Forwarded-Proto https;
              proxy_set_header X-Forwarded-Ssl on;
            '')
            serviceCfg.extraNginxConfig
          ]);
        };
      }) enabledServices;
    };

    # ACME configuration when any service doesn't use tunnel
    security.acme = lib.mkIf anyUseAcme {
      acceptTerms = true;
      defaults.email = (lib.head (lib.filter (s: !s.useTunnel) (lib.attrValues enabledServices))).acmeEmail;
    };

    # Open firewall ports when any service doesn't use tunnel
    networking.firewall.allowedTCPPorts = lib.mkIf anyUseAcme [ 80 443 ];
  };
}
