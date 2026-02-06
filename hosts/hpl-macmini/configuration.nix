{ pkgs, hostVars, ... }:

{

  home-manager.users.${hostVars.username} = {
    home.username = hostVars.username;
    home.homeDirectory = "/Users/${hostVars.username}";
    home.stateVersion = "24.11";
  };

  users.users.${hostVars.username} = {
    home = "/Users/${hostVars.username}";
    shell = pkgs.zsh;
  };

  nix.settings.experimental-features = "nix-command flakes";

  environment.systemPackages = with pkgs; [
		iterm2
  ];

  system.stateVersion = 6;
}
