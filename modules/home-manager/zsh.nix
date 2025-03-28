{ config, pkgs, lib, ... }:

{
  programs.zsh = {
		enable = true;
		enableCompletion = true;
		autosuggestion.enable = true;
		syntaxHighlighting.enable = true;
		history.size = 1000;

		shellAliases = {
			ll = "ls -lah";
			nixos = "cd /home/evan/configurations/";
			c = "clear";		


			#Update
			update-kde = "sudo nixos-rebuild switch --flake /home/evan/configurations/#kde";

			#Upgrade
      upgrade-kde = "nix flake update /home/evan/configurations/ && sudo nixos-rebuild switch --flake /home/evan/configurations/#kde && sudo nix-collect-garbage -d";

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
