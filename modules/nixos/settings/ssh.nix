{ lib, hostVars, allHostKeys, ... }:

let
  keys = import ../../../keys.nix;
  externalKeys = lib.mapAttrsToList (_: v: v.key) keys;
  authorizedKeys = externalKeys ++ allHostKeys;
in
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };

  users.users.${hostVars.username}.openssh.authorizedKeys.keys = authorizedKeys;

  networking.firewall.allowedTCPPorts = [ 22 ];
}
