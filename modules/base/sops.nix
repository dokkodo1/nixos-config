{ config, pkgs, lib, username ? null, darwinUsername ? null, ... }:

let
  # Use the appropriate username based on platform
  user = if pkgs.stdenv.isDarwin then darwinUsername else username;
  homeDir = if pkgs.stdenv.isDarwin then "/Users/${user}" else "/home/${user}";
in
{
  # sops-nix configuration for encrypted secrets
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    validateSopsFiles = false;  # Disable validation during build
    
    # Age key configuration - works on both platforms
    age = {
      keyFile = "${homeDir}/.config/sops/age/keys.txt";
      generateKey = true;  # Generate key if it doesn't exist
    };
  };

  # Ensure sops package is available on both platforms
  environment.systemPackages = with pkgs; [ sops ];
}