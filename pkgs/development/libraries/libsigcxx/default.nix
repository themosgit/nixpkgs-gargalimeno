{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  meson,
  ninja,
  gnome,
  aflplusplus,
}:

stdenv.mkDerivation rec {
  __structuredAttrs = true;

  pname = "libsigc++";
  version = "2.12.1";

  src = fetchurl {
    url = "mirror://gnome/sources/libsigc++/${lib.versions.majorMinor version}/libsigc++-${version}.tar.xz";
    sha256 = "sha256-qdvuMjNR0Qm3ruB0qcuJyj57z4rY7e8YUfTPNZvVCEM=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ pkg-config
    meson
    ninja aflplusplus ];
  preConfigure = ''
    export CC="${aflplusplus}/bin/afl-clang-lto"
    export CXX="${aflplusplus}/bin/afl-clang-lto++"
  '';


  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "libsigc++";
      attrPath = "libsigcxx";
      versionPolicy = "odd-unstable";
      freeze = "2.99.1";
    };
  };

  meta = {
    homepage = "https://libsigcplusplus.github.io/libsigcplusplus/";
    description = "Typesafe callback system for standard C++";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.all;
  };
}
