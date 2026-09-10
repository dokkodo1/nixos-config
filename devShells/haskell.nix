{ pkgs }:

let
  haskellPackages = pkgs.haskellPackages;
in
pkgs.mkShell {
  packages = [
    haskellPackages.ghc
    haskellPackages.ghcid
  ];

  NIX_GHC_LIBDIR = "${haskellPackages.ghc}/lib/ghc-${haskellPackages.ghc.version}";

  shellHook = ''
    echo "Haskell devenv loaded"
    echo "GHC: $(ghc --version)"
  '';
}
