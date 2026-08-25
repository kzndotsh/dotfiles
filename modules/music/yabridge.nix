# yabridge — Windows VST2/VST3/CLAP inside Linux DAWs via Wine.
# https://github.com/robbert-vdh/yabridge
# https://yabridge.org/
#
# Needs wine-tkg (this repo: `wine.enable` → nix-gaming wine-tkg + ntsync).
# Do not use a fshack wine-tkg profile — it breaks D3D plugin UIs (upstream README).
#
# Workflow:
#   1. wine /path/to/installer.exe          # into ~/.wine (or another prefix)
#   2. yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/VST3"
#   3. yabridgectl sync                     # shims in ~/.vst ~/.vst3 ~/.clap
#   4. rescan in the DAW
#
# Host matrix (upstream): Bitwig/REAPER full VST2/VST3/CLAP; Ardour has no CLAP;
# Carla has no CLAP. Native plugins in plugins.nix are preferred when they exist.
#
# FL Studio does not need this — Windows VSTs load in ~/.wine-flstudio directly.
{ config, lib, pkgs, ... }:
let
  cfg = config.music;
in
{
  options.music.yabridge = {
    enable = lib.mkEnableOption "yabridge (Windows VST2/VST3/CLAP bridge via Wine)";
  };

  config = lib.mkIf (cfg.enable && cfg.yabridge.enable) {
    wine.enable = lib.mkDefault true;

    environment.systemPackages = with pkgs; [
      yabridge
      yabridgectl
    ];
  };
}
