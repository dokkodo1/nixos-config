{ pkgs, lib, config, ... }:
{
  programs.neovim = {
    enable = true;
    extraLuaConfig = builtins.readFile ./init.lua;
  };
}