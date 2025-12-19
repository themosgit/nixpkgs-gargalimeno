{
  lib,
  stdenv,
  kernel,
  aflplusplus,
}:

stdenv.mkDerivation {
  __structuredAttrs = true;

  pname = "intel-speed-select";
  inherit (kernel) src version;

  makeFlags = [ "bindir=${placeholder "out"}/bin" 
    "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
  ];

  postPatch = ''
    cd tools/power/x86/intel-speed-select
    sed -i 's,/usr,,g' Makefile
  '';

  meta = {
    description = "Tool to enumerate and control the Intel Speed Select Technology features";
    mainProgram = "intel-speed-select";
    homepage = "https://www.kernel.org/";
    license = lib.licenses.gpl2Only;
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ]; # x86-specific
    broken = kernel.kernelAtLeast "5.18";
  };
}
