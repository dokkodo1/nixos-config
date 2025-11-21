{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.control.virtualization;
in {
  options.control.virtualization = {
    enable = mkEnableOption "Enable virtualization with libvirt/QEMU/KVM";
    
    gpuPassthrough = {
      enable = mkEnableOption "Enable GPU passthrough configuration";
      
      cpuType = mkOption {
        type = types.enum [ "intel" "amd" ];
        example = "amd";
        description = "CPU vendor for IOMMU configuration";
      };
      
      gpuIDs = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "10de:2684" "10de:22ba" ];
        description = ''
          PCI IDs of GPU to pass through (vendor:device format).
          Find with: lspci -nn | grep -E "VGA|Audio"
          Include both the VGA and Audio device IDs.
        '';
      };
      
      reserveHostGPU = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "1002:7480";
        description = ''
          Optional: PCI ID of GPU to reserve for host (integrated graphics).
          Leave null if you have two discrete GPUs.
        '';
      };
    };
    
    lookingGlass = {
      enable = mkEnableOption "Enable Looking Glass for seamless VM display" // { default = false; };
      
      sharedMemorySize = mkOption {
        type = types.int;
        default = 128;
        description = "Shared memory size in MB for Looking Glass (should match VM resolution)";
      };
      
      user = mkOption {
        type = types.str;
        example = "yourusername";
        description = "User to grant Looking Glass permissions to";
      };
    };
    
    hugepages = {
      enable = mkEnableOption "Enable hugepages for better VM performance" // { default = true; };
      
      size = mkOption {
        type = types.int;
        default = 16384;
        description = "Amount of memory in MB to allocate to hugepages (set based on VM RAM needs)";
      };
    };
    
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      example = literalExpression "[ pkgs.quickemu pkgs.win-virtio ]";
      description = "Additional virtualization-related packages to install";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Base virtualization setup
    {
      users.groups.libvirtd.members = [ "root" ];

      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [(pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd];
          };
        };
      };

      programs.virt-manager.enable = true;
      
      environment.systemPackages = with pkgs; [
        virt-manager
        virt-viewer
        spice
        spice-gtk
        spice-protocol
        win-virtio
        win-spice
        virtiofsd
      ] ++ cfg.extraPackages;

    }

    (mkIf cfg.gpuPassthrough.enable {
      assertions = [
        {
          assertion = cfg.gpuPassthrough.gpuIDs != [];
          message = "You must specify GPU PCI IDs for passthrough in control.virtualization.gpuPassthrough.gpuIDs";
        }
      ];

      # Enable IOMMU
      boot.kernelParams = [
        (if cfg.gpuPassthrough.cpuType == "intel" 
         then "intel_iommu=on" 
         else "amd_iommu=on")
        "iommu=pt"
        # Prevent host from loading GPU drivers
        "video=efifb:off"
      ] ++ (optional (cfg.gpuPassthrough.gpuIDs != []) 
            "vfio-pci.ids=${concatStringsSep "," cfg.gpuPassthrough.gpuIDs}");

      boot.initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];

      boot.kernelModules = [ "kvm-${cfg.gpuPassthrough.cpuType}" ];

      # Bind GPU to VFIO at boot
      boot.extraModprobeConfig = ''
        options vfio-pci ids=${concatStringsSep "," cfg.gpuPassthrough.gpuIDs}
        softdep drm pre: vfio-pci
      '' + (optionalString (cfg.gpuPassthrough.reserveHostGPU != null) ''
        softdep amdgpu pre: vfio-pci
        softdep nvidia pre: vfio-pci
      '');
    })

    # Looking Glass configuration
    (mkIf cfg.lookingGlass.enable {
      assertions = [
        {
          assertion = cfg.lookingGlass.user != "";
          message = "You must specify a user for Looking Glass in control.virtualization.lookingGlass.user";
        }
      ];

      environment.systemPackages = with pkgs; [
        looking-glass-client
      ];

      systemd.tmpfiles.rules = [
        "f /dev/shm/looking-glass 0660 ${cfg.lookingGlass.user} qemu-libvirtd -"
      ];

      # Create kvmfr module for better Looking Glass performance
      boot.extraModulePackages = with config.boot.kernelPackages; [
        (kvmfr.overrideAttrs (old: {
          # Set static permissions for the kvmfr device
          patches = (old.patches or []);
        }))
      ];

      boot.extraModprobeConfig = ''
        options kvmfr static_size_mb=${toString cfg.lookingGlass.sharedMemorySize}
      '';

      boot.kernelModules = [ "kvmfr" ];
    })

    # Hugepages for performance
    (mkIf cfg.hugepages.enable {
      boot.kernelParams = [ 
        "hugepagesz=1G"
        "hugepages=${toString (cfg.hugepages.size / 1024)}"
      ];
      
      # Allow libvirt to use hugepages
      systemd.services.libvirtd.preStart = ''
        mkdir -p /dev/hugepages1G
        mount -t hugetlbfs -o pagesize=1G none /dev/hugepages1G || true
      '';
    })
  ]);
}
