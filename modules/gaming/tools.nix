# GameMode, Gamescope, and optional capture wrapper.
#
# Gamescope per-game Steam launch examples (not global):
#   gamescope -W 2560 -H 1440 -r 144 -f -e -- %command%
#   gamescope -W 2560 -H 1440 -r 144 -f -e --mangoapp -- %command%
# Use --mangoapp inside Gamescope, not mangohud (see mangohud.nix).
#
# game-wrapper (optional): gamemoderun + mangohud + obs-vkcapture. No Zink — RADV is faster on this AMD GPU.
#
# Capture: OBS_VKCAPTURE=1 %command% or obs-vkcapture %command%
# On Sway also set OBS_USE_EGL=1 inside OBS.
{ config, lib, pkgs, ... }:
let
  cfg = config.gaming;
  # Unload resident Ollama models so CS2 isn't sharing VRAM/KFD with ROCm.
  # Needs `gamemoderun %command%` on the Steam title.
  unloadOllama = pkgs.writeShellScript "gamemode-unload-ollama" ''
    set -euo pipefail
    ps=$(${lib.getExe pkgs.curl} -sf --max-time 2 http://127.0.0.1:11434/api/ps) || exit 0
    echo "$ps" | ${lib.getExe pkgs.jq} -r '.models[]?.name // empty' | while IFS= read -r model; do
      [ -z "$model" ] && continue
      ${lib.getExe pkgs.curl} -sf --max-time 15 http://127.0.0.1:11434/api/generate \
        -H 'Content-Type: application/json' \
        -d "{\"model\":$(${lib.getExe pkgs.jq} -n --arg m "$model" '$m'),\"keep_alive\":0}" \
        >/dev/null || true
    done
  '';
in
{
  config = lib.mkIf cfg.enable {
    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
          ioprio = "high";
          inhibit_screensaver = 0; # Sway idle is handled in desktop/sway
        };
        cpu = {
          park_cores = "no";
          # 5800X: leave CPU 0 for the desktop; pin the rest to the game.
          pin_cores = "1-15";
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          # Needs hardware.amdgpu.overdrive.enable (modules/hardware).
          amd_performance_level = "high";
        };
        custom = {
          start = "${unloadOllama}";
          script_timeout = 30;
        };
      };
    };

    programs.gamescope = {
      enable = true;
      # capSysNice plus non-root Gamescope often fails to start on NixOS.
      capSysNice = false;
    };

    environment.systemPackages = with pkgs; [
      vulkan-tools
      vkbasalt
      steam-run
      libstrangle
    ]
    ++ lib.optionals cfg.streaming.enable [
      pkgs.obs-vkcapture
      pkgs.gpu-screen-recorder
      pkgs.easyeffects
    ]
    ++ lib.optionals cfg.steamtinkerlaunch.enable [ pkgs.steamtinkerlaunch ]
    ++ lib.optionals cfg.gameWrapper.enable [
      (pkgs.writeShellApplication {
        name = "game-wrapper";
        runtimeInputs = with pkgs; [ gamemode mangohud obs-vkcapture ];
        runtimeEnv = { OBS_VKCAPTURE = "1"; };
        text = ''
          exec gamemoderun mangohud obs-vkcapture "$@"
        '';
      })
    ];
  };
}
