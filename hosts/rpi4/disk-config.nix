{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/mmcblk0";  # SD card on RPi4
        content = {
          type = "gpt";
          partitions = {
            # Boot partition (FAT32 for RPi4 firmware)
            boot = {
              size = "512M";
              type = "EF00";  # EFI System Partition
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };
            
            # Root partition (ephemeral)
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-L" "nixos" "-f" ];
                subvolumes = {
                  # Ephemeral root
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  
                  # Persistent data
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  
                  # Nix store (can be ephemeral or persistent)
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  
                  # Swap file location
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "2G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}