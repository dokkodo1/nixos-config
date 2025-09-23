{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
		plugins = [
		];
    extraLuaConfig = builtins.readFile ./init.lua;
  };
}
