{ config, pkgs, lib, ... }:

{
  #Grapicscard
  hardware.graphics = {
  	enable = true;
  	enable32Bit = true;
  };
}
