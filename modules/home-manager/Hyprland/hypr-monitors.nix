{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland.settings = {
    monitor = [
	    "DP-1, 1920x1080@144, 0x0, 1"
    ];
  };
}