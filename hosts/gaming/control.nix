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
  };
}
