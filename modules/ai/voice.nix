# Voice catalog — STT/TTS. All on-demand (`autoStart = false`).
#
#   speaches    :8300  STT  CPU   docker-speaches
#   kokoro      :8880  TTS  CPU   docker-kokoro-tts
#   fish        :8849  TTS  cloud docker-fish-tts-proxy  (FISH_API_KEY in ai.env)
#   moss        :8851  TTS  CPU   docker-moss-tts        (image moss-tts-nano-fixed)
#   chatterbox  :8850  TTS  GPU   docker-chatterbox-tts  (fights Ollama)
#
# `enable` = systemd unit exists. Does not auto-start.
# Flip backends in hosts/desktop/configuration.nix (`ai.voice`).
# Open WebUI URLs come from `openWebui.stt` / `openWebui.tts` (must be enabled).
# Open WebUI is a native NixOS service, so catalog URLs use 127.0.0.1 (not host.docker.internal).
#
# No first-class NixOS services.speaches / kokoro — OCI containers only.
# https://wiki.nixos.org/wiki/Docker
# https://search.nixos.org/options?query=virtualisation.oci-containers.containers
{ config, lib, ... }:
let
  cfg = config.ai.voice;

  # Open WebUI AUDIO_*_OPENAI_API_BASE_URL wants the /v1 prefix (OpenAI SDK style).
  # https://docs.openwebui.com/features/chat-conversations/audio/speech-to-text/env-variables
  catalog = {
    # https://speaches.ai/usage/speech-to-text/
    speaches = {
      kind = "stt";
      url = "http://127.0.0.1:8300/v1";
      model = "Systran/faster-distil-whisper-small.en";
    };
    # https://github.com/remsky/Kokoro-FastAPI
    kokoro = {
      kind = "tts";
      url = "http://127.0.0.1:8880/v1";
      model = "kokoro";
    };
    # Proxy maps OpenAI /v1/audio/speech → Fish POST /v1/tts (model header).
    # https://docs.fish.audio/api-reference/endpoint/openapi-v1/text-to-speech
    fish = {
      kind = "tts";
      url = "http://127.0.0.1:8849/v1";
      model = "s2.1-pro-free";
    };
    # Local image, not upstream `python app.py` (that is Gradio on :18083).
    # Upstream OpenAI path is vLLM-Omni, not this container.
    # https://github.com/OpenMOSS/MOSS-TTS-Nano
    moss = {
      kind = "tts";
      url = "http://127.0.0.1:8851/v1";
      model = "";
    };
    # https://github.com/devnen/Chatterbox-TTS-Server
    chatterbox = {
      kind = "tts";
      url = "http://127.0.0.1:8850/v1";
      model = "";
    };
  };

  mkEnable = name: default: lib.mkOption {
    type = lib.types.bool;
    inherit default;
    description = "Define the ${name} container (on-demand, not auto-start)";
  };
in
{
  options.ai.voice = {
    speaches.enable = mkEnable "speaches STT" true;
    kokoro.enable = mkEnable "kokoro TTS" true;
    fish.enable = mkEnable "Fish Audio TTS proxy" true;
    moss.enable = mkEnable "MOSS-TTS-Nano" false;
    chatterbox.enable = mkEnable "Chatterbox TTS (ROCm)" false;

    openWebui = {
      stt = lib.mkOption {
        type = lib.types.enum [ "speaches" ];
        default = "speaches";
        description = "STT backend Open WebUI uses";
      };
      tts = lib.mkOption {
        type = lib.types.enum [ "fish" "kokoro" "moss" "chatterbox" ];
        default = "fish";
        description = "TTS backend Open WebUI uses";
      };
    };

    catalog = lib.mkOption {
      type = lib.types.attrs;
      readOnly = true;
      default = catalog;
      description = "Port/URL/model map for Open WebUI and agents";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.${cfg.openWebui.stt}.enable;
        message = "ai.voice.openWebui.stt=${cfg.openWebui.stt} but that backend is disabled";
      }
      {
        assertion = cfg.${cfg.openWebui.tts}.enable;
        message = "ai.voice.openWebui.tts=${cfg.openWebui.tts} but that backend is disabled";
      }
    ];

    virtualisation.oci-containers.containers = lib.mkMerge [
      # Speaches STT
      # OpenAI-compatible STT (faster-whisper). CPU image — do not pass /dev/dri.
      # https://speaches.ai/  https://speaches.ai/installation/  https://speaches.ai/configuration/
      # Env is Pydantic Settings: nested fields use `__` (WHISPER__COMPUTE_TYPE → whisper.compute_type).
      (lib.mkIf cfg.speaches.enable {
        speaches = {
          # Pin: compose.cpu.yaml tracks latest-cpu (stale). v0.9.0-rc.3 is the current GHCR CPU tag.
          # https://github.com/speaches-ai/speaches/releases/tag/v0.9.0-rc.3
          image = "ghcr.io/speaches-ai/speaches:0.9.0-rc.3-cpu";
          # Container listens UVICORN_PORT=8000. Host :8300 avoids clash with open-terminal :8000.
          ports = [ "127.0.0.1:8300:8000" ];
          # Official compose volume path. Persist HF hub so PRELOAD_MODELS is not re-fetched.
          volumes = [ "speaches-hf-cache:/home/ubuntu/.cache/huggingface/hub" ];
          # Linux Docker does not define host.docker.internal unless added.
          # https://docs.docker.com/engine/network/drivers/bridge/
          extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
          environment = {
            # faster-whisper: int8 is the CPU recommendation. Default compute_type is "default".
            # https://github.com/SYSTRAN/faster-whisper
            WHISPER__COMPUTE_TYPE = "int8";
            WHISPER__INFERENCE_DEVICE = "cpu";
            # -1 = never unload (official: 300s). Cold load of distil-small.en is slow on CPU.
            STT_MODEL_TTL = "-1";
            TTS_MODEL_TTL = "-1";
            # Speaches audio-in-audio-out / chat completions. Default is localhost:11434 (wrong in-container).
            # Official default API key string is literally "cant-be-empty" (OpenAI SDKs reject empty).
            CHAT_COMPLETION_BASE_URL = "http://host.docker.internal:11434/v1";
            CHAT_COMPLETION_API_KEY = "cant-be-empty";
            # Official default true. Gradio UI on the published port.
            ENABLE_UI = "true";
            # Official default debug.
            LOG_LEVEL = "info";
            # URL Gradio uses to reach the API. Official default unset = "the URL the user opened".
            # localhost:8000 is correct inside the container. If Gradio hands this to the browser,
            # host :8000 is open-terminal, not Speaches (host Speaches is :8300).
            LOOPBACK_HOST_URL = "http://localhost:8000";
            # Official example uses this exact Systran id. App exits if the id is unknown.
            PRELOAD_MODELS = ''["Systran/faster-distil-whisper-small.en"]'';
          };
          autoStart = false;
        };
      })

      # Kokoro-FastAPI TTS
      # OpenAI /v1/audio/speech. Model id is the literal string "kokoro".
      # https://github.com/remsky/Kokoro-FastAPI
      # https://docs.openwebui.com/features/chat-conversations/audio/text-to-speech/Kokoro-FastAPI-integration/
      # CPU ONNX image. UI: :8880/web  docs: :8880/docs  health: :8880/health
      (lib.mkIf cfg.kokoro.enable {
        kokoro-tts = {
          image = "ghcr.io/remsky/kokoro-fastapi-cpu:latest";
          ports = [ "127.0.0.1:8880:8880" ];
          autoStart = false;
        };
      })

      # Fish Audio TTS (local OpenAI proxy)
      # Fish's native API is POST https://api.fish.audio/v1/tts (model in header), not /v1/audio/speech.
      # https://docs.fish.audio/llms.txt
      # https://docs.fish.audio/api-reference/endpoint/openapi-v1/text-to-speech
      # Image is local — Nix does not build it. packages/fish-tts-proxy/AGENTS.md
      (lib.mkIf cfg.fish.enable {
        fish-tts-proxy = {
          image = "fish-tts-proxy:latest";
          ports = [ "127.0.0.1:8849:8849" ];
          # FISH_API_KEY. Official env name: https://docs.fish.audio/developer-guide/getting-started/quickstart
          environmentFiles = [ "${config.my.secretsDir}/ai.env" ];
          autoStart = false;
        };
      })

      # MOSS-TTS-Nano
      # 0.1B, 48 kHz stereo, CPU. Official demo: python app.py → http://127.0.0.1:18083 (Gradio).
      # https://github.com/OpenMOSS/MOSS-TTS-Nano
      # Image moss-tts-nano-fixed is local (OpenAI /v1 wrapper). Upstream OpenAI serving is vLLM-Omni.
      (lib.mkIf cfg.moss.enable {
        moss-tts = {
          image = "moss-tts-nano-fixed:latest";
          ports = [ "127.0.0.1:8851:18083" ];
          volumes = [
            "moss-tts-models:/root/.cache/huggingface"
            "moss-tts-voices:/app/custom_voices"
          ];
          environment.HF_HOME = "/root/.cache/huggingface";
          autoStart = false;
        };
      })

      # Chatterbox TTS (ROCm)
      # Resemble Chatterbox behind OpenAI /v1/audio/speech. Server default port 8004.
      # https://github.com/devnen/Chatterbox-TTS-Server
      # https://github.com/resemble-ai/chatterbox
      # Official ROCm compose: devices kfd+dri, group_add video+render, shm_size 8g.
      # https://github.com/devnen/Chatterbox-TTS-Server/blob/main/docker-compose-rocm.yml
      # VRAM: Resemble #44 community ~6–7 GB; ~1.5 GB with bf16+offload. Fights Ollama on 12 GB.
      (lib.mkIf cfg.chatterbox.enable {
        chatterbox-tts = {
          image = "chatterbox-tts-rocm:latest";
          ports = [ "127.0.0.1:8850:8004" ];
          volumes = [
            "chatterbox-hf-cache:/app/hf_cache"
            "chatterbox-voices:/app/voices"
            "chatterbox-reference:/app/reference_audio"
            "chatterbox-outputs:/app/outputs"
          ];
          environment = {
            # Official compose: set only for unsupported GPUs. RX 6700 XT is gfx1031.
            # Common value 10.3.0 = RX 5000/6000. Same pin as comfyui.
            HSA_OVERRIDE_GFX_VERSION = "10.3.0";
            # SDMA broken on gfx1030 — see modules/ai/AGENTS.md
            HSA_ENABLE_SDMA = "0";
            HF_HOME = "/app/hf_cache";
          };
          # devices is first-class (example "/dev/dri:/dev/dri"). group-add / shm-size are not.
          devices = [ "/dev/kfd:/dev/kfd" "/dev/dri:/dev/dri" ];
          extraOptions = [
            "--group-add=video"
            "--group-add=render"
            # Official ROCm compose uses 8g. Keep 2g.
            "--shm-size=2g"
          ];
          autoStart = false;
        };
      })
    ];
  };
}
