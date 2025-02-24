{ config, pkgs, lib, inputs, ... }:

{ 
  programs.firefox = {
     	enable = true;

	policies = {
  		BlockAboutConfig = true;
		DefaultDownloadDirectory = "\${home}/Downloads";
	};

	profiles.standard = {
		isDefault = true;

	#	extensions =  with inputs.firefox-addons.${pkgs.system};[
	#		ublock-origin
	#		bitwarden
	#	];

		bookmarks = [
	  	{
		  name = "Nix-Packages";
		  tags = [ "NixOS" ];
		  url = "https://search.nixos.org/packages";
	  	}
	  	{
		  name = "MyNixOS";
		  tags = [ "NixOS" ];
		  url = "https://mynixos.com/";
	  	}
	  	{
		  name = "Home-Manager-Manual";
		  tags = [ "NixOS" ];
		  url = "https://nix-community.github.io/home-manager/index.xhtml";
	  	}
	  	{
		  name = "Home-Manager-Options";
		  tags = [ "NixOS" ];
		  url = "https://home-manager-options.extranix.com/";
	  	}
	  	{
		  name = "Matrix";
		  tags = [ "Matrix" ];
		  url = "https://matrix.org/docs/matrix-concepts/elements-of-matrix/#homeserver";
	  	}
	  #	{
	#	  name = "";
	#	  typeCode = 3;
	#	  type = "text/x-moz-place-separator";
	 # 	}
	  	{
		  name = "Gitlab";
		  tags = [ "Git" ];
		  url = "https://gitlab.com/";
	  	}
	  	{
		  name = "GitHub";
		  tags = [ "Git" ];
		  url = "https://github.com/FluxedOverload";
	  	}
	  #	{
	#	  name = "";
	#	  typeCode = 3;
	#	  type = "text/x-moz-place-separator";
	 # 	}
	  	{
		  name = "FritzBox";
		  tags = [ "Home-Network" ];
		  url = "http://192.168.10.10/";
	  	}
	  	{
		  name = "Firewall";
		  tags = [ "Home-Network" ];
		  url = "https://172.16.0.1/";
	  	}
	  	{
		  name = "Proxmox";
		  tags = [ "Home-Network" ];
		  url = "https://172.16.0.10:8006/#v1:0:18:4:::::::";
	   	}
	  #	{
	#	  name = "";
	#	  typeCode = 3;
	#	  type = "text/x-moz-place-separator";
	 # 	}
	  	{
		  name = "Reddit";
		  tags = [ "Social" ];
		  url = "https://www.reddit.com/";
	  	}
	  	{
		  name = "Youtube";
		  tags = [ "Social" ];
		  url = "https://www.youtube.com/";
	  	}
		
	];

	search = {
		force = true;
		default = "DuckDuckGo";
		order = [ "DuckDuckGo" "Google" ];
	};	
     };
  };
}
