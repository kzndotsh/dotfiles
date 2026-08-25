# ComfyUI — on-demand image gen. Local Docker image, ROCm 7.2, gfx1031 via 10.3.0.
#
# Unit: docker-comfyui (`autoStart = false`). Fights Ollama on 12 GB — unload first.
# Image `qinzhen/comfyui-rocm72:local` is local (docker commit). Nix does not pull it.
# Base: rocm/pytorch:rocm7.2.1_ubuntu24.04_py3.12_pytorch_release_2.9.1
#
# No first-class services.comfyui. OCI only.
# https://docs.comfy.org/development/comfyui-server/startup-flags
# https://github.com/Comfy-Org/ComfyUI/blob/master/comfy/cli_args.py
# https://wiki.nixos.org/wiki/Docker
# https://search.nixos.org/options?query=virtualisation.oci-containers.containers
{ pkgs, lib, config, ... }:
let
  modelsDir = "/opt/comfyui/models";
  customNodesDir = "/opt/comfyui/custom_nodes";
  wget = lib.getExe pkgs.wget;
  git = lib.getExe pkgs.git;

  # Dest paths are ComfyUI folder names (checkpoints / diffusion_models / text_encoders / …).
  # CivitAI: GET /api/download/models/{versionId}. Token required for file downloads.
  # https://education.civitai.com/civitais-guide-to-downloading-via-api/
  models = [
    # SDXL checkpoints (Lightning = fast, 4–6 steps / CFG 1–2)
    { url = "https://civitai.com/api/download/models/782002"; dest = "checkpoints/juggernautXL_v9Rdphoto2Lightning.safetensors"; }
    { url = "https://civitai.com/api/download/models/789646"; dest = "checkpoints/realvisxlV50_v50Lightning.safetensors"; }
    { url = "https://huggingface.co/bluepen5805/blue_pencil-XL/resolve/main/blue_pencil-XL-v7.0.0.safetensors"; dest = "checkpoints/bluePencilXL_v700.safetensors"; }

    # SDXL Pony (Realism By Stable Yogi v6.5 DMD2, 4-step, Q8 GGUF)
    { url = "https://civitai.com/api/download/models/2985497?type=Model&format=GGUF&size=pruned&quantType=Q8_0"; dest = "checkpoints/realismByStableYogi_ponyV65_Q8.gguf"; }

    # SDXL Pony (Realism By Stable Yogi v6.5 FP16, for Open WebUI)
    { url = "https://civitai.com/api/download/models/2985392"; dest = "checkpoints/realismByStableYogi_ponyV65.safetensors"; }

    # CyberRealistic XL v9 (photorealistic, natural language)
    { url = "https://civitai.com/api/download/models/2611295"; dest = "checkpoints/cyberrealisticXL_v90.safetensors"; }

    # Pony Realism v2.3 ULTRA (best photorealistic Pony finetune)
    { url = "https://civitai.com/api/download/models/1920896"; dest = "checkpoints/ponyRealism_v23ULTRA.safetensors"; }

    # Flux.1 Schnell (full FP16, ~23 GB — will not sit in 12 GB; needs offload)
    { url = "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/flux1-schnell.safetensors"; dest = "diffusion_models/flux1-schnell.safetensors"; }

    # Flux.1 Dev Q5 GGUF (near-FP16 quality, fits 12GB)
    { url = "https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q5_K_S.gguf"; dest = "diffusion_models/flux1-dev-Q5_K_S.gguf"; }

    # Flux.2 Klein 4B fp8 (fastest Flux, 4-step, Apache 2.0, ~9GB VRAM)
    { url = "https://huggingface.co/black-forest-labs/FLUX.2-klein-4b-fp8/resolve/main/flux-2-klein-4b-fp8.safetensors"; dest = "diffusion_models/flux2-klein-4b-fp8.safetensors"; }

    # Text encoders (shared by Flux.1)
    { url = "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"; dest = "text_encoders/clip_l.safetensors"; }
    { url = "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors"; dest = "text_encoders/t5xxl_fp8_e4m3fn.safetensors"; }

    # Flux.2 Klein text encoder (Qwen 3 4B — NOT T5)
    { url = "https://huggingface.co/Comfy-Org/flux2-klein/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors"; dest = "text_encoders/qwen_3_4b.safetensors"; }

    # VAE
    { url = "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors"; dest = "vae/ae.safetensors"; }
    { url = "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors"; dest = "vae/flux2-vae.safetensors"; }

    # Upscalers
    { url = "https://huggingface.co/Kim2091/AnimeSharp/resolve/main/4x-AnimeSharp.pth"; dest = "upscale_models/4x-AnimeSharp.pth"; }
    { url = "https://huggingface.co/Kim2091/UltraSharp/resolve/main/4x-UltraSharp.pth"; dest = "upscale_models/4x-UltraSharp.pth"; }
    { url = "https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth"; dest = "upscale_models/4xNMKDSuperscale.pth"; }
    { url = "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/1x-ITF-SkinDiffDetail-Lite-v1.pth"; dest = "upscale_models/1x-ITF-SkinDiffDetail-Lite-v1.pth"; }

    # LoRAs
    { url = "https://huggingface.co/tianweiy/DMD2/resolve/main/dmd2_sdxl_4step_lora.safetensors"; dest = "loras/dmd2_sdxl_4step_lora.safetensors"; }

    # Detection models (Impact-Pack / FaceDetailer)
    { url = "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt"; dest = "ultralytics/bbox/face_yolov8m.pt"; }
    { url = "https://huggingface.co/Bingsu/adetailer/resolve/main/hand_yolov8s.pt"; dest = "ultralytics/bbox/hand_yolov8s.pt"; }
    { url = "https://dl.fbaipublicfiles.com/segment_anything/sam_vit_b_01ec64.pth"; dest = "sams/sam_vit_b_01ec64.pth"; }
  ];
in
{
  virtualisation.oci-containers.containers.comfyui = {
    image = "qinzhen/comfyui-rocm72:local";
    # devices is first-class. group-add / network / add-host are not.
    # Official ROCm compose also --group-add render; we only add video.
    devices = [ "/dev/kfd:/dev/kfd" "/dev/dri:/dev/dri" ];
    extraOptions = [
      "--group-add" "video"
      # host.docker.internal is unused under --network=host (localhost is the host).
      "--add-host=host.docker.internal:host-gateway"
      # host net: LLMVRAMManager → Ollama :11434. Also binds ComfyUI on all ifaces.
      # Desktop firewall is on with all ports allowed — :8188 is LAN-reachable. Official default listen is 127.0.0.1.
      "--network=host"
    ];
    environment = {
      # gfx1031 → gfx1030. Same pin as ollama / chatterbox. See ollama.nix for citations.
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
      # Official ROCR default 1. 0 = no SDMA copies. PyTorch/ComfyUI page-fault workaround.
      # https://rocm.docs.amd.com/projects/ROCR-Runtime/en/latest/api-reference/environment_variables.html
      HSA_ENABLE_SDMA = "0";
      # Official default 0. 1 = keep scratch until process exit (timeout mitigation).
      HSA_NO_SCRATCH_RECLAIM = "1";
      # 0 = default (async). 1 serializes launches — debug only, 30–50% slower.
      HIP_LAUNCH_BLOCKING = "0";
      # AMD: enable experimental AOTriton SDPA on arches that are not fully supported.
      # gfx1030/1031 are not in the official AOTriton allowlist (gfx90a/942/1100/1201/950).
      # https://rocm.docs.amd.com/projects/radeon-ryzen/en/docs-7.1/docs/install/installryz/native_linux/install-pytorch.html
      TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL = "1";
      # Force MIOpen path. cuDNN does not exist on ROCm; some wheels still probe it.
      TORCH_CUDNN_ENABLED = "0";
      # ComfyUI #2471 (RX 6800 / gfx1030). We use 0.7 / 4096 (issue example was 0.6 / 6144).
      # Newer comments prefer PYTORCH_ALLOC_CONF; HIP_ name still works. expandable_segments
      # is the modern knob — not set here.
      # https://github.com/Comfy-Org/ComfyUI/issues/2471
      PYTORCH_HIP_ALLOC_CONF = "garbage_collection_threshold:0.7,max_split_size_mb:4096";
      # Persist Find-Db on the host volume (miopen-cache). Avoids ~/.cache/miopen corruption.
      # https://rocm.docs.amd.com/projects/MIOpen/en/latest/conceptual/finddb.html
      MIOPEN_USER_DB_PATH = "/workspace/ComfyUI/.miopen";
      MIOPEN_CUSTOM_CACHE_DIR = "/workspace/ComfyUI/.miopen";
      # 3 = HYBRID (FindDb hit or full find). Official default is now DYNAMIC_HYBRID / 5.
      # 2 = FAST (immediate fallback — what ROCm #4729 used). 1 = NORMAL (benchmark all).
      # https://rocm.docs.amd.com/projects/MIOpen/en/latest/how-to/find-and-immediate.html
      MIOPEN_FIND_MODE = "3";
      # Older MIOpen knob. May be a no-op on current ROCm.
      MIOPEN_CONV_PRECISE_ROCBLAS_TIMING = "0";
      # ComfyUI_MD_Nodes LLMVRAMManager → unload Ollama before gen. Needs host net.
      MD_OLLAMA_HOST = "http://localhost:11434";
    };
    # Official flags: https://docs.comfy.org/development/comfyui-server/startup-flags
    # --listen 0.0.0.0 = all ifaces (default is 127.0.0.1). --port 8188 is the default.
    # --fp16-vae: VAE in fp16 (may black-image). --fp32-vae caused AMD timeouts (ROCm #4729).
    # --lowvram: text encoders on CPU unless dynamic VRAM is on (Nvidia-default; we do not enable it).
    # --reserve-vram 2.5: GB held back for OS/other. Official has no recommended number.
    # --disable-smart-memory / --enable-dynamic-vram are NOT passed (dynamic crashed gfx1030).
    # pip every start: contradicts "bake via docker commit". Left as-is — recreations still work.
    cmd = [ "bash" "-c" "pip install -q gguf opencv-python-headless segment-anything scikit-image piexif dill matplotlib scipy requests && python3 main.py --listen 0.0.0.0 --port 8188 --fp16-vae --lowvram --reserve-vram 2.5" ];
    # Bind-mounts: Docker creates missing host dirs as root. comfyui-models runs as the desktop user.
    volumes = [
      "/opt/comfyui/models:/workspace/ComfyUI/models"
      "/opt/comfyui/output:/workspace/ComfyUI/output"
      "/opt/comfyui/custom_nodes:/workspace/ComfyUI/custom_nodes"
      "/opt/comfyui/miopen-cache:/workspace/ComfyUI/.miopen"
      "/opt/comfyui/pip-cache:/root/.cache/pip"
      "/opt/comfyui/workflows:/workspace/ComfyUI/user/default/workflows"
    ];
    autoStart = false;
  };

  # On-demand disk pull. Does not start ComfyUI. Idempotent (skip if dest exists).
  systemd.services.comfyui-models = {
    description = "Download ComfyUI models + ComfyUI_MD_Nodes (LLMVRAMManager)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "infinity";
      User = config.my.username;
      Group = "users";
      # huggingface-token: HF_TOKEN=…  ai.env: CIVITAI_TOKEN=… (and other keys).
      EnvironmentFile = [
        "${config.my.secretsDir}/huggingface-token"
        "${config.my.secretsDir}/ai.env"
      ];
    };
    script = ''
      set -euo pipefail
      ${lib.concatMapStringsSep "\n" (m: ''
        dest="${modelsDir}/${m.dest}"
        if [[ ! -f "$dest" ]]; then
          echo "Downloading ${m.dest}..."
          mkdir -p "$(dirname "$dest")"
          if [[ "${m.url}" == *civitai* ]]; then
            url="${m.url}"
            if [[ "$url" == *"?"* ]]; then
              url="$url&token=$CIVITAI_TOKEN"
            else
              url="$url?token=$CIVITAI_TOKEN"
            fi
            # Query ?token= is the documented download-tool form. Header is preferred
            # (token then stays out of wget argv / logs). wget follows the S3 redirect.
            # https://developer.civitai.com/site/guide/authentication
            ${wget} -q --show-progress -O "$dest.tmp" "$url"
          else
            ${wget} -q --show-progress --header="Authorization: Bearer $HF_TOKEN" -O "$dest.tmp" "${m.url}"
          fi
          mv "$dest.tmp" "$dest"
        else
          echo "Already exists: ${m.dest}"
        fi
      '') models}
      # Open WebUI graph needs LLMVRAMManager. Do not pip -r this repo (CUDA wheels).
      # Node only needs requests (installed in the container cmd).
      mdNodes="${customNodesDir}/ComfyUI_MD_Nodes"
      if [[ ! -f "$mdNodes/utility/MD_LLM_VRAMManager.py" ]]; then
        echo "Cloning ComfyUI_MD_Nodes..."
        mkdir -p "${customNodesDir}"
        ${git} clone --depth 1 https://github.com/MDMAchine/ComfyUI_MD_Nodes.git "$mdNodes"
      else
        echo "Already exists: ComfyUI_MD_Nodes"
      fi
      echo "All models ready."
    '';
  };
}
