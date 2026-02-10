{ pkgs, hostVars, ... }:

let
  homeDir = if pkgs.stdenv.isDarwin
    then "/Users/${hostVars.username}"
    else "/home/${hostVars.username}";
  configDir = "${homeDir}/${hostVars.repoName}";
in
{
  home-manager.users.${hostVars.username} = {
    home.sessionVariables = {
      NIX_CONFIG_DIR = configDir;
    };

    programs = {
      direnv.enable = true;
      direnv.nix-direnv.enable = true;

      zsh = {
        enable = true;
        dotDir = "${homeDir}/.zsh";
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

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

        shellAliases = {
          nixos = "cd ${configDir}";
        };

        initContent = ''
          flake-update() {
            cd "$NIX_CONFIG_DIR" || return 1
            git update-index --no-skip-worktree flake.lock
            nix flake update
            git add flake.lock
            git commit -m "chore: update flake.lock"
            git update-index --skip-worktree flake.lock
            echo "Flake updated and committed. skip-worktree re-enabled."
          }

          flake-protect() {
            cd "$NIX_CONFIG_DIR" || return 1
            git update-index --skip-worktree flake.lock
            echo "flake.lock protected from git pull changes."
          }

          source ${./zshrc}
        '';
      };

      starship = {
        enable = true;
        enableZshIntegration = true;
      };
    };

    xdg.configFile."starship.toml".source = ./starship.toml;
    xdg.configFile."grc/nix.conf".source = ./grc-nix.conf;
  };
}
