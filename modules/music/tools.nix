# Studio utilities (not DAWs). Gated on music.tools.enable.
#
# Already on PATH from other modules — do not duplicate here:
#   pw-cli / pw-top / pw-record → pipewire
#   ffmpeg → modules/packages
#
# Tenacity is the Audacity fork after the trademark split.
# Carla (KXStudio) hosts LV2/VST/LADSPA standalone — no CLAP support.
# jack_capture records JACK/PipeWire-JACK ports (pw-record is the native PipeWire tool).
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
      # Editing and analysis tools.
      tenacity
      spek
      sox

      # Hosts and routing utilities.
      carla
      pavucontrol # per-app levels; qpwgraph (default.nix) is the graph view

      # Audio capture tools.
      jack_capture

      # MIDI utilities.
      qmidiarp
      kmidimon

      # ALSA debugging helpers.
      alsa-utils # aplay -l, speaker-test
    ];
  };
}
