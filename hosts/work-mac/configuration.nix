{ pkgs, darwinUsername, ... }:

{
  imports = [
  ];

#	darwin.installApps = true;
#	darwin.fullCopies = true;
  users.users.${darwinUsername} = {
    home = "/Users/${darwinUsername}";
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
