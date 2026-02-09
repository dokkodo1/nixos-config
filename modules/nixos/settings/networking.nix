{ hostVars, ... }:

{
  networking = {
    hostName = "${hostVars.hostname}";
    networkmanager = {
      enable = true;
      wifi = {
        backend = "wpa_supplicant";  
        powersave = false;
      };
    };
    
    firewall = {
      enable = true;
      allowedTCPPorts = [
      ];
      allowedUDPPorts = [
      ];
    };
  };
}
