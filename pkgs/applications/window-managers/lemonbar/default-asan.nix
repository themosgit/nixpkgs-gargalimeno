{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
  libxcb,
  aflplusplus,
  libllvm,
}:

stdenv.mkDerivation rec {
  pname = "lemonbar-asan";
  version = "1.5";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "LemonBoy";
    repo = "bar";
    rev = "v${version}";
    sha256 = "sha256-OLhgu0kmMZhjv/VST8AXvIH+ysMq72m4TEOypdnatlU=";
  };

  nativeBuildInputs = [ aflplusplus libllvm ];

  buildInputs = [
    libxcb
    perl
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
    description = "Lightweight xcb based bar";
    homepage = "https://github.com/LemonBoy/bar";
    maintainers = with lib.maintainers; [
      meisternu
      moni
    ];
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "lemonbar";
  };
}
