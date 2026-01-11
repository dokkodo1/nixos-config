{ username, repoName, ... }:

{
  home-manager.users.${username} = {
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "24.11";
    home.sessionVariables = {
      NH_FLAKE = "/home/${username}/${repoName}";
    };
  };
}
