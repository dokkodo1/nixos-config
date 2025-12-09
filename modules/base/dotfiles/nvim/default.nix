{ pkgs, username, darwinUsername ? null, ... }:

let
  actualUsername = if pkgs.stdenv.isDarwin && darwinUsername != null
    then darwinUsername
    else username;
in
{
  environment.variables.EDITOR = "nvim"; # or nvim, vim, vscode, whatever;
  home-manager.users.${actualUsername} = {
    programs.neovim = {
      enable = true;
      extraLuaConfig = builtins.readFile ./init.lua;
    };
    
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
