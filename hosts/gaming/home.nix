{ username, ... }:

{
  imports = [
    ../../modules/user
    ../../modules/user/terminal/kitty.nix
    ../../modules/user/userPrograms
  ];
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";
}
