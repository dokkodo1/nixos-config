{ pkgs, inputs, ... }:

{

  environment.systemPackages = with pkgs; [
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
