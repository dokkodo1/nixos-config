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

    enableRegistry = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GitLab Container Registry";
    };

    enablePages = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GitLab Pages";
    };
  };

  config = lib.mkIf cfg.enable {
    # Declare sops secrets for GitLab
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
    };

    # GitLab service
    services.gitlab = {
      enable = true;

      # Use gitlab user (NixOS default, not git)
      user = "gitlab";
      group = "gitlab";

      # Domain and protocol settings
      host = cfg.domain;
      port = 443;
      https = true;

      # Database password from sops
      databasePasswordFile = config.sops.secrets.gitlab_db_password.path;

      # Initial root password from sops
      initialRootPasswordFile = config.sops.secrets.gitlab_root_password.path;

      # Required secrets
      secrets = {
        secretFile = config.sops.secrets.gitlab_secret.path;
        otpFile = config.sops.secrets.gitlab_otp.path;
        dbFile = config.sops.secrets.gitlab_db.path;
        jwsFile = config.sops.secrets.gitlab_jws.path;
      };

      # SMTP - disabled for now, can be configured later
      smtp.enable = false;

      # Extra configuration for multi-user
      extraConfig = {
        gitlab = {
          email_from = cfg.email;
          email_display_name = "Dokkodo GitLab";
          email_reply_to = cfg.email;
          # Allow signups (you can restrict this later via admin UI)
          signup_enabled = true;
          # Require admin approval for new signups
          require_admin_approval_after_user_signup = true;
        };
        # Gravatar for user avatars
        gravatar.enabled = true;
      };
    };

    # Nginx reverse proxy
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts.${cfg.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
          proxyWebsockets = true;
        };
      };
    };

    # ACME (Let's Encrypt) configuration
    security.acme = {
      acceptTerms = true;
      defaults.email = cfg.email;
    };

    # Firewall: open HTTP and HTTPS
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    # GitLab SSH access (optional - uses port 22)
    # If you want Git over SSH, ensure port 22 is accessible
    # Users will clone with: git clone gitlab@git.dokkodo.me:user/repo.git
  };
}
