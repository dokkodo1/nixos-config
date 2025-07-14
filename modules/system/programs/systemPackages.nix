{ pkgs, inputs, ... }:
{
  programs = {
    vim = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    tree
    git
    bitwarden-cli
    w3m-nox
    tmux
    btop
    parted
    rar
    nh
    home-manager # <<< remove if using home-manager as module
  ];
}
