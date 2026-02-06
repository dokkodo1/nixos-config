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
    
    wireless.enable = true;  
    firewall = {
      enable = true;
      allowedTCPPorts = [
      ];
      allowedUDPPorts = [
      ];
    };
  };
}
