{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ vscode ];
  services.vscode-server.enable = true;
}
