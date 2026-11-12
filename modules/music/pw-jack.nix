# pw-jack per package: JACK clients load PipeWire's libjack through their own LD_LIBRARY_PATH,
# instead of services.pipewire.jack.enable exporting it to every process (deprecated upstream).
{ pkgs, jack }:
pkg:
pkgs.symlinkJoin {
  name = "${pkg.pname or (pkgs.lib.getName pkg)}-pw-jack";
  paths = [ pkg ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    for b in "$out"/bin/*; do
      wrapProgram "$b" --prefix LD_LIBRARY_PATH : ${jack}/lib
    done
    # Launchers with absolute Exec= paths would skip the wrapper.
    for d in "$out"/share/applications/*.desktop; do
      [ -e "$d" ] || continue
      if grep -q "${pkg}/bin" "$d"; then
        src=$(readlink -f "$d")
        rm "$d"
        sed "s|${pkg}/bin|$out/bin|g" "$src" > "$d"
      fi
    done
  '';
  inherit (pkg) meta;
}
