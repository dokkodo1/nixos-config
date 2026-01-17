{ pkgs, username, darwinUsername ? null, inputs, ... }:

let
  actualUsername = if pkgs.stdenv.isDarwin && darwinUsername != null
    then darwinUsername
    else username;
in
{
  home-manager.users.${actualUsername} = {
    programs.tmux = {
      enable = true;
      plugins = [{
        plugin = inputs.tmux-powerkit.packages.${pkgs.stdenv.hostPlatform.system}.default;
        extraConfig = ''
          set -g @powerkit_plugins "datetime,battery,cpu,memory,git,bitwarden"
          set -g @powerkit_theme "gruvbox"
          set -g @powerkit_theme_variant "dark"
        '';
      }];
      extraConfig = ''
        source-file ${./tmux.conf}
      '';
    };
    home.packages = with pkgs; [ doxpkgs.tmux-default ];
  };
}
