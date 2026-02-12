{ config, pkgs, lib, ... }:

let
  cfg = config.control.cloudflareTunnel;
in
{
  options.control.cloudflareTunnel = {
    enable = lib.mkEnableOption "Cloudflare Tunnel for exposing services";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.cloudflare_tunnel_token = {};

    systemd.services.cloudflared-tunnel = {
      description = "Cloudflare Tunnel";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      script = ''
        ${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run \
          --token $(cat ${config.sops.secrets.cloudflare_tunnel_token.path})
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 5;
      };
    };
  };
}
