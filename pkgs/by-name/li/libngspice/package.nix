{
  lib,
  stdenv,
  fetchurl,
  flex,
  bison,
  fftw,
  withNgshared ? true,
  libXaw,
  libXext,
  llvmPackages,
  readline,
  aflplusplus,
}:

stdenv.mkDerivation rec {
  __structuredAttrs = true;

  pname = "${lib.optionalString withNgshared "lib"}ngspice";
  version = "45";

  src = fetchurl {
    url = "mirror://sourceforge/ngspice/ngspice-${version}.tar.gz";
    hash = "sha256-8arYq6woKKe3HaZkEd6OQGUk518wZuRnVUOcSQRC1zQ=";
  };

  nativeBuildInputs = [ flex
    bison aflplusplus ];
  configureFlags = [
    "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
  ];


  buildInputs = [
    fftw
    readline
  ]
  ++ lib.optionals (!withNgshared) [
    libXaw
    libXext
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    llvmPackages.openmp
  ];

  configureFlags =
    lib.optionals withNgshared [
      "--with-ngshared"
    ]
    ++ [
      "--enable-xspice"
      "--enable-cider"
      "--enable-osdi"
    ];

  enableParallelBuilding = true;

  meta = {
    description = "Next Generation Spice (Electronic Circuit Simulator)";
    mainProgram = "ngspice";
    homepage = "http://ngspice.sourceforge.net";
    license = with lib.licenses; [
      bsd3
      gpl2Plus
      lgpl2Plus
    ]; # See https://sourceforge.net/p/ngspice/ngspice/ci/master/tree/COPYING
    maintainers = with lib.maintainers; [ bgamari ];
    platforms = lib.platforms.unix;
  };
}
