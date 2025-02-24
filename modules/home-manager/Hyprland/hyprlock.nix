{ config, pkgs, lib, ... }:

{
  programs.hyprlock = {
		enable = true;
		settings = {	
		  general = {
	    	disable_loading_bar = true;
	    	grace = 300;
	    	hide_cursor = true;
	    	no_fade_in = false;
	  	};

	  	background = [
	      {
	    	path = "screenshot";
	    	blur_passes = 3;
	    	blur_size = 8;
	      }
	  	];

		  input-field = [ 
		    {
	   		size = "20%, 5%";
	    	outline_thickness = 3;
	    	inner_color = "rgba(0, 0, 0, 0)";
	    	outer_color = "rgba(bb9af7ee) rgba(7aa2f7ee) 45deg";
	    	check_color= "rgba(00ff99ee) rgba(ff6633ee) 120deg";
	    	fail_color= "rgba(ff6633ee) rgba(ff0066ee) 40deg";
	    	font_color = "#000000";
	    	fade_on_empty = false;
	    	rounding = 15;
	    	position = "0, -300";
	    	halign = "center";
	    	valign = "center";
		    }
		  ];


			# Day
		  label = [ 
		    {
	    	text = "$TIME";
	    	color = "#ffffff";
	   		font_size = 34;
	  		font_family = "JetBrains Mono Nerd Font 10";
	  		position = "0, -100";
    		halign = "center";
    		valign = "top";
		    }
		  ];

# ---------------- NO IDEA WHAT THIS IS --------------------------
#	 	  # Date
#		  label-date = [
#		    {
#	    	monitor = "";
#	    	text = ''cmd[update:18000000] echo "<b> "$('%A, %-d %B %Y')" </b>"'';
#	    	color = "$color12";
#	    	font_size = 34;
#	    	font_family = "JetBrains Mono Nerd Font 10";
#	    	position = "0, -300";
#	    	halign = "center";
#	    	valign = "top";
#		    }
#		  ];
#
#
#	    # Week
#		  label-week = [
#		    {
#	    	monitor = "";
#	    	text = ''cmd[update:18000000] echo "<b> "$(date +'Week %U')" </b>"'';
#	    	color = "$color5";
#	    	font_size = "24";
#	  		font_family = "JetBrains Mono Nerd Font 10";
#	    	position = "0, -300";
#	    	halign = "center";
#	    	valign = "top";
#		    }
#		  ];
#
#
#	    # Time
#		  label-time = [
#		    {
#	    	monitor = "";
#				text = ''cmd[update:1000] echo "<b><big> $(date +"%H:%M:%S") </big></b>"''; # 24H
#	 			color = "$color15";
#	  		font_size = 94;
#	   		font_family = "JetBrains Mono Nerd Font 10";
#	   		position = "0, 0";
#	    	halign = "center";
#	    	valign = "center";
#		    }
#		  ];

		};
  };
}
