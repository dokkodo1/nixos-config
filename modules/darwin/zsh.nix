{ config, pkgs, lib, ... }:

{
  programs.zsh = {
		enable = true;
		enableCompletion = true;
		autosuggestion.enable = true;
		syntaxHighlighting.enable = true;
		history.size = 1000;

		shellAliases = {
			ls = "ls --auto-color";
			ll = "ls -l";
			c = "clear";		
		};
  };
}
