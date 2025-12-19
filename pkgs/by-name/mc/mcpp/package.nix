{
  lib,
  stdenv,
  fetchFromGitHub,
  aflplusplus,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mcpp";
  version = "2.7.2.2";

  src = fetchFromGitHub {
    owner = "museoa";

  nativeBuildInputs = [ aflplusplus ];
    repo = "mcpp";
    rev = finalAttrs.version;
    hash = "sha256-wz225bhBF0lFerOAhl8Rwmw8ItHd9BXQceweD9BqvEQ=";
  };

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  };

  patches = [
    ./readlink.patch
  ];

  configureFlags = [ "--enable-mcpplib" 
    "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
  ];

  meta = {
    homepage = "https://github.com/museoa/mcpp";
    description = "Matsui's C preprocessor";
    mainProgram = "mcpp";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
