{ pkgs, ... }:

{

  #Grapics card
  environment.systemPackages = [ pkgs.lact ];
  environment.variables.AMD_VULKAN_ICD = "RADV"; # forces RADV, defaults to amdvlk if provided in hardware.graphics.extraPackages
  systemd.packages = [ pkgs.lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];
  hardware.graphics = {
    # NixOS enables Vulkan through Mesa RADV by default
    # https://nixos.org/manual/nixos/unstable/index.html#sec-gpu-accel-vulkan

    # openGL / Mesa
    enable = true;
    enable32Bit = true;

    # AMDVLK  
    #    extraPackages = [ pkgs.amdvlk ];
    #    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };
   # Force radv
}
