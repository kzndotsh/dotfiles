# ComfyUI image generation — on-demand Docker container with a local ROCm 7.2 image.
# autoStart = false; unload Ollama first on 12 GB VRAM. Image is built locally, not pulled by Nix.
{ pkgs, lib, config, ... }:
let
  modelsDir = "/opt/comfyui/models";
  customNodesDir = "/opt/comfyui/custom_nodes";
  wget = lib.getExe pkgs.wget;
  git = lib.getExe pkgs.git;

  # dest paths match ComfyUI folder names. CivitAI downloads need a token in ai.env.
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

    # VAE files for Flux checkpoints.
    { url = "https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors"; dest = "vae/ae.safetensors"; }
    { url = "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors"; dest = "vae/flux2-vae.safetensors"; }

    # Upscaler models for post-processing.
    { url = "https://huggingface.co/Kim2091/AnimeSharp/resolve/main/4x-AnimeSharp.pth"; dest = "upscale_models/4x-AnimeSharp.pth"; }
    { url = "https://huggingface.co/Kim2091/UltraSharp/resolve/main/4x-UltraSharp.pth"; dest = "upscale_models/4x-UltraSharp.pth"; }
    { url = "https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth"; dest = "upscale_models/4xNMKDSuperscale.pth"; }
    { url = "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/1x-ITF-SkinDiffDetail-Lite-v1.pth"; dest = "upscale_models/1x-ITF-SkinDiffDetail-Lite-v1.pth"; }

    # LoRA weights.
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
    devices = [ "/dev/kfd:/dev/kfd" "/dev/dri:/dev/dri" ];
    extraOptions = [
      "--group-add" "video"
      "--add-host=host.docker.internal:host-gateway"
      # Host networking lets LLMVRAMManager reach Ollama on :11434 and binds ComfyUI on all interfaces.
      # Desktop firewall allows all ports, so :8188 is LAN-reachable.
      "--network=host"
    ];
    environment = {
      # Spoof gfx1031 as gfx1030 — same pin as ollama and chatterbox.
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";
      # SDMA copies page-fault on gfx1030; disable them for PyTorch/ComfyUI stability.
      HSA_ENABLE_SDMA = "0";
      # Keep scratch memory until exit — avoids ROCm timeout issues on this GPU.
      HSA_NO_SCRATCH_RECLAIM = "1";
      # Leave at 0 for normal async launches; 1 is debug-only and costs 30–50% throughput.
      HIP_LAUNCH_BLOCKING = "0";
      # gfx1030 isn't on AMD's AOTriton allowlist — enable experimental SDPA anyway.
      TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL = "1";
      # Force MIOpen path; cuDNN doesn't exist on ROCm but some wheels still probe it.
      TORCH_CUDNN_ENABLED = "0";
      # HIP allocator tuning for gfx1030 (see Comfy-Org/ComfyUI#2471).
      PYTORCH_HIP_ALLOC_CONF = "garbage_collection_threshold:0.7,max_split_size_mb:4096";
      # Persist MIOpen Find-Db on the host volume so ~/.cache/miopen doesn't corrupt.
      MIOPEN_USER_DB_PATH = "/workspace/ComfyUI/.miopen";
      MIOPEN_CUSTOM_CACHE_DIR = "/workspace/ComfyUI/.miopen";
      # HYBRID find mode — use cached kernels when available, benchmark otherwise.
      MIOPEN_FIND_MODE = "3";
      MIOPEN_CONV_PRECISE_ROCBLAS_TIMING = "0";
      # ComfyUI_MD_Nodes LLMVRAMManager unloads Ollama before generation — needs host net.
      MD_OLLAMA_HOST = "http://localhost:11434";
    };
    # --listen 0.0.0.0 exposes all interfaces; --fp16-vae saves VRAM; --lowvram offloads encoders to CPU.
    # --reserve-vram 2.5 leaves headroom for the OS. Do not pass --enable-dynamic-vram (crashes gfx1030).
    # pip on every start keeps recreations working even though baking deps into the image would be cleaner.
    cmd = [ "bash" "-c" "pip install -q gguf opencv-python-headless segment-anything scikit-image piexif dill matplotlib scipy requests && python3 main.py --listen 0.0.0.0 --port 8188 --fp16-vae --lowvram --reserve-vram 2.5" ];
    # Docker creates missing host dirs as root — comfyui-models runs as the desktop user instead.
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

  # On-demand disk pull. Does not start ComfyUI. Skips files that already exist.
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
      # huggingface-token holds HF_TOKEN; ai.env holds CIVITAI_TOKEN and other keys.
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
            ${wget} -q --show-progress -O "$dest.tmp" "$url"
          else
            ${wget} -q --show-progress --header="Authorization: Bearer $HF_TOKEN" -O "$dest.tmp" "${m.url}"
          fi
          mv "$dest.tmp" "$dest"
        else
          echo "Already exists: ${m.dest}"
        fi
      '') models}
      # Open WebUI's graph needs LLMVRAMManager — clone it, don't pip -r (CUDA wheels).
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
