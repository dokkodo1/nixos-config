{ pkgs, lib, config, inputs, ... }:


{
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };
  nix.settings = {
    substituters = [
		  "https://nix-citizen.cachix.org"
    ];
    trusted-public-keys = [
		  "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
    ];
  };
  
  environment.systemPackages = with pkgs; [
	  discord
    lug-helper
    inputs.nix-citizen.packages."x86_64-linux".star-citizen
    lutris
    heroic-unwrapped
    mangohud
    openrgb-with-all-plugins
    gamemode
    dxvk
    protonup-qt
    wineWowPackages.waylandFull   # wayland unstable
    wineWowPackages.staging       # experimental
    winetricks
  ];

  programs = {
    steam.enable = true;
    steam.gamescopeSession.enable = true;
    gamemode.enable = true;
    gamescope.enable = true;
		appimage.enable = true;
		appimage.binfmt = true;
		appimage.package = pkgs.appimage-run.override { extraPkgs = pkgs: [ ]; };
  };
}
