{ pkgs, lib, config, hostVars, ... }:

with lib;
let
  cfg = config.control.display;
in {
  options.control.display = {
    dwl.enable = lib.mkEnableOption "Enable dwl, the wayland implementation of dwl";
    i3wm.enable = lib.mkEnableOption "Enable i3wm, a minimal x11 window manager";
    kde.enable = lib.mkEnableOption "Enable wayland kde, the desktop environment";
  };
  config = mkMerge [
    (mkIf (cfg.dwl.enable || cfg.kde.enable || cfg.i3wm.enable) {
      xdg.portal.enable = true;
      environment.systemPackages = with pkgs; [
        xdg-utils
        adwaita-icon-theme
      ] ++ lib.optionals (!cfg.kde.enable) [ adwaita-qt ];

      home-manager.users.${hostVars.username} = {
        gtk = {
          enable = true;
          gtk2.force = true;
          theme = {
            name = "Adwaita-dark";
            package = pkgs.gnome-themes-extra;
          };
          iconTheme = {
            name = "Adwaita";
            package = pkgs.adwaita-icon-theme;
          };
        };
        dconf.enable = lib.mkForce false;
      };

      qt = lib.mkIf (!cfg.kde.enable) {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita-dark";
      };
    })

    (mkIf (cfg.dwl.enable) {
      users.users.${hostVars.username}.extraGroups = [ "input" "video" ];
      services.xserver.xkb = {
        layout = "us";
        variant = "";
        options = "";
      };
      services.libinput.enable = lib.mkDefault true;
      programs.xwayland.enable = lib.mkDefault true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
      
      environment.systemPackages = with pkgs; [
        foot
        wmenu
        wl-clipboard
        bemenu
        swaybg
        grim
        slurp
        waybar
      ];

      programs.dwl = {
        enable = lib.mkDefault true;
        package = pkgs.dwl;  # uses our overlay
      };
      
      fonts.packages = with pkgs; [
        jetbrains-mono
        font-awesome
      ];
      
      home-manager.users.${hostVars.username} = {
        programs.foot = {
          enable = lib.mkDefault true;
          # settings.main.font = "JetBrainsMono Nerd Font:size=12";
          # settings = builtins.readFile ../../dotfiles/foot/foot.ini;
        };
        home.file.".config/foot/foot.ini" = {
          source = ../../dotfiles/foot/foot.ini;
          force = true;
        };

        programs.waybar = {
          enable = true;
        };
        

        home.file.".config/waybar/config.jsonc" = {
          source = ../../dotfiles/waybar/config.jsonc;
          force = true;
        };
        home.file.".config/waybar/style.css" = {
          source = ../../dotfiles/waybar/style.css;
          force = true;
        };
      };
    })

    (mkIf (cfg.kde.enable) {
      users.users.${hostVars.username}.extraGroups = [ "input" "video" ];
      services.displayManager.sddm.enable = lib.mkDefault true;
      services.displayManager.sddm.wayland.enable = lib.mkDefault true;
      services.desktopManager.plasma6.enable = lib.mkDefault true;
      environment.systemPackages = with pkgs; [ konsave wl-clipboard foot ];
      environment.plasma6.excludePackages = with pkgs.kdePackages; [ plasma-browser-integration elisa ];
      home-manager.users.${hostVars.username} = {
        programs.foot = {
          enable = lib.mkDefault true;
        };
        home.file.".config/foot/foot.ini" = {
          source = ../../dotfiles/foot/foot.ini;
          force = true;
        };
      };
    })

    (mkIf (cfg.i3wm.enable) {
      users.users.${hostVars.username}.extraGroups = [ "input" "video" ];
      services.xserver = {
        enable = lib.mkDefault true;
        displayManager.startx.enable = lib.mkDefault true;
        windowManager.i3 = {
          enable = lib.mkDefault true;
          extraPackages = with pkgs; [
            i3status i3lock
          ];
        };
      };
  
      environment.systemPackages = with pkgs; [ xterm ];
      environment.etc."X11/xresources".text = ''
        xterm*faceName: monospace:size=12
        xterm*font: -*-fixed-medium-r-*-*-14-*-*-*-*-*-*-*
        xterm*boldFont: -*-fixed-bold-r-*-*-14-*-*-*-*-*-*-*
        xterm*scrollBar: false
        xterm*rightScrollBar: false
        xterm*jumpScroll: true
        xterm*multiScroll: true
        xterm*toolBar: false
      '';
  
      environment.etc."i3/config".text = ''
        set $mod Mod4
  
        set $bg #1a1b26
        set $fg #a9b1d6
        set $blue #7aa2f7
        set $green #73daca
        set $yellow #e0af69
        set $red #f7768e
        set $grey #414868
  
        client.focused            $blue   $blue   $bg   $green  $blue
        client.focused_inactive   $grey   $bg     $fg   $grey   $grey
        client.unfocused          $grey   $bg     $fg   $grey   $grey
        client.urgent             $red    $red    $bg   $red    $red
        
        bindsym $mod+Return exec xterm -e tmux
        bindsym $mod+d exec firefox
        bindsym $mod+Shift+q kill
        bindsym $mod+f fullscreen toggle
        bindsym $mod+Shift+c reload
        bindsym $mod+Shift+r restart
        bindsym $mod+Shift+e exit
  
        bindsym $mod+h focus left
        bindsym $mod+j focus down
        bindsym $mod+k focus up
        bindsym $mod+l focus right
  
        bindsym $mod+Shift+h move left
        bindsym $mod+Shift+j move down
        bindsym $mod+Shift+k move up
        bindsym $mod+Shift+l move right
  
        bindsym $mod+1 workspace number 1
        bindsym $mod+2 workspace number 2
        bindsym $mod+3 workspace number 3
  
        bindsym $mod+Shift+1 move container to workspace number 1
        bindsym $mod+Shift+2 move container to workspace number 2
        bindsym $mod+Shift+3 move container to workspace number 3
  
        bar {
          status_command i3status
          position top
  
          colors {
            background $bg
            statusline $fg
            separator $grey
  
            focused_workspace   $blue   $blue   $bg
            active_workspace    $grey   $grey   $fg
            inactive_workspace  $bg     $bg     $fg
            urgent_workspace    $red    $red    $bg
          }
        }
  
        default_border pixel 1
        default_floating_border pixel 1
        hide_edge_borders smart
  
        focus_follows_mouse no
      '';
    })
  ];
}

