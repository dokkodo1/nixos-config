{ pkgs, ... }:

{
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

    environment.systemPackages = with pkgs; [ firefox xterm ];
    environment.etc."X11/xresources".text = ''
      ! Tokyo night theme
      xterm*background: #1a1b266
      xterm*foreground: #a9b1d6
      xterm*cursorColor: #a9b1d6

      xterm*color0: #414868
      xterm*color1: #f7768e
      xterm*color2: #73daca
      xterm*color3: #e0af69
      xterm*color4: #7aa2f7
      xterm*color5: #bb9af7
      xterm*color6: #7dcfff
      xterm*color7: #c0caf8
      xterm*color8: #414868
      xterm*color9: #f7768e
      xterm*color10: #73daca
      xterm*color11: #e0af69
      xterm*color12: #7aa2f7
      xterm*color13: #bb9af7
      xterm*color14: #7dcfff
      xterm*color15: #c0caf5

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
}
