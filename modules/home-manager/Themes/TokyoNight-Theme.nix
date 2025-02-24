{ pkgs }:

pkgs.stdenv.mkDerivation {
	name = "TokyoNight";
	src = pkgs.fetFromGitHub {
	  owner = "Fausto-Korpsvart";
	  repo = "Tokyonight-GTK-Theme";
	  rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
	  sha256 = "123414";
	};
	instalPhase = ''
	  mkdir -p $out
	  cp -R ./* $out/
	'';
}
