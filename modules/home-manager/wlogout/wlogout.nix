{ config, ... }:

{
  programs.wlogout = {
    enable = true;
    style = builtins.readFile ./wlogout.css;
    layout = [
	{
    	label = "lock";
    	action = "hyprlock";
	text = "lock";
    	keybind = "l";
	}
	{
    	label = "reboot";
    	action = "systemctl reboot";
	text = "reboot";
    	keybind = "r";
	}
	{
    	label = "logout";
    	action = "loginctl terminate-user $USER";
	text = "logout";
    	keybind = "e";
	}
	{
    	label = "shutdown";
    	action = "systemctl poweroff";
	text = "shutdown";
    	keybind = "s";
	}
    ];
  };
}
