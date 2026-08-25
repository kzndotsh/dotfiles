# Studio utilities (not DAWs). Gated on music.tools.enable.
#
# Already on PATH from other modules — do not duplicate:
#   pw-cli / pw-top / pw-record → pipewire
#   ffmpeg → modules/packages
#
# Tenacity is the Audacity fork after the trademark split:
#   https://tenacityaudio.org/
# Carla (KXStudio) hosts LV2/VST/LADSPA standalone — no CLAP:
#   https://kx.studio/Applications:Carla
# jack_capture records JACK/PipeWire-JACK ports (pw-record is the native PW tool).
{ config, lib, pkgs, ... }:
let
  cfg = config.music;
in
{
  options.music.tools = {
    enable = lib.mkEnableOption "audio tools (Carla, Tenacity, sox, MIDI utilities, etc.)";
  };

  config = lib.mkIf (cfg.enable && cfg.tools.enable) {
    environment.systemPackages = with pkgs; [
      # Edit / analyse
      tenacity
      spek
      sox

      # Host / route
      carla
      pavucontrol # per-app levels; qpwgraph (default.nix) is the graph

      # Capture
      jack_capture

      # MIDI
      qmidiarp
      kmidimon

      # ALSA debug
      alsa-utils # aplay -l, speaker-test
    ];
  };
}
