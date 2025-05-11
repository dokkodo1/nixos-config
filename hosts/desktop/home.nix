{ config, pkgs, ... }:

{
  imports = [
	./../../modules/home-manager/git.nix
	./../../modules/home-manager/zsh.nix
	./../../modules/home-manager/terminals/kitty.nix
  ./../../modules/home-manager/fastfetch.nix
  ];

  home.username = "dokkodo";
  home.homeDirectory = "/home/dokkodo";
  nixpkgs.config.allowUnfree = true;
  home.packages = [

  ];

  home.file = {
    ".vimrc".source = ./../../modules/home-manager/vim/vimrc;
  };
  
  home.sessionVariables = {

  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
