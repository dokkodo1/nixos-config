{ config, pkgs, lib, ... }:

{
  fonts.packages = [
	pkgs.font-awesome
	pkgs.jetbrains-mono
  ];
}
