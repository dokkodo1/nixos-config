{ ... }:
{
  /*

            this is where my opinionated options are. i'll grow this out once i've refactored a few more modules

  */
  control = {

    gpuVendor = ""; # example: "amd" or "nvidia"

    gaming = {
      enable = true;
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
        cpuType = "intel"; # or "amd"

        gpuIDs = [ ]; # example = [ "10de:2684" "10de:22ba" ];     
                       /*            
          PCI IDs of GPU to pass through
              (vendor:device format).
       Find with: lspci -nn | grep -E "VGA|Audio"
       Include both the VGA and Audio device IDs.
                       */
      };
        
      reserveHostGPU = null; # example = "1002:7480";
                       /*
                 :: nullOr str
        Optional: PCI ID of GPU to reserve for 
            host (integrated graphics).
       Leave null if you have two discrete GPUs.
                       */
      
      lookingGlass = { 
        enable = false; # view VM on same output as linux, no 2nd monitor, very nice
        sharedMemorySize = 128; # Shared memory size in MB for Looking Glass (should match VM resolution)
        user = "myCoolUserWow";
      };

      hugepages = { 
        enable = true; # gib VM RAM
        size = 16384; # Amount of memory in MB to allocate to hugepages (set based on VM RAM needs)
      };
    };
  };
}
