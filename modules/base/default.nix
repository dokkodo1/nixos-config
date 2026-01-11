{ pkgs, lib, ... }:

{
  imports = [ ./dotfiles ]
   ++ lib.optional pkgs.stdenv.isLinux ./nixos
   ++ lib.optional pkgs.stdenv.isDarwin ./darwin;
}
