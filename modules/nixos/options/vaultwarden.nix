{ config, lib, ... }:

let
  cfg = config.control.vaultwarden;
in
{
  options.control.vaultwarden = {
    enable = lib.mkEnableOption "Vaultwarden password manager";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "vault.dokkodo.me";
      description = "Domain name for the Vaultwarden instance";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/vaultwarden";
      description = "Directory for Vaultwarden data";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Internal port for Vaultwarden";
    };

    signupsAllowed = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow new user signups";
    };

    invitationsAllowed = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow admin to invite new users";
    };

    showPasswordHint = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Show password hints on login page";
    };

    adminToken = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable admin panel (uses sops secret for token)";
      };
    };

    smtp = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable SMTP for email notifications and invites";
      };
    };

    backup = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Include Vaultwarden data in distributed backups";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = lib.mkMerge [
      (lib.mkIf cfg.adminToken.enable {
        vaultwarden_admin_token = {
          owner = "vaultwarden";
          group = "vaultwarden";
        };
      })
      (lib.mkIf cfg.smtp.enable {
        smtp_host = { owner = "vaultwarden"; group = "vaultwarden"; };
        smtp_username = { owner = "vaultwarden"; group = "vaultwarden"; };
        smtp_password = { owner = "vaultwarden"; group = "vaultwarden"; };
        smtp_from = { owner = "vaultwarden"; group = "vaultwarden"; };
      })
    ];

    services.vaultwarden = {
      enable = true;

      config = {
        DOMAIN = "https://${cfg.domain}";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = cfg.port;

        SIGNUPS_ALLOWED = cfg.signupsAllowed;
        INVITATIONS_ALLOWED = cfg.invitationsAllowed;
        SHOW_PASSWORD_HINT = cfg.showPasswordHint;

        # WebSocket support for live sync
        WEBSOCKET_ENABLED = true;
        WEBSOCKET_ADDRESS = "127.0.0.1";
        WEBSOCKET_PORT = cfg.port + 1;
      };

      environmentFile = lib.mkIf (cfg.adminToken.enable || cfg.smtp.enable) "/run/vaultwarden/env";
    };

    control.webService.vaultwarden = {
      enable = true;
      domain = cfg.domain;
      upstream = "http://127.0.0.1:${toString cfg.port}";
      useTunnel = true;
      websockets = true;
    };

    control.distributedBackup.paths = lib.mkIf cfg.backup.enable [
      { path = cfg.dataDir; name = "vaultwarden"; }
    ];

    systemd.services.vaultwarden-env = lib.mkIf (cfg.adminToken.enable || cfg.smtp.enable) {
      description = "Generate Vaultwarden environment file";
      requiredBy = [ "vaultwarden.service" ];
      before = [ "vaultwarden.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        RuntimeDirectory = "vaultwarden";
        RuntimeDirectoryMode = "0700";
        User = "vaultwarden";
        Group = "vaultwarden";
      };
      script = ''
        rm -f /run/vaultwarden/env
        touch /run/vaultwarden/env
        chmod 600 /run/vaultwarden/env

        ${lib.optionalString cfg.adminToken.enable ''
          cat ${config.sops.secrets.vaultwarden_admin_token.path} >> /run/vaultwarden/env
        ''}

        ${lib.optionalString cfg.smtp.enable ''
          echo "SMTP_HOST=$(cat ${config.sops.secrets.smtp_host.path})" >> /run/vaultwarden/env
          echo "SMTP_PORT=587" >> /run/vaultwarden/env
          echo "SMTP_SECURITY=starttls" >> /run/vaultwarden/env
          echo "SMTP_USERNAME=$(cat ${config.sops.secrets.smtp_username.path})" >> /run/vaultwarden/env
          echo "SMTP_PASSWORD=$(cat ${config.sops.secrets.smtp_password.path})" >> /run/vaultwarden/env
          echo "SMTP_FROM=$(cat ${config.sops.secrets.smtp_from.path})" >> /run/vaultwarden/env
        ''}
      '';
    };

    systemd.services.vaultwarden.serviceConfig = {
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      ReadWritePaths = [ cfg.dataDir ];
    };
  };
}
