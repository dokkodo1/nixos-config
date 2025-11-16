{ username, ... }:

{
  imports = [
    ../../modules/user
    ../../modules/user/programs/qutebrowser
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  
  home.stateVersion = "24.11";
}
