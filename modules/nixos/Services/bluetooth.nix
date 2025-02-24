{ config, pkgs, lib, ... }:

{
  hardware.bluetooth = {
	enable = true;
	powerOnBoot = true;

	settings = {
	  General = {
		Experimental = true;
		Enable = "Source,Sink,Media,Socket";
	  };
	};
  };

  services.blueman.enable = true;

  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [ "network.target" "sound.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  
}
