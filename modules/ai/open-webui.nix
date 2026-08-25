# Open WebUI — always-on chat UI → Ollama + ComfyUI + open-terminal.
# STT/TTS URLs come from ai.voice.openWebui (catalog in voice.nix).
#
# Native NixOS service (not Docker). Default listen is 127.0.0.1:8080;
# we bind 0.0.0.0:4000. Desktop firewall is on with all ports allowed → LAN can hit :4000.
# https://docs.openwebui.com/getting-started/env-configuration
# https://search.nixos.org/options?query=services.open-webui
{ config, ... }:
let
  voice = config.ai.voice;
  stt = voice.catalog.${voice.openWebui.stt};
  tts = voice.catalog.${voice.openWebui.tts};

  # ComfyUI API-format graph. Official: export via "Save (API Format)".
  # https://docs.openwebui.com/getting-started/env-configuration#comfyui_workflow
  # Node 0 is ComfyUI_MD_Nodes LLMVRAMManager (not stock). Cloned by comfyui-models.
  # latent 5 → 0 → 1 so unload finishes before KSampler (unconnected node raced).
  # Juggernaut XL v9 RDPhoto2 Lightning_4S: 4–6 steps, CFG 1–2, DPM++ SDE.
  # https://huggingface.co/imagepipeline/Juggernaut-XL-V9-RDPhoto2-Lightning_4S
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

  # Official type: list[dict]. Keys are type + node_ids (array) + key.
  # NOT field + node_id (that was the old bug). Env parse landed in open-webui#19918.
  # https://docs.openwebui.com/getting-started/env-configuration#comfyui_workflow_nodes
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
    # NixOS default 127.0.0.1. 0.0.0.0 = all ifaces (docs example).
    host = "0.0.0.0";
    # NixOS default 8080. Docker docs often map 3000:8080. We use 4000.
    port = 4000;
    environment = {
      # Official name is now OLLAMA_BASE_URL (default http://localhost:11434).
      # OLLAMA_API_BASE_URL is deprecated but still read (strips a trailing /api).
      # Left as-is — same host/port as the new name without /api.
      # https://docs.openwebui.com/getting-started/env-configuration#ollama_base_url
      OLLAMA_API_BASE_URL = "http://localhost:11434";
      # Official default True (DB/UI wins). False = env wins; UI edits die on restart.
      ENABLE_PERSISTENT_CONFIG = "False";

      # ─── RAG ───
      # Official engines: "" (SentenceTransformers) | ollama | openai | azure_openai
      RAG_EMBEDDING_ENGINE = "ollama";
      # Official default sentence-transformers/all-MiniLM-L6-v2. Must be in ollama loadModels.
      RAG_EMBEDDING_MODEL = "qwen3-embedding:0.6b";

      # ─── Image Generation (ComfyUI) ───
      # Official default False / openai / True (prompt enhance).
      ENABLE_IMAGE_GENERATION = "True";
      # Thinking models wrap JSON in <think> and break the prompt parser.
      ENABLE_IMAGE_PROMPT_GENERATION = "False";
      IMAGE_GENERATION_ENGINE = "comfyui";
      COMFYUI_BASE_URL = "http://localhost:8188";
      COMFYUI_WORKFLOW = comfyuiWorkflow;
      COMFYUI_WORKFLOW_NODES = comfyuiWorkflowNodes;
      # Empty default → Open WebUI sends blank ckpt_name. Must match a file in checkpoints/.
      IMAGE_GENERATION_MODEL = "juggernautXL_v9Rdphoto2Lightning.safetensors";
      # Official default 512x512.
      IMAGE_SIZE = "1024x1024";
      # Official default 50. Lightning_4S card is 4–6. Must match KSampler steps (node map writes this).
      IMAGE_STEPS = "6";

      # ─── Misc ───
      # Official default True. Extra Ollama calls on every keystroke — off on 12 GB.
      ENABLE_AUTOCOMPLETE_GENERATION = "False";
      # Official default INFO. DEBUG logs prompts/tokens. Always-on.
      GLOBAL_LOG_LEVEL = "DEBUG";
      # WEBUI_AUTH default True (first user = admin). WEBUI_SECRET_KEY unset —
      # NixOS stateDir persists the generated key. Do not rotate casually.

      # ─── TTS / STT (ai.voice.openWebui) ───
      # Native service → catalog 127.0.0.1 URLs work. ENABLE_PERSISTENT_CONFIG=False → env wins.
      # https://docs.openwebui.com/features/chat-conversations/audio/speech-to-text/env-variables
      # https://docs.openwebui.com/troubleshooting/audio/
      # Engine "openai" = any OpenAI-compatible /v1/audio/{speech,transcriptions}.
      # AUDIO_TTS_VOICE is unset → official default "alloy". Fish needs a real reference_id
      # (fish.audio/discover); Kokoro maps alloy via openai_mappings.json. moss/chatterbox
      # catalog.model is empty — set a voice/model in the request or this stays blank.
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
  # Official image + volume path. Port 8000 is the official default (clashes with Speaches).
  # https://docs.openwebui.com/features/open-terminal/setup/installation/
  # https://github.com/open-webui/open-terminal
  virtualisation.oci-containers.containers.open-terminal = {
    image = "ghcr.io/open-webui/open-terminal";
    # Binds 0.0.0.0:8000 (not 127.0.0.1). Desktop firewall off → LAN can hit it.
    ports = [ "8000:8000" ];
    volumes = [ "open-terminal:/home/user" ];
    # Official: OPEN_TERMINAL_API_KEY, or OPEN_TERMINAL_API_KEY_FILE (file contents = key).
    # https://docs.openwebui.com/features/open-terminal/advanced/configuration
    # Dedicated file — do not point at ai.env (this container is a shell; `env` would leak other keys).
    # Do not set both KEY and KEY_FILE.
    environmentFiles = [ "${config.my.secretsDir}/open-terminal.env" ];
    autoStart = true;
  };
}
