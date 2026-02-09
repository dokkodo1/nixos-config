{ pkgs, hostVars, ... }:

{
  # sops-nix configuration for encrypted secrets
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    validateSopsFiles = false;  # Disable validation during build
    
    # Age key configuration - works on both platforms
    age = {
      keyFile = "/home/${hostVars.username}/.config/sops/age/keys.txt";
      generateKey = true;  # Generate key if it doesn't exist
    };
  };

  # Ensure sops package is available on both platforms
  environment.systemPackages = with pkgs; [ sops age ];
}
