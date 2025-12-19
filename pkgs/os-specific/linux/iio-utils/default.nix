{
  lib,
  stdenv,
  kernel,
  aflplusplus,
}:

stdenv.mkDerivation {
  __structuredAttrs = true;

  pname = "iio-utils";
  inherit (kernel) src version;

  makeFlags = [ "bindir=${placeholder "out"}/bin" 
    "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
  ];

  postPatch = ''
    cd tools/iio
  '';

  meta = {
    description = "Userspace tool for interacting with Linux IIO";
    homepage = "https://www.kernel.org/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
