{ pkgs, username, darwinUsername ? null, ... }:

let
  actualUsername = if pkgs.stdenv.isDarwin && darwinUsername != null
    then darwinUsername
    else username;
in
{
  home-manager.users.${actualUsername}.programs = {
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history.size = 1000;

      shellAliases = {
        wc3 = "wine Games/wc3/drive_c/Program Files/Warcraft 3/Warcraft III.exe";
        ll = "ls -lah";
        nixos = if pkgs.stdenv.isDarwin
          then "cd /Users/${darwinUsername}/configurations/"
          else "cd /home/${username}/configurations/";
        tm = "tmux-default";
        screenshot = ''grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png'';
        screenshot-clip = ''grim -g "$(slurp)" - | wl-copy'';
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
        claude_session() {
            echo "=== Session Context ==="
            cat ~/session_context.md 2>/dev/null || echo "No session context file found at ~/session_context.md"
            echo "========================"
            echo
            claude "$@"  # This launches Claude with any arguments you pass
        }
        alias claude-with-context="claude_session"
        # Only source p10k config if it exists
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
        eval "$(direnv hook zsh)"

        launch() {
            "$@" &disown
            exit
        }

        reload_zsh() {
        local repo_zshrc=$HOME/configurations/modules/base/dotfiles/zshrc
        if [[ -f "$repo_zshrc" ]]; then
            source "$repo_zshrc"
            echo "zshrc loaded from repo!"
        else
            echo "Error: zshrc not found at $repo_zshrc"
        fi
        }
        alias zreload="reload_zsh"
      '';
    };
  };
}
