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
			update-default = "sudo nixos-rebuild switch --flake /home/dokkodo/configurations/#default";
			update-gamestation = "sudo nixos-rebuild switch --flake /home/dokkodo/configurations/#gamestation";

			#Upgrade
			upgrade-default = "sudo nixos-rebuild switch --upgrade --flake /home/dokkodo/configurations/#default";
			upgrade-gamestation = "sudo nixos-rebuild switch --upgrade --flake /home/dokkodo/configurations/#gamestation";
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
