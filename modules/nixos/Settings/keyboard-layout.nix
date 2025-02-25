{ config, pkgs, lib, ... }:

{
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";


  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "us";
}
