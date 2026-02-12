{ lib , ... }:

{
  services.ollama = {
    enable = true;
    acceleration = "cuda"; # or "rocm"
  };
  systemd.services.wantedBy = lib.mkForce [ ];
}
