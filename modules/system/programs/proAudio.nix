{ pkgs, inputs, ... }:

{

  security.rtkit.enable = true;
  services.pipewire = {
  	enable = true;
  	alsa.enable = true;
  	alsa.support32Bit = true;
  	pulse.enable = true;
  	jack.enable = true;
  };

  users.users.dokkodo.extraGroups = [ "audio" ];
  musnix = {
	# https://github.com/musnix/musnix
    enable = true;
 	  kernel.realtime = true;
 	  kernel.packages = pkgs.linuxPackages_latest_rt;
 	  soundcardPciId = ""; # not applicable to USB sound cards. Example "00:1b.0" found with lspci | grep -i audio
 	  ffado.enable = false; # use free FireWare audio drivers
 	  rtcqs.enable = true; # https://wiki.linuxaudio.org/wiki/system_configuration#rtcqs 
		das_watchdog.enable = false; # https://github.com/kmatheussen/das_watchdog
  };
  environment.systemPackages = with pkgs; [
    pkgs.pavucontrol
	  inputs.native-access-nix.packages.x86_64-linux.native-access
	  wineWowPackages.yabridge
		yabridge
		yabridgectl
	  qpwgraph
	  qjackctl
    reaper
    reaper-sws-extension
    reaper-reapack-extension
		ardour
    musescore
  ];

	services.udisks2.enable = true;
  # https://wiki.nixos.org/wiki/PipeWire#AirPlay/RAOP_configuration
  services.avahi.enable = true;
  services.pipewire = {
    # opens UDP ports 6001-6002
    raopOpenFirewall = true;
    extraConfig.pipewire."10-airplay"."context.modules" = [
		  {
        name = "libpipewire-module-raop-discover";
        # increase the buffer size if you get dropouts/glitches
        # args = {
        #   "raop.latency.ms" = 500;
        # };
      }
		];
  };
}
