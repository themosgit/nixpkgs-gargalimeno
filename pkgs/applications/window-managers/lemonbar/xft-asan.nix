{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
  libxcb,
  libXft,
  aflplusplus,
  libllvm,
}:

stdenv.mkDerivation {
  pname = "lemonbar-xft-asan";
  version = "unstable-2020-09-10";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "drscream";
    repo = "lemonbar-xft";
    rev = "481e12363e2a0fe0ddd2176a8e003392be90ed02";
    sha256 = "sha256-BNYBbUouqqsRQaPkpg+UKg62IV9uI34gKJuiAM94CBU=";
  };

  nativeBuildInputs = [ aflplusplus libllvm ];

  buildInputs = [
    libxcb
    libXft
    perl
  ];

  preConfigure = ''
    export LD="${aflplusplus}/bin/afl-ld-lto"
  '';

  makeFlags = [
    "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clnag-lto++"
    "LD=${aflplusplus}/bin/afl-ld-lto"
    "AR=${libllvm}/bin/llvm-ar"
    "RANLIB=${libllvm}/bin/llvm-ranlib"
    "AS=${libllvm}/bin/llvm-as"
    "AFL_LLVM_CMPLOG=1"
    "AFL_USE_ASAN=1"
    "AFL_USE_UBSAN=1"
    "CFLAGS=-Wno-error"
    "CXXFLAGS=-Wno-error"
  ];

  configureFlags = [ "--disable-shared" "--enable-static" ];

  installFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  meta = {
    description = "Lightweight xcb based bar with XFT-support";
    mainProgram = "lemonbar";
    homepage = "https://github.com/drscream/lemonbar-xft";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ moni ];
  };
}
