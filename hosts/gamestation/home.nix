{ config, pkgs, inputs, ... }:

{
  imports = [
	./../../modules/home-manager/git.nix                  # done
	./../../modules/home-manager/Hyprland/hyprland.nix    # done
	./../../modules/home-manager/Hyprland/hyprpaper.nix   # done
	./../../modules/home-manager/Hyprland/hyprlock.nix    # done
	./../../modules/home-manager/Terminals/kitty.nix      # done
	./../../modules/home-manager/desktop-essentials.nix
	./../../modules/home-manager/Wofi/wofi.nix
	./../../modules/home-manager/Waybar/waybar.nix
	./../../modules/home-manager/zsh.nix
	./../../modules/home-manager/fastfetch.nix
	./../../modules/home-manager/gaming.nix
	./../../modules/home-manager/Themes/theme.nix
	./../../modules/home-manager/wlogout/wlogout.nix
	#./../../modules/home-manager/firefox.nix
  ];

  home.username = "dokkodo";
  home.homeDirectory = "/home/dokkodo";
  nixpkgs.config.allowUnfree = true; 
  home.packages = [

  ];

  home.file = {

  };
  
  home.sessionVariables = {

  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
