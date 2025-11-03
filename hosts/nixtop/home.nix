{ username, ... }:

{
  imports = [
    ../../modules/user
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  
  home.stateVersion = "24.11";
}
