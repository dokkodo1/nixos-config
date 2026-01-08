{ pkgs, darwinUsername, ... }:

{
  imports = [
    ../../modules/base/dotfiles
    ../../modules/base/sops.nix
    # ../../modules/options/tailscale.nix  # Temporarily disabled for testing
  ];

  # Temporary direct Tailscale config for Darwin
  services.tailscale.enable = true;
  environment.systemPackages = with pkgs; [ tailscale ];

  home-manager.users.${darwinUsername} = {
    home.username = darwinUsername;
    home.homeDirectory = "/Users/${darwinUsername}";
    home.stateVersion = "24.11";
  };
#	darwin.installApps = true;
#	darwin.fullCopies = true;
  users.users.${darwinUsername} = {
    home = "/Users/${darwinUsername}";
    shell = pkgs.zsh;
  };

  nix.settings.experimental-features = "nix-command flakes";

  environment.systemPackages = with pkgs; [
    tree
    git
		gh
    tmux
    btop
    rar
    nh 
    sshfs
    fuse
		iterm2
    doxpkgs.tmux-default
  ];

  system.stateVersion = 6;
}
