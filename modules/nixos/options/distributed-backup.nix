{ config, pkgs, lib, ... }:

let
  cfg = config.control.distributedBackup;

  pathOpts = lib.types.submodule {
    options = {
      path = lib.mkOption {
        type = lib.types.str;
        description = "Path to back up";
      };
      name = lib.mkOption {
        type = lib.types.str;
        description = "Name for this backup (used in target directory structure)";
      };
    };
  };

  sshKeyPath = "/root/.ssh/id_ed25519_backup";
  sshOpts = "-o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=accept-new -i ${sshKeyPath}";

  backupScript = pkgs.writeShellScript "distributed-backup" ''
    set -euo pipefail

    TARGETS="${lib.concatStringsSep " " cfg.targets}"
    TARGET_DIR="${cfg.targetDir}"
    METHOD="${cfg.method}"
    PATHS_JSON='${builtins.toJSON cfg.paths}'
    SSH_OPTS="${sshOpts}"

    log() {
      echo "[$(date -Iseconds)] $*"
    }

    # Get online Tailscale peers
    get_online_peers() {
      ${pkgs.tailscale}/bin/tailscale status --json | \
        ${pkgs.jq}/bin/jq -r '.Peer | to_entries[] | select(.value.Online == true) | .value.HostName'
    }

    # Check if target is online and has backup directory
    check_target() {
      local target="$1"
      if ssh $SSH_OPTS "root@$target" "test -d '$TARGET_DIR'" 2>/dev/null; then
        return 0
      fi
      return 1
    }

    # Run restic backup
    backup_restic() {
      local target="$1"
      local path="$2"
      local name="$3"
      local repo="sftp:root@$target:$TARGET_DIR/restic/$name"

      export RESTIC_PASSWORD_FILE="${config.sops.secrets.backup_restic_password.path}"
      export SFTP_COMMAND="ssh $SSH_OPTS root@$target -s sftp"

      # Initialize repo if needed
      if ! ${pkgs.restic}/bin/restic -r "$repo" -o sftp.command="$SFTP_COMMAND" snapshots >/dev/null 2>&1; then
        log "Initializing restic repo for $name on $target"
        ${pkgs.restic}/bin/restic -r "$repo" -o sftp.command="$SFTP_COMMAND" init
      fi

      log "Backing up $name to $target via restic"
      ${pkgs.restic}/bin/restic -r "$repo" -o sftp.command="$SFTP_COMMAND" backup "$path" ${lib.concatStringsSep " " cfg.restic.extraArgs}
    }

    # Run rsync backup
    backup_rsync() {
      local target="$1"
      local path="$2"
      local name="$3"
      local dest="root@$target:$TARGET_DIR/rsync/$name/"

      log "Backing up $name to $target via rsync"
      ${pkgs.rsync}/bin/rsync -avz -e "ssh $SSH_OPTS" ${lib.concatStringsSep " " cfg.rsync.extraArgs} "$path/" "$dest"
    }

    # Main backup logic
    main() {
      local online_peers
      online_peers=$(get_online_peers)

      local success=0
      local attempted=0

      for target in $TARGETS; do
        if echo "$online_peers" | grep -qx "$target"; then
          log "Target $target is online, checking backup directory..."

          if check_target "$target"; then
            log "Target $target has backup directory, starting backup..."
            attempted=$((attempted + 1))

            local backup_success=1
            while IFS= read -r path_entry; do
              path=$(echo "$path_entry" | ${pkgs.jq}/bin/jq -r '.path')
              name=$(echo "$path_entry" | ${pkgs.jq}/bin/jq -r '.name')

              if [ ! -e "$path" ]; then
                log "Warning: Path $path does not exist, skipping"
                continue
              fi

              if [ "$METHOD" = "restic" ]; then
                if ! backup_restic "$target" "$path" "$name"; then
                  log "Error: restic backup of $name to $target failed"
                  backup_success=0
                fi
              else
                if ! backup_rsync "$target" "$path" "$name"; then
                  log "Error: rsync backup of $name to $target failed"
                  backup_success=0
                fi
              fi
            done < <(echo "$PATHS_JSON" | ${pkgs.jq}/bin/jq -c '.[]')

            if [ "$backup_success" = "1" ]; then
              log "Backup to $target completed successfully"
              success=$((success + 1))
            fi
          else
            log "Target $target is online but backup directory $TARGET_DIR does not exist"
          fi
        else
          log "Target $target is offline"
        fi
      done

      if [ "$success" -eq 0 ]; then
        if [ "$attempted" -eq 0 ]; then
          log "Error: No targets were available for backup"
        else
          log "Error: All backup attempts failed"
        fi
        exit 1
      fi

      log "Backup completed successfully to $success target(s)"
    }

    main
  '';
in
{
  options.control.distributedBackup = {
    enable = lib.mkEnableOption "distributed backup to Tailscale peers";

    allowIncoming = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow this host to receive backups from other hosts (enables root SSH with backup key)";
    };

    paths = lib.mkOption {
      type = lib.types.listOf pathOpts;
      default = [];
      description = "Paths to back up";
      example = [
        { path = "/var/lib/vaultwarden"; name = "vaultwarden"; }
        { path = "/var/backup/gitlab"; name = "gitlab"; }
      ];
    };

    targets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Tailscale hostnames to try as backup targets";
      example = [ "nixtop" "desktop" "hpl-macmini" ];
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "Backup schedule (systemd calendar format)";
      example = "*-*-* 02:00:00";
    };

    targetDir = lib.mkOption {
      type = lib.types.str;
      default = "/backup";
      description = "Directory on remote targets for storing backups";
    };

    method = lib.mkOption {
      type = lib.types.enum [ "restic" "rsync" ];
      default = "restic";
      description = "Backup method: restic (encrypted, deduplicated) or rsync (plain copies)";
    };

    restic = {
      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "--exclude-caches" ];
        description = "Extra arguments to pass to restic backup";
      };
    };

    rsync = {
      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "--delete" "--compress" ];
        description = "Extra arguments to pass to rsync";
      };
    };

    onFailure = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable failure notifications";
      };

      script = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Custom script to run on failure (default logs to journald with high priority)";
      };
    };
  };

  config = lib.mkMerge [
    # Config for hosts that RECEIVE backups (or send them - enable implies allowIncoming)
    (lib.mkIf (cfg.allowIncoming || cfg.enable) {
      # Add backup public key to root's authorized_keys
      users.users.root.openssh.authorizedKeys.keys =
        let keys = import ../../../keys.nix;
        in lib.optional (keys ? backup) keys.backup.key;

      # Allow root login with keys only (for backups)
      services.openssh.settings.PermitRootLogin = "prohibit-password";
    })

    # Config for hosts that SEND backups
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.paths != [];
          message = "control.distributedBackup.paths must not be empty when backup is enabled";
        }
        {
          assertion = cfg.targets != [];
          message = "control.distributedBackup.targets must not be empty when backup is enabled";
        }
      ];

      sops.secrets = lib.mkMerge [
        (lib.mkIf (cfg.method == "restic") {
          backup_restic_password = {};
        })
        {
          backup_ssh_key = {
            mode = "0600";
            path = "/root/.ssh/id_ed25519_backup";
          };
        }
      ];

      systemd.services.distributed-backup = {
        description = "Distributed backup to Tailscale peers";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        path = [ pkgs.openssh ];

        environment = {
          SSH_IDENTITY_FILE = "/root/.ssh/id_ed25519_backup";
        };

        serviceConfig = {
          Type = "oneshot";
          ExecStart = backupScript;
          User = "root";

          # Allow SSH access to Tailscale peers
          PrivateNetwork = false;
        };

        onFailure = lib.mkIf cfg.onFailure.enable [ "distributed-backup-notify.service" ];
      };

      systemd.services.distributed-backup-notify = lib.mkIf cfg.onFailure.enable {
        description = "Notify on distributed backup failure";

        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            if cfg.onFailure.script != null
            then cfg.onFailure.script
            else pkgs.writeShellScript "backup-notify" ''
              echo "Distributed backup failed! Check: journalctl -u distributed-backup" | \
                ${pkgs.systemd}/bin/systemd-cat -t distributed-backup -p err
            '';
        };
      };

      systemd.timers.distributed-backup = {
        description = "Timer for distributed backup";
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnCalendar = cfg.schedule;
          Persistent = true;
          RandomizedDelaySec = "30m";
        };
      };
    })
  ];
}
