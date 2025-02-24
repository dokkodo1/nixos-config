{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
  	nmap
	netcat-gnu
	metasploit
	exploitdb
  ];
}
