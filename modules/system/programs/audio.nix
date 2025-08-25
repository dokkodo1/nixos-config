{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    reaper
    musescore
  ];

}
