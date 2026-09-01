# AGENTS.md — ai

> Scope: `modules/ai` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Desktop AI inference, voice, and kiro-gateway. RX 6700 XT (12 GB VRAM, gfx1030) + 128 GB RAM.

**Rule:** Only one heavy GPU consumer at a time — Ollama MoE or ComfyUI.

## Files

| File | Port(s) | Always on? | Role |
|------|---------|-----------|------|
| `default.nix` | — | — | Dispatcher; Docker backend |
| `ollama.nix` | `:11434` | yes | Ollama ROCm + custom models + MoE downloads |
| `comfyui.nix` | `:8188` | no | Image gen (Docker) — on-demand |
| `open-webui.nix` | `:4000` | yes | Chat UI + ComfyUI image gen + open-terminal |
| `voice.nix` | catalog | no | STT/TTS; flags in `hosts/desktop/configuration.nix` |
| `w-okada.nix` | `:18888` | no | w-okada RVC (ROCm venv + virtual mic) |
| `kiro-gateway.nix` | `:9000` | yes | Anthropic-compatible proxy |

## Usage

```bash
systemctl start docker-comfyui        # :8188 — unload Ollama first (`ollama ps`)
systemctl start comfyui-models        # idempotent model downloads
systemctl start docker-speaches       # STT :8300
systemctl start docker-kokoro-tts     # TTS :8880
systemctl start docker-fish-tts-proxy # TTS :8849 (FISH_API_KEY)
ollama run qwen3-coder-unsloth
ollama ps
```

## Verify

```bash
nix build .#nixosConfigurations.ikigai.config.system.build.toplevel
```

## ROCm / gfx1030 (RX 6700 XT)

- Spoof gfx1031 as gfx1030: `HSA_OVERRIDE_GFX_VERSION=10.3.0` (Ollama + ComfyUI)
- **Ollama:** works with flash attention + q8_0 KV cache
- **ComfyUI:** Docker only — image `qinzhen/comfyui-rocm72:local` (ROCm 7.2 matched stack). Native pip/venv wheels are broken on gfx1030 (MIOpen / hipBLASLt). See `comfyui.nix` for env vars.
- **Do not** use `--enable-dynamic-vram` on gfx1030 (GPU coredump)
- **Do not** force COMPUTE power profile from udev (fights 3D games)
- Kernel: `amdgpu.lockup_timeout=5000,...`, `gpu_recovery=1` in `boot/kernel.nix`
- GameMode unloads Ollama before CS2 (`gamemoderun %command%`)

### ComfyUI (active config)

- Unit: **`docker-comfyui`**, not `comfyui`
- Launch args: `--listen 0.0.0.0 --port 8188 --fp16-vae --lowvram --reserve-vram 2.5`
- **Do not add:** `--enable-dynamic-vram`, `--disable-smart-memory`, `--reserve-vram 3`, `HIP_LAUNCH_BLOCKING=1`
- Image must exist locally; `comfyui-models` needs `~/.secrets/huggingface-token` + `CIVITAI_TOKEN` in `~/.secrets/ai.env`
- First Docker start may create `/opt/comfyui` as root — `chown` once if `comfyui-models` cannot write

### VRAM (12 GB, 2.5 GB reserved)

SDXL alone works with Ollama unloaded. SDXL + large LLM or FLUX schnell alone will OOM.

## Ollama gotchas

- **Do not** set `services.ollama.syncModels = true` — deletes custom aliases
- Custom creates: `*-4k`, dusk-rainbow, satyr, hauhau, gemmasutra-9b, hypernovasynth-12b, unslopnemo-12b, impish-bloodmoon-12b, kansensakura-eclipse-12b. Do not also pull the `hf.co/...` FROM names
- Context pinned 8k; `NUM_PARALLEL=2` doubles KV — check `ollama ps` for spill to CPU
- `HSA_NO_SCRATCH_RECLAIM=1` holds scratch until service exit (VRAM tax)
- GameMode `keep_alive=0` unloads resident models

## w-okada gotchas

- Enable: `ai.wOkada` in `hosts/desktop/configuration.nix`
- One-time: `w-okada-setup` → venv under `~/.local/share/w-okada`
- Models: `w-okada-models` → **48 kHz** slot 0 by default. 32k/40k: `W_OKADA_MODELS=all`
- Setup installs `fairseq` (py311 fork) + `pyworld` — not in upstream `requirements.txt`; re-run setup if model pick crashes
- Start: `w-okada` (singleton user unit, Web UI :18888) — **unload Ollama first** on 12 GB VRAM
- Stop / restart: `w-okada --stop` then `w-okada` (or `systemctl --user restart w-okada`). Unit `TimeoutStopSec=10s` then SIGKILL — HIP children ignore TERM. Do not `systemd-run` a second copy
- Do **not** change Web UI **CHUNK** — dropdown is the worklet default (192), last entries go to **8192** and explode the PortAudio buffer. Server is Nix **128**; pick 128 only to sync the label
- Virtual mic: declarative PipeWire graph in `w-okada.nix` — sinks, WirePlumber links, pulse loopback
- **Server** audio mode in Web UI (not client) — client mode shows empty devices on Linux
- Output routing: `PULSE_SINK=VoiceChanger-Output` in `w-okada` (no route daemon)
- Auto routing: `w-okada-audio` or `ai.wOkada.audio.autoDefaults`
- Pitch: TUNE **+10..+14** in Web UI; disable Discord Krisp
- Tuning cheat sheet: `packages/w-okada/AGENTS.md`
- Start settings: CHUNK **128**, EXTRA **32768**, F0 **rmvpe**, Server Device, GAIN **1.0**; if `res` > `buf` try `rmvpe_onnx` / EXTRA **16384`
- Upstream Linux is clone+venv only (no HuggingFace Linux bundle); std Linux edition is Beatrice-only in v2.2+ — use **v1 server path** / git clone for **RVC on AMD**

## Voice gotchas

- `fish-tts-proxy`, `moss-tts-nano-fixed`, `chatterbox-tts-rocm` are **local Docker images** (not flake outputs)
- Fish proxy: Open WebUI → OpenAI API → Fish native API (`packages/fish-tts-proxy/`)
- Chatterbox fights Ollama for GPU (~6–7 GB)

## Open WebUI gotchas

- `ENABLE_PERSISTENT_CONFIG=False` — env wins over Admin UI
- `ENABLE_IMAGE_PROMPT_GENERATION=False` — thinking models break JSON prompt parser
- `COMFYUI_WORKFLOW_NODES`: `type` + `node_ids` + `key` (not `field` + `node_id`)
- open-terminal key: `~/.secrets/open-terminal.env` (`OPEN_TERMINAL_API_KEY`)

## kiro-gateway gotchas

- Binds `127.0.0.1:9000`; official API key env is `PROXY_API_KEY` in `~/.secrets/ai.env`
- Named tunnel `cloudflared-kiro` → `kiro.kzn.sh` (creds from `nix run .#vps-tunnels-sync`)
- Patches: `packages/kiro-gateway/patch-cursor.py`

## See also

- [`modules/hardware/`](../hardware/) — AMDGPU, ROCm, LACT
- [`modules/gaming/AGENTS.md`](../gaming/AGENTS.md) — GameMode, CS2 launch options
- [`packages/kiro-gateway/`](../../packages/kiro-gateway/)
- [`packages/fish-tts-proxy/`](../../packages/fish-tts-proxy/)
