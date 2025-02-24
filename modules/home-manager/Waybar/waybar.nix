{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    style = builtins.readFile ./waybar.css; 
    settings = {
    	mainBar = {
  			layer = "top";
  			position = "top";
  			height = 32;
  			spacing = 12;
  			margin = "10";
  			reload_sytle_on_change = true;
    
#Choose the order of the modules
				modules-left = [
					"group/lefties"
					"tray"
  			];
  			modules-center = [
					"clock"
  			];
  			modules-right = [
					"group/controls"
					"group/hardware"
					"group/power"
  			];


#Groups
#-----------------------------------------------------------------------------------

				"group/lefties" = {
					orientation = "horizontal";
					modules = [ 
					  "image#logo"
					  "hyprland/workspaces"
					];
				};

				"group/controls" = {
					orientation = "horizontal";
					modules = [
					  "network"
					  "pulseaudio"
					];	
				};

				"group/hardware" = {
					orientation = "horizontal";
					modules = [
					  "cpu"
					  "memory"
					  "temperature"
					  "battery"
					];
				};

				"group/power" = {
					orientation = "horizontal";
					modules = [
						"custom/power"
					];	
				};

#Modules configuration
#-----------------------------------------------------------------------------------
				"hyprland/workspaces" = {
					active-only = false;
					all-outputs = true;
					format = "{id}";
#					persistent-workspaces": {
#					  "*" = 5;
#					};
				};

#-----------------------------------------------------------------------------------
				"image#logo" = {
					path = "/etc/nixos/files/icons/NixOS-Logo.png";
					on-click = "kitty";
				};

#-----------------------------------------------------------------------------------
				"clock" = {
					tooltip-format = "<tt><small>{calendar}</small></tt>";
					calendar = {
					  mode = "month";
					  mode-mon-col = 3;
					  weeks-pos = "right";
					  on-scroll = 1;
					  on-click-right = "mode";
  			  	format = {
  			    	months = "<span color='#ffead3'><b>{}</b></span>";
  			    	days = "<span color='#ecc6d9'><b>{}</b></span>";
  			    	weeks = "<span color='#99ffdd'><b>W{}</b></span>";
  			    	weekdays = "<span color='#ffcc66'><b>{}</b></span>";
  			    	today = "<span color='#ff6699'><b><u>{}</u></b></span>";
  			  	};	
					};
  			  actions = {
  			  	on-click-right = "mode";
  			  	on-click-forward = "tz_up";
  			    on-click-backward = "tz_down";
  			    on-scroll-up = "shift_up";
  			  	on-scroll-down = "shift_down";
  			 	};
  			  format = " {:%d/%m/%Y  %H:%M}";
  			  format-alt = "  {:%d/%m/%Y  %H:%M:%S}";
  			  interval = 1;
				};

#-----------------------------------------------------------------------------------
				"cpu" = {
  			  format = "{usage}% ";
  			  tooltip = false;
				};
			
#-----------------------------------------------------------------------------------
				"memory" = {
        	format = "{}% ";
				};

#-----------------------------------------------------------------------------------
				"temperature" = {
#        	thermal-zone = 2;
#        	hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
        	critical-threshold = 80;
#        	format-critical = "{temperatureC}°C {icon}";
        	format = "{temperatureC}°C {icon}";
        	format-icons = ["" "" ""];
				};

#-----------------------------------------------------------------------------------
				"backlight" = {
        	device = "acpi_video1";
        	format = "{percent}% {icon}";
        	format-icons = ["" "" "" "" "" "" "" "" ""];
				};

#-----------------------------------------------------------------------------------
				"battery" = {
        	states = {
           	good = 95;
        	  warning = 30;
        	  critical = 15;
        	};
        	format = "{capacity}% {icon}";
        	format-full = "{capacity}% {icon}";
        	format-charging = "{capacity}% ";
       	 	format-plugged = "{capacity}% ";
        	format-alt = "{time} {icon}";
#        	format-good = ""; #An empty format will hide the module
#        	format-full = "";
        	format-icons = ["" "" "" "" ""];
				};

#-----------------------------------------------------------------------------------
				"network" = {
#        	interface": "wlp2*", // (Optional) To force the use of this interface
        	format-wifi = "{essid} ({signalStrength}%) ";
        	format-ethernet = "{ipaddr}/{cidr} ";
        	tooltip-format = "{ifname} via {gwaddr} ";
        	format-linked = "{ifname} (No IP) ";
        	format-disconnected = "Disconnected ⚠";
        	format-alt = "{ifname}: {ipaddr}/{cidr}";
				};

#------------------------------------------------,-----------------------------------
				"custom/power" = {
        	format = "⏻ ";
					tooltip = false;
					on-click = "wlogout";
				};


#-----------------------------------------------------------------------------------
				"tray" = {
#					"icon-size": 20;
					"spacing" = 8;
				};

#-----------------------------------------------------------------------------------
				"pulseaudio" = {
					format = "{volume}% {icon}";
					format-bluetooth = "{volume}% {icon}";
					format-muted = "";
					format-icons = {
					  "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
					  "alsa_output.pci-0000_00_1f.3.analog-stereo-muted" = "";
					  headphone = "";
					  hands-free = "";
					  headset = "";
					  phone = "";
					  phone-muted = "";
					  portable = "";
					  car = "";
					  default = ["" ""];
					};
					scroll-step = 1;
					on-click = "pavucontrol";
					ignored-sinks = ["Easy Effects Sink"];
				};
#-----------------------------------------------------------------------------------

    	};
  	};
  };
}
