{ pkgs, darwinUsername, ... }:

{
  imports = [
    ../../modules/base/dotfiles
  ];

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
