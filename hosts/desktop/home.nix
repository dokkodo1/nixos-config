{ config, pkgs, ... }:

{
  imports = [
	./../../modules/home-manager/terminal/git.nix
	./../../modules/home-manager/terminal/zsh.nix
	./../../modules/home-manager/terminal/kitty.nix
  ./../../modules/home-manager/terminal/fastfetch.nix
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
