{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  gettext,
  caja,
  glib,
  gst_all_1,
  gtk3,
  gupnp_1_6,
  imagemagick,
  mate-desktop,
  wrapGAppsHook3,
  mateUpdateScript,
  aflplusplus,
  libllvm,
}:

stdenv.mkDerivation rec {
  pname = "caja-extensions-asan";
  version = "1.28.0";

  __structuredAttrs = true;

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor version}/caja-extensions-${version}.tar.xz";
    sha256 = "0phsXgdAg1/icc+9WCPu6vAyka8XYyA/RwCruBCeMXU=";
  };

  nativeBuildInputs = [
    pkg-config
    gettext
    wrapGAppsHook3
    aflplusplus
    libllvm
  ];

  buildInputs = [
    caja
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gtk3
    gupnp_1_6
    imagemagick
    mate-desktop
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
    "CFLAGS=-static-libsan -Wno-error"
    "CXXFLAGS=-static-libsan -Wno-error"
  ];

  postPatch = ''
    for f in image-converter/caja-image-{resizer,rotator}.c; do
      substituteInPlace $f --replace-fail 'argv[0] = "convert"' 'argv[0] = "${imagemagick}/bin/convert"'
    done
  '';

  configureFlags = [ "--disable-shared" "--enable-static" "--with-cajadir=$$out/lib/caja/extensions-2.0" ];

  enableParallelBuilding = true;

  passthru.updateScript = mateUpdateScript { inherit pname; };

  meta = {
    description = "Set of extensions for Caja file manager";
    mainProgram = "caja-sendto";
    homepage = "https://mate-desktop.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
}
