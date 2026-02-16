{ config, lib, pkgs, ... }:

let
  cfg = config.control.monitoring;
  hostname = config.networking.hostName;

  ports = {
    prometheus = 9090;
    grafana = 3000;
    loki = 3100;
    alertmanager = 9093;
    nodeExporter = 9100;
    nginxExporter = 9113;
    postgresExporter = 9187;
    promtail = 9080;
    nginxStatus = 8085;
    matrixAlertBot = 3033;
    gitlabExporter = 9168;
  };

  matrixEnabled = config.control.matrix.enable or false;
  gitlabEnabled = config.control.gitlab.enable or false;

  # Derive matrix homeserver from config if not explicitly set
  matrixHomeserver =
    if cfg.alertmanager.matrix.homeserver != ""
    then cfg.alertmanager.matrix.homeserver
    else if matrixEnabled
    then "https://matrix.${config.control.matrix.baseDomain}"
    else "";
in
{
  options.control.monitoring = {
    enable = lib.mkEnableOption "monitoring server (Prometheus + Grafana + Loki)";

    agent = {
      enable = lib.mkEnableOption "monitoring agent (node_exporter + promtail)";

      lokiUrl = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "URL of the Loki server for log shipping";
        example = "http://monitoring-server:3100";
      };
    };

    grafana = {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Domain name for Grafana";
        example = "grafana.example.com";
      };

      useTunnel = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use Cloudflare Tunnel for external access";
      };

      anonymousAccess = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Allow anonymous read-only access to dashboards";
      };
    };

    prometheus = {
      retentionDays = lib.mkOption {
        type = lib.types.int;
        default = 30;
        description = "Number of days to retain Prometheus metrics";
      };

      remoteTargets = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Tailscale hostnames to scrape node_exporter from";
        example = [ "workstation1" "workstation2" ];
      };

      exporters = {
        node = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable node_exporter for system metrics";
        };

        nginx = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable nginx-prometheus-exporter";
        };

        postgres = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable postgres_exporter";
        };

        systemd = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable systemd exporter for service metrics";
        };
      };
    };

    loki = {
      retentionDays = lib.mkOption {
        type = lib.types.int;
        default = 30;
        description = "Number of days to retain logs in Loki";
      };
    };

    alertmanager = {
      enable = lib.mkEnableOption "Alertmanager for notifications";

      email = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Send alerts via email (uses smtp_* secrets)";
        };

        to = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Email address to send alerts to";
          example = "alerts@example.com";
        };
      };

      matrix = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Send alerts to a Matrix room";
        };

        homeserver = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Matrix homeserver URL. If empty and control.matrix is enabled, derives from matrix.baseDomain";
          example = "https://matrix.example.com";
        };

        roomId = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Matrix room ID for alerts";
          example = "!abc123:example.com";
        };
      };
    };

    backup = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Include monitoring data in distributed backups";
      };
    };
  };

  config = lib.mkMerge [
    # ============================================
    # ASSERTIONS
    # ============================================
    {
      assertions = [
        {
          assertion = cfg.enable -> cfg.grafana.domain != "";
          message = "control.monitoring.grafana.domain must be set when monitoring is enabled";
        }
        {
          assertion = (cfg.agent.enable && !cfg.enable) -> cfg.agent.lokiUrl != "";
          message = "control.monitoring.agent.lokiUrl must be set when agent mode is enabled without server mode";
        }
        {
          assertion = cfg.alertmanager.email.enable -> cfg.alertmanager.email.to != "";
          message = "control.monitoring.alertmanager.email.to must be set when email alerts are enabled";
        }
        {
          assertion = cfg.alertmanager.matrix.enable -> cfg.alertmanager.matrix.roomId != "";
          message = "control.monitoring.alertmanager.matrix.roomId must be set when matrix alerts are enabled";
        }
        {
          assertion = cfg.alertmanager.matrix.enable -> matrixHomeserver != "";
          message = "control.monitoring.alertmanager.matrix.homeserver must be set (or control.matrix must be enabled) when matrix alerts are enabled";
        }
      ];
    }

    # ============================================
    # AGENT MODE (node_exporter + promtail)
    # ============================================
    (lib.mkIf cfg.agent.enable {
      # Override DynamicUser - upstream module creates promtail user/group
      # but DynamicUser prevents it from owning pre-created directories
      systemd.services.promtail.serviceConfig = {
        DynamicUser = lib.mkForce false;
      };

      # Create state directory with correct ownership (promtail user/group from upstream)
      systemd.tmpfiles.rules = [
        "d /var/lib/promtail 0750 promtail promtail -"
      ];

      # Node exporter for system metrics
      services.prometheus.exporters.node = {
        enable = true;
        port = ports.nodeExporter;
        enabledCollectors = [
          "systemd"
          "processes"
          "filesystem"
          "diskstats"
          "netdev"
          "meminfo"
          "loadavg"
          "cpu"
        ];
        listenAddress = "0.0.0.0";
      };

      # Promtail for log shipping
      services.promtail = {
        enable = true;
        configuration = {
          server = {
            http_listen_port = ports.promtail;
            grpc_listen_port = 0;
          };

          positions = {
            filename = "/var/lib/promtail/positions.yaml";
          };

          clients = [{
            url = "${cfg.agent.lokiUrl}/loki/api/v1/push";
          }];

          scrape_configs = [
            {
              job_name = "systemd-journal";
              journal = {
                max_age = "12h";
                labels = {
                  job = "systemd-journal";
                  host = hostname;
                };
              };
              relabel_configs = [{
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }];
            }
            {
              job_name = "nginx";
              static_configs = [{
                targets = [ "localhost" ];
                labels = {
                  job = "nginx";
                  host = hostname;
                  __path__ = "/var/log/nginx/*.log";
                };
              }];
            }
          ];
        };
      };

      # Open firewall for node_exporter on Tailscale interface only
      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ ports.nodeExporter ];
    })

    # ============================================
    # SERVER MODE (full stack)
    # ============================================
    (lib.mkIf cfg.enable {
      # Also enable agent mode on server
      control.monitoring.agent.enable = true;
      control.monitoring.agent.lokiUrl = "http://localhost:${toString ports.loki}";

      # ----------------------------------------
      # Secrets
      # ----------------------------------------
      sops.secrets = lib.mkMerge [
        {
          grafana_admin_password = {
            owner = "grafana";
            group = "grafana";
          };
        }
        (lib.mkIf (cfg.alertmanager.enable && cfg.alertmanager.email.enable) {
          smtp_host = {};
          smtp_username = {};
          smtp_password = {};
          smtp_from = {};
        })
        (lib.mkIf (cfg.alertmanager.enable && cfg.alertmanager.matrix.enable) {
          matrix_alertmanager_token = {};
        })
      ];

      # ----------------------------------------
      # Grafana
      # ----------------------------------------
      services.grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = ports.grafana;
            domain = cfg.grafana.domain;
            root_url = "https://${cfg.grafana.domain}";
          };

          security = {
            admin_user = "admin";
            admin_password = "$__file{${config.sops.secrets.grafana_admin_password.path}}";
          };

          "auth.anonymous" = lib.mkIf cfg.grafana.anonymousAccess {
            enabled = true;
            org_role = "Viewer";
          };

          analytics.reporting_enabled = false;
        };

        provision = {
          enable = true;

          datasources.settings.datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://localhost:${toString ports.prometheus}";
              isDefault = true;
              editable = false;
            }
            {
              name = "Loki";
              type = "loki";
              url = "http://localhost:${toString ports.loki}";
              editable = false;
            }
          ] ++ lib.optional cfg.alertmanager.enable {
            name = "Alertmanager";
            type = "alertmanager";
            url = "http://localhost:${toString ports.alertmanager}";
            editable = false;
            jsonData = {
              implementation = "prometheus";
            };
          };
        };
      };

      # Expose Grafana via webService
      control.webService.grafana = {
        enable = true;
        domain = cfg.grafana.domain;
        upstream = "http://127.0.0.1:${toString ports.grafana}";
        useTunnel = cfg.grafana.useTunnel;
        websockets = true;
      };

      # ----------------------------------------
      # Prometheus
      # ----------------------------------------
      services.prometheus = {
        enable = true;
        port = ports.prometheus;
        listenAddress = "127.0.0.1";
        retentionTime = "${toString cfg.prometheus.retentionDays}d";

        globalConfig = {
          scrape_interval = "15s";
          evaluation_interval = "15s";
        };

        scrapeConfigs = [
          # Local node exporter
          {
            job_name = "node";
            static_configs = [{
              targets = [ "localhost:${toString ports.nodeExporter}" ];
              labels = { host = hostname; };
            }];
          }
        ]
        # Remote node exporters
        ++ lib.optional (cfg.prometheus.remoteTargets != []) {
          job_name = "remote-nodes";
          static_configs = [{
            targets = map (h: "${h}:${toString ports.nodeExporter}") cfg.prometheus.remoteTargets;
          }];
          relabel_configs = [{
            source_labels = [ "__address__" ];
            regex = "([^:]+):.*";
            target_label = "host";
          }];
        }
        # Nginx exporter
        ++ lib.optional cfg.prometheus.exporters.nginx {
          job_name = "nginx";
          static_configs = [{
            targets = [ "localhost:${toString ports.nginxExporter}" ];
            labels = { host = hostname; };
          }];
        }
        # Postgres exporter
        ++ lib.optional cfg.prometheus.exporters.postgres {
          job_name = "postgres";
          static_configs = [{
            targets = [ "localhost:${toString ports.postgresExporter}" ];
            labels = { host = hostname; };
          }];
        }
        # Matrix Synapse metrics (if enabled)
        ++ lib.optional matrixEnabled {
          job_name = "matrix-synapse";
          static_configs = [{
            targets = [ "localhost:${toString (config.control.matrix.port or 8008)}" ];
            labels = { host = hostname; };
          }];
          metrics_path = "/_synapse/metrics";
        }
        # GitLab metrics (if enabled)
        ++ lib.optional gitlabEnabled {
          job_name = "gitlab";
          static_configs = [{
            targets = [ "localhost:${toString ports.gitlabExporter}" ];
            labels = { host = hostname; };
          }];
          scheme = "http";
        };

        # Alertmanager integration
        alertmanagers = lib.mkIf cfg.alertmanager.enable [{
          static_configs = [{
            targets = [ "localhost:${toString ports.alertmanager}" ];
          }];
        }];

        # Default alert rules
        rules = lib.mkIf cfg.alertmanager.enable [
          (builtins.toJSON {
            groups = [{
              name = "system";
              rules = [
                {
                  alert = "HighCPUUsage";
                  expr = ''100 - (avg by(host) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85'';
                  for = "5m";
                  labels.severity = "warning";
                  annotations = {
                    summary = "High CPU usage on {{ $labels.host }}";
                    description = "CPU usage is above 85% for 5 minutes";
                  };
                }
                {
                  alert = "HighMemoryUsage";
                  expr = ''(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85'';
                  for = "5m";
                  labels.severity = "warning";
                  annotations = {
                    summary = "High memory usage on {{ $labels.host }}";
                    description = "Memory usage is above 85% for 5 minutes";
                  };
                }
                {
                  alert = "LowDiskSpace";
                  expr = ''(node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"} / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"}) * 100 < 15'';
                  for = "5m";
                  labels.severity = "warning";
                  annotations = {
                    summary = "Low disk space on {{ $labels.host }}";
                    description = "Disk space is below 15% on {{ $labels.device }}";
                  };
                }
                {
                  alert = "ServiceDown";
                  expr = ''node_systemd_unit_state{state="failed"} == 1'';
                  for = "1m";
                  labels.severity = "critical";
                  annotations = {
                    summary = "Service failed on {{ $labels.host }}";
                    description = "Service {{ $labels.name }} is in failed state";
                  };
                }
                {
                  alert = "TargetDown";
                  expr = "up == 0";
                  for = "5m";
                  labels.severity = "critical";
                  annotations = {
                    summary = "Target {{ $labels.job }} is down";
                    description = "{{ $labels.instance }} has been down for 5 minutes";
                  };
                }
              ];
            }];
          })
        ];
      };

      # Nginx exporter (stub_status based)
      services.prometheus.exporters.nginx = lib.mkIf cfg.prometheus.exporters.nginx {
        enable = true;
        port = ports.nginxExporter;
        scrapeUri = "http://127.0.0.1:${toString ports.nginxStatus}/nginx_status";
      };

      # Enable nginx stub_status for the exporter
      services.nginx.virtualHosts."localhost" = lib.mkIf cfg.prometheus.exporters.nginx {
        listen = [{ addr = "127.0.0.1"; port = ports.nginxStatus; }];
        locations."/nginx_status" = {
          extraConfig = ''
            stub_status on;
            access_log off;
          '';
        };
      };

      # Postgres exporter
      services.prometheus.exporters.postgres = lib.mkIf cfg.prometheus.exporters.postgres {
        enable = true;
        port = ports.postgresExporter;
        runAsLocalSuperUser = true;
      };

      # ----------------------------------------
      # Loki
      # ----------------------------------------
      services.loki = {
        enable = true;
        configuration = {
          auth_enabled = false;

          server = {
            http_listen_port = ports.loki;
            http_listen_address = "0.0.0.0";
          };

          common = {
            path_prefix = "/var/lib/loki";
            storage.filesystem = {
              chunks_directory = "/var/lib/loki/chunks";
              rules_directory = "/var/lib/loki/rules";
            };
            replication_factor = 1;
            ring = {
              instance_addr = "127.0.0.1";
              kvstore.store = "inmemory";
            };
          };

          schema_config.configs = [{
            from = "2024-01-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }];

          limits_config = {
            retention_period = "${toString cfg.loki.retentionDays}d";
            reject_old_samples = true;
            reject_old_samples_max_age = "168h";
          };

          compactor = {
            working_directory = "/var/lib/loki/compactor";
            retention_enabled = true;
            delete_request_store = "filesystem";
          };
        };
      };

      # Open Loki port on Tailscale interface only
      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ ports.loki ];

      # ----------------------------------------
      # Alertmanager (optional)
      # ----------------------------------------
      services.prometheus.alertmanager = lib.mkIf cfg.alertmanager.enable {
        enable = true;
        port = ports.alertmanager;
        listenAddress = "127.0.0.1";

        configuration = {
          route = {
            receiver = "default";
            group_by = [ "alertname" "host" ];
            group_wait = "30s";
            group_interval = "5m";
            repeat_interval = "4h";
          };

          receivers = [
            {
              name = "default";
              webhook_configs =
                if cfg.alertmanager.matrix.enable then [{
                  url = "http://localhost:${toString ports.matrixAlertBot}/alerts";
                  send_resolved = true;
                }] else [];
              email_configs =
                if cfg.alertmanager.email.enable then [{
                  to = cfg.alertmanager.email.to;
                  send_resolved = true;
                }] else [];
            }
          ];
        } // (if cfg.alertmanager.email.enable then {
          global = {
            smtp_smarthost = "{{ .ExternalURL }}";
            smtp_from = "{{ .ExternalURL }}";
            smtp_require_tls = true;
          };
        } else {});
      };

      # This runs a webhook receiver that posts to Matrix
      systemd.services.matrix-alertmanager-bot = lib.mkIf (cfg.alertmanager.enable && cfg.alertmanager.matrix.enable) {
        description = "Matrix Alertmanager Bot";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        script = ''
          export MATRIX_HOMESERVER="${matrixHomeserver}"
          export MATRIX_ROOM_ID="${cfg.alertmanager.matrix.roomId}"
          export MATRIX_ACCESS_TOKEN="$(cat ${config.sops.secrets.matrix_alertmanager_token.path})"
          export LISTEN_ADDRESS="127.0.0.1:${toString ports.matrixAlertBot}"
          exec ${pkgs.alertmanager-matrix-forwarder or pkgs.writeShellScript "matrix-alert-stub" ''
            # Fallback if package not available
            echo "Matrix alertmanager forwarder not available, using simple webhook logger"
            ${pkgs.python3}/bin/python3 -m http.server ${toString ports.matrixAlertBot} --bind 127.0.0.1
          ''}
        '';

        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = 5;
          DynamicUser = true;
        };
      };

      # ----------------------------------------
      # Enable Matrix metrics if Matrix is enabled
      # ----------------------------------------
      services.matrix-synapse.settings.enable_metrics = lib.mkIf matrixEnabled true;

      # ----------------------------------------
      # Distributed backup
      # ----------------------------------------
      control.distributedBackup.paths = lib.mkIf cfg.backup.enable [
        { path = "/var/lib/prometheus2"; name = "prometheus"; }
        { path = "/var/lib/grafana"; name = "grafana"; }
        { path = "/var/lib/loki"; name = "loki"; }
      ];
    })
  ];
}
