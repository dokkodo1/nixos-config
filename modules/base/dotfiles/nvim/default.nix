{ pkgs, username, darwinUsername ? null, ... }:

let
  actualUsername = if pkgs.stdenv.isDarwin && darwinUsername != null
    then darwinUsername
    else username;
in
{
  environment.variables.EDITOR = "nvim";
  home-manager.users.${actualUsername} = {
    programs.neovim = {
      enable = true;
    };
    
    # Symlink entire nvim config to repo for hot reloading
    xdg.configFile."nvim/init.lua".source = ./init.lua;
    xdg.configFile."nvim/lua/settings.lua".source = ./lua/settings.lua;
    xdg.configFile."nvim/lua/keymaps.lua".source = ./lua/keymaps.lua;
    xdg.configFile."nvim/lua/plugins.lua".source = ./lua/plugins.lua;
    
    home.packages = with pkgs; [
      lua-language-server
      rust-analyzer
      llvm
      clang-tools
      nixd
      basedpyright
      git
      nodejs
      tree-sitter  
      ripgrep
      btop
      fastfetch
      doxpkgs.tmux-default
    ];
  };
}
