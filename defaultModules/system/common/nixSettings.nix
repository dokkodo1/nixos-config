{ pkgs, config, lib, ... }:

{
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };
}