{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
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
