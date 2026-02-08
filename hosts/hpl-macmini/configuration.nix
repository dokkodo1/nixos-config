{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
		iterm2
  ];
}
