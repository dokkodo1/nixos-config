{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.cudatoolkit ];
}
