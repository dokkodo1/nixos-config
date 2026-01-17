{ pkgs, username, ... }: {

  imports = [
    ./hardware-configuration.nix
  ];

  /*
            this is where my opinionated options are. i'll grow this out once i've written a few more modules
                              hooray more abstraction hooray
  */
  
  control = {
    audio = {
      enable = true; # disabling this is not recommended, but for servers
      pavucontrol.enable = false; # enable to... control pipewire audio with GUI, requires display server
    };

    gpuVendor = null; # example: "amd" or "nvidia", intel not implemented

    display = {
      kde.enable = false; # desktop environment similar to windows with wayland, my recommendation for a DE
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
        openrgb.enable = false; 
        ratbagd.enable = false;
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
        user = "${username}";
      };

      hugepages = { 
        enable = false; # gib VM RAM
        size = 16384; # Amount of memory in MB to allocate to hugepages (set based on VM RAM needs)
      };
    };

    audio.proAudio = {
      enable = false;
      reaper.enable = false;
      ardour.enable = false;
      nativeAccess.enable = false;
      musescore.enable = false;
    };

    tailscale = {
      enable = false;
      ssh = true;
      exitNode = false;
    };

    remoteBuilders = {
      enable = false; # enable distributed builds
      serveAsBuilder = false; # allow other machines to use this host for remote builds
      enableLinuxBuilder = false; # (Darwin only) enable Linux VM for building x86_64-linux packages on macOS

      useBuilders = []; # list of remote builders to use for offloading compilation
      /*
        example = [
          {
            hostName = "hpl-macmini"; # or IP address, or tailscale hostname
            systems = [ "x86_64-darwin" ]; # what systems this builder can build
            sshUser = "builder"; # SSH user for remote builds
            maxJobs = 8; # max parallel jobs
            speedFactor = 2; # relative speed (higher = prefer this builder)
          }
          {
            hostName = "hpl-tower";
            systems = [ "x86_64-linux" ];
            sshUser = "builder";
            maxJobs = 12;
            speedFactor = 3;
          }
        ];
      */
    };
  };

  # if you're going to change out your bootloader, i heard it's safer to `rebuild boot` rather than `rebuild switch` but i've never had a problem with switching
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.firmware = [ pkgs.linux-firmware ]; # because why not

  services.xserver = {
    enable = true;
    videoDrivers = [ "modesetting" ];
  };
}

