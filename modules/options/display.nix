{ pkgs, lib, config, username, ... }:

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

    (mkIf (cfg.dwl.enable) {
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
        foot dwl wmenu waybar wl-clipboard
      ];
      programs.dwl = {
        enable = true;
      };
      home-manager.users.${username} = {
        programs.foot = {
          enable = true;
          settings.main.font = "JetBrainsMono Nerd Font:size=12";
        };
      };
    })

    (mkIf (cfg.kde.enable) {
      users.users.${username}.extraGroups = [ "input" "video" ];
      services.displayManager.sddm.enable = true;
      services.displayManager.sddm.wayland.enable = true;
      services.desktopManager.plasma6.enable = true;
      environment.systemPackages = with pkgs; [ konsave wl-clipboard ];
      environment.plasma6.excludePackages = with pkgs.kdePackages; [ plasma-browser-integration elisa ];
      home-manager.users.${username}.programs.kitty = lib.mkForce {
	    	enable = true;
	    	settings = {
	    		font_family = "JetBrainsMono Nerd Font";
	    		font_size = 12;

	    		cursor_shape = "underline";
	    		cursor_blink_interval = 0;
	    		copy_on_select = true;
	    		strip_trailing_spaces = "smart";

	    		enable_audio_bell = false;

	    		confirm_os_window_close = 0;
	    		window_margin_width = 8;
	    		hide_window_decorations = true;

	    		foreground = "#a9b1d6";
	    		background = "#1a1b26";
	    		background_opacity = 0.60;
	    		background_blur = 1;
	    		dynamic_background_opacity = true; 
	    		wayland_enable_ime = true;

	    		color0 = "#414868";
	    		color8 = "#414868";
	    		#: black

	    		color1 = "#f7768e";
	    		color9 = "#f7768e";
	    		#: red

	    		color2 = "#73daca";
	    		color10 = "#73daca";
	    		#: green

	    		color3 = "#e0af69";
	    		color11 = "#e0af69";
	    		#: yellow

	    		color4 = "#7aa2f7";
	    		color12 = "#7aa2f7";
	    		#: blue

	    		color5 = "#bb9af7";
	    		color13 = " #bb9af7";
	    		#: magenta

	    		color6 = "#7dcfff";
	    		color14 = "#7dcfff";
	    		#: cyan

	    		color7 = "#c0caf5";
	    		color15 = "#c0caf5";
	    		#: white
	    	};
      };
    })

    (mkIf (cfg.i3wm.enable) {
      users.users.${username}.extraGroups = [ "input" "video" ];
      services.xserver = {
        enable = true;
        displayManager.startx.enable = true;
        windowManager.i3 = {
          enable = true;
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
  
        bindsum $mod+1 workspace number 1
        bindsum $mod+2 workspace number 2
        bindsum $mod+3 workspace number 3
  
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

