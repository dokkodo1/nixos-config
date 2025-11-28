{ lib , ... }:

{
  services.ollama = {
    enable = true;
    acceleration = "cuda"; # or "rocm"
  };
  # won't start service automatically, so start with `sudo systemctl start ollama` then `ollama run llama3.2` or whatever, stop it with `sudo systemctl stop ollama`
  systemd.services.wantedBy = lib.mkForce [ ];
}
