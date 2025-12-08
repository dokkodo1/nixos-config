{ hostname, ... }:

{
  networking = {
    hostName = "${hostname}";
    networkmanager = {
      enable = true;
      wifi = {
        backend = "wpa_supplicant";  
        powersave = false;
      };
    };
    
    wireless.enable = false;  
    firewall = {
      enable = true;
      allowedTCPPorts = [
      ];
      allowedUDPPorts = [
      ];
    };
  };
}
