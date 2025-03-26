{ config, pkgs, lib, inputs, ... }:

{
  users.users.callummcdonald = {
    home = "/Users/callummcdonald";
  };

  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs = {
    hostPlatform = "x86_64-darwin";
    config.allowUnfree = true;
    config.allowUnsupportedSystem = true;
  };

  programs.zsh.enable = tue;

  environment.systemPackages = with pkgs; [
    vim
    tree
    git
  ];

}