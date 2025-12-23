{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
  aflplusplus,
  libllvm
}:

stdenv.mkDerivation rec {
  pname = "vmm_clock";
  version = "0.2.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "voutilad";
    repo = "vmm_clock";
    rev = version;
    hash = "sha256-XYRxrVixvImxr2j3qxBcv1df1LvPRKqKKgegW3HqUcQ=";
  };

  hardeningDisable = [
    "pic"
    "format"
  ];

  nativeBuildInputs = [
    aflplusplus
    libllvm
    kernel.moduleBuildDependencies
  ];

  preBuild = ''
    export AFL_DONT_OPTIMIZE=1
    export AFL_NOOPT=1
    export AFL_USE_ASAN=0
    export AFL_USE_UBSAN=0
  '';

  buildPhase = ''
    runHook preBuild

    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      CC="${aflplusplus}/bin/afl-gcc-fast" \
      DEPMOD=echo \
      INSTALL_MOD_PATH=$out \
      KERNELRELEASE=${kernel.modDirVersion} \
      EXTRA_CFLAGS="-Wno-error" \
      modules

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      DEPMOD=echo \
      INSTALL_MOD_PATH=$out \
      KERNELRELEASE=${kernel.modDirVersion} \
      modules_install

    runHook postInstall
  '';

  extraConfig = ''
    CONFIG_RTC_HCTOSYS yes
  '';

  configureFlags = [
    "--disables-shared"
    "--enable-static"
  ];

  meta = {
    description = "Experimental implementation of a kvmclock-derived clocksource for Linux guests under OpenBSD's hypervisor";
    homepage = "https://github.com/voutilad/vmm_clock";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ qbit ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };

  enableParallelBuilding = true;
}
