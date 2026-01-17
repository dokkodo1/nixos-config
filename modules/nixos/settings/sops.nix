{ pkgs, username ? null,  ... }: {

  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    validateSopsFiles = false;  # Disable validation during build
    age = {
      keyFile = "/home/${username}/.config/sops/age/keys.txt";
      generateKey = true;  # Generate key if it doesn't exist
    };
  };
  environment.systemPackages = with pkgs; [ sops ];
}
