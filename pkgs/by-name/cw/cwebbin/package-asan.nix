{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  tie,
  aflplusplus,
  libllvm,
}:

let
  cweb = fetchurl {
    url = "https://www.ctan.org/tex-archive/web/c_cpp/cweb/cweb-3.64ah.tgz";
    sha256 = "1hdzxfzaibnjxjzgp6d2zay8nsarnfy9hfq55hz1bxzzl23n35aj";
  };
in
stdenv.mkDerivation rec {
  pname = "cwebbin-asan";
  version = "22p";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ascherer";
    repo = "cwebbin";
    rev = "2016-05-20-22p";
    sha256 = "0zf93016hm9i74i2v384rwzcw16y3hg5vc2mibzkx1rzvqa50yfr";
  };

  prePatch = ''
    tar xf ${cweb}
  '';

  # Remove references to __DATE__ and __TIME__
  postPatch = ''
    substituteInPlace wmerg-patch.ch --replace ' ("__DATE__", "__TIME__")' ""
    substituteInPlace ctang-patch.ch --replace ' ("__DATE__", "__TIME__")' ""
    substituteInPlace ctangle.cxx --replace ' ("__DATE__", "__TIME__")' ""
    substituteInPlace cweav-patch.ch --replace ' ("__DATE__", "__TIME__")' ""
  '';

  nativeBuildInputs = [ tie aflplusplus libllvm ];

  makefile = "Makefile.unix";

  preBuild = ''
    export LD="${aflplusplus}/bin/afl-ld-lto"
    export AFL_LLVM_CMPLOG=1
    # ENABLE sanitizers for bug detection
    export AFL_USE_ASAN=1
    export AFL_USE_UBSAN=1
    # Suppress leak detection during build (bootstrap binaries may leak)
    export ASAN_OPTIONS="detect_leaks=0"
  '';

  makeFlags = [
    "MACROSDIR=$(out)/share/texmf/tex/generic/cweb"
    "CWEBINPUTS=$(out)/lib/cweb"
    "DESTDIR=$(out)/bin/"
    "MANDIR=$(out)/share/man/man1"
    "EMACSDIR=$(out)/share/emacs/site-lisp"
    "CP=cp"
    "RM=rm"
    "PDFTEX=echo"
    # AFL++ LTO instrumentation with ASAN+UBSAN and preserved application flags
    "CC=${aflplusplus}/bin/afl-clang-lto++ -static-libsan -O3 -I./catalogs -W -Wall -Wno-error -Wno-register"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
    "LD=${aflplusplus}/bin/afl-ld-lto"
    "LINKFLAGS=-s -static-libsan"
    "AR=${libllvm}/bin/llvm-ar"
    "RANLIB=${libllvm}/bin/llvm-ranlib"
    "AS=${libllvm}/bin/llvm-as"
  ];

  buildFlags = [
    "boot"
    "cautiously"
  ];

  preInstall = ''
    mkdir -p $out/share/man/man1 $out/share/texmf/tex/generic $out/share/emacs $out/lib
  '';

  meta = {
    inherit (src.meta) homepage;
    description = "Literate Programming in C/C++ (ASAN+UBSAN instrumented)";
    platforms = with lib.platforms; unix;
    maintainers = [ ];
    license = lib.licenses.abstyles;
  };
}
