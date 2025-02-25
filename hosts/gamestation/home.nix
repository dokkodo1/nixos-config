{ config, pkgs, inputs, ... }:

{
  imports = [
	./../../modules/home-manager/git.nix                  # done
	./../../modules/home-manager/Hyprland/hyprland.nix    # done
	./../../modules/home-manager/Hyprland/hyprpaper.nix   # done
	./../../modules/home-manager/Hyprland/hyprlock.nix    # done
	./../../modules/home-manager/Terminals/kitty.nix      # done

	./../../modules/home-manager/Wofi/wofi.nix						# done
	./../../modules/home-manager/Waybar/waybar.nix				# done
	./../../modules/home-manager/zsh.nix									# done
	./../../modules/home-manager/fastfetch.nix						# done
	
	./../../modules/home-manager/Themes/theme.nix					# done
	./../../modules/home-manager/wlogout/wlogout.nix			# done
	./../../modules/home-manager/firefox.nix							# who knows
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
