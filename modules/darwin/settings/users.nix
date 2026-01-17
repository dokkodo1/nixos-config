{ pkgs, darwinUsername, ... }: {

  users.users.${darwinUsername} = {
    home = "/Users/${darwinUsername}";
    shell = pkgs.zsh;
  };
}
