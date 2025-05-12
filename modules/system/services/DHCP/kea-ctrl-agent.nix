{ config, pkgs, lib, ... }:

{
  services.kea.ctrl-agent = {
	enable = true;
	
	settings = {
		
    		"Control-agent" = {
        		"http-host" = "172.16.0.22";
        		"http-port" = 8000;
        		#"trust-anchor": "/path/to/the/ca-cert.pem",
        		#"cert-file": "/path/to/the/agent-cert.pem",
        		#"key-file": "/path/to/the/agent-key.pem",
        		#"cert-required": true,
        		"authentication" = {
           	 		"type" = "basic";
            			"realm" = "kea-control-agent";
            			"clients" = [
            			{
                			"user" = "admin";
                			"password" = "1234";
            			} ];
        		};

        		#"control-sockets" = {
            		#"dhcp4" = {
                	#	"comment" = "main server";
                	#	"socket-type" = "unix";
                	#	"socket-name" = "/path/to/the/unix/socket-v4";
            		#};
            		#"d2" = {
                	#	"socket-type" = "unix";
                	#	"socket-name" = "/path/to/the/unix/socket-d2";
            		#};
        		#};
			#
        		#"hooks-libraries" = [
       			#{
            		#	"library" = "/opt/local/control-agent-commands.so";
           		#	"parameters" = {
                	#	"param1" = "foo";
            		#	};
        		#} ];

        		"loggers" = [ {
            			"name" = "kea-ctrl-agent";
            			"severity" = "INFO";
        		} ];
    		};

	};
  };
}
