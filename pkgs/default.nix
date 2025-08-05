{ pkgs }:
{
  testScript = pkgs.callPackage ./testScript { };
  rpi-install = pkgs.callPackage ./rpi-install { };
  # Add more custom packages here
}