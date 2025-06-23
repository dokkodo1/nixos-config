{ config, pkgs, lib, ... }:

{

  environment.systemPackages = with pkgs; [
    reaper
    musescore
  ];

}