{ config, lib, pkgs, ... }:

let
  cfg = config.control.matrix;
  domain = cfg.baseDomain;
  matrixDomain = "matrix.${domain}";
in
{
  options.control.matrix = {
    enable = lib.mkEnableOption "Matrix Synapse homeserver";

    baseDomain = lib.mkOption {
      type = lib.types.str;
      description = "Base domain (server_name). Matrix domain will be matrix.<baseDomain>";
      example = "example.com";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8008;
      description = "Internal HTTP port for Synapse";
    };

    enableRegistration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow public registration";
    };

    maxUploadSizeMib = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "Maximum upload size in MiB";
    };

    useTunnel = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use Cloudflare Tunnel for external access";
    };

    backup.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Matrix data in distributed backups";
    };

    rateLimit = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable nginx rate limiting for Matrix endpoints";
      };

      requestsPerSecond = lib.mkOption {
        type = lib.types.int;
        default = 10;
        description = "Requests per second per IP before rate limiting kicks in";
      };

      burst = lib.mkOption {
        type = lib.types.int;
        default = 20;
        description = "Number of requests to allow in bursts above the rate limit";
      };
    };

    adminApi = {
      restrict = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Restrict /_synapse/admin endpoints to localhost and Tailscale.
          When true, admin API only accessible from 127.0.0.1 and 100.64.0.0/10.
          Admin tasks must be done locally or via Tailscale SSH.
        '';
      };
    };

    mediaRetention = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable automatic media cleanup";
      };

      localMediaLifetimeDays = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = ''
          Days to retain local media (uploaded by your users).
          null = keep forever. Recommended: 365 or higher if enabling.
        '';
        example = 365;
      };

      remoteMediaLifetimeDays = lib.mkOption {
        type = lib.types.int;
        default = 90;
        description = ''
          Days to retain cached remote media (from federated servers).
          This is safe to set lower as it can be re-fetched.
        '';
      };
    };

    federation = {
      mode = lib.mkOption {
        type = lib.types.enum [ "full" "whitelist" "disabled" ];
        default = "whitelist";
        description = ''
          Federation mode:
          - full: Federate with any server (risky)
          - whitelist: Only federate with servers in the whitelist (recommended)
          - disabled: No federation, isolated server
        '';
      };

      whitelist = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "matrix.org" ];
        description = "Servers to federate with (when mode = whitelist)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = cfg.baseDomain != "";
      message = "control.matrix.baseDomain must be set";
    }];

    # Sops secrets
    sops.secrets.matrix_registration_secret = {
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };

    # PostgreSQL database
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "matrix-synapse" ];
      ensureUsers = [{
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }];
    };

    # Matrix Synapse
    services.matrix-synapse = {
      enable = true;
      settings = {
        server_name = domain;
        public_baseurl = "https://${matrixDomain}";

        listeners = [{
          port = cfg.port;
          bind_addresses = [ "127.0.0.1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [{
            names = [ "client" "federation" ];
            compress = true;
          }];
        }];

        database = {
          name = "psycopg2";
          allow_unsafe_locale = true;
          args = {
            user = "matrix-synapse";
            database = "matrix-synapse";
            host = "/run/postgresql";
          };
        };

        max_upload_size_mib = cfg.maxUploadSizeMib;
        url_preview_enabled = true;
        enable_registration = cfg.enableRegistration;
        enable_metrics = false;
        registration_shared_secret_path = config.sops.secrets.matrix_registration_secret.path;

        trusted_key_servers = [{ server_name = "matrix.org"; }];

        # Federation settings based on mode
        allow_public_rooms_over_federation = cfg.federation.mode == "full";
      } // lib.optionalAttrs (cfg.federation.mode == "disabled") {
        federation_domain_whitelist = [];
      } // lib.optionalAttrs (cfg.federation.mode == "whitelist") {
        federation_domain_whitelist = cfg.federation.whitelist;
      } // lib.optionalAttrs cfg.mediaRetention.enable {
        media_retention = {
          remote_media_lifetime = "${toString cfg.mediaRetention.remoteMediaLifetimeDays}d";
        } // lib.optionalAttrs (cfg.mediaRetention.localMediaLifetimeDays != null) {
          local_media_lifetime = "${toString cfg.mediaRetention.localMediaLifetimeDays}d";
        };
      };
    };

    # Nginx rate limit zone for Matrix (at http level)
    services.nginx.appendHttpConfig = lib.mkIf cfg.rateLimit.enable ''
      limit_req_zone $binary_remote_addr zone=matrix_limit:10m rate=${toString cfg.rateLimit.requestsPerSecond}r/s;
    '';

    # Reverse proxy for matrix.<domain>
    control.webService.matrix = {
      enable = true;
      domain = matrixDomain;
      upstream = "http://127.0.0.1:${toString cfg.port}";
      useTunnel = cfg.useTunnel;
      extraNginxConfig = lib.concatStringsSep "\n" (lib.filter (s: s != "") [
        "client_max_body_size ${toString cfg.maxUploadSizeMib}M;"
        (lib.optionalString cfg.rateLimit.enable
          "limit_req zone=matrix_limit burst=${toString cfg.rateLimit.burst} nodelay;")
      ]);
    };

    # Admin API restriction (separate location block with stricter access)
    services.nginx.virtualHosts.${matrixDomain}.locations = lib.mkIf cfg.adminApi.restrict {
      "/_synapse/admin" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        extraConfig = ''
          # Only allow localhost and Tailscale CGNAT range
          allow 127.0.0.1;
          allow ::1;
          allow 100.64.0.0/10;
          deny all;

          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header Host $host;
        '';
      };
    };

    # .well-known endpoints on base domain (required for federation)
    services.nginx.virtualHosts.${domain} = {
      listen = lib.mkIf cfg.useTunnel [
        { addr = "127.0.0.1"; port = 80; }
      ];
      enableACME = !cfg.useTunnel;
      forceSSL = !cfg.useTunnel;

      locations."= /.well-known/matrix/server".extraConfig = ''
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '${builtins.toJSON { "m.server" = "${matrixDomain}:443"; }}';
      '';
      locations."= /.well-known/matrix/client".extraConfig = ''
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '${builtins.toJSON {
          "m.homeserver".base_url = "https://${matrixDomain}";
          "m.identity_server" = {};
        }}';
      '';
    };

    # Distributed backup
    control.distributedBackup.paths = lib.mkIf cfg.backup.enable [
      { path = "/var/lib/matrix-synapse"; name = "matrix-synapse"; }
    ];

    # Helper scripts for Matrix administration
    environment.systemPackages = let
      serverUrl = "http://localhost:${toString cfg.port}";
      secretPath = config.sops.secrets.matrix_registration_secret.path;
    in [
      # Register new users
      (pkgs.writeShellScriptBin "matrix-register-user" ''
        exec ${pkgs.matrix-synapse}/bin/register_new_matrix_user \
          -k "$(cat ${secretPath})" \
          "$@" \
          ${serverUrl}
      '')

      # Admin API helper (requires MATRIX_ADMIN_TOKEN env var)
      # Usage: matrix-admin GET /_synapse/admin/v1/server_version
      #        matrix-admin POST /_synapse/admin/v1/reset_password/@user:domain '{"new_password":"..."}'
      (pkgs.writeShellScriptBin "matrix-admin" ''
        if [ -z "$MATRIX_ADMIN_TOKEN" ]; then
          echo "Error: MATRIX_ADMIN_TOKEN not set"
          echo "Get a token: matrix-get-token <admin-username> <password>"
          exit 1
        fi
        METHOD="$1"
        ENDPOINT="$2"
        shift 2
        exec ${pkgs.curl}/bin/curl -s -X "$METHOD" \
          -H "Authorization: Bearer $MATRIX_ADMIN_TOKEN" \
          -H "Content-Type: application/json" \
          "${serverUrl}$ENDPOINT" "$@"
      '')

      # Get access token for a user
      # Usage: matrix-get-token <username>
      (pkgs.writeShellScriptBin "matrix-get-token" ''
        USER="$1"
        if [ -z "$USER" ]; then
          echo "Usage: matrix-get-token <username>"
          exit 1
        fi
        read -s -p "Password: " PASS
        echo >&2
        PAYLOAD=$(${pkgs.jq}/bin/jq -n \
          --arg user "$USER" \
          --arg pass "$PASS" \
          '{type:"m.login.password",user:$user,password:$pass}')
        ${pkgs.curl}/bin/curl -s -X POST \
          -H "Content-Type: application/json" \
          -d "$PAYLOAD" \
          "${serverUrl}/_matrix/client/v3/login" | ${pkgs.jq}/bin/jq -r '.access_token'
      '')

      # Common admin tasks
      (pkgs.writeShellScriptBin "matrix-list-users" ''
        if [ -z "$MATRIX_ADMIN_TOKEN" ]; then
          echo "Error: MATRIX_ADMIN_TOKEN not set"
          exit 1
        fi
        ${pkgs.curl}/bin/curl -s \
          -H "Authorization: Bearer $MATRIX_ADMIN_TOKEN" \
          "${serverUrl}/_synapse/admin/v2/users?limit=''${1:-100}" | ${pkgs.jq}/bin/jq '.users[] | {name, admin, deactivated}'
      '')

      (pkgs.writeShellScriptBin "matrix-reset-password" ''
        if [ -z "$MATRIX_ADMIN_TOKEN" ]; then
          echo "Error: MATRIX_ADMIN_TOKEN not set"
          exit 1
        fi
        USER="$1"
        if [ -z "$USER" ]; then
          echo "Usage: matrix-reset-password @user:${domain}"
          exit 1
        fi
        read -s -p "New password: " NEWPASS
        echo >&2
        read -s -p "Confirm password: " NEWPASS2
        echo >&2
        if [ "$NEWPASS" != "$NEWPASS2" ]; then
          echo "Passwords do not match" >&2
          exit 1
        fi
        PAYLOAD=$(${pkgs.jq}/bin/jq -n \
          --arg pass "$NEWPASS" \
          '{new_password:$pass,logout_devices:true}')
        ${pkgs.curl}/bin/curl -s -X POST \
          -H "Authorization: Bearer $MATRIX_ADMIN_TOKEN" \
          -H "Content-Type: application/json" \
          -d "$PAYLOAD" \
          "${serverUrl}/_synapse/admin/v1/reset_password/$USER"
      '')

      (pkgs.writeShellScriptBin "matrix-deactivate-user" ''
        if [ -z "$MATRIX_ADMIN_TOKEN" ]; then
          echo "Error: MATRIX_ADMIN_TOKEN not set"
          exit 1
        fi
        USER="$1"
        if [ -z "$USER" ]; then
          echo "Usage: matrix-deactivate-user @user:${domain}"
          exit 1
        fi
        read -p "Deactivate $USER? This cannot be undone. [y/N] " confirm
        if [ "$confirm" = "y" ]; then
          ${pkgs.curl}/bin/curl -s -X POST \
            -H "Authorization: Bearer $MATRIX_ADMIN_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"erase":false}' \
            "${serverUrl}/_synapse/admin/v1/deactivate/$USER"
        fi
      '')

      (pkgs.writeShellScriptBin "matrix-server-info" ''
        echo "=== Server Version ==="
        ${pkgs.curl}/bin/curl -s "${serverUrl}/_synapse/admin/v1/server_version" | ${pkgs.jq}/bin/jq .
        echo ""
        echo "=== Federation Status ==="
        ${pkgs.curl}/bin/curl -s "https://${domain}/.well-known/matrix/server"
        echo ""
        ${pkgs.curl}/bin/curl -s "https://${matrixDomain}/_matrix/federation/v1/version" | ${pkgs.jq}/bin/jq . 2>/dev/null || echo "(federation endpoint may require auth)"
      '')
    ];
  };
}
