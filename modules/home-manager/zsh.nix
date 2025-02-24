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
		nixos = "cd /etc/nixos/";
		c = "clear";		


		#Update
		update-default = "sudo nixos-rebuild switch --flake /etc/nixos#default";
		update-gamestation = "sudo nixos-rebuild switch --flake /etc/nixos#gamestation";
	 	update-notebook = "sudo nixos-rebuild switch --flake /etc/nixos#notebook";
		update-raspberry = "sudo nixos-rebuild switch --flake /etc/nixos#raspberry";
		
		#Upgrade
		upgrade-default = "sudo nixos-rebuild switch --upgrade --flake /etc/nixos#default";
		upgrade-gamestation = "sudo nixos-rebuild switch --upgrade --flake /etc/nixos#gamestation";
	 	upgrade-notebook = "sudo nixos-rebuild switch --upgrade --flake /etc/nixos#notebook";
		upgrade-raspberry = "sudo nixos-rebuild switch --upgrade --flake /etc/nixos#raspberry";
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
