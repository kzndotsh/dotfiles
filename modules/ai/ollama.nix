# Ollama — always-on LLM inference. RX 6700 XT (gfx1031) via ROCm gfx1030 override.
#
# loadModels / moe pulls = disk only. VRAM occupancy is keep_alive after a request.
# https://docs.ollama.com/llms.txt
# https://docs.ollama.com/faq
# https://wiki.nixos.org/wiki/Ollama
# NixOS: https://search.nixos.org/options?query=services.ollama
{ config, pkgs, lib, ... }:
let
  ollamaPkg = pkgs.ollama-rocm;
  ollamaExe = lib.getExe ollamaPkg;

  # ollama create -f. FROM can be a library tag or hf.co/org/repo:quant.
  # https://docs.ollama.com/modelfile
  # https://huggingface.co/docs/hub/ollama
  ollamaCustomModels = [
    # 14B @ 8k + NUM_PARALLEL=2 is tight on 12 GB. Pin 4k on these aliases only.
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
    # Official ChatML example uses {{ if .System }}, <|im_end|> after turns, then assistant.
    # This template always emits a system block and has no im_end — left as-is.
    # https://docs.ollama.com/modelfile#template
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
    # Was llama-server :8081. Same GGUF as the moe hf.co pull below.
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
    # 4096 matches the old llama-server profile (not the 8192 server default).
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
    # Blob for qwen3-coder-unsloth. create is the short name; this pull is disk cache.
    "hf.co/unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M"
  ];
in
{
  services.ollama = {
    enable = true;
    # First-class. Wiki: ollama-rocm + rocmOverrideGfx for undetected AMD.
    # 6700 XT (gfx1031) is on neither official list:
    #   AMD Linux: https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html
    #   Ollama:    https://docs.ollama.com/gpu  (6800/6900 yes; 6700 XT no)
    # Closest official RDNA2 is PRO W6800 / gfx1030.
    package = ollamaPkg;
    # Sets HSA_OVERRIDE_GFX_VERSION. Not in the official ROCR env table —
    # rocminfo/runtime spoof. Compiler emits override ISA; hardware still gfx1031.
    # AMD: only when no native kernels exist (gfx1031 → 10.3.0 is that case).
    #   https://rocm.docs.amd.com/projects/ROCR-Runtime/en/latest/api-reference/environment_variables.html
    #   https://github.com/amd/skills/blob/main/staging/rocm-doctor/reference.md
    # AMD staff + Ollama maintainer: 10.3.0 for gfx1031 / RX 6700.
    #   https://github.com/ROCm/ROCm/issues/2720
    #   https://github.com/ROCm/tensorflow-upstream/issues/2629
    #   https://github.com/ollama/ollama/issues/3547
    # NixOS wiki example is this exact card. HCC_AMDGPU_TARGET is obsolete.
    #   https://wiki.nixos.org/wiki/Ollama
    # Syntax is x.y.z (docs: RX 5400 gfx1034 → 10.3.0). gfx1031 / 10.3.1 fail Tensile.
    #   https://github.com/ollama/ollama/issues/6003
    rocmOverrideGfx = "10.3.0";
    # Disk pull via ollama-model-loader.service — does NOT load into VRAM.
    # Do not enable syncModels: that deletes anything not in this list (custom aliases).
    # https://ollama.com/library
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
    # Seen only by ollama.service, not a bare `ollama run` binary — the CLI talks to the server.
    # host/port stay NixOS defaults: 127.0.0.1:11434 (do not set OLLAMA_HOST here).
    environmentVariables = {
      # Official default for <24 GiB VRAM is 4k. We pin 8k. Coding agents want ≥64k
      # (docs.ollama.com/context-length) — that will not fit 12 GB with a 30B.
      # RAM/VRAM scales by NUM_PARALLEL × CONTEXT_LENGTH.
      OLLAMA_CONTEXT_LENGTH = "8192";
      # Official: auto-on when backend/device support it. 1 = force on, 0 = force off.
      # KV quant below only applies when flash attention is active.
      OLLAMA_FLASH_ATTENTION = "1";
      # Official default f16. q8_0 ≈ half the KV memory, "recommended if not using f16".
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      # Official default 1. 2 = two in-flight requests; KV budget doubles (2 × 8192).
      OLLAMA_NUM_PARALLEL = "2";
      # Official default 3 × GPU count (= 3 here). Still "provided they fit" — 12 GB will not
      # hold three 9B@8k. Extra slots just mean idle models can stay until keep_alive.
      OLLAMA_MAX_LOADED_MODELS = "3";
      # Official default 5m. 0 = unload now, -1 = forever. GameMode sends keep_alive=0.
      OLLAMA_KEEP_ALIVE = "1h";
      # Official: local-only (no cloud models / web search). Also valid in ~/.ollama/server.json.
      OLLAMA_NO_CLOUD = "1";
      # ROCm, not Ollama. Official default 0. 1 = permanently assign scratch to this
      # process's queues (not reclaimed mid-dispatch). Held until ollama.service exits.
      # Always-on → VRAM tax even with no model loaded. Timeout mitigation.
      # https://rocm.docs.amd.com/projects/ROCR-Runtime/en/latest/api-reference/environment_variables.html
      HSA_NO_SCRATCH_RECLAIM = "1";
      # HSA_ENABLE_SDMA official default 1. ComfyUI/chatterbox set 0 (gfx1030 page faults).
      # Ollama only auto-applies 0 for Vega RX 56 (gfx900), not 6700 XT. Leave unset
      # unless we see "Memory access fault by GPU". Fallback if ROCm dies: OLLAMA_VULKAN=1.
      # Do not set AMD_SERIALIZE_KERNEL / HCC_AMDGPU_TARGET (debug / obsolete).
    };
  };

  systemd.services = {
    # Always-on: do not pin DPM=high / COMPUTE. That leaves ROCm+forced clocks
    # under CS2 (MES hang class). GameMode unloads models; SMU ramps on inference.
    ollama-custom-models = {
      description = "Create Ollama custom models (DeepSeek 14B @ 4k, RP, Unsloth, HauhauCS)";
      after = [ "ollama.service" "ollama-model-loader.service" "network-online.target" ];
      wants = [ "network-online.target" "ollama-model-loader.service" ];
      wantedBy = [ "multi-user.target" ];
      bindsTo = [ "ollama.service" ];
      environment = config.systemd.services.ollama.environment;
      # DynamicUser is fine: create/pull go through the server HTTP API; blobs live in the
      # ollama service home, not this uid. Does not wait for ollama-moe-models — first
      # Unsloth create may pull the GGUF itself if the moe unit has not finished.
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
