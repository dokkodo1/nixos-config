{ config, pkgs, lib, ... }:

{
  programs.hyprland = {
	enable = true;
	withUWSM = true; 
  };

  environment.systemPackages = [
    pkgs.hyprpaper
  ];
}
