# Ollama — always-on LLM inference on RX 6700 XT (gfx1031) via ROCm gfx1030 override.
#
# loadModels caches weights on disk only — VRAM use is controlled by keep_alive after a request.
{ config, pkgs, lib, ... }:
let
  ollamaPkg = pkgs.ollama-rocm;
  ollamaExe = lib.getExe ollamaPkg;

  ollamaCustomModels = [
    # 14B @ 8k is tight on 12 GB — pin 4k on these aliases only.
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
    # Measured uncensored 12B that fits 12 GB at Q4. `/set nothink` in Ollama for the heretic path.
    {
      name = "gemma4-12b-heretic";
      modelfile = pkgs.writeText "gemma4-12b-heretic.modelfile" ''
        FROM igorls/gemma-4-12B-it-heretic-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
      '';
    }
    # 9B RP, Q4 ~5.8 GB. Extra alias next to gemma4-12b-heretic.
    {
      name = "gemmasutra-9b";
      modelfile = pkgs.writeText "gemmasutra-9b.modelfile" ''
        FROM hf.co/TheDrummer/Gemmasutra-9B-v1-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
      '';
    }
    # 12B merge, Q4 ~7.6 GB.
    {
      name = "hypernovasynth-12b";
      modelfile = pkgs.writeText "hypernovasynth-12b.modelfile" ''
        FROM hf.co/mradermacher/HyperNovaSynth-12B-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
      '';
    }
    # UnslopNemo 12B v4.1, Q4 ~7.6 GB.
    {
      name = "unslopnemo-12b";
      modelfile = pkgs.writeText "unslopnemo-12b.modelfile" ''
        FROM hf.co/mradermacher/UnslopNemo-12B-v4.1-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
      '';
    }
    # Impish Bloodmoon 12B Abliterated, Q4 ~7.6 GB.
    {
      name = "impish-bloodmoon-12b";
      modelfile = pkgs.writeText "impish-bloodmoon-12b.modelfile" ''
        FROM hf.co/mradermacher/Impish_Bloodmoon_12B_Abliterated-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
      '';
    }
    # KansenSakura Eclipse 12B, Q4 ~7.6 GB.
    {
      name = "kansensakura-eclipse-12b";
      modelfile = pkgs.writeText "kansensakura-eclipse-12b.modelfile" ''
        FROM hf.co/mradermacher/KansenSakura-Eclipse-RP-12b-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
      '';
    }
  ];

  # No 30B/35B disk cache — those are RAM-offload on 12 GB and showed up as slow leftovers.
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
    # One tag per recipe. Uncensored Qwen daily is huihui 9B; Hauhau is a separate create alias.
    # jaahas + dolphin3 were extra 8/9B copies of the same job.
    loadModels = [
      "qwen3.5:9b"
      "deepseek-r1:14b"
      "gemma4:e4b"
      "gemma4:12b"
      "qwen2.5-coder:7b"
      "qwen3-embedding:0.6b"
      "huihui_ai/qwen3.5-abliterated:9b"
      "huihui_ai/deepseek-r1-abliterated:14b"
    ];
    # Only ollama.service sees these — a bare `ollama run` talks to the server on 127.0.0.1:11434.
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "8192"; # Default 8k; 14B aliases pin 4k. Do not pull 30B/35B onto this GPU.
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0"; # Half the KV memory of f16 with flash attention on
      OLLAMA_NUM_PARALLEL = "1"; # One slot — NUM_PARALLEL multiplies KV (was 2 × 8k)
      OLLAMA_MAX_LOADED_MODELS = "1"; # One resident model on 12 GB
      OLLAMA_KEEP_ALIVE = "10m"; # Chat pause, not a 1h VRAM lease. GameMode still sends 0 before CS2
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
      description = "Create Ollama custom models (14B @ 4k, RP, HauhauCS)";
      after = [ "ollama.service" "ollama-model-loader.service" "network-online.target" ];
      wants = [ "network-online.target" "ollama-model-loader.service" ];
      wantedBy = [ "multi-user.target" ];
      bindsTo = [ "ollama.service" ];
      environment = config.systemd.services.ollama.environment;
      # DynamicUser is fine — create/pull go through the server HTTP API; blobs live in ollama's home.
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

  };
}
