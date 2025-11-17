{ config, pkgs, ... }:
{

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable; # can replace stable with either beta, latest, or production. Worth imo
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
