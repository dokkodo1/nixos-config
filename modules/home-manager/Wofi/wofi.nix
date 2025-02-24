{ config, pkgs, lib, ... }:

{
  programs.wofi = {
		enable = true;
		style = builtins.readFile ./wofi.css;
		settings = {
			width = 420;
			height = 550;
			location = "center";
			show = "drun";
			matching = "fuzzy";
			prompt = "Search...";
			filter_rate = 100;
			allow_markup=true;
			no_actions = true;
			halign = "fill";
			orientation = "vertical";
			content_halign = "fill";
			insensitive = true;
			allow_images = true;
			image_size = 28;
			gtk_dark = false;
			term ="kitty";
		};
  };
}
