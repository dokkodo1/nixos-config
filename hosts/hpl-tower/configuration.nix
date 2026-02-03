{ pkgs, ... }:

{
  imports = [
    # ./disko-simple.nix
    ./hardware-configuration.nix
  ];

  control.tailscale.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.enableAllFirmware = true;

  environment.systemPackages = with pkgs; [
    claude-code
  ];
  # SSH keys for dokkodo user  
  # users.users.dokkodo.openssh.authorizedKeys.keys = [
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSUHwWhaJPV4wHXrMnp4jxSkrNoZWIsbdUYQrCM3x6p callum.dokkodo@gmail.com"
  # ];
}
