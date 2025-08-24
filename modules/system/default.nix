{
  imports = [
    ./programs/systemPackages.nix
#    ./programs/qbt.nix
    ./programs/minimalX.nix
    ./settings/users.nix
    ./settings/nixSettings.nix
    ./services/networking.nix
    ./services/ssh.nix
    ./services/sound.nix
    ./services/bluetooth.nix
  ];
}
