{
  disko.devices = {
    disk = {
      # Samsung SSD - Main system disk
      main = {
        device = "/dev/sdc";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };

      # Storage disk 1 - 2TB Seagate
      storage1 = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/storage/disk1";
              };
            };
          };
        };
      };

      # Storage disk 2 - 2TB Seagate SSHD
      storage2 = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/storage/disk2";
              };
            };
          };
        };
      };

      # Backup disk - 500GB WD
      backup = {
        device = "/dev/sdd";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            backup = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/backup";
              };
            };
          };
        };
      };
    };
  };
}