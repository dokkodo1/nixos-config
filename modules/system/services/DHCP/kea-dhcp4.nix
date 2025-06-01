{ config, pkgs, lib, ... }:

{
  services.kea.dhcp4 = {
	enable = true;

	settings = {
		interfaces-config = {
    		  interfaces = [
      		    "end0"
    		  ];
  		};
  	lease-database = {
    	  name = "/var/lib/kea/dhcp4.leases";
    	  persist = true;
    	  type = "memfile";
  	};
  	rebind-timer = 2000;
  	renew-timer = 1000;
  	subnet4 = [
    	  {
      	    id = 1;
      	    pools = [
              {
				pool = "172.16.10.1 - 172.16.10.255";
              } 
            ];
      	    subnet = "172.16.0.0/16";
    	  }
  	];
  	valid-lifetime = 4000;
  	};
   };
}
