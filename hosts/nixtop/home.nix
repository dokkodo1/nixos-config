{ config, pkgs, ... }:

{
  imports = [
	  ./../../modules/user/terminal/git.nix
    ./../../modules/user/terminal/fastfetch.nix
    ./../../modules/user/userPrograms
  ];

  home.username = "dokkodo";
  home.homeDirectory = "/home/dokkodo";
  nixpkgs.config.allowUnfree = true;
  home.packages = [

  ];

  home.file = {
    ".vimrc".source = ./../../modules/user/vim/vimrc;
  };
  
  home.sessionVariables = {

  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
