{
  pkgs,
  lib,
  cmake,
  ninja,
  sphinx,
  python3Packages,
  aflplusplus,
}:

pkgs.stdenv.mkDerivation {
  __structuredAttrs = true;

  pname = "ckdl";
  version = "1.0";

  src = pkgs.fetchFromGitHub {
    owner = "tjol";
    repo = "ckdl";
    tag = "1.0";
    hash = "sha256-qEfRZzoUQZ8umdWgx+N4msjPBbuwDtkN1kNDfZicRjY=";
  };

  outputs = [
    "bin"
    "dev"
    "lib"
    "doc"
    "out"
  ];

  nativeBuildInputs = [ cmake
    ninja
    sphinx
    python3Packages.furo aflplusplus ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTS" true)
    "-DBUILD_SHARED_LIBS=OFF"
    "-DCMAKE_C_COMPILER=${aflplusplus}/bin/afl-clang-lto"
    "-DCMAKE_CXX_COMPILER=${aflplusplus}/bin/afl-clang-lto++"
  ];

  postPatch = ''
    cd doc
    make singlehtml
    mkdir -p $doc/share/doc
    mv _build/singlehtml $doc/share/doc/ckdl

    cd ..
  '';

  postInstall = ''
    mkdir -p $bin/bin

    # some tools that are important for debugging.
    # idk why they are not copied to bin by cmake, but I’m too tired to figure it out
    install src/utils/ckdl-tokenize $bin/bin
    install src/utils/ckdl-parse-events $bin/bin
    install src/utils/ckdl-cat $bin/bin
    touch $out
  '';

  meta = {
    description = "C library that implements reading and writing the KDL Document Language";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
