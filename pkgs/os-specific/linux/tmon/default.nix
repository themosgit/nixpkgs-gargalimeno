{
  lib,
  stdenv,
  kernel,
  ncurses,
  aflplusplus,
}:

stdenv.mkDerivation {
  __structuredAttrs = true;

  pname = "tmon";
  version = kernel.version;

  inherit (kernel) src;

  buildInputs = [ ncurses ];

  nativeBuildInputs = [ aflplusplus ];

  configurePhase = ''
    cd tools/thermal/tmon
  '';

  makeFlags = [
    "ARCH=${stdenv.hostPlatform.linuxArch}"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "INSTALL_ROOT=\"$(out)\""
    "BINDIR=bin"
      "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
  ];
  NIX_CFLAGS_LINK = "-lgcc_s";

  enableParallelBuilding = true;

  meta = {
    description = "Monitoring and Testing Tool for Linux kernel thermal subsystem";
    mainProgram = "tmon";
    homepage = "https://www.kernel.org/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
