{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.where-is-my-sddm-theme pkgs.sddm-sugar-dark  pkgs.libsForQt5.qt5.qtgraphicaleffects ];

  services.displayManager.sddm = {
	enable = true;
#	wayland.enable = true;
	theme = "sugar-dark";
  };
}
