# MangoHud overlay — Tokyo Night colours.
# https://github.com/flightlessmango/MangoHud
#
# GPU stats need kernel.perf_event_paranoid <= 1 (boot/sysctl.nix sets 3).
# https://docs.kernel.org/admin-guide/sysctl/kernel.html#perf-event-paranoid
#
# Steam: mangohud %command%  or  gamemoderun mangohud %command%
# Gamescope: --mangoapp, not mangohud
# Test: mangohud vkcube
{ config, lib, pkgs, ... }:
let
  cfg = config.gaming;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mangohud ];

    environment.etc."xdg/MangoHud/MangoHud.conf".text = ''
      gpu_stats
      cpu_stats
      fps
      frametime
      gpu_temp
      gpu_core_clock
      gpu_mem_clock
      vram
      position=top-left
      toggle_hud=Shift_R+F12
      font_size=20
      font_glyph_ranges=0x0020-0x00FF
      background_alpha=0.4
      gpu_color=FFFFFF
      cpu_color=BB9AF7
      fps_color=7AA2F7
      frametime_color=9ECE6A
      gpu_temp_color=F7768E
      vram_color=FF9E64
    '';

    system.userActivationScripts.mangohud-link.text = ''
      mkdir -p $HOME/.config/MangoHud
      ln -sfn /etc/xdg/MangoHud/MangoHud.conf $HOME/.config/MangoHud/MangoHud.conf
    '';

    boot.kernel.sysctl."kernel.perf_event_paranoid" = lib.mkForce 1;
  };
}
