# RisuAI — local character-chat UI (SillyTavern alternative) via Docker on :6001.
#
# Pattern matches ComfyUI / voice: oci-containers + Docker backend from modules/ai/default.nix.
# Upstream: https://github.com/kwaroran/RisuAI (ghcr.io/kwaroran/risuai, docker-compose port 6001).
#
# Enable (hosts/desktop/configuration.nix):
#   ai.risuai.enable = true;
#
# Launch after `nh os switch ~/dotfiles` (do not run switch unless Logan asks):
#   systemctl start docker-risuai
#   → http://127.0.0.1:6001
#
# Stop:
#   systemctl stop docker-risuai
#
# Point at local Ollama (UI settings — no Nix keys inventable here):
#   Model picker → Ollama (local) / model id `ollama-hosted`
#   Ollama URL → http://127.0.0.1:11434
#   Ollama Model → a tag from `ollama list` (e.g. gemmasutra-9b)
# Alternate: custom / reverse_proxy OpenAI-compatible URL
#   http://127.0.0.1:11434/v1/chat/completions (or base …/v1) with any placeholder key.
# Browser talks to Ollama on the host; localhost is correct. If fetch fails with CORS,
# add OLLAMA_ORIGINS for http://127.0.0.1:6001 (and http://localhost:6001) on ollama.service.
#
# TTS: RisuAI has built-in TTS later; can also reuse ai.voice (kokoro/fish) OpenAI-compatible
# endpoints once wiring is figured out in the UI — leave for a follow-up.
#
# Data: /var/lib/risuai → /app/save (upstream docker-compose volume risuai-save).
# Legal gate: prebuilt GHCR ignores VITE_RISU_LEGAL_CONFIGURED at runtime (Vite).
# Build `risuai:local` via packages/risuai/build.sh for private self-host.
{ config, lib, ... }:
let
  cfg = config.ai.risuai;
in
{
  options.ai.risuai = {
    enable = lib.mkEnableOption "RisuAI Docker character-chat UI on :6001";

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Start docker-risuai at boot (default: on-demand like ComfyUI)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 6001;
      description = "Host port published to container :6001";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "risuai:local";
      description = "Local image from packages/risuai/build.sh (VITE_RISU_LEGAL_CONFIGURED=TRUE baked in). Rebuild after upstream updates.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/risuai";
      description = "Host bind for RisuAI save data (/app/save)";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root root -"
    ];

    virtualisation.oci-containers.containers.risuai = {
      inherit (cfg) image autoStart;
      ports = [ "127.0.0.1:${toString cfg.port}:6001" ]; # loopback only; desktop firewall allows all ports
      volumes = [ "${cfg.dataDir}:/app/save" ];
      # host-gateway kept for any server-side calls to host services; browser→Ollama still uses 127.0.0.1.
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
    };
  };
}
