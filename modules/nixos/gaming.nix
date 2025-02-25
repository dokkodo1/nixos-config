{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
	  discord
    mangohud
    lug-helper
    inputs.nix-citizen.packages."x86_64-linux".star-citizen
    protonup-qt
    dxvk
    lutris
    wineWowPackages.waylandFull
    wineWowPackages.staging
    winetricks
    lact
    btop
  ];

  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamemode = {
      enable = true;
    };
    gamescope = {
      enable = true;
    };
  };
}
