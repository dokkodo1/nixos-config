{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland.enable = true; 

  imports = [
	./hypr-autostart.nix
	./hypr-keybinds.nix
	./hypr-optics.nix
	./hypr-monitors.nix
	./hypr-inputs.nix
  ];
}
