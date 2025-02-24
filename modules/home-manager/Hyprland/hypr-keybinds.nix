{ config, pkgs, lib, ... }:

{

  wayland.windowManager.hyprland.settings = {

	"$mainMod" = "SUPER";
	"$terminal" = "kitty";
	"$fileManager" = "thunar";
	"$menu" = "wofi --show drun";

#------------------------------------

	bind = [
		"$mainMod, Return, exec, $terminal"
		"$mainMod, W, killactive,"
		"$mainMod, M, exit,"
		"$mainMod, E, exec, $fileManager"
		"$mainMod, V, togglefloating,"
		"$mainMod, R, exec, $menu"
		"$mainMod, F, fullscreen,"

# Move focus with mainMod + HJKL
		"$mainMod, H, movefocus, l"
		"$mainMod, L, movefocus, r"
		"$mainMod, J, movefocus, u"
		"$mainMod, K, movefocus, d"

#Move windows with mainMod + Shift + HJKL
		"$mainMod SHIFT, H, movewindow, l"
		"$mainMod SHIFT, L, movewindow, r"
		"$mainMod SHIFT, J, movewindow, u"
		"$mainMod SHIFT, K, movewindow, d"

# Switch workspaces with mainMod + [0-9]
		"$mainMod, 1, workspace, 1"
		"$mainMod, 2, workspace, 2"
		"$mainMod, 3, workspace, 3"
		"$mainMod, 4, workspace, 4"
		"$mainMod, 5, workspace, 5"
		"$mainMod, 6, workspace, 6"
		"$mainMod, 7, workspace, 7"
		"$mainMod, 8, workspace, 8"
		"$mainMod, 9, workspace, 9"
		"$mainMod, 0, workspace, 10"

# Move active window to a workspace with mainMod + SHIFT + [0-9]
		"$mainMod SHIFT, 1, movetoworkspace, 1"
		"$mainMod SHIFT, 2, movetoworkspace, 2"
		"$mainMod SHIFT, 3, movetoworkspace, 3"
		"$mainMod SHIFT, 4, movetoworkspace, 4"
		"$mainMod SHIFT, 5, movetoworkspace, 5"
		"$mainMod SHIFT, 6, movetoworkspace, 6"
		"$mainMod SHIFT, 7, movetoworkspace, 7"
		"$mainMod SHIFT, 8, movetoworkspace, 8"
		"$mainMod SHIFT, 9, movetoworkspace, 9"
		"$mainMod SHIFT, 0, movetoworkspace, 10"
	
#Lockscreen
		"$mainMod, S, exec, hyprlock"
	];

	bindd = [
# Take Screenshot
		'' , Print, Screenshot Region, exec, grim -g "$(slurp)" - | wl-copy ''
		"$mainMod, Print, Screenshot Screen, exec, grim -o DP-3 - | wl-copy "

	];

	bindm = [
# Move/resize windows with mainMod + LMB/RMB and dragging
		"$mainMod, mouse:272, movewindow"
		"$mainMod, mouse:273, resizewindow"
	];	
  };
}
