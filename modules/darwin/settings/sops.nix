{ pkgs, hostVars, ... }:

{
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    validateSopsFiles = false;
    
    age = {
      keyFile = "/Users/${hostVars.username}/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };

  environment.systemPackages = with pkgs; [ sops ];
}
