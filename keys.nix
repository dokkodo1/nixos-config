{
  # SSH public keys for non-NixOS devices (phones, work laptops, etc.)
  #   android = {
  #     key = "ssh-ed25519 AAAA...";
  #     description = "My Android phone";
  #   };

  backup = {
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFAJ34eWlXMQZMj0xiHp8Ux6RcCZCo0YtHW9Vqi/0jUe backup@nix-config";
    description = "Distributed backup SSH key";
  };
}
