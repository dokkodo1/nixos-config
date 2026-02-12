{
  # SSH public keys for non-NixOS devices (phones, work laptops, etc.)
  # These are added to authorized_keys on all hosts
  #
  # Example:
  #   iphone = {
  #     key = "ssh-ed25519 AAAA...";
  #     description = "iPhone SE";
  #   };

  backup = {
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFAJ34eWlXMQZMj0xiHp8Ux6RcCZCo0YtHW9Vqi/0jUe backup@nix-config";
    description = "Distributed backup SSH key";
  };
}
