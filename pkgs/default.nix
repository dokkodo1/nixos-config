{ pkgs }:
{
  tmux-default = pkgs.callPackage ./tmux-default { };
  tmux-powerkit = pkgs.callPackage ./tmux-powerkit { };
}