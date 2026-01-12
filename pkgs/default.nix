{ pkgs }:
{
  testScript = pkgs.callPackage ./testScript { };
  rpi-install = pkgs.callPackage ./rpi-install { };
  tmux-default = pkgs.callPackage ./tmux-default { };
  tmux-powerkit = pkgs.callPackage ./tmux-powerkit { };
  # Add more custom packages here
}