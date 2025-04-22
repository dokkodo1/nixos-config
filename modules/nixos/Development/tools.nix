{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [

    # terminal
    sshfs
    tmux
    tree

    # utils
    rpi-imager
    parted
    gparted
    ventoy-full
    syncthing
    appimage-run
    
  ];

}