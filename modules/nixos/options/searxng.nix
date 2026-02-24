{ config, lib, ... }:

let
  cfg = config.control.searxng;
in
{
  options.control.searxng = {
    enable = lib.mkEnableOption "SearXNG metasearch engine";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "search.dokkodo.me";
      description = "Domain name for the SearXNG instance";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8888;
      description = "Internal uwsgi HTTP port";
    };

    publicAccess = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Access mode for SearXNG.
        false = Tailscale-only (HTTP on tailscale0 interface)
        true = Cloudflare Tunnel (HTTPS via control.webService)
      '';
    };

    rateLimit = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Redis-backed rate limiting";
      };
    };

    instance = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "SearXNG";
        description = "Instance name displayed in the UI";
      };
    };

    backup = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Include favicons cache in distributed backups";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.searxng_secret_key = {
      owner = "searx";
      group = "searx";
    };

    # Environment file generation service
    systemd.services.searxng-env = {
      description = "Generate SearXNG environment file";
      requiredBy = [ "searx-init.service" "uwsgi.service" ];
      before = [ "searx-init.service" "uwsgi.service" ];
      after = [ "sops-nix.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        RuntimeDirectory = "searxng";
        RuntimeDirectoryMode = "0750";
        User = "searx";
        Group = "searx";
      };
      script = ''
        rm -f /run/searxng/env
        touch /run/searxng/env
        chmod 640 /run/searxng/env
        echo "SEARXNG_SECRET=$(cat ${config.sops.secrets.searxng_secret_key.path})" >> /run/searxng/env
      '';
    };

    services.searx = {
      enable = true;
      redisCreateLocally = cfg.rateLimit.enable;

      environmentFile = "/run/searxng/env";

      settings = {
        general = {
          instance_name = cfg.instance.name;
          debug = false;
          privacypolicy_url = false;
          donation_url = false;
          contact_url = false;
          enable_metrics = false;
        };

        search = {
          safe_search = 0;
          autocomplete = "duckduckgo";
          default_lang = "en";
          formats = [ "html" "json" ];
        };

        server = {
          port = cfg.port;
          bind_address = "127.0.0.1";
          secret_key = "@SEARXNG_SECRET@";
          base_url = if cfg.publicAccess
            then "https://${cfg.domain}/"
            else "http://${cfg.domain}/";
          image_proxy = true;
          http_protocol_version = "1.1";
          method = "GET";
        };

        ui = {
          static_use_hash = true;
          default_theme = "simple";
          theme_args.simple_style = "auto";
          infinite_scroll = true;
          query_in_title = true;
          center_alignment = true;
        };

        outgoing = {
          request_timeout = 3.0;
          max_request_timeout = 15.0;
          useragent_suffix = "";
          pool_connections = 100;
          pool_maxsize = 20;
        };

        # Rate limiting via Redis
        limiter = lib.mkIf cfg.rateLimit.enable {
          enable = true;
        };

        # Enable common search engines
        engines = [
          { name = "google"; engine = "google"; disabled = false; }
          { name = "duckduckgo"; engine = "duckduckgo"; disabled = false; }
          { name = "bing"; engine = "bing"; disabled = false; }
          { name = "wikipedia"; engine = "wikipedia"; disabled = false; }
          { name = "wikidata"; engine = "wikidata"; disabled = false; }
          { name = "github"; engine = "github"; disabled = false; }
          { name = "stackoverflow"; engine = "stackoverflow"; disabled = false; }
          { name = "arxiv"; engine = "arxiv"; disabled = false; }
        ];
      };

      # Use uwsgi for production
      configureUwsgi = true;
      uwsgiConfig = {
        socket = "/run/searx/searx.sock";
        chmod-socket = "660";
        http = "127.0.0.1:${toString cfg.port}";
      };
    };

    # Ensure searx user exists before env service runs
    users.users.searx = {
      isSystemUser = true;
      group = "searx";
    };
    users.groups.searx = {};

    # Add nginx user to searx group for socket access
    users.users.nginx.extraGroups = [ "searx" ];

    # Cloudflare Tunnel mode (publicAccess = true)
    control.webService.searxng = lib.mkIf cfg.publicAccess {
      enable = true;
      domain = cfg.domain;
      upstream = "http://127.0.0.1:${toString cfg.port}";
      useTunnel = true;
    };

    # Tailscale-only mode (publicAccess = false)
    services.nginx = lib.mkIf (!cfg.publicAccess) {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;

      virtualHosts.${cfg.domain} = {
        listen = [{ addr = "0.0.0.0"; port = 80; }];

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          extraConfig = ''
            # Tailscale IP range only
            allow 100.64.0.0/10;
            deny all;
          '';
        };
      };
    };

    # Open port 80 on Tailscale interface only for non-public mode
    networking.firewall.interfaces."tailscale0".allowedTCPPorts =
      lib.mkIf (!cfg.publicAccess) [ 80 ];

    # Distributed backup for favicons cache
    control.distributedBackup.paths = lib.mkIf cfg.backup.enable [
      { path = "/var/cache/searx"; name = "searxng-cache"; }
    ];
  };
}
