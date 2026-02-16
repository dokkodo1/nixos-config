{ config, lib, pkgs, ... }:

{
  options.control.gpuVendor = lib.mkOption {
    type = lib.types.enum [ "amd" "nvidia" "intel" null ];
    default = null;
    description = "GPU vendor";
  };

  config = lib.mkMerge [
    (lib.mkIf (config.control.gpuVendor == "amd") {
      boot.kernelModules = [ "amdgpu" ];
      services.xserver.videoDrivers = [ "amdgpu" ];
      environment.systemPackages = [ pkgs.lact ];
      environment.variables.AMD_VULKAN_ICD = "RADV"; # forces RADV, defaults to amdvlk if provided in hardware.graphics.extraPackages
      systemd.packages = [ pkgs.lact ];
      systemd.services.lactd.wantedBy = [ "multi-user.target" ];
      hardware.graphics = {
        # NixOS enables Vulkan through Mesa RADV by default
        # https://nixos.org/manual/nixos/unstable/index.html#sec-gpu-accel-vulkan
        enable = lib.mkDefault true;
        enable32Bit = lib.mkDefault true;
      };

    })
    
    (lib.mkIf (config.control.gpuVendor == "nvidia") {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.graphics = {
        enable = lib.mkDefault true;
        enable32Bit = lib.mkDefault true;
      };
      
      hardware.nvidia = {
        modesetting.enable = lib.mkDefault true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.production; # can replace stable with either beta, latest, or production. Worth imo
      };
    
      environment.systemPackages = with pkgs; [
        nvtopPackages.nvidia
      ];

    })
    (lib.mkIf (config.control.gpuVendor == "intel") {
      # one day ...

    })
  ];
}
