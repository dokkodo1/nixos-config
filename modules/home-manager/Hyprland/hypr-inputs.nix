{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland.settings = {
		input = {
    	kb_layout = "us";
    	kb_options = "caps:swapescape";
    	follow_mouse = 0;
    	sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
		};
  };
}
