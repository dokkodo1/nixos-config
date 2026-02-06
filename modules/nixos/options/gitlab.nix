{ config, pkgs, lib, ... }:

let
  cfg = config.control.gitlab;
in
{
  options.control.gitlab = {
    enable = lib.mkEnableOption "Self-hosted GitLab instance";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "git.dokkodo.me";
      description = "Domain name for the GitLab instance";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "gitlab@dokkodo.me";
      description = "Email address for GitLab notifications";
    };

    useTunnel = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Use Cloudflare Tunnel for external access.
        Requires cloudflare_tunnel_token secret.
        When enabled, ACME is disabled and Cloudflare handles HTTPS.
      '';
    };

    enableRunner = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable GitLab Runner for CI/CD.
        Requires gitlab_runner_token secret (create runner in Admin > CI/CD > Runners first).
      '';
    };

    enableRegistry = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GitLab Container Registry for Docker images";
    };

    enablePages = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GitLab Pages for static site hosting";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      gitlab_db_password = {
        owner = "gitlab";
        group = "gitlab";
      };
      gitlab_root_password = {
        owner = "gitlab";
        group = "gitlab";
      };
      gitlab_secret = {
        owner = "gitlab";
        group = "gitlab";
      };
      gitlab_otp = {
        owner = "gitlab";
        group = "gitlab";
      };
      gitlab_db = {
        owner = "gitlab";
        group = "gitlab";
      };
      gitlab_jws = {
        owner = "gitlab";
        group = "gitlab";
      };
      gitlab_activerecord_primary = {
        owner = "gitlab";
        group = "gitlab";
      };
      gitlab_activerecord_deterministic = {
        owner = "gitlab";
        group = "gitlab";
      };
      gitlab_activerecord_salt = {
        owner = "gitlab";
        group = "gitlab";
      };
    } // lib.optionalAttrs cfg.useTunnel {
      cloudflare_tunnel_token = {};
    } // lib.optionalAttrs cfg.enableRunner {
      gitlab_runner_token = {
        owner = "gitlab-runner";
        group = "gitlab-runner";
      };
    };

    services.gitlab = {
      enable = true;
      user = "gitlab";
      group = "gitlab";

      host = cfg.domain;
      port = 443;
      https = true;

      databasePasswordFile = config.sops.secrets.gitlab_db_password.path;
      initialRootPasswordFile = config.sops.secrets.gitlab_root_password.path;
      secrets = {
        secretFile = config.sops.secrets.gitlab_secret.path;
        otpFile = config.sops.secrets.gitlab_otp.path;
        dbFile = config.sops.secrets.gitlab_db.path;
        jwsFile = config.sops.secrets.gitlab_jws.path;
        activeRecordPrimaryKeyFile = config.sops.secrets.gitlab_activerecord_primary.path;
        activeRecordDeterministicKeyFile = config.sops.secrets.gitlab_activerecord_deterministic.path;
        activeRecordSaltFile = config.sops.secrets.gitlab_activerecord_salt.path;
      };

      smtp.enable = false;

      extraConfig = {
        gitlab = {
          email_from = cfg.email;
          email_display_name = "Dokkodo GitLab";
          email_reply_to = cfg.email;
          signup_enabled = true;
          require_admin_approval_after_user_signup = true;
        };
        gravatar.enabled = true;
      };
      backup = {
        startAt = "02:00";
        keepTime = 604800;
      };
    };

    services.gitlab-runner = lib.mkIf cfg.enableRunner {
      enable = true;
      services = {
        shell-runner = {
          executor = "shell";
          authenticationTokenConfigFile = config.sops.secrets.gitlab_runner_token.path;
          limit = 4;
          tagList = [ "nixos" "shell" ];
        };
      };
    };

    systemd.services.cloudflared-tunnel = lib.mkIf cfg.useTunnel {
      description = "Cloudflare Tunnel for GitLab";
      after = [ "network-online.target" "gitlab.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token $(cat ${config.sops.secrets.cloudflare_tunnel_token.path})
      '';
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 5;
      };
    };

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts.${cfg.domain} = {
        # When using tunnel, Cloudflare handles HTTPS
        # Nginx serves HTTP locally, tunnel connects to it. Goddamn magic
        enableACME = !cfg.useTunnel;
        forceSSL = !cfg.useTunnel;

        listen = lib.mkIf cfg.useTunnel [
          { addr = "127.0.0.1"; port = 80; }
        ];

        locations."/" = {
          proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
          proxyWebsockets = true;
          # Required for Cloudflare Tunnel - tell GitLab the original request was HTTPS
          extraConfig = lib.optionalString cfg.useTunnel ''
            proxy_set_header X-Forwarded-Proto https;
            proxy_set_header X-Forwarded-Ssl on;
          '';
        };
      };
    };

    # ACME only when not using tunnel
    security.acme = lib.mkIf (!cfg.useTunnel) {
      acceptTerms = true;
      defaults.email = cfg.email;
    };

    # Firewall: SSH always, HTTP/HTTPS only when not using tunnel
    networking.firewall.allowedTCPPorts =
      [ 22 ] ++ (lib.optionals (!cfg.useTunnel) [ 80 443 ]);
  };
}
