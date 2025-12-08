{ pkgs, ... }:
{
  users.users.root = {
    shell = pkgs.zsh;
  };

  home-manager.users.root = {
    home.username = "root";
    home.homeDirectory = "/root";
    home.stateVersion = "24.11";
    
    programs.neovim = {
      enable = true;
      extraLuaConfig = builtins.readFile ./dotfiles/nvim/init.lua;
    };
    
    programs.tmux = {
      enable = true;
      extraConfig = ''
        source-file ${./dotfiles/tmux/tmux.conf}
      '';
    };
    
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ll = "ls -lah";
        tm = "tmux-default";
      };
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
    
    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
