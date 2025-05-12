{ config, pkgs, lib, inputs, ... }:


{
  imports = [

  ];

  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };

  nix.settings = {
    substituters = ["https://nix-citizen.cachix.org"];
    trusted-public-keys = ["nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="];
  };
  
  environment.systemPackages = with pkgs; [
	  discord
    lug-helper
    inputs.nix-citizen.packages."x86_64-linux".star-citizen
    protonup-qt
    dxvk
    lutris
    mangohud
    gamemode
    
    wineWowPackages.waylandFull   # wayland unstable
    wineWowPackages.staging       # experimental
    winetricks

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
