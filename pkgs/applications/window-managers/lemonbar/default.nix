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
  pname = "lemonbar";
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
    # CRITICAL: Use 'unset' to disable sanitizers, NOT =0
    # AFL++ treats any set value (even =0) as enabling sanitizers
    unset AFL_USE_ASAN
    unset AFL_USE_UBSAN
  '';

  makeFlags = [
    "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
    "LD=${aflplusplus}/bin/afl-ld-lto"
    "AR=${libllvm}/bin/llvm-ar"
    "RANLIB=${libllvm}/bin/llvm-ranlib"
    "AS=${libllvm}/bin/llvm-as"
    "CFLAGS=-DVERSION=\\\"${version}\\\" -D_GNU_SOURCE -Wno-error"
    "CXXFLAGS=-DVERSION=\\\"${version}\\\" -D_GNU_SOURCE -Wno-error"
    "LDFLAGS=${libxcb-static}/lib/libxcb.a ${libxcb-static}/lib/libxcb-xinerama.a ${libxcb-static}/lib/libxcb-randr.a ${libXau-static}/lib/libXau.a ${libXdmcp-static}/lib/libXdmcp.a"
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
