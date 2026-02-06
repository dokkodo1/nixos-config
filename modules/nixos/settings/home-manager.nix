{ hostVars, ... }:

{
  home-manager.users.${hostVars.username} = {
    home.username = hostVars.username;
    home.homeDirectory = "/home/${hostVars.username}";
    home.stateVersion = "24.11";
    home.sessionVariables = {
      NH_FLAKE = "/home/${hostVars.username}/${hostVars.repoName}";
    };
  };
}
