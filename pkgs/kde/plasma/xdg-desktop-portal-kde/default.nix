{
  mkKdeDerivation,
  pkg-config,
  qtwayland,
  cups,
  aflplusplus,
}:
mkKdeDerivation {
  pname = "xdg-desktop-portal-kde";

  extraNativeBuildInputs = [ pkg-config ];
  extraBuildInputs = [
    qtwayland
    cups
  ];
}
