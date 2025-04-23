{ config, pkgs, lib, ... }:

{
  security.pki.certificateFiles = [
    ./../../files/certs/rootCA.pem
  ];
}