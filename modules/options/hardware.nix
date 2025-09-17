{ pkgs, ... }:

{

  #Grapics card
  environment.systemPackages = [ pkgs.lact ];
  environment.variables.AMD_VULKAN_ICD = "RADV"; # forces RADV, defaults to amdvlk if provided in hardware.graphics.extraPackages
  systemd.packages = [ pkgs.lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];
  hardware.graphics = {
    # NixOS enables Vulkan through Mesa RADV by default
    # https://nixos.org/manual/nixos/unstable/index.html#sec-gpu-accel-vulkan

    # openGL / Mesa
    enable = true;
    enable32Bit = true;

    # AMDVLK  
    extraPackages = [ pkgs.amdvlk ];
    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };
   # Force radv

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
