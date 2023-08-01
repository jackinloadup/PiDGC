{ lib
, stdenv
, qmake
, qt5
, wrapQtAppsHook
}:
stdenv.mkDerivation {
  version = "0.1";
  pname = "display";

  src = ./.;

  nativeBuildInputs = [
    qmake
    wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtmultimedia
    qt5.qtserialport
    qt5.qtwayland
  ] ++ lib.optionals stdenv.isLinux [
    qt5.qtwayland
  ];
  meta = {
    description = "Raspberry Pi based Digital Gauge Cluster";
    homepage = "https://github.com/joshellissh/PiDGC";
    platforms = with lib.platforms; linux;
  };
}
