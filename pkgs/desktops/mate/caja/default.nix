{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  pkg-config,
  gettext,
  gtk-layer-shell,
  gtk3,
  libnotify,
  libxml2,
  libexif,
  exempi,
  mate-desktop,
  hicolor-icon-theme,
  wayland,
  wrapGAppsHook3,
  mateUpdateScript,
  aflplusplus,
  libllvm,
}:

stdenv.mkDerivation rec {
  pname = "caja";
  version = "1.28.0";

  __structuredAttrs = true;

  outputs = [
    "out"
    "man"
  ];

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "HjAUzhRVgX7C73TQnv37aDXYo3LtmhbvtZGe97ghlXo=";
  };

  patches = [
    # wayland: ensure windows can be moved if compositor is using CSD
    # https://github.com/mate-desktop/caja/pull/1787
    (fetchpatch {
      url = "https://github.com/mate-desktop/caja/commit/b0fb727c62ef9f45865d5d7974df7b79bcf0d133.patch";
      hash = "sha256-2QAXveJnrPPyFSBST6wQcXz9PRsJVdt4iSYy0gubDAs=";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    wrapGAppsHook3
    aflplusplus
    libllvm
  ];

  buildInputs = [
    gtk-layer-shell
    gtk3
    libnotify
    libxml2
    libexif
    exempi
    mate-desktop
    hicolor-icon-theme
    wayland
  ];

  preConfigure = ''
    export LD="${aflplusplus}/bin/afl-ld-lto"
  '';

  makeFlags = [
    "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
    "LD=${aflplusplus}/bin/afl-ld-lto"
    "AR=${libllvm}/bin/llvm-ar"
    "RANLIB=${libllvm}/bin/llvm-ranlib"
    "AS=${libllvm}/bin/llvm-as"
    "AFL_LLVM_CMPLOG=1"
    "AFL_USE_ASAN=0"
    "AFL_USE_UBSAN=0"
    "CFLAGS=-Wno-error"
    "CXXFLAGS=-Wno-error"
  ];

  configureFlags = [ "--disable-update-mimedb" "--disable-shared" "--enable-static" ];

  enableParallelBuilding = true;

  passthru.updateScript = mateUpdateScript { inherit pname; };

  meta = {
    description = "File manager for the MATE desktop";
    homepage = "https://mate-desktop.org";
    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
    ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
}
