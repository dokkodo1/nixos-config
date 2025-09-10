{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
		plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
		];
    extraLuaConfig = builtins.readFile ./init.lua;
  };
}
