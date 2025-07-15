{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    sshfs
    rpi-imager
    #ventoy-full
    syncthing
    appimage-run
    
  ];

    # ventoy bandaid
  #nixpkgs.config.permittedInsecurePackages = [
  #  "ventoy-1.1.05"
  #];
}