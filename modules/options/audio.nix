{ lib, config, pkgs, inputs, ... }:

with lib;
let
  cfg = config.control.audio;
in {
  options.control.audio = {
    enable = mkEnableOption "Enable pipewire with pulse and jack support and sets 48khz/1024 buffer" // { default = true; };
    pavucontrol.enable = mkEnableOption "Enables pavucontrol, a GTK based GUI for controlling audio IO, requires display server";
    proAudio = {
      enable = mkEnableOption "Downloads and configures relevant packages for low latency audio recording with REAPER, Wine, and yabridge";
      reaper.enable = mkEnableOption "Enables REAPER with sws-extensions and reapack package manager";
      ardour.enable = mkEnableOption "Enables Ardour, the open-source DAW";
      nativeAccess.enable = mkEnableOption "Native-Access is hella glitchy, but this is how you may do it";
      musescore.enable = mkEnableOption "Enables Musescore music notation software";
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      security.rtkit.enable = lib.mkDefault true;
      services.pipewire = {
      	enable = lib.mkDefault true;
      	alsa.enable = lib.mkDefault true;
      	alsa.support32Bit = lib.mkDefault true;
      	pulse.enable = lib.mkDefault true;
      	jack.enable = lib.mkDefault true;
        extraConfig.pipewire = {
          "10-clock-rate" = {
            "context.properties" = {
              "default.clock.rate" = 48000;
              "default.clock.quantum" = 1024;
              "default.clock.min.quantum" = 512;
              "default.clock.max.quantum" = 2048;
            };
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

    })
    (mkIf (cfg.enable && cfg.pavucontrol.enable) {
      environment.systemPackages = [
        pkgs.pavucontrol
      ];
    })
    (mkIf (cfg.enable && cfg.proAudio.enable) {

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
      zramSwap = {
        enable = lib.mkDefault true;
        algorithm = "zstd";
        memoryPercent = 20;
      };
      services.udisks2.enable = lib.mkDefault true;
      services.avahi.enable = lib.mkDefault true;
      musnix = {
      # https://github.com/musnix/musnix                                                                            	
        enable = lib.mkDefault true;                                                                                                
        kernel.realtime = true;                                                                                     	
        #kernel.packages = pkgs.linuxPackages-latest_rt;                                                             	
        soundcardPciId = ""; # not applicable to USB sound cards. Example "00:1b.0" found with lspci | grep -i audio	
        ffado.enable = false; # use free FireWare audio drivers                                                     	
        rtcqs.enable = lib.mkDefault true; # https://wiki.linuxaudio.org/wiki/system_configuration#rtcqs                            
          das_watchdog.enable = false; # https://github.com/kmatheussen/das_watchdog                                 
      };                                                                                                             
      # opens UDP ports 6001-6002
      services.pipewire.raopOpenFirewall = true;
      services.pipewire.extraConfig.pipewire."10-airplay"."context.modules" = [
        {
          name = "libpipewire-module-raop-discover";
          # increase the buffer size if you get dropouts/glitches
          # args = {
          #   "raop.latency.ms" = 500;
          # };
        }
      ];
    })
  ];
}
