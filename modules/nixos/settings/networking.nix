{ userVars, ... }:

{
  networking = {
    hostName = "${userVars.hostname}";
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
