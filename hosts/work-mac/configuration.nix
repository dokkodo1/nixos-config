{ config, pkgs, lib, inputs, ... }:

{
  users.users.callummcdonald = {
    home = "/Users/callummcdonald";
  };

  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  services.nix-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;
}