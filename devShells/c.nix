{ pkgs }:

pkgs.mkShell {
  packages = with pkgs; [
    clang
    gnumake
    gdb
    file
    clang-tools
  ];

  shellHook = ''
    cat > compile_flags.txt << CFLAGS
-I${pkgs.glibc.dev}/include
CFLAGS
    echo "C devenv loaded"
  '';
}
