{ pkgs, darwinUsername ? null, ... }: {

  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    validateSopsFiles = false;  # Disable validation during build
    age = {
      keyFile = "/Users/${darwinUsername}/.config/sops/age/keys.txt";
      generateKey = true;  # Generate key if it doesn't exist
    };
  };
  environment.systemPackages = with pkgs; [ sops ];
}
