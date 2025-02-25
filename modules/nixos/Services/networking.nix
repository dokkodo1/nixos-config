{ config, pkgs, lib, ... }:

{
  networking = {

    hostName = "Nix-Station";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [

      ];
      allowedUDPPorts = [

      ];      
    };
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.dhcpcd.enable = true;

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
