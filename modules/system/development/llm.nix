{ pkgs , ... }:

{
# https://wiki.nixos.org/wiki/Ollama
environment.systemPackages = [
   (pkgs.ollama.override { 
      acceleration = "rocm";
    })
  ];
}
