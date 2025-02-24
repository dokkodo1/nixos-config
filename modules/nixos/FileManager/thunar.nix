{ config, pkgs, lib, ... }:

{
  imports = [
	./drives.nix
  ];

  programs.thunar = {
	enable = true;
	plugins = with pkgs.xfce; [
		thunar-archive-plugin
		thunar-volman
	];
  };
}
