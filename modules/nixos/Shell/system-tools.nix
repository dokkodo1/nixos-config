{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
  	vim
	wget
	tree
	feh
	grim
	wl-clipboard
	slurp
  ];
}
