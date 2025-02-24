{ config, pkgs, lib, ... }:

{ 
#QT
  qt.enable = false;
#  qt.platformTheme = "gtk";
#  qt.style.name = "tokyo-night-gtk-theme";

#  qt.style.package = tokyo-night-gtk-theme;

#GTK
  gtk.enable = true;
  
  gtk.cursorTheme.package = pkgs.afterglow-cursors-recolored;
  gtk.cursorTheme.name = "dracula-teddy";

  gtk.theme.package = pkgs.tokyonight-gtk-theme;
  gtk.theme.name = "Tokyonight-Dark";

  gtk.iconTheme.package = pkgs.papirus-icon-theme;
  gtk.iconTheme.name = "Papirus";
}
