{ pkgs, ... }:

{
    services.xserver = {
        enable = true;
        displayManager.startx.enable = true;
        windowManager.openbox.enable = true;
        videoDrivers = [ "modesetting" ];
    };

    environment.systemPackages = with pkgs; [ firefox xterm ];
}
