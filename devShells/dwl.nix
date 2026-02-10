{ pkgs }:

pkgs.mkShell {
  name = "dwl-dev";
  nativeBuildInputs = with pkgs; [ pkg-config wayland-scanner gcc gnumake ];
  buildInputs = with pkgs; [
    libinput libxcb libxkbcommon pixman wayland wayland-protocols
    wlroots libdrm fcft libxcb libxcb-wm
  ];
  shellHook = ''
    echo "DWL Development Shell"
    echo "  cd modules/dotfiles/dwl"
    echo "  make clean && make"
    echo "  ./dwl (to test)"
  '';
}
