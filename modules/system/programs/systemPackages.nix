{ pkgs, ... }:
{
  programs = {
    vim = {
      enable = true;
    };
  };
	
	fonts.packages = with pkgs; [
		nerd-fonts.jetbrains-mono
	];

#	console = {
#	  earlySetup = true;
#    font = "ter-v22n";
#    colors = [
#      "414868" "f7768e" "73daca" "e0af69" 
#      "7aa2f7" "bb9af7" "7dcfff" "c0caf5"
#      "414868" "f7768e" "73daca" "e0af69"
#      "7aa2f7" "bb9af7" "7dcfff" "c0caf5"
#    ];
#  };

  environment.systemPackages = with pkgs; [
    tree
		bat
    pciutils
		iw
    git
		gh
    bitwarden-cli
    w3m-nox
    tmux
		btop
    parted
		rar
    home-manager # <<< remove if using home-manager as module
    nh
		nixd 
		gcc
  ];
}
