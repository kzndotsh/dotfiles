# Native Linux plugins installed to /run/current-system/sw/lib/{lv2,vst3,clap,ladspa,…}.
# Discovery paths are set in default.nix. Full catalog is in AGENTS.md in this directory.
#
# Vendor Linux builds (u-he, TAL, Pianoteq, Arturia): extract to ~/.vst3 or ~/.lv2, then rescan.
{ config, lib, pkgs, ... }:
let
  cfg = config.music;
in
{
  options.music.plugins = {
    synths.enable = lib.mkEnableOption "synthesizer plugins (Surge XT, Vital, Cardinal, etc.)";
    effects.enable = lib.mkEnableOption "effect plugins (LSP, Airwindows, ChowTape, etc.)";
    drums.enable = lib.mkEnableOption "drum machines, samplers, and beat tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.flatten [
      # Software synthesizers.
      (lib.optionals cfg.plugins.synths.enable (with pkgs; [
        surge-xt
        vital
        cardinal
        odin2
        zynaddsubfx
        bespokesynth
        dexed
        sorcer
        vaporizer2
        opnplug
        distrho-ports
        sfizz
      ]))

      # Audio effects plugins.
      (lib.optionals cfg.plugins.effects.enable (with pkgs; [
        lsp-plugins
        zam-plugins
        calf
        chow-tape-model
        fire
        wolf-shaper
        dragonfly-reverb
        aether-lv2
        magnetophonDSP.RhythmDelay
        airwindows-lv2
        x42-plugins
        noise-repellent
        gate12
        bshapr
      ]))

      # Drum machines and samplers.
      (lib.optionals cfg.plugins.drums.enable (with pkgs; [
        hydrogen
        geonkick
        drumkv1
        ninjas2
        mod-arpeggiator-lv2
      ]))
    ];
  };
}
