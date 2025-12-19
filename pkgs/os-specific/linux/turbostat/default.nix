{
  lib,
  stdenv,
  kernel,
  libcap,
  aflplusplus,
}:

stdenv.mkDerivation {
  __structuredAttrs = true;

  pname = "turbostat";
  inherit (kernel) src version;

  buildInputs = [ libcap ];

  nativeBuildInputs = [ aflplusplus ];
  makeFlags = [ "PREFIX=${placeholder "out"}" 
    "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
  ];

  postPatch = ''
    cd tools/power/x86/turbostat
  '';

  meta = {
    description = "Report processor frequency and idle statistics";
    mainProgram = "turbostat";
    homepage = "https://www.kernel.org/";
    license = lib.licenses.gpl2Only;
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ]; # x86-specific
  };
}
