# Open WebUI chat UI — always on, talks to Ollama, ComfyUI, and the voice backends.
# Binds 0.0.0.0:4000; desktop firewall allows all ports so LAN clients can reach it.
{ config, ... }:
let
  voice = config.ai.voice;
  stt = voice.catalog.${voice.openWebui.stt};
  tts = voice.catalog.${voice.openWebui.tts};

  # ComfyUI API-format graph — export via "Save (API Format)" in the UI.
  # Node 0 is ComfyUI_MD_Nodes LLMVRAMManager (cloned by comfyui-models).
  # latent 5 → 0 → 1 so Ollama unload finishes before KSampler starts.
  # Juggernaut XL v9 RDPhoto2 Lightning_4S: 4–6 steps, CFG 1–2, DPM++ SDE.
  comfyuiWorkflow = builtins.toJSON {
    "0" = {
      inputs = {
        action = "Unload Ollama Models (API)";
        trigger = true;
        latent_in = [ "5" 0 ];
      };
      class_type = "LLMVRAMManager";
    };
    "1" = {
      inputs = {
        seed = 0; steps = 6; cfg = 2.0;
        sampler_name = "dpmpp_sde"; scheduler = "normal"; denoise = 1;
        model = [ "2" 0 ]; positive = [ "3" 0 ];
        negative = [ "4" 0 ]; latent_image = [ "0" 4 ];
      };
      class_type = "KSampler";
    };
    "2" = {
      inputs = { ckpt_name = "juggernautXL_v9Rdphoto2Lightning.safetensors"; };
      class_type = "CheckpointLoaderSimple";
    };
    "3" = {
      inputs = { text = "Prompt"; clip = [ "2" 1 ]; };
      class_type = "CLIPTextEncode";
    };
    "4" = {
      inputs = { text = "(worst quality, low quality:1.4), blurry, jpeg artifacts, (cartoon, anime, illustration:1.3), 3d render, cgi, bad anatomy, (bad hands, malformed hands, wrong fingers:1.3), extra limbs, deformed, disfigured, ugly, plastic skin, text, watermark, signature, unrealistic"; clip = [ "2" 1 ]; };
      class_type = "CLIPTextEncode";
    };
    "5" = {
      inputs = { width = 1024; height = 1024; batch_size = 1; };
      class_type = "EmptyLatentImage";
    };
    "6" = {
      inputs = { samples = [ "1" 0 ]; vae = [ "2" 2 ]; };
      class_type = "VAEDecode";
    };
    "7" = {
      inputs = { filename_prefix = "openwebui"; images = [ "6" 0 ]; };
      class_type = "SaveImage";
    };
  };

  # Open WebUI expects type + node_ids (array) + key — not the old field + node_id shape.
  comfyuiWorkflowNodes = builtins.toJSON [
    { type = "prompt"; node_ids = [ "3" ]; key = "text"; }
    { type = "model"; node_ids = [ "2" ]; key = "ckpt_name"; }
    { type = "width"; node_ids = [ "5" ]; key = "width"; }
    { type = "height"; node_ids = [ "5" ]; key = "height"; }
    { type = "steps"; node_ids = [ "1" ]; key = "steps"; }
    { type = "seed"; node_ids = [ "1" ]; key = "seed"; }
  ];
in
{
  services.open-webui = {
    enable = true;
    host = "0.0.0.0"; # Listen on all interfaces, not just localhost
    port = 4000;
    environment = {
      # Deprecated name but still works — same host/port as OLLAMA_BASE_URL without /api.
      OLLAMA_API_BASE_URL = "http://localhost:11434";
      # Env wins over Admin UI edits — UI changes won't survive a restart.
      ENABLE_PERSISTENT_CONFIG = "False";

      # RAG embeddings via Ollama instead of bundled SentenceTransformers.
      RAG_EMBEDDING_ENGINE = "ollama";
      RAG_EMBEDDING_MODEL = "qwen3-embedding:0.6b"; # Must be in ollama loadModels

      # Image generation through the local ComfyUI container.
      ENABLE_IMAGE_GENERATION = "True";
      # Thinking models wrap JSON in tags and break the prompt parser.
      ENABLE_IMAGE_PROMPT_GENERATION = "False";
      IMAGE_GENERATION_ENGINE = "comfyui";
      COMFYUI_BASE_URL = "http://localhost:8188";
      COMFYUI_WORKFLOW = comfyuiWorkflow;
      COMFYUI_WORKFLOW_NODES = comfyuiWorkflowNodes;
      # Without this, Open WebUI sends a blank ckpt_name — must match a file in checkpoints/.
      IMAGE_GENERATION_MODEL = "juggernautXL_v9Rdphoto2Lightning.safetensors";
      IMAGE_SIZE = "1024x1024";
      IMAGE_STEPS = "6"; # Lightning checkpoint wants 4–6; must match KSampler in the workflow

      # Autocomplete fires extra Ollama calls on every keystroke — too expensive on 12 GB VRAM.
      ENABLE_AUTOCOMPLETE_GENERATION = "False";
      GLOBAL_LOG_LEVEL = "DEBUG"; # Always-on service — DEBUG helps trace prompt/token issues
      # WEBUI_AUTH stays on (first user becomes admin). Secret key persists in stateDir — don't rotate casually.

      # Speech I/O — URLs come from ai.voice catalog; Open WebUI uses OpenAI-compatible endpoints.
      AUDIO_TTS_ENGINE = "openai";
      AUDIO_TTS_OPENAI_API_BASE_URL = tts.url;
      AUDIO_TTS_OPENAI_API_KEY = "unused";
      AUDIO_TTS_MODEL = tts.model;

      AUDIO_STT_ENGINE = "openai";
      AUDIO_STT_OPENAI_API_BASE_URL = stt.url;
      AUDIO_STT_OPENAI_API_KEY = "unused";
      AUDIO_STT_MODEL = stt.model;
    };
  };

  # Open Terminal — tool backend for the UI (User Settings → Integrations).
  # https://docs.openwebui.com/features/open-terminal/setup/installation/
  virtualisation.oci-containers.containers.open-terminal = {
    image = "ghcr.io/open-webui/open-terminal";
    ports = [ "8000:8000" ]; # Binds 0.0.0.0 — desktop firewall allows LAN access
    volumes = [ "open-terminal:/home/user" ];
    # Dedicated secrets file — don't point at ai.env (this container is a shell; env would leak other keys).
    environmentFiles = [ "${config.my.secretsDir}/open-terminal.env" ];
    autoStart = true;
  };
}
