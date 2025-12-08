{ pkgs }:
{
  testScript = pkgs.callPackage ./testScript { };
  rpi-install = pkgs.callPackage ./rpi-install { };
  tmux-default = pkgs.callPackage ./tmux-default { };
  # Add more custom packages here
}