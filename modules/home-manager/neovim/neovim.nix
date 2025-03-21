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
      xclip
      wl-clipboard
    ];

    extraConfig = ''

    '';

    plugins = with pkgs.vimPlugins; [
      
      {
        plugin = nvim-lspconfig;
	config = toLuaFile ./plugins/lsp.lua;
      }

      {
        plugin = comment-nvim;
	config = toLua "require(\"Comment\").setup()";
      }

      {
        plugin = telescope-nvim;
	config = toLuaFile ./plugins/telescope.lua;
      }
      telescope-fzf-native-nvim

      
      {
        plugin = nvim-cmp;
	config = toLuaFile ./plugins/cmp.lua;
      }
      cmp_luasnip
      cmp-nvim-lsp
      luasnip
      friendly-snippets
      lualine-nvim
      vim-nix
      neodev-nvim

      {
        plugin = (nvim-treesitter.withPlugins (p: [
	  p.tree-sitter-nix
	  p.tree-sitter-vim
	  p.tree-sitter-bash
	  p.tree-sitter-lua
	  p.tree-sitter-python
	  p.tree-sitter-json
	]));
	config = toLuaFile ./plugins/treesitter.lua;
      }
      
      
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./options.lua}
    '';

  };
}
