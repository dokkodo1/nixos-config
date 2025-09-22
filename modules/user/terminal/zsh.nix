{ pkgs, ... }:

{
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 1000;

    shellAliases = {
      ll = "ls -l";
      c = "clear";
			gpull = "cd ~/configurations && git pull && cd ~/proj && git pull";
      nixos = if pkgs.stdenv.isDarwin 
        then "cd /Users/callummcdonald/configurations/"
        else "cd /home/dokkodo/configurations/";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
				"git"
				"man"
				"ssh"
				"rust"
				"podman"
			];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initContent = ''
      # Only source p10k config if it exists
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      eval "$(direnv hook zsh)"
    '';
  };
}
