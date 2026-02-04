{ pkgs, userVars, ... }:

{

  home-manager.users.${userVars.darwinUsername} = {
    home.username = userVars.darwinUsername;
    home.homeDirectory = "/Users/${userVars.darwinUsername}";
    home.stateVersion = "24.11";
  };

  users.users.${userVars.darwinUsername} = {
    home = "/Users/${userVars.darwinUsername}";
    shell = pkgs.zsh;
  };

  nix.settings.experimental-features = "nix-command flakes";

  environment.systemPackages = with pkgs; [
		iterm2
  ];

  system.stateVersion = 6;
}
