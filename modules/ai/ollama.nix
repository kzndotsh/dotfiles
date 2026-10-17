# Ollama — always-on LLM inference on RX 6700 XT (gfx1031) via ROCm gfx1030 override.
#
# loadModels caches weights on disk only — VRAM use is controlled by keep_alive after a request.
{ config, pkgs, lib, ... }:
let
  ollamaPkg = pkgs.ollama-rocm;
  ollamaExe = lib.getExe ollamaPkg;

  ollamaCustomModels = [
    # 14B @ 8k is tight on 12 GB — pin 4k on these aliases only.
    # Samplers: DeepSeek-R1-Distill card (temp 0.5–0.7, 0.6 recommended, top_p 0.95); the library tag ships none.
    {
      name = "deepseek-r1-14b-4k";
      modelfile = pkgs.writeText "deepseek-r1-14b-4k.modelfile" ''
        FROM deepseek-r1:14b
        PARAMETER num_ctx 4096
        PARAMETER temperature 0.6
        PARAMETER top_p 0.95
      '';
    }
    {
      name = "deepseek-r1-abliterated-14b-4k";
      modelfile = pkgs.writeText "deepseek-r1-abliterated-14b-4k.modelfile" ''
        FROM huihui_ai/deepseek-r1-abliterated:14b
        PARAMETER num_ctx 4096
        PARAMETER temperature 0.6
        PARAMETER top_p 0.95
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
    # Samplers: base Qwen3-4B-Thinking-2507 card (Temperature 0.6, TopP 0.95, TopK 20, MinP 0).
    {
      name = "satyr-v0.1-4b";
      modelfile = pkgs.writeText "satyr-v0.1-4b.modelfile" ''
        FROM hf.co/PantheonUnbound/Satyr-V0.1-4B:Q4_K_M
        PARAMETER num_ctx 8192
        PARAMETER temperature 0.6
        PARAMETER top_p 0.95
        PARAMETER top_k 20
        PARAMETER min_p 0
        PARAMETER repeat_penalty 1.0
      '';
    }
    # Samplers: HauhauCS card, thinking mode (non-thinking: temp 0.7, top_p 0.8).
    {
      name = "hauhau-qwen35";
      modelfile = pkgs.writeText "hauhau-qwen35.modelfile" ''
        FROM hf.co/HauhauCS/Qwen3.5-9B-Uncensored-HauhauCS-Aggressive:Q4_K_M
        PARAMETER num_ctx 8192
        PARAMETER temperature 0.6
        PARAMETER top_p 0.95
        PARAMETER top_k 20
        PARAMETER min_p 0
      '';
    }
    # 4096 matches the old llama-server profile, not the server's 8192 default.
    # Samplers (both Gemma 4 aliases): Google's Gemma 4 values, quoted on the HauhauCS card.
    {
      name = "hauhau-gemma4";
      modelfile = pkgs.writeText "hauhau-gemma4.modelfile" ''
        FROM hf.co/HauhauCS/Gemma-4-E4B-Uncensored-HauhauCS-Aggressive:Q4_K_M
        PARAMETER num_ctx 4096
        PARAMETER temperature 1.0
        PARAMETER top_p 0.95
        PARAMETER top_k 64
      '';
    }
    # Measured uncensored 12B that fits 12 GB at Q4. `/set nothink` in Ollama for the heretic path.
    {
      name = "gemma4-12b-heretic";
      modelfile = pkgs.writeText "gemma4-12b-heretic.modelfile" ''
        FROM igorls/gemma-4-12B-it-heretic-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
        PARAMETER temperature 1.0
        PARAMETER top_p 0.95
        PARAMETER top_k 64
      '';
    }
    # 9B RP, Q4 ~5.8 GB. Extra alias next to gemma4-12b-heretic.
    # Card has no samplers: DavidAU baseline (min_p 0.05, top_p 0.95, rep pen 1.05 over 64); Gemma 2 wants temp ~1.
    {
      name = "gemmasutra-9b";
      modelfile = pkgs.writeText "gemmasutra-9b.modelfile" ''
        FROM hf.co/TheDrummer/Gemmasutra-9B-v1-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
        PARAMETER temperature 1.0
        PARAMETER min_p 0.05
        PARAMETER top_p 0.95
        PARAMETER top_k 40
        PARAMETER repeat_penalty 1.05
        PARAMETER repeat_last_n 64
      '';
    }
    # 12B merge, Q4 ~7.6 GB. Samplers: Marcjoni/HyperNovaSynth-12B card (temp 0.75–1.25, min_p 0.035, top_k 0, top_p 1).
    {
      name = "hypernovasynth-12b";
      modelfile = pkgs.writeText "hypernovasynth-12b.modelfile" ''
        FROM hf.co/mradermacher/HyperNovaSynth-12B-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
        PARAMETER temperature 1.0
        PARAMETER min_p 0.035
        PARAMETER top_p 1.0
        PARAMETER top_k 0
        PARAMETER repeat_penalty 1.05
        PARAMETER repeat_last_n 64
      '';
    }
    # UnslopNemo 12B v4.1, Q4 ~7.6 GB. Card has no samplers: DavidAU baseline.
    {
      name = "unslopnemo-12b";
      modelfile = pkgs.writeText "unslopnemo-12b.modelfile" ''
        FROM hf.co/mradermacher/UnslopNemo-12B-v4.1-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
        PARAMETER temperature 0.8
        PARAMETER min_p 0.05
        PARAMETER top_p 0.95
        PARAMETER top_k 40
        PARAMETER repeat_penalty 1.05
        PARAMETER repeat_last_n 64
      '';
    }
    # Impish Bloodmoon 12B Abliterated, Q4 ~7.6 GB. Samplers: the Ollama-supported part of the
    # card's RP preset (Impish_Nemo Dynamic_Paragraph_XTC_ST.json); its DRY/XTC/dynatemp 0.85–1.3 need llama.cpp.
    {
      name = "impish-bloodmoon-12b";
      modelfile = pkgs.writeText "impish-bloodmoon-12b.modelfile" ''
        FROM hf.co/mradermacher/Impish_Bloodmoon_12B_Abliterated-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
        PARAMETER temperature 1.0
        PARAMETER min_p 0.05
        PARAMETER top_p 0.75
        PARAMETER top_k 20
        PARAMETER repeat_penalty 1.0
      '';
    }
    # KansenSakura Eclipse 12B, Q4 ~7.6 GB. Samplers: Retreatcost/KansenSakura-Eclipse-RP-12b card.
    {
      name = "kansensakura-eclipse-12b";
      modelfile = pkgs.writeText "kansensakura-eclipse-12b.modelfile" ''
        FROM hf.co/mradermacher/KansenSakura-Eclipse-RP-12b-GGUF:Q4_K_M
        PARAMETER num_ctx 8192
        PARAMETER temperature 0.8
        PARAMETER min_p 0.025
        PARAMETER top_p 0.97
        PARAMETER top_k 0
        PARAMETER repeat_penalty 1.05
        PARAMETER repeat_last_n 64
      '';
    }
    # Library tags can't carry our PARAMETERs, so these aliases add the vendor values on top.
    # qwen2.5-coder: Qwen2.5-Coder-7B-Instruct generation_config.json.
    {
      name = "qwen2.5-coder-7b-tuned";
      modelfile = pkgs.writeText "qwen2.5-coder-7b-tuned.modelfile" ''
        FROM qwen2.5-coder:7b
        PARAMETER temperature 0.7
        PARAMETER top_p 0.8
        PARAMETER top_k 20
        PARAMETER repeat_penalty 1.1
      '';
    }
    # huihui's tag lacks the presence_penalty 1.5 the official qwen3.5:9b ships; other params inherit.
    {
      name = "qwen3.5-abliterated-9b-tuned";
      modelfile = pkgs.writeText "qwen3.5-abliterated-9b-tuned.modelfile" ''
        FROM huihui_ai/qwen3.5-abliterated:9b
        PARAMETER presence_penalty 1.5
      '';
    }
    # JoyCaption Beta One: card example (temperature 0.6, top_p 0.9, top_k off); keeps the uploader's num_ctx 4096.
    {
      name = "joycaption-beta-one";
      modelfile = pkgs.writeText "joycaption-beta-one.modelfile" ''
        FROM aha2025/llama-joycaption-beta-one-hf-llava:Q4_K_M
        PARAMETER temperature 0.6
        PARAMETER top_p 0.9
        PARAMETER top_k 0
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
      # Vision: captioning / image Q&A (JoyCaption also has a tuned alias above).
      "aha2025/llama-joycaption-beta-one-hf-llava:Q4_K_M"
      "minicpm-v4.6"
      "moondream"
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
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        DynamicUser = true;
        # Stamp per alias = Modelfile store path, so an edited Modelfile re-creates the alias.
        StateDirectory = "ollama-custom-models";
      };
      script = ''
        set -uo pipefail
        failures=0
        ${lib.concatMapStringsSep "\n" (m: ''
          stamp="$STATE_DIRECTORY/"${lib.escapeShellArg m.name}
          if ${ollamaExe} show ${lib.escapeShellArg m.name} >/dev/null 2>&1 \
            && [[ "$(cat "$stamp" 2>/dev/null)" == ${lib.escapeShellArg "${m.modelfile}"} ]]; then
            echo "Up to date: ${m.name}"
          else
            echo "Creating ${m.name}..."
            if ${ollamaExe} create ${lib.escapeShellArg m.name} -f ${lib.escapeShellArg m.modelfile}; then
              printf '%s' ${lib.escapeShellArg "${m.modelfile}"} > "$stamp"
            else
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
