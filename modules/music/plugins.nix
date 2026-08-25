# Native Linux plugins → /run/current-system/sw/lib/{lv2,vst3,clap,ladspa,…}.
# Discovery: env vars in default.nix. Catalog: AGENTS.md in this directory.
#
# https://linuxdaw.org/
# https://lv2plug.in/
# https://cleveraudio.org/
# https://wiki.nixos.org/wiki/Audio_production
#
# Vendor Linux builds (u-he, TAL, Pianoteq, Arturia): extract to ~/.vst3 or ~/.lv2, rescan.
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
      # ─── Synths ────────────────────────────────────────────────────────
      (lib.optionals cfg.plugins.synths.enable (with pkgs; [
        surge-xt # hybrid; LV2/VST3/CLAP — https://surge-synthesizer.github.io/
        vital # wavetable (unfree) — https://vital.audio/
        cardinal # VCV Rack as plugin — https://cardinal.kx.studio/
        odin2 # analog-modeled + FM
        zynaddsubfx # additive / pads — https://zynaddsubfx.sourceforge.io/
        bespokesynth # modular environment
        dexed # DX7 FM
        sorcer # wavetable
        vaporizer2 # wavetable
        opnplug # YM2612 FM
        distrho-ports # Obxd, TAL-NoiseMaker, Vex — https://github.com/DISTRHO/DISTRHO-Ports
        sfizz # SFZ sampler — https://sfz.tools/sfizz/
      ]))

      # ─── Effects ───────────────────────────────────────────────────────
      (lib.optionals cfg.plugins.effects.enable (with pkgs; [
        lsp-plugins # EQ/comp/limiter — https://lsp-plug.in/
        zam-plugins # dynamics / tube — https://www.zamaudio.com/
        calf # filters, verb, delay — https://calf-studio-gear.org/
        chow-tape-model # tape sat — https://github.com/Chowdhury-DSP/ChowTapeModel
        fire # multiband distortion
        wolf-shaper # spline waveshaper
        dragonfly-reverb # hall/room/plate — https://github.com/michaelwillis/dragonfly-reverb
        aether-lv2 # Cloudseed-style verb
        magnetophonDSP.RhythmDelay
        airwindows-lv2 # https://www.airwindows.com/
        x42-plugins # meters, tuner — https://x42-plugins.com/
        noise-repellent
        gate12 # trance gate
        bshapr # beat / envelope shaper
      ]))

      # ─── Drums & samplers ──────────────────────────────────────────────
      (lib.optionals cfg.plugins.drums.enable (with pkgs; [
        hydrogen # pattern drum machine — http://hydrogen-music.org/
        geonkick # percussion synth — https://geonkick.org/
        drumkv1 # kit sampler
        ninjas2 # loop slicer
        mod-arpeggiator-lv2
      ]))
    ];
  };
}
