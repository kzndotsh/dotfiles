{ appimageTools, fetchurl }:

let
  pname = "crankshaft";
  version = "2.0.1";

  src = fetchurl {
    url = "https://github.com/KraXen72/crankshaft/releases/download/${version}/crankshaft-x64.AppImage";
    sha256 = "1ld6kxh1n1ri15yf5jsxdjkzly0kk61piykkfag1adj8v9qa52h6";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageTools.extract { inherit pname version src; }}/crankshaft.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/crankshaft.desktop \
      --replace-warn 'Exec=AppRun' "Exec=$out/bin/${pname}"
  '';
}
