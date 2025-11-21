{
  imports = [
    ./options
    ./programs/systemPackages.nix
    ./settings/users.nix
    ./settings/keyboardLayout.nix
    ./settings/nixSettings.nix
    ./services/networking.nix
    ./services/ssh.nix
    ./services/sound.nix
    ./services/bluetooth.nix
  ];
}
