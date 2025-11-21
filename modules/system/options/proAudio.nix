{ lib, config, pkgs, inputs, ... }:

with lib;
let
  cfg = config.control.proAudio;
in {
  options.control.proAudio = {
    enable = mkEnableOption "Downloads and configures relevant packages for low latency audio recording with REAPER, Wine, and yabridge";
    reaper.enable = mkEnableOption "Enables REAPER with sws-extensions and reapack package manager";
    ardour.enable = mkEnableOption "Enables Ardour, the open-source DAW";
    nativeAccess.enable = mkEnableOption "Native-Access is hella glitchy, but this is how you may do it";
    musescore.enable = mkEnableOption "Enables Musescore music notation software";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
	    wineWowPackages.yabridge
	  	yabridge
	  	yabridgectl
	    qpwgraph
	    qjackctl
    ]
    ++ optionals cfg.reaper.enable [ reaper reaper-sws-extension reaper-reapack-extension ]
    ++ optional cfg.ardour.enable ardour
    ++ optional cfg.nativeAccess.enable inputs.native-access-nix.packages.x86_64.native-access
    ++ optional cfg.musescore.enable musescore;

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
  };
}
