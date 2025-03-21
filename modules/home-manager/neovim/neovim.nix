{ config, pkgs, lib, inputs, ... }:

{
  programs.neovim = 
  let
    toLua = str: "lua << EOF\n${str}\nEOF\n";
    toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
  in
  {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    
    extraPackages = with pkgs; [
      lua-language-server
      rnix-lsp

      xclip
      wl-clipboard
    ];
    extraConfig = ''

    '';
    plugins = with pkgs.vimPlugins; [
      
      {
        plugin = nvim-lspconfig;
	config = toLuaFile ./neovim/plugins/lsp.lua
      }

      {
        plugin = telescope-nvim;
	config = toLuaFile ./neovim/plugins/telescope.lua
      }
      telescope-fzf-native-nvim

      {
        plugin = (nvim-treesitter.withPlugins (p: [
	  p.tree-sitter-nix
	  p.tree-sitter-vim
	  p.tree-sitter-bash
	  p.tree-sitter-lua
	  p.tree-sitter-python
	  p.tree-sitter-json
	]));
	config = toLuaFile ./neovim/plugins/treesitter.lua;
      }
      
      vim-nix

    ];

    extraLuaConfig = ''
      ${builtins.readFile ./neovim/options.lua}
    '';

  };
}
