{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "tmux-powerkit";
  version = "unstable-2024-12-21";

  src = fetchFromGitHub {
    owner = "fabioluciano";
    repo = "tmux-powerkit";
    rev = "main";
    sha256 = "sha256-9095xkvKhRyUy5opntaeX29evPLV74ry4d2R2Rnv5EY=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/tmux-plugins/tmux-powerkit
    cp -r * $out/share/tmux-plugins/tmux-powerkit/

    runHook postInstall
  '';

  meta = with lib; {
    description = "The Ultimate tmux Status Bar Framework";
    longDescription = ''
      A comprehensive status bar framework for tmux with 42 production-ready plugins,
      32 themes with 56 variants, and 9 separator styles. Features smart caching
      with Stale-While-Revalidate lazy loading.
    '';
    homepage = "https://github.com/fabioluciano/tmux-powerkit";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ ];
  };
}
