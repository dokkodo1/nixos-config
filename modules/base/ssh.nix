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

  networking.firewall.allowedTCPPorts = [ 22 ];
}
