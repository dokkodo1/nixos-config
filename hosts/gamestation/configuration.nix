# NOT EDITED AT ALL
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
	./hardware-configuration.nix
	inputs.home-manager.nixosModules.default
    #Overlay
	./../../modules/nixos/sddm.nix                        # done
	./../../modules/nixos/WindowManager.nix               # done
	./../../modules/nixos/FileManager/thunar.nix          # done
    #System	
	./../../modules/nixos/fonts.nix                       # done
#	./../../modules/nixos/homeoffice.nix
#	./../../modules/nixos/Shell/htp.nix                   # done
	./../../modules/nixos/Shell/system-tools.nix
    #Gaming
	./../../modules/nixos/desktop-essentials.nix   	      # done
	./../../modules/nixos/gaming.nix								      # done
    #Settings
	./../../modules/nixos/Settings/hardware.nix           # done
	./../../modules/nixos/Settings/keyboard-layout.nix    # done
	./../../modules/nixos/Settings/time.nix               # done
	./../../modules/nixos/Settings/users.nix              # done
    #Services
	./../../modules/nixos/Services/networking.nix         # done
	./../../modules/nixos/Services/ssh.nix                # done
	./../../modules/nixos/Services/bluetooth.nix          # done
	./../../modules/nixos/Services/sound.nix              # done
  ];


  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Star Citizen stuff
    kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "fs.file-max" = 524288;
    };
  };

  systemd = {
    packages = with pkgs; [
      lact
    ];
    services = {
      lactd.wantedBy = ["multi-user.target"];
    };
  };

  security = {    
    polkit = {
      enable = true;
      debug = true;
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "@wheel" ];
      substituters = ["https://nix-citizen.cachix.org"];
      trusted-public-keys = ["nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="];
    };
    gc = {
      automatic = true;
      dates = "weekly";
    };
  }; 

  home-manager = {
	#also pass inputs to home-manager modules
	  extraSpecialArgs = {inherit inputs; };
	  users = {
	    "dokkodo" = import ./home.nix;
	  };
  };

 

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.xserver.enable = true;

  security.pam.services.hyprlock = {};
  security.pam.services.swaylock = {};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  system.stateVersion = "24.11";
}
