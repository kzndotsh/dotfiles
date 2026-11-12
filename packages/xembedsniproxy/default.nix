{
  lib,
  stdenv,
  cmake,
  kdePackages,
  qt6,
  libx11,
  libxtst,
  libxcb,
  libxcb-image,
  libxcb-util,
  libxcb-wm,
}:

# KDE xembedsniproxy built alone from the plasma-workspace source (not the ~490 MB
# plasma-workspace closure), patched for Java AWT tray icons.
stdenv.mkDerivation {
  pname = "xembedsniproxy";
  inherit (kdePackages.plasma-workspace) version src;

  patches = [ ./awt-tray-icons.patch ];

  postPatch = ''
    cp ${./CMakeLists.txt} CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    kdePackages.kcoreaddons
    kdePackages.kcrash
    kdePackages.kdbusaddons
    kdePackages.kwindowsystem
    libx11
    libxtst
    libxcb
    libxcb-image
    libxcb-util
    libxcb-wm
  ];

  cmakeFlags = [ (lib.cmakeFeature "WORKSPACE_VERSION" kdePackages.plasma-workspace.version) ];

  meta = {
    description = "XEmbed to StatusNotifierItem tray proxy (KDE), patched for AWT icons";
    homepage = "https://invent.kde.org/plasma/plasma-workspace";
    license = lib.licenses.gpl2Plus;
    mainProgram = "xembedsniproxy";
    platforms = lib.platforms.linux;
  };
}
