{ pkgs, ... }:

{
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
}
