{ config, pkgs, userVars, ... }:

let
  actualUsername = if pkgs.stdenv.isDarwin && userVars.darwinUsername != null
    then userVars.darwinUsername
    else userVars.username;
  actualHome = if pkgs.stdenv.isDarwin
    then "/Users/${actualUsername}"
    else "/home/${actualUsername}";
in
{
  home-manager.users.${actualUsername} = {
    programs = {
      direnv.enable = true;
      direnv.nix-direnv.enable = true;

      # Enable zsh with minimal Nix configuration
      zsh = {
        enable = true;
        dotDir = "${actualHome}/.zsh";
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

        # Source the zshrc file from repo for hot-reloading
        initContent = ''
          source ${./zshrc}
        '';
      };

      # Starship prompt - minimal lean style
      starship = {
        enable = true;
        enableZshIntegration = true;
      };
    };

    # Explicit .zshenv at home root to bootstrap ZDOTDIR before zsh starts.
    # Without this, zsh can't find .zshrc inside .zsh/ and runs newuser-install.
    home.file.".zshenv".text = ''
      export ZDOTDIR="$HOME/.zsh"
    '';

    # Symlink starship config for hot-reloading
    xdg.configFile."starship.toml".source = ./starship.toml;

    # Symlink grc config for colorizing Nix store paths
    xdg.configFile."grc/nix.conf".source = ./grc-nix.conf;
  };
}
