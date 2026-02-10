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
          # Check if flake.lock is currently protected (skip-worktree)
          _flake_is_locked() {
            cd "$NIX_CONFIG_DIR" 2>/dev/null || return 1
            # S = skip-worktree, H = normal
            [[ "$(git ls-files -v flake.lock 2>/dev/null | cut -c1)" == "S" ]]
          }

          flake-unlock() {
            cd "$NIX_CONFIG_DIR" || return 1
            if ! _flake_is_locked; then
              echo "flake.lock is already unlocked"
              return 0
            fi
            git update-index --no-skip-worktree flake.lock
            echo "flake.lock UNLOCKED - remember to run 'flake-lock' when done"
          }

          flake-lock() {
            cd "$NIX_CONFIG_DIR" || return 1
            if _flake_is_locked; then
              echo "flake.lock is already locked"
              return 0
            fi
            git update-index --skip-worktree flake.lock
            echo "flake.lock protected"
          }

          flake-status() {
            cd "$NIX_CONFIG_DIR" || return 1
            if _flake_is_locked; then
              echo "flake.lock is LOCKED (protected)"
            else
              echo "flake.lock is UNLOCKED"
            fi
          }

          # Full update workflow: unlock, update all inputs, commit, relock
          flake-update() {
            cd "$NIX_CONFIG_DIR" || return 1
            git update-index --no-skip-worktree flake.lock
            nix flake update
            git add flake.lock
            git commit -m "chore: update flake.lock"
            git update-index --skip-worktree flake.lock
            echo "Flake updated and committed. Re-locked."
          }

          # Update specific input(s): flake-update-input nixpkgs home-manager
          flake-update-input() {
            cd "$NIX_CONFIG_DIR" || return 1
            if [[ $# -eq 0 ]]; then
              echo "Usage: flake-update-input <input> [input2] ..."
              return 1
            fi
            git update-index --no-skip-worktree flake.lock
            for input in "$@"; do
              nix flake update "$input"
            done
            git add flake.lock
            git commit -m "chore: update flake inputs: $*"
            git update-index --skip-worktree flake.lock
            echo "Updated $* and re-locked."
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
