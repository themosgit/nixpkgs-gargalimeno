{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
  libxcb,
  libXft,
  aflplusplus,
}:

stdenv.mkDerivation {
  __structuredAttrs = true;

  pname = "lemonbar-xft";
  version = "unstable-2020-09-10";

  src = fetchFromGitHub {
    owner = "drscream";
    repo = "lemonbar-xft";
    rev = "481e12363e2a0fe0ddd2176a8e003392be90ed02";
    sha256 = "sha256-BNYBbUouqqsRQaPkpg+UKg62IV9uI34gKJuiAM94CBU=";
  };

  buildInputs = [
    libxcb
    libXft
    perl
  ];

  nativeBuildInputs = [ aflplusplus ];
  makeFlags = [
    "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
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
