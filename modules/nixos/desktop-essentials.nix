{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
  	firefox
		bitwarden-desktop
		telegram-desktop
		whatsapp-for-linux
		qbittorrent
		vlc
		zoom-us
		brave
		vscode
  ]; 
}
