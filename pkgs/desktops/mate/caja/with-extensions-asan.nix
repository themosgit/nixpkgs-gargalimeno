{
  stdenv,
  lib,
  glib,
  wrapGAppsHook3,
  xorg,
  caja-asan,
  cajaExtensions,
  extensions ? [ ],
  useDefaultExtensions ? true,
}:

let
  selectedExtensions = extensions ++ (lib.optionals useDefaultExtensions cajaExtensions);
in
stdenv.mkDerivation {
  pname = "${caja-asan.pname}-with-extensions";
  inherit (caja-asan) version outputs;

  src = null;

  nativeBuildInputs = [
    glib
    wrapGAppsHook3
    xorg.lndir
  ];

  buildInputs =
    lib.forEach selectedExtensions (x: x.buildInputs)
    ++ selectedExtensions
    ++ [ caja-asan ]
    ++ caja-asan.buildInputs;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  preferLocalBuild = true;
  allowSubstitutes = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    lndir -silent ${caja-asan.out} $out
    lndir -silent ${caja-asan.man} $out

    dbus_service_path="share/dbus-1/services/org.mate.freedesktop.FileManager1.service"
    rm -f $out/share/applications/* "$out/$dbus_service_path"
    for file in ${caja-asan}/share/applications/*; do
      substitute "$file" "$out/share/applications/$(basename $file)" \
        --replace-fail "${caja-asan}" "$out"
    done
    substitute "${caja-asan}/$dbus_service_path" "$out/$dbus_service_path" \
      --replace-fail "${caja-asan}" "$out"

    runHook postInstall
  '';

  preFixup = lib.optionalString (selectedExtensions != [ ]) ''
    gappsWrapperArgs+=(
      --set CAJA_EXTENSION_DIRS ${
        lib.concatMapStringsSep ":" (x: "${x.outPath}/lib/caja-asan/extensions-2.0") selectedExtensions
      }
    )
  '';

  inherit (caja-asan) meta;
}
