{ pkgs, inputs, ... }:
{
  programs = {
    vim = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    tree
    gparted
    tmux
    btop
    nh
    home-manager # <<< remove if using home-manager as module
  ];
}