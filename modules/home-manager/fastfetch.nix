{ config, pkgs, lib, ... }:

{
  programs.fastfetch = {
		enable = true;

		settings = {
		  logo = {
  	  	source = "/home/evan/configurations/files/icons/NixOS-Logo.png";
  	  	type = "kitty-direct";
  	  	padding = {
# 	   		"top" = 2;
  	      "left" = 4;
  	  	};
				width = 40;
				height = 22;
  	  };
  	  display = {
  	    separator = " ";
  	  };

  	  modules = [
				"break"
  	    "break"
  	    {
  	      "type" = "os";
  	      "key" = " ";
  	      "keyColor" = "34";
  	    }
  	    {
  	      "type" = "kernel";
  	      "key" = " ";
  	      "keyColor" = "34";
  	    }
  	    {
  	      "type" = "packages";
  	      "key" = " ";
  	     	"keyColor" = "34"; 
  	    }
  	    {
  	      "type" = "shell";
  	      "key" = " ";
  	      "keyColor" = "34";
				}
  	    "break"
  	    {
  	      "type" = "terminal";
  	      "key" = " ";
  	      "keyColor" = "34"; 
  	    }
  	    {
  	      "type" = "wm";
  	      "key" = " ";
  	      "keyColor" = "34"; 
  	    }
  	    {
  	      "type" = "cursor";
  	      "key" = " ";
  	      "keyColor" = "34"; 
  	    }
  	    {
  	      "type" = "terminalfont";
  	      "key" = " ";
  	      "keyColor" = "34"; 
  	    }
  	    {
  	      "type" = "uptime";
  	      "key" = " ";
  	      "keyColor" = "34"; 
  	    }
  	    {
  	      "type" = "command";
  	      "key" = "󱦟 ";
  	      "keyColor" = "34";
  	      "text" = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
  	    }
  	    {
  	      "type" = "datetime";
  	      "format" = "{1}-{3}-{11}";
  	      "key" = " ";
  	      "keyColor" = "34"; 
  	    }
  	    "break"
  	    "break"
  	    {
  	      "type" = "cpu";
  	      "key" = " ";
  	      "keyColor" = "blue";
  	    }
  	    {	
  	      "type" = "gpu";
  	      "key" = " ";
  	      "keyColor" = "blue";
  	    }
  	    {
  	      "type" = "memory";
  	      "key" = " ";
  	      "keyColor" = "blue";
  	    }
  	    "break"
  	    "break"
  	  ];
		};	
	};
}
