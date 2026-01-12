{ lib, ... }:

{
  imports = [
    ./disko-simple.nix
  ];

  control.tailscale.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.enableAllFirmware = true;

  # SSH keys for dokkodo user  
  users.users.dokkodo.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSUHwWhaJPV4wHXrMnp4jxSkrNoZWIsbdUYQrCM3x6p callum.dokkodo@gmail.com"
  ];

  # Set a temporary password for dokkodo user (password: "nixos")
  users.users.dokkodo.initialPassword = "nixos";
  
  # Allow both password and key auth for initial setup
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";  # temporarily allow root
}
