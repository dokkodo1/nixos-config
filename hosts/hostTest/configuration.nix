{ pkgs, modPath, inputs, config, hostname, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (modPath + "/system")
  ];



  # uncomment these two options if you want to use cachyos kernel
  # if commented, you'll be on the default for nixpkgs
  #boot.kernelPackages = pkgs.linuxPackages_cachyos;
  #services.scx.enable = true;

   

  /*

            this is where my opinionated options are. i'll grow this out once i've written a few more modules
                              hooray more abstraction hooray

  */
  
  control = {

    audio = {
      enable = true; # disabling this is not recommended, but for servers
      pavucontrol.enable = false; # enable to... control pipewire audio with GUI, requires display server
    };

    gpuVendor = null; # example: "amd" or "nvidia"

    display = {
      kde.enable = false; # desktop environment similar to windows with wayland
      dwl.enable = false; # minimal and performant window manager with wayland
      i3wm.enable = false; # minimal and performant window manager with x11
    };

    gaming = {
      enable = false;
      starCitizen.enable = false;
      launchers.lutris.enable = false; # good option for star citizen, or anything you can't/won't launch through steam.
      launchers.heroic.enable = false; # GOG + Epic + Amazon Games store/launcher. Linux native, pretty damn neat if a little jank. Tiny and worth trying
      extras = {
        discord.enable = true; # defaults to true
        openrgb.enable = true; 
        ratbagd.enable = true;
      };
    };

    virtualization = {
      enable = false;
      gpuPassthrough = {
        enable = false;
        cpuType = null; # or "intel" or "amd"
        gpuIDs = [ ]; # example = [ "10de:2684" "10de:22ba" ];     
                       /*            
          PCI IDs of GPU to pass through
              (vendor:device format).
       Find with: lspci -nn | grep -E "VGA|Audio"
       Include both the VGA and Audio device IDs.
                       */
        reserveHostGPU = null; # example = "1002:7480";
                       /*
                 :: nullOr str
        Optional: PCI ID of GPU to reserve for 
            host (integrated graphics).
       Leave null if you have two discrete GPUs.
                       */
      };
      
      lookingGlass = { 
        enable = false; # view VM on same output as linux, no 2nd monitor, very nice
        sharedMemorySize = 128; # Shared memory size in MB for Looking Glass (should match VM resolution)
        user = "myCoolUserWow";
      };

      hugepages = { 
        enable = false; # gib VM RAM
        size = 16384; # Amount of memory in MB to allocate to hugepages (set based on VM RAM needs)
      };
    };

    audio = {
      proAudio = {
        enable = false;
        reaper.enable = false;
        ardour.enable = false;
        nativeAccess.enable = false;
        musescore.enable = false;
      };
    };
  };



  /*

            this is no-touchy land
                              hooray more abstraction hooray

  */


  networking.hostName = hostname; # if you change this, make the same change in flake.nix
  system.stateVersion = "24.11"; # ESPECIALLY DO NOT TOUCH <<<

  # # if you're going to change out your bootloader, i heard it's safer to `rebuild boot` rather than `rebuild switch` but i've never had a problem with switching
  # boot.loader = {
  #   systemd-boot.enable = true;
  #   efi.canTouchEfiVariables = true;
  # };

  boot.loader = {
    grub.enable = true;
    grub.device = "/dev/sda";
    grub.configurationLimit = 6;
    grub.efiSupport = false;
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTR{name}=="AT Translated Set 2 keyboard", ATTR{power/control}="on"
    '';

  hardware.enableAllFirmware = true;
  boot.kernelModules = [ "b43" ];
  hardware.firmware = [ pkgs.linux-firmware ];

  security.polkit = {
    enable = true;
    debug = true;
  };

  users.users.${username}.extraGroups = [
    "audio"
    "video"
    "input"
    "cpu"
  ];

  #  services.xserver = {
  #    enable = false;
  #    videoDrivers = [ "modesetting" ];
  #  };

  environment.variables = {
    EDITOR = "nvim";
  };
        
  programs.neovim.enable = true;
  programs.firefox.enable = false;

  home-manager = {
	  extraSpecialArgs = { inherit inputs username hostname; };
    backupFileExtension = "backup";
    useGlobalPkgs = true;
  };
}

