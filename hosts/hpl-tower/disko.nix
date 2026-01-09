{
  disko.devices = {
    disk = {
      # Samsung SSD - Main system disk with impermanence
      main = {
        type = "disk";
        device = "/dev/sdc";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          };
        };
      };

      # Storage disk 1 - 2TB Seagate
      storage1 = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };

      # Storage disk 2 - 2TB Seagate SSHD
      storage2 = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };

      # Additional storage - 500GB WD
      backup = {
        type = "disk";
        device = "/dev/sdd";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "backup";
              };
            };
          };
        };
      };
    };

    zpool = {
      # Main system pool on Samsung SSD
      rpool = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";

        datasets = {
          # Persistent data
          "safe" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "/persist";
          };
          "safe/home" = {
            type = "zfs_fs";
            mountpoint = "/persist/home";
          };
          "safe/root" = {
            type = "zfs_fs";
            mountpoint = "/persist/root";
          };
          
          # Ephemeral root (gets wiped on boot)
          "local" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            postCreateHook = "zfs snapshot rpool/local/root@blank";
          };
          
          # Nix store
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              atime = "off";
              canmount = "on";
              "com.sun:auto-snapshot" = "false";
            };
          };
        };
      };

      # Main storage pool - RAID1 mirror of the 2TB drives
      storage = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          compression = "lz4";
          atime = "off";
          "com.sun:auto-snapshot" = "true";
        };

        datasets = {
          "projects" = {
            type = "zfs_fs";
            mountpoint = "/storage/projects";
            options = {
              recordsize = "1M"; # Good for large audio files
              "com.sun:auto-snapshot" = "true";
            };
          };
          "media" = {
            type = "zfs_fs";
            mountpoint = "/storage/media";
            options = {
              recordsize = "1M"; # Good for large media files
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };

      # Backup pool - Single disk for additional backup
      backup = {
        type = "zpool";
        rootFsOptions = {
          compression = "gzip-9"; # High compression for backup
          atime = "off";
        };

        datasets = {
          "archive" = {
            type = "zfs_fs";
            mountpoint = "/backup";
            options = {
              "com.sun:auto-snapshot" = "false"; # Manual snapshots only
            };
          };
        };
      };
    };
  };
}
