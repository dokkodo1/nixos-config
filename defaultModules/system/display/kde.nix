{ config, pkgs, lib, ... }:

{
  services = {
    displayManager = {
      #defaultSession = "plasmax11"; # display server toggle. default is Wayland
      sddm.enable = true;
      sddm.wayland.enable = true;
    };
    desktopManager = {
      plasma6.enable = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      konsave
    ];
    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      elisa
    ];
  };
}
