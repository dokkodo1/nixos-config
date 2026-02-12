{ pkgs }:
{
  tmux-default = pkgs.callPackage ./tmux-default { };
  tmux-powerkit = pkgs.callPackage ./tmux-powerkit { };
  teamspeak6-server = pkgs.callPackage ./teamspeak6-server { };
  audio-share = pkgs.callPackage ./audio-share { };
}