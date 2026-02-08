{ hostVars, ... }:

{
  home-manager.users.${hostVars.username} = {
    home.username = hostVars.username;
    home.homeDirectory = "/Users/${hostVars.username}";
    home.stateVersion = "24.11";
  };
}
