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

  services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
    "monitor.bluez.properties" = {
      	"bluez5.enable-sbc-xq" = true;
      	"bluez5.enable-msbc" = true;
      	"bluez5.enable-hw-volume" = true;
      	"bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
    };
  };

#  services.blueman.enable = true;

#  systemd.user.services.mpris-proxy = {
#    description = "Mpris proxy";
#    after = [ "network.target" "sound.target" ];
#    wantedBy = [ "default.target" ];
#    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
#  };

  
}
