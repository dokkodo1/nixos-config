{ config, pkgs, lib, ... }:

{
  programs.zsh = {
		enable = true;
		enableCompletion = true;
		autosuggestion.enable = true;
		syntaxHighlighting.enable = true;
		history.size = 1000;

		shellAliases = {
			ll = "ls -l";
			nixos = "cd /home/dokkodo/configurations/";
			c = "clear";		


			#Update
			update-kde = "sudo nixos-rebuild switch --flake /home/dokkodo/configurations/#kde";
			update-hyprland = "sudo nixos-rebuild switch --flake /home/dokkodo/configurations/#hyprland";

			#Upgrade
			upgrade-kde = "sudo nixos-rebuild switch --upgrade --flake /home/dokkodo/configurations/#kde";
			upgrade-hyprland = "sudo nixos-rebuild switch --upgrade --flake /home/dokkodo/configurations/#hyprland";
		};

		oh-my-zsh = {
			enable = true;
			plugins = ["git"];
		};
  };

  programs.zsh.plugins = [

	{name = "powerlevel10k";src = pkgs.zsh-powerlevel10k;file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";}

  ];

  programs.zsh.initExtra = ''

	source ~/.p10k.zsh

	''; 
  
}
