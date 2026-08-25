# Native Linux DAWs. FL Studio (Wine) is in ./flstudio.nix.
#
# Bitwig 6 — VST2/VST3/CLAP, no LV2. Co-developed CLAP.
#   Default on Sway is XWayland; BITWIG_WAYLAND=1 is experimental.
#   BITWIG_DISABLE_VULKAN=1 if AMD GPU plugin windows crash.
#
# REAPER 7 — VST2/VST3/CLAP/LV2/JSFX. Does not read VST_PATH / VST3_PATH / CLAP_PATH.
#   Add paths by hand: Options → Preferences → VST → path list
#     /run/current-system/sw/lib/{vst3,vst,clap}  ~/.vst3 ~/.vst ~/.clap
#   SWS extension included.
#
# Ardour 9 — LV2/VST2/VST3/LADSPA, reads env vars. No CLAP (upstream: no per-note modulation benefit vs LV2).
#   Native PipeWire backend; JACK via PipeWire also works.
#
# LMMS 1.2.2 — VST2 + LADSPA only (1.3 still not in nixpkgs).
#   Qt5 build has no qtwayland → wrap to xcb (XWayland). Prefer SDL or JACK, not Pulse (distortion).
#
# Zrythm 1.0 — LV2/VST2/VST3/CLAP/LADSPA/DSSI.
{ config, lib, pkgs, ... }:
let
  cfg = config.music;
in
{
  options.music.daw = {
    bitwig.enable = lib.mkEnableOption "Bitwig Studio (electronic production, modular, CLAP)";
    reaper.enable = lib.mkEnableOption "REAPER (flexible mixing/recording DAW)";
    ardour.enable = lib.mkEnableOption "Ardour (open-source recording/mastering, best LV2)";
    lmms.enable = lib.mkEnableOption "LMMS (free FL Studio-style beat making)";
    zrythm.enable = lib.mkEnableOption "Zrythm (modern FOSS DAW, all plugin formats)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.flatten [
      (lib.optional cfg.daw.bitwig.enable pkgs.bitwig-studio)
      (lib.optionals cfg.daw.reaper.enable [
        pkgs.reaper
        pkgs.reaper-sws-extension
      ])
      (lib.optional cfg.daw.ardour.enable pkgs.ardour)
      (lib.optional cfg.daw.lmms.enable (pkgs.lmms.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          wrapProgram $out/bin/lmms --set QT_QPA_PLATFORM xcb
        '';
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
      })))
      (lib.optional cfg.daw.zrythm.enable pkgs.zrythm)
    ];
  };
}
