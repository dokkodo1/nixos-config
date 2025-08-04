{ pkgs }:
{
  testScript = pkgs.callPackage ./testScript { };
  # Add more custom packages here
}