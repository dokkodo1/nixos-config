{ config, pkgs, lib, ... }:

{
  programs.git = {
	  enable = true;
	  #userName = "Name";
	  #userEmail = "name@mail.com";
	  #extraConfig = {
	  #	init.defaultBranch = "main";
	  #	safe.directory = "/etc/nixos";	
    #};
  };
}
