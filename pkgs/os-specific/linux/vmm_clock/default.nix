{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
  aflplusplus,
}:

stdenv.mkDerivation rec {
  __structuredAttrs = true;

  pname = "vmm_clock";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "voutilad";

  nativeBuildInputs = [ aflplusplus ];
  makeFlags = [
    "CC=${aflplusplus}/bin/afl-clang-lto"
    "CXX=${aflplusplus}/bin/afl-clang-lto++"
  ];

    repo = "vmm_clock";
    rev = version;
    hash = "sha256-XYRxrVixvImxr2j3qxBcv1df1LvPRKqKKgegW3HqUcQ=";
  };

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  extraConfig = ''
    CONFIG_RTC_HCTOSYS yes
  '';

  makeFlags = kernelModuleMakeFlags ++ [
    "DEPMOD=echo"
    "INSTALL_MOD_PATH=$(out)"
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
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
