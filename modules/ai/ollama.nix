# Ollama — always-on LLM inference on RX 6700 XT (gfx1031) via ROCm gfx1030 override.
#
# loadModels and moe pulls cache weights on disk only — VRAM use is controlled by keep_alive after a request.
{ config, pkgs, lib, ... }:
let
  ollamaPkg = pkgs.ollama-rocm;
  ollamaExe = lib.getExe ollamaPkg;

  ollamaCustomModels = [
    # 14B @ 8k + NUM_PARALLEL=2 is tight on 12 GB — pin 4k on these aliases only.
    {
      name = "deepseek-r1-14b-4k";
      modelfile = pkgs.writeText "deepseek-r1-14b-4k.modelfile" ''
        FROM deepseek-r1:14b
        PARAMETER num_ctx 4096
      '';
    }
    {
      name = "deepseek-r1-abliterated-14b-4k";
      modelfile = pkgs.writeText "deepseek-r1-abliterated-14b-4k.modelfile" ''
        FROM huihui_ai/deepseek-r1-abliterated:14b
        PARAMETER num_ctx 4096
      '';
    }
    # Custom template — always emits a system block and skips im_end tokens.
    {
      name = "dusk-rainbow";
      modelfile = pkgs.writeText "dusk-rainbow.modelfile" ''
        FROM hf.co/SicariusSicariiStuff/Dusk_Rainbow_GGUFs:Q4_K_M
        TEMPLATE """<|im_start|>system
        {{ .System }}
        <|im_start|>user
        {{ .Prompt }}
        <|im_start|>assistant
        """
        PARAMETER temperature 0.7
        PARAMETER min_p 0.05
        PARAMETER num_ctx 8192
      '';
    }
    {
      name = "satyr-v0.1-4b";
      modelfile = pkgs.writeText "satyr-v0.1-4b.modelfile" ''
        FROM hf.co/PantheonUnbound/Satyr-V0.1-4B:Q4_K_M
        PARAMETER num_ctx 8192
      '';
    }
    # Replaces the old llama-server on :8081 — same GGUF as the moe hf.co pull below.
    {
      name = "qwen3-coder-unsloth";
      modelfile = pkgs.writeText "qwen3-coder-unsloth.modelfile" ''
        FROM hf.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
      '';
    }
    {
      name = "hauhau-qwen35";
      modelfile = pkgs.writeText "hauhau-qwen35.modelfile" ''
        FROM hf.co/HauhauCS/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive:Q4_K_M
        PARAMETER num_ctx 8192
      '';
    }
    # 4096 matches the old llama-server profile, not the server's 8192 default.
    {
      name = "hauhau-gemma4";
      modelfile = pkgs.writeText "hauhau-gemma4.modelfile" ''
        FROM hf.co/HauhauCS/Gemma-4-E4B-Uncensored-HauhauCS-Aggressive:Q4_K_M
        PARAMETER num_ctx 4096
      '';
    }
  ];

  ollamaMoEDownloadModels = [
    "qwen3-coder:30b"
    "huihui_ai/Qwen3.6-abliterated:35b"
    # Blob for qwen3-coder-unsloth — create uses the short name; this pull is disk cache.
    "hf.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M"
  ];
in
{
  services.ollama = {
    enable = true;
    package = ollamaPkg;
    # RX 6700 XT (gfx1031) isn't on AMD's or Ollama's supported-GPU lists — spoof as gfx1030.
    # https://github.com/ollama/ollama/issues/3547
    rocmOverrideGfx = "10.3.0";
    # Disk pull via ollama-model-loader — does NOT load into VRAM.
    # Never enable syncModels: it deletes custom aliases not in this list.
    loadModels = [
      "qwen3.5:9b"
      "deepseek-r1:14b"
      "gemma4:e4b"
      "qwen2.5-coder:7b"
      "qwen3-embedding:0.6b"
      "jaahas/qwen3.5-uncensored:9b"
      "dolphin3:8b"
      "huihui_ai/qwen3.5-abliterated:9b"
      "huihui_ai/deepseek-r1-abliterated:14b"
    ];
    # Only ollama.service sees these — a bare `ollama run` talks to the server on 127.0.0.1:11434.
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "8192"; # Up from 4k — coding agents want more, but 30B won't fit at 64k on 12 GB
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0"; # Half the KV memory of f16 with flash attention on
      OLLAMA_NUM_PARALLEL = "2"; # Two in-flight requests — KV budget doubles (2 × 8192)
      OLLAMA_MAX_LOADED_MODELS = "3"; # Extra slots for idle models until keep_alive expires
      OLLAMA_KEEP_ALIVE = "1h"; # GameMode sends keep_alive=0 before CS2
      OLLAMA_NO_CLOUD = "1"; # Local models only — no cloud fallback or web search
      HSA_NO_SCRATCH_RECLAIM = "1"; # Hold ROCm scratch until service exit — timeout mitigation, VRAM tax when idle
      # HSA_ENABLE_SDMA left unset for Ollama (ComfyUI/chatterbox set 0 for gfx1030 page faults).
      # Fallback if ROCm dies: OLLAMA_VULKAN=1. Don't set AMD_SERIALIZE_KERNEL or HCC_AMDGPU_TARGET.
    };
  };

  systemd.services = {
    # Don't pin DPM=high / COMPUTE here — forced clocks under CS2 caused MES hangs.
    # GameMode unloads models; the SMU ramps on inference.
    ollama-custom-models = {
      description = "Create Ollama custom models (DeepSeek 14B @ 4k, RP, Unsloth, HauhauCS)";
      after = [ "ollama.service" "ollama-model-loader.service" "network-online.target" ];
      wants = [ "network-online.target" "ollama-model-loader.service" ];
      wantedBy = [ "multi-user.target" ];
      bindsTo = [ "ollama.service" ];
      environment = config.systemd.services.ollama.environment;
      # DynamicUser is fine — create/pull go through the server HTTP API; blobs live in ollama's home.
      # First Unsloth create may pull the GGUF itself if ollama-moe-models hasn't finished.
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; DynamicUser = true; };
      script = ''
        set -uo pipefail
        failures=0
        ${lib.concatMapStringsSep "\n" (m: ''
          if ${ollamaExe} show ${lib.escapeShellArg m.name} >/dev/null 2>&1; then
            echo "Already exists: ${m.name}"
          else
            echo "Creating ${m.name}..."
            if ! ${ollamaExe} create ${lib.escapeShellArg m.name} -f ${lib.escapeShellArg m.modelfile}; then
              echo "ERROR: failed to create ${m.name}" >&2
              failures=$((failures + 1))
            fi
          fi
        '') ollamaCustomModels}
        if [[ "$failures" -gt 0 ]]; then
          echo "$failures custom model(s) failed" >&2
          exit 1
        fi
      '';
    };

    ollama-moe-models = {
      description = "Download Ollama MoE models (disk cache only)";
      after = [ "ollama.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      bindsTo = [ "ollama.service" ];
      environment = config.systemd.services.ollama.environment;
      serviceConfig = { Type = "oneshot"; RemainAfterExit = true; DynamicUser = true; };
      script = ''
        ${lib.getExe pkgs.parallel} --tag ${ollamaExe} pull ::: ${lib.escapeShellArgs ollamaMoEDownloadModels} || true
      '';
    };
  };
}
