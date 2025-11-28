{ username, ... }:

{
 home-manager.users.${username} = {
   home.username = username;
   home.homeDirectory = "/home/${username}";
   home.stateVersion = "24.11";
  };
}
