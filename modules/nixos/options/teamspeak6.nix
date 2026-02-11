{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.control.teamspeak6;
  pkg = pkgs.doxpkgs.teamspeak6-server;
in {
  options.control.teamspeak6 = {
    enable = mkEnableOption "TeamSpeak 6 Server Beta";

    acceptLicense = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Accept the TeamSpeak license agreement.
        You must set this to true to run the server.
        Read the license at: https://teamspeak.com/en/legal/
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/teamspeak6";
      description = "Directory for server data, database, and logs";
    };

    voicePort = mkOption {
      type = types.port;
      default = 9987;
      description = "UDP port for voice connections";
    };

    fileTransferPort = mkOption {
      type = types.port;
      default = 30033;
      description = "TCP port for file transfers";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open firewall ports for voice and file transfer";
    };

    query = {
      http = {
        enable = mkEnableOption "HTTP query interface";
        port = mkOption {
          type = types.port;
          default = 10080;
          description = "Port for HTTP query interface";
        };
      };
      ssh = {
        enable = mkEnableOption "SSH query interface";
        port = mkOption {
          type = types.port;
          default = 10022;
          description = "Port for SSH query interface";
        };
      };
    };

    database = {
      plugin = mkOption {
        type = types.enum [ "sqlite3" "mariadb" ];
        default = "sqlite3";
        description = "Database backend to use";
      };

      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Database host (MariaDB only)";
      };

      port = mkOption {
        type = types.port;
        default = 3306;
        description = "Database port (MariaDB only)";
      };

      name = mkOption {
        type = types.str;
        default = "teamspeak";
        description = "Database name (MariaDB only)";
      };

      username = mkOption {
        type = types.str;
        default = "teamspeak";
        description = "Database username (MariaDB only)";
      };

      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to file containing database password (MariaDB only)";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.acceptLicense;
        message = ''
          You must accept the TeamSpeak license to use TeamSpeak 6 Server.
          Set control.teamspeak6.acceptLicense = true after reading the license.
        '';
      }
      {
        assertion = cfg.database.plugin == "sqlite3" || cfg.database.passwordFile != null;
        message = "MariaDB requires database.passwordFile to be set";
      }
    ];

    users.users.teamspeak = {
      isSystemUser = true;
      group = "teamspeak";
      home = cfg.dataDir;
      description = "TeamSpeak 6 server user";
    };

    users.groups.teamspeak = {};

    systemd.services.teamspeak6 = {
      description = "TeamSpeak 6 Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        TSSERVER_LICENSE_ACCEPTED = "accept";
        TSSERVER_DEFAULT_PORT = toString cfg.voicePort;
        TSSERVER_FILE_TRANSFER_PORT = toString cfg.fileTransferPort;
        TSSERVER_DATABASE_PLUGIN = cfg.database.plugin;
        TSSERVER_DATABASE_SQL_PATH = "${pkg}/share/teamspeak6-server/sql";
        TSSERVER_DATABASE_SQL_CREATE_PATH = "${pkg}/share/teamspeak6-server/sql/create_${
          if cfg.database.plugin == "sqlite3" then "sqlite" else cfg.database.plugin
        }";
        TSSERVER_LOG_PATH = "${cfg.dataDir}/logs";
        TSSERVER_QUERY_DOCUMENTATION_PATH = "${pkg}/share/teamspeak6-server/serverquerydocs";
      } // optionalAttrs cfg.query.http.enable {
        TSSERVER_QUERY_HTTP_ENABLED = "1";
        TSSERVER_QUERY_HTTP_PORT = toString cfg.query.http.port;
      } // optionalAttrs cfg.query.ssh.enable {
        TSSERVER_QUERY_SSH_ENABLED = "1";
        TSSERVER_QUERY_SSH_PORT = toString cfg.query.ssh.port;
      } // optionalAttrs (cfg.database.plugin == "mariadb") {
        TSSERVER_DATABASE_HOST = cfg.database.host;
        TSSERVER_DATABASE_PORT = toString cfg.database.port;
        TSSERVER_DATABASE_NAME = cfg.database.name;
        TSSERVER_DATABASE_USERNAME = cfg.database.username;
      };

      serviceConfig = {
        Type = "simple";
        User = "teamspeak";
        Group = "teamspeak";
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${pkg}/bin/tsserver";
        Restart = "on-failure";
        RestartSec = 5;

        StateDirectory = "teamspeak6";
        StateDirectoryMode = "0750";

        # Read database password if using MariaDB
        EnvironmentFile = mkIf (cfg.database.plugin == "mariadb" && cfg.database.passwordFile != null)
          cfg.database.passwordFile;

        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
      };

      preStart = ''
        mkdir -p ${cfg.dataDir}/logs
      '';
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPorts = [ cfg.voicePort ];
      allowedTCPPorts = [ cfg.fileTransferPort ]
        ++ optional cfg.query.http.enable cfg.query.http.port
        ++ optional cfg.query.ssh.enable cfg.query.ssh.port;
    };
  };
}
