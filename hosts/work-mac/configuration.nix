{ config, pkgs, lib, inputs, ... }:

{
  users.users.callummcdonald = {
    home = "/Users/callummcdonald";
  };

  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs = {
    hostPlatform = "x86_64-darwin";
    config.allowUnfree = true;
    config.allowUnsupportedSystem = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    tree
    git
    sshfs
    fuse
  ];

  system.stateVersion = 6;
}