{ pkgs, username, ... }:
{
  environment.variables.EDITOR = "nvim"; # or nvim, vim, vscode, whatever;
  home-manager.users.${username} = {
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
