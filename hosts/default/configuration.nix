
{ pkgs, modPath, ... }:

{
  dokkodo = {

    packages = {
		  excludedPackages = [ ];
			all = [ ];
    };

    hardware = {
      graphics = {
        amd.enable = true;
				nvidia.enable = false;
				intel.enable = false;
			};
			cpu = {
        intel.enable = true;
				amd.enable = false;
			};
			bluetooth.enable = false;
			wifi.enable = false;
		};

		display = {
      server = {
			  x11 = {
				  enable = true;
					minimal = true;
        };
				wayland.enable = true;
      };
      displayManager = {
        sddm.enable = true;
			};
			desktop = {
        kde.enable = true;
				gnome.enable = false;
				hyprland.enable = false;
				dwm.enable = false;
				i3.enable = false;
			};
		};

		kernel = "default"; # or "stable", "unstable", "rt", "rt-latest", "cachyos"

		gaming = {
      enable = true;
			starCitizen.enable = false;
			extraLaunchers = [ "lutris" "heroic" "bnet" ];
			excludedPackages = [ ];
		};

		proAudio = {
      enable = true;
			daw = [ "reaper" "ardour" ];
			musescore.enable = false;
			plugins = {
			  managers.native-access = {
				  enable = true;
					downloadPath = "absolute/path/to/NI/downloads";
					contentPath = "absolute/path/to/NI/content";
					tempPath = "absolute/path/to/NI/temp";
				};
        
		};
  };

  #Hard drive boilerplate
  fileSystems."path/to/mount/point" = {
    device = "/dev/disk/by-uuid/[hashOfUuid]";
    fsType = "";
    options = [ ];
  };  
  systemd.tmpfiles.rules = [
    "d /mnt/sata1 0775 dokkodo users - -"
  ];
}
