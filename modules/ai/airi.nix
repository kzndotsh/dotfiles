# AIRI Stage Web — self-hosted Neuro-sama-style companion (Live2D/VRM + realtime voice).
# Image: airi:local via packages/airi/build.sh (static nginx UI on container :80).
# GHCR ghcr.io/moeru-ai/airi:latest is pull-denied without auth as of 2026-09.
#
# LLM/TTS/STT are configured in the browser (localStorage), not via container env —
# the page runs on the host browser and talks to localhost Ollama / fish / OpenRouter.
#
# Port 6100 — avoids Risu :6001, fish :8849, Open WebUI :4000, qBittorrent :8080.
#
# Desktop Electron (overlay / voice): extracted .deb + packages/airi/fhs.nix
# (`nix run github:moeru-ai/airi` fails — see packages/airi/AGENTS.md).
# Desktop is preferred for voice/overlay; this Docker path is secondary (browser access only).
{ config, lib, ... }:
let
  cfg = config.ai.airi;
in
{
  options.ai.airi = {
    enable = lib.mkEnableOption "AIRI Stage Web companion (Docker / oci-containers)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 6100;
      description = "Host port mapped to nginx :80 inside the AIRI container";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "airi:local";
      description = "Local image from packages/airi/build.sh (GHCR latest currently needs auth)";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Start at boot. Default false — on-demand like ComfyUI / voice containers.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Expose the AIRI port beyond loopback (LAN). Default binds 127.0.0.1 only.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.airi = {
      inherit (cfg) image autoStart;
      ports = [
        (
          if cfg.openFirewall then "${toString cfg.port}:80"
          else "127.0.0.1:${toString cfg.port}:80"
        )
      ];
      # Stage Web is static assets only — no volume/env required for basic use.
      # Character/settings live in the browser profile (IndexedDB / localStorage).
      extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
