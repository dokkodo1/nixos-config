{ config, pkgs, lib, inputs, modPath, ... }:

{
  imports = [
  ];

  users.users.callummcdonald = {
    home = "/Users/callummcdonald";
  };

  nix.settings.experimental-features = "nix-command flakes";

  environment.systemPackages = with pkgs; [
    tree
    git
    tmux
    btop
    rar
    nh 
    sshfs
    fuse
  ];

  system.stateVersion = 6;
}