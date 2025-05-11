{ config, pkgs, lib, ... }:

{
  services.kea.dhcp-ddns = {
	enable = true;

	settings = {
		dns-server-timeout = 100;
  		forward-ddns = {
    		  ddns-domains = [ ];
  		};
  		ip-address = "127.0.0.1";
  		ncr-format = "JSON";
  		ncr-protocol = "UDP";
  		port = 53001;
  		reverse-ddns = {
    		  ddns-domains = [ ];
  		};
  		tsig-keys = [ ];

	};
   };
}
