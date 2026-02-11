{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "teamspeak6-server";
  version = "6.0.0-beta8";

  src = fetchurl {
    url = "https://github.com/teamspeak/teamspeak6-server/releases/download/v6.0.0/beta8/teamspeak-server_linux_amd64-v${version}.tar.bz2";
    hash = "sha256-U9jazezXFGcW95iu20Ktc64E1ihXSE4CiQx3jkgDERc=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    stdenv.cc.cc.lib  # libgcc_s.so.1
  ];

  # The tarball bundles its own libs - let autoPatchelfHook use them
  autoPatchelfIgnoreMissingDeps = [ "libm.so.6" "libpthread.so.0" "libdl.so.2" "libc.so.6" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/share/teamspeak6-server

    # Main binary
    install -Dm755 tsserver $out/bin/tsserver

    # Bundled libraries
    install -Dm644 libc++.so.1 $out/lib/
    install -Dm644 libssh.so.4 $out/lib/
    install -Dm644 libatomic.so.1 $out/lib/
    install -Dm644 libunwind.so.1 $out/lib/

    # SQL scripts and documentation
    cp -r sql $out/share/teamspeak6-server/
    cp -r serverquerydocs $out/share/teamspeak6-server/

    # License and docs
    install -Dm644 LICENSE $out/share/teamspeak6-server/
    install -Dm644 CHANGELOG $out/share/teamspeak6-server/

    runHook postInstall
  '';

  meta = with lib; {
    description = "TeamSpeak 6 Server Beta - voice communication server";
    homepage = "https://teamspeak.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
