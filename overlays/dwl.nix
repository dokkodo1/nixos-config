{ inputs }:

final: prev: {
  dwl = prev.stdenv.mkDerivation {
    pname = "dwl";
    version = "0.8-local";
    src = inputs.dwl-source;

    nativeBuildInputs = with prev; [ pkg-config wayland-scanner ];
    buildInputs = with prev; [
      libinput libxcb libxkbcommon pixman wayland wayland-protocols
      wlroots libdrm fcft libxcb libxcb-wm
    ];

    makeFlags = [
      "PREFIX=$(out)"
      "PKG_CONFIG=${prev.pkg-config}/bin/pkg-config"
    ];

    meta = with prev.lib; {
      description = "Dynamic window manager for Wayland (local build)";
      homepage = "https://codeberg.org/dwl/dwl";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
      mainProgram = "dwl";
    };
  };
}
