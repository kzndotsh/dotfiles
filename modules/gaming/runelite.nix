# RuneLite (OSRS). https://github.com/runelite/runelite
#
# Belt-and-suspenders AWT env for Sway. Do not force --scale=2 — output scale
# 2.0 already scales XWayland. Run `runelite-configure` once if the sidebar is
# too small (writes ~/.runelite). Window rules live in desktop/sway/.
{ config, lib, pkgs, ... }:
let
  cfg = config.gaming;
  runeliteBin = lib.getExe pkgs.runelite;
  wrapper = pkgs.writeShellScriptBin "runelite" ''
    export _JAVA_AWT_WM_NONREPARENTING=1
    exec ${runeliteBin} "$@"
  '';
  configure = pkgs.writeShellScriptBin "runelite-configure" ''
    export _JAVA_AWT_WM_NONREPARENTING=1
    exec ${runeliteBin} --configure "$@"
  '';
  configureDesktop = pkgs.makeDesktopItem {
    name = "RuneLite-configure";
    desktopName = "RuneLite (configure)";
    comment = "RuneLite launcher settings (scale, JVM args, hardware accel)";
    exec = "runelite-configure";
    icon = "runelite";
    categories = [ "Game" "Settings" ];
    startupNotify = false;
  };
  runelite = pkgs.symlinkJoin {
    name = "runelite";
    paths = [
      wrapper
      configure
      configureDesktop
      pkgs.runelite
    ];
    postBuild = ''
      rm -f $out/bin/runelite
      cp ${wrapper}/bin/runelite $out/bin/runelite
    '';
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.runelite.enable) {
    environment.systemPackages = [ runelite ];
  };
}
