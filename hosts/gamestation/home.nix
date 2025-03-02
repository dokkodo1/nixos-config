{ config, pkgs, inputs, ... }:

{
  imports = [
	./../../modules/home-manager/git.nix                  
	./../../modules/home-manager/Hyprland/hyprland.nix    
	./../../modules/home-manager/Hyprland/hyprpaper.nix   
	./../../modules/home-manager/Hyprland/hyprlock.nix    
	./../../modules/home-manager/Terminals/kitty.nix      

	./../../modules/home-manager/Wofi/wofi.nix						
	./../../modules/home-manager/Waybar/waybar.nix				
	./../../modules/home-manager/zsh.nix									
	./../../modules/home-manager/fastfetch.nix						
	
	./../../modules/home-manager/Themes/theme.nix					
	./../../modules/home-manager/wlogout/wlogout.nix			
#	./../../modules/home-manager/firefox.nix							
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
