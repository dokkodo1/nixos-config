{ userVars, ... }:

{
  home-manager.users.${userVars.username} = {
    home.username = userVars.username;
    home.homeDirectory = "/home/${userVars.username}";
    home.stateVersion = "24.11";
    home.sessionVariables = {
      NH_FLAKE = "/home/${userVars.username}/${userVars.repoName}";
    };
  };
}
