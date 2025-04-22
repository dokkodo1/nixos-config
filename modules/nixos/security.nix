{ config, pkgs, lib, ... }:

{
  security.pki.certificateFiles = [
    /home/dokkodo/certs/rootCA.pem 
  ];
}