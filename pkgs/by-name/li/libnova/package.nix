{
  lib,
  stdenv,
  fetchgit,
  autoreconfHook,
  aflplusplus,
}:

stdenv.mkDerivation rec {
  __structuredAttrs = true;

  pname = "libnova";
  version = "0.16";

  # pull from git repo because upstream stopped tarball releases after v0.15
  src = fetchgit {
    url = "https://git.code.sf.net/p/libnova/${pname}";
    rev = "v${version}";
    sha256 = "0icwylwkixihzni0kgl0j8dx3qhqvym6zv2hkw2dy6v9zvysrb1b";
  };

  nativeBuildInputs = [ autoreconfHook aflplusplus ];
  configureFlags = [
    "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
  ];


  meta = {
    description = "Celestial Mechanics, Astrometry and Astrodynamics Library";
    mainProgram = "libnovaconfig";
    homepage = "http://libnova.sf.net";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [
      returntoreality
    ];
    platforms = lib.platforms.unix;
  };
}
