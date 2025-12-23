{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
  libxcb,
  libXft,
  xorg,
  aflplusplus,
  libllvm,
  fontconfig,
  freetype,
  zlib,
  bzip2,
  libpng,
  expat,
  brotli,
}:

let

  libpng-static = libpng.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ [ "--enable-static" ];
    dontDisableStatic = true;
  });

  expat-static = expat.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ [ "--enable-static" ];
    dontDisableStatic = true;
  });

  freetype-static = freetype.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ [ "--enable-static" ];
    dontDisableStatic = true;
  });

  fontconfig-static = fontconfig.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ [ "--enable-static" ];
    dontDisableStatic = true;
  });

  libX11-static = xorg.libX11.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ [ "--enable-static" ];
    dontDisableStatic = true;
  });

  libXrender-static = xorg.libXrender.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ [ "--enable-static" ];
    dontDisableStatic = true;
  });

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

  libxft-static = libXft.overrideAttrs (old: {
    configureFlags = (old.configureFlags or []) ++ [ "--enable-static" ];
    dontDisableStatic = true;
  });
in
stdenv.mkDerivation rec {
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
    libxcb-static
    libX11-static
    libXrender-static
    libXau-static
    libXdmcp-static
    libxft-static
    freetype-static
    fontconfig-static
    zlib
    bzip2
    brotli
    libpng-static
    expat-static
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
    "CFLAGS=-static-libsan -Wno-error -DVERSION=\\\"${version}\\\" -D_GNU_SOURCE"
    "CXXFLAGS=-static-libsan -Wno-error -DVERSION=\\\"${version}\\\" -D_GNU_SOURCE"
    "LDFLAGS=-static-libsan ${libxft-static}/lib/libXft.a ${libXrender-static}/lib/libXrender.a ${fontconfig-static.lib}/lib/libfontconfig.a ${freetype-static}/lib/libfreetype.a ${libX11-static}/lib/libX11.a ${libX11-static}/lib/libX11-xcb.a ${libxcb-static}/lib/libxcb.a ${libxcb-static}/lib/libxcb-xinerama.a ${libxcb-static}/lib/libxcb-randr.a ${expat-static}/lib/libexpat.a ${libpng-static}/lib/libpng.a -L${brotli.lib}/lib -lbrotlidec -L${bzip2.out}/lib -lbz2 -L${zlib}/lib -lz ${libXau-static}/lib/libXau.a ${libXdmcp-static}/lib/libXdmcp.a"
  ];

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
