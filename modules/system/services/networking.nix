{
  networking = {
    networkmanager = {
      enable = true;
      wifi = {
        backend = "wpa_supplicant";  # Sometimes iwd causes issues
        powersave = false;
      };
      #dns = "none";
    };
    # Ensure WiFi isn't disabled
    wireless.enable = false;  # Make sure this conflicts with NetworkManager
    firewall = {
      enable = true;
      allowedTCPPorts = [

      ];
      allowedUDPPorts = [
    #    67 68 # << for WAP via eth
      ];
    };
  };
}
