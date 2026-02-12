{ pkgs, hostVars, ... }:

{
  environment.variables.EDITOR = "nvim";
  home-manager.users.${hostVars.username} = {
    programs.neovim = {
      enable = true;
    };

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
      glow
    ];
  };
}
