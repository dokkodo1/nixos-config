{ pkgs, ... }:

{
  imports = [
  ];

	darwin.installApps = true;
	darwin.fullCopies = true;
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
		iterm2
  ];

  system.stateVersion = 6;
}
