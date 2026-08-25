# Session Desktop blocks suspend on Linux by spawning systemd-inhibit --what=idle … sleep infinity.
# Crashes leave orphan inhibitors that break swayidle. Upstream skips this when
# SESSION_ALLOW_APP_SUSPENSION is set (see power_saver_inhibitor.js).
{ lib, pkgs }:
let
  # nixpkgs marks session-desktop broken (pnpm lock / tarball integrity). Keep the wrapper
  # ready for when upstream fixes it — not in systemPackages until then.
  sessionDesktop = pkgs.session-desktop.overrideAttrs (old: {
    meta = lib.filterAttrs (n: n != "broken") old.meta;
  });
in
pkgs.symlinkJoin {
  name = "session-desktop";
  paths = [ sessionDesktop ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/session-desktop \
      --set SESSION_ALLOW_APP_SUSPENSION 1
  '';
}
