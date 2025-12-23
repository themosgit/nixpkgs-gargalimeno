{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
  libxcb,
  xorg,
  aflplusplus,
  libllvm,
}:

let
  libXau-static = xorg.libXau.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ [ "--enable-static" ];
    dontDisableStatic = true;
  });

  libXdmcp-static = xorg.libXdmcp.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ [ "--enable-static" ];
    dontDisableStatic = true;
  });

  libxcb-static = (libxcb.override {
    libxau = libXau-static;
    libxdmcp = libXdmcp-static;
  }).overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ [ "--enable-static" ];
    dontDisableStatic = true;
  });
in
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
    libxcb-static
    libXau-static
    libXdmcp-static
    perl
  ];

  preBuild = ''
    export LD="${aflplusplus}/bin/afl-ld-lto"
    export AFL_LLVM_CMPLOG=1
    # ENABLE sanitizers for bug detection
    export AFL_USE_ASAN=1
    export AFL_USE_UBSAN=1
    # Suppress leak detection during build (bootstrap may leak)
    export ASAN_OPTIONS="detect_leaks=0"
  '';

  makeFlags = [
    "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
    "LD=${aflplusplus}/bin/afl-ld-lto"
    "AR=${libllvm}/bin/llvm-ar"
    "RANLIB=${libllvm}/bin/llvm-ranlib"
    "AS=${libllvm}/bin/llvm-as"
    "CFLAGS=-static-libsan -DVERSION=\\\"${version}\\\" -D_GNU_SOURCE -Wno-error"
    "CXXFLAGS=-static-libsan -DVERSION=\\\"${version}\\\" -D_GNU_SOURCE -Wno-error"
    "LDFLAGS=-static-libsan ${libxcb-static}/lib/libxcb.a ${libxcb-static}/lib/libxcb-xinerama.a ${libxcb-static}/lib/libxcb-randr.a ${libXau-static}/lib/libXau.a ${libXdmcp-static}/lib/libXdmcp.a"
  ];

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
