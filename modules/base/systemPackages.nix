{ pkgs, ... }:
{
	fonts.packages = with pkgs; [
		nerd-fonts.jetbrains-mono
	];

  environment.systemPackages = with pkgs; [
    tree
    cloc
    file
    gnumake
    busybox
		bat
    pciutils
		iw
    git
		gh
    bitwarden-cli
    w3m-nox
    tmux
    yazi
    fastfetch
		btop
    parted
		rar
    nh
		nixd 
		gcc
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
  };
}
