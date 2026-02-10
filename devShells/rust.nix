{ pkgs }:

pkgs.mkShell {
  packages = with pkgs; [
    cargo
    rustc
    rustfmt
    clippy
    rust-analyzer
  ];

  nativeBuildInputs = with pkgs; [ pkg-config ];

  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

  shellHook = ''
    echo "Rust devenv loaded"
    echo "rustc: $(rustc --version)"
  '';
}
