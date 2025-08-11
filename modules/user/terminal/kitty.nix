{ config, pkgs, lib, ... }:

{
  programs.kitty = lib.mkForce {
		enable = true;
		settings = {
			font_family = "JetBrainsMono Nerd Font";
			font_size = 12;

			cursor_shape = "underline";
			cursor_blink_interval = 0;
			copy_on_select = true;
			strip_trailing_spaces = "smart";

			enable_audio_bell = false;

			confirm_os_window_close = 0;
			window_margin_width = 8;
			hide_window_decorations = true;

			foreground = "#a9b1d6";
			background = "#1a1b26";
			background_opacity = 0.60;
			background_blur = 1;
			dynamic_background_opacity = true; 
			wayland_enable_ime = true;

			color0 = "#414868";
			color8 = "#414868";
			#: black

			color1 = "#f7768e";
			color9 = "#f7768e";
			#: red

			color2 = "#73daca";
			color10 = "#73daca";
			#: green

			color3 = "#e0af69";
			color11 = "#e0af69";
			#: yellow

			color4 = "#7aa2f7";
			color12 = "#7aa2f7";
			#: blue

			color5 = "#bb9af7";
			color13 = " #bb9af7";
			#: magenta

			color6 = "#7dcfff";
			color14 = "#7dcfff";
			#: cyan

			color7 = "#c0caf5";
			color15 = "#c0caf5";
			#: white
		};
  };
}
