{ config, pkgs, ... }:

{
  imports = [
	./../../modules/user/terminal/git.nix
	./../../modules/user/terminal/zsh.nix
	./../../modules/user/terminal/kitty.nix
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

  xdg.enable = true;
  xdg.userDirs = {
    extraConfig = {
      XDG_GAME_DIR = "${config.home.homeDirectory}/Media/Games";
      XDG_GAME_SAVE_DIR = "${config.home.homeDirectory}/Media/Game Saves";
    };
  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
