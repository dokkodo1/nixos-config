{ darwinUsername, ... }: {

  home-manager.users.${darwinUsername} = {
    home.username = darwinUsername;
    home.homeDirectory = "/Users/${darwinUsername}";
    home.stateVersion = "24.11";
  };
}
