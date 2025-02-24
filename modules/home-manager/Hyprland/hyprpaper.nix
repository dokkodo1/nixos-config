{ config, pkgs, lib, ... }:

{ 
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = ["/home/dokkodo/configurations/files/wallpaper/SpaceFog-Pink.png"];
      wallpaper = ["/home/dokkodo/configurations/files/wallpaper/SpaceFog-Pink.png"];
    };
  };
}
