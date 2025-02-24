{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [
  	pkgs.gvfs
	pkgs.usbutils	
  ];

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.devmon.enable = true;
}
