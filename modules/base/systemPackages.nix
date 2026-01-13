{ pkgs, lib, ... }:
{
	fonts.packages = with pkgs; [
		nerd-fonts.jetbrains-mono
		dejavu_fonts  # Add DejaVu fonts for qutebrowser
	];

  environment.systemPackages = with pkgs; [
    tree
    cloc
    file
    gnumake
		bat
    pciutils
    git
		gh
    w3m-nox
    tmux
    yazi
    fastfetch
		btop
		rar
    nh
		nixd 
		gcc
  ] ++ lib.optionals pkgs.stdenv.isLinux [
      busybox
      iw
      parted
      bitwarden-cli
    ];
}
