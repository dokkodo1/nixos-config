{ pkgs }:

let
  haskellPackages = pkgs.haskellPackages;
in
pkgs.mkShell {
  packages = with pkgs; [
    haskellPackages.ghc
    cabal-install
    haskell-language-server
    haskellPackages.hoogle
    haskellPackages.ghcid
    haskellPackages.hlint
    haskellPackages.ormolu
  ];

  NIX_GHC_LIBDIR = "${haskellPackages.ghc}/lib/ghc-${haskellPackages.ghc.version}";

  shellHook = ''
    echo "Haskell devenv loaded"
    echo "GHC: $(ghc --version)"
  '';
}
