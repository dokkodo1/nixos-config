{ config, pkgs, lib, ... }:

{
  imports = [
	./kea-dhcp4.nix
	./kea-ctrl-agent.nix
	./kea-dhcp-ddns.nix
  ];
}
