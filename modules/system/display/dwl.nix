{ pkgs, username, ... }:
{
  boot.kernelParams = [ "i915.modeset=1" "i804.nopnp=1" "8042.reset=1" ];
  users.users.${username}.extraGroups = [ "input" "video" ];
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "";
  };
  services.libinput.enable = true;
  programs.xwayland.enable = true;
  environment.systemPackages = with pkgs; [
    foot
    dwl
    bemenu
    waybar
    wl-clipboard
  ];
  programs.dwl = {
    enable = true;
  };
}
