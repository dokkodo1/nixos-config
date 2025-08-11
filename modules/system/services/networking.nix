{ config, pkgs, lib, ... }:

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
    # custom DNS server, apparently not the best solution
    #useDHCP = true;
    #dhcpcd.enable = true;
    #nameservers = [
      #"192.168.101.240"
      #"1.1.1.1"
      #"8.8.8.8"

    #];
  };

  # <<< SET UP WAP VIA ETHERNET >>>
  #services.create_ap = {
    #enable = true;
    #settings = {
      #INTERNET_IFACE = "eno2";
      #WIFI_IFACE = "wlan0";
      #SSID = "totally secure network trust me";
      #PASSPHRASE = "5450642c!";
    #};
  #};
  #             ^^^     ^^^

  # trying to troubleshoot some dns nonsense
  #networking.resolvconf.enable = false;
  #services.resolved.enable = false;


  # <<< SOME NETWORKING BOILERPLATE >>>
  #networking.networkmanager.enable = true;
  #networking.hostName = "mynix1"; # Define your hostname.
  #networking.networkmanager.ensureProfiles.profiles = { 
  #  ethPort = {
  #    connection = {
  #      id = "ethPort";
  #      uuid = "e0a61b63-5555-5555-5555-55555de1620c";
  #      type = "ethernet";
  #      autoconnect-priority = "-999";
  #      interface-name = "enp7s0";
  #      timestamp = "1714525092";
  #    };
  #    ethernet = {
  #    };
  #    ipv4 = {
  #      address1 = "192.168.2.51/16,192.168.1.1";
  #      dns = "1.1.1.1;192.168.1.1;";  #
  # 
  #             ^^^     ^^^


  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

#Static IP (Raspi) 
#  networking.interfaces = {
#  	end0.ipv4.addresses = [{
#    		address = "172.16.10.1";
#     		prefixLength = 16;
#    	}];
#  };
#  networking.defaultGateway = {
# 	address = "172.16.0.1";
# 	interface = "end0";
#  };
}
