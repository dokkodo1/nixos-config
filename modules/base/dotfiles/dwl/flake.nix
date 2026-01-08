{
  description = "DWL development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            # Build tools
            gcc
            pkg-config
            gnumake
            wayland-scanner
          ];
          
          buildInputs = with pkgs; [
            # Core DWL dependencies - use wlroots 0.17 for dwl compatibility
            wlroots_0_17
            wayland
            wayland-protocols
            libxkbcommon
            libinput
            xwayland
            
            # Rendering dependencies
            pixman
            mesa
            libdrm
            libGL
            
            # Additional wayland/wlroots dependencies
            cairo
            pango
            libpng
            libjpeg
            
            # System dependencies
            systemd
            seatd
            
            # Additional useful tools
            gdb
            valgrind
          ];
          
          shellHook = ''
            echo "DWL development environment loaded"
            echo "Ready to compile dwl"
          '';
        };
      });
}