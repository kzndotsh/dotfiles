# AGENTS.md — ai

> Scope: `modules/ai` — inherits [`AGENTS.md`](../../AGENTS.md) unless noted.

Desktop AI inference, voice, and kiro-gateway. RX 6700 XT (12 GB VRAM, gfx1030) + 128 GB RAM.

**Rule:** Only one heavy GPU consumer at a time — Ollama or ComfyUI.

## Files

| File | Port(s) | Always on? | Role |
|------|---------|-----------|------|
| `default.nix` | — | — | Dispatcher; Docker backend |
| `ollama.nix` | `:11434` | yes | Ollama ROCm + custom models (no 30B/35B disk cache) |
| `comfyui.nix` | `:8188` | no | Image gen (Docker) — on-demand |
| `open-webui.nix` | `:4000` | yes | Chat UI + ComfyUI image gen + open-terminal (`:8000`, container on `0.0.0.0` — LAN-reachable) |
| `voice.nix` | catalog | no | STT/TTS; flags in `hosts/desktop/configuration.nix` |
| `w-okada.nix` | `:18888` | no | w-okada RVC (ROCm venv + virtual mic) |
| `kiro-gateway.nix` | `:9000` | yes | Anthropic-compatible proxy |
| `kirocrew.nix` | `:5476` | login | Kiro Crew gateway (user unit; drives `kiro-cli`) |
| `llmcord.nix` | — | yes | Discord bot (llmcord) → kiro-gateway `:9000`; `ai.llmcord.*`; token in `~/.secrets/llmcord.env` |
| `opencode.nix` | — | — | Declarative `~/.config/opencode/opencode.jsonc` (tmpfiles symlink) |
| `risuai.nix` | `:6001` | no | RisuAI character-chat UI (Docker) — on-demand; loopback only |
| `airi.nix` | `:6100` | no | AIRI Stage Web companion (Docker) — on-demand |

## Usage

```bash
systemctl start docker-comfyui        # :8188 — unload Ollama first (`ollama ps`)
systemctl start comfyui-models        # idempotent model downloads
systemctl start docker-speaches       # STT :8300
systemctl start docker-kokoro-tts     # TTS :8880
systemctl start fish-audio-suite-proxy # TTS :8849 (FISH_API_KEY; native service from the fish-audio-suite flake)
ollama run qwen2.5-coder:7b
ollama ps
systemctl start docker-risuai          # :6001 — character chat UI (Ollama in UI settings)
systemctl start docker-airi            # :6100 — AIRI companion UI (providers in browser)
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
- Context pinned 8k; `NUM_PARALLEL=1`, `MAX_LOADED_MODELS=1`, `KEEP_ALIVE=10m` — check `ollama ps` for spill to CPU
- `HSA_NO_SCRATCH_RECLAIM=1` holds scratch until service exit (VRAM tax)
- GameMode `keep_alive=0` unloads resident models
- One tag per recipe in `ollama ls`. GPU-fit only: 7–14B + Gemma 12B. No 30B/35B. Custom creates: `*-4k`, `dusk-rainbow`, `satyr-v0.1-4b`, `hauhau-*`, `gemma4-12b-heretic`, `gemmasutra-9b`, `hypernovasynth-12b`, `unslopnemo-12b`, `impish-bloodmoon-12b`, `kansensakura-eclipse-12b`. Do not also pull the `hf.co/...` FROM names.

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
- Start settings: CHUNK **128**, EXTRA **32768**, F0 **rmvpe**, Server Device, GAIN **1.0**; if `res` > `buf` try `rmvpe_onnx` / EXTRA **16384**
- Upstream Linux is clone+venv only (no HuggingFace Linux bundle); std Linux edition is Beatrice-only in v2.2+ — use **v1 server path** / git clone for **RVC on AMD**

### Venv breaks after nixos-rebuild (GC / Python store path change)

After `nh os switch` or `nix store gc`, the venv's Python symlink can point to a GC'd store path:
```
~/.local/share/w-okada/.venv/bin/python → /nix/store/<old-hash>-python3-3.11.16/bin/python  # broken
```
**Fix:** `rm -rf ~/.local/share/w-okada/.venv && git -C ~/.local/share/w-okada/src stash && w-okada-setup`
The git stash is needed because `w-okada-setup` does a `git pull` and the Nix wrapper patches `ServerDevice.py` on every start, leaving an unstaged change. Setup re-applies the patch itself so the stash is safe to discard.
The final `python -c "from fairseq..."` in setup will fail with `libzstd.so.1: cannot open shared object file` — that's expected (LD_LIBRARY_PATH not set in setup context). If it prints `RVC deps OK`, it's fine. If it exits 1 with libzstd error, the venv is still good — the runtime wrapper sets LD_LIBRARY_PATH correctly.

### Performance is [0, 0, 0, 0] — that's normal

The Web UI performance display always shows `[0, 0, 0, 0]`. This is intentional upstream — `enableMainprocessTimer = False` is hardcoded in `VoiceChangerV2.py`. It does **not** mean inference is broken or audio isn't flowing. Real inference timing (measured Sep 2026): **~167ms pipeline, ~170ms total** on a 48kHz model (RX 6700 XT). To check if audio is actually flowing: `pw-record --target VoiceChanger-Mic /tmp/test.wav && sleep 3 && ffmpeg -i /tmp/test.wav -af volumedetect -f null /dev/null 2>&1 | grep max_volume`.

### server audio start not auto-firing

The `apply-audio.py` script runs at unit start to seed `stored_setting.json` and trigger server audio via the w-okada API. If the API isn't ready yet (server still loading model), the call silently fails and server audio stays off — Web UI shows no conversion happening. Fix: open http://127.0.0.1:18888, click Start on the server audio panel. Or via API: `curl -s http://127.0.0.1:18888/update_settings -X POST -F "key=serverAudioStated" -F "val=1"`.

### Duplex stream patch in ServerDevice.py

PortAudio on PipeWire ALSA **cannot** run two separate half-duplex streams (InputStream + OutputStream) on device 11 simultaneously — the output callback holds the PipeWire graph lock and the input callback never fires, producing `[0,0,0,0]` with no audio conversion despite the graph looking correct. The Nix wrapper patches `ServerDevice.py` (`packages/w-okada/`) to use a single duplex `sd.Stream` when input and output are the same device. **Do not revert this patch** — without it, server audio appears to start but inference never runs.

### voiceChangerType is RVCr2, not RVC

All `.pth` models load as `RVCr2` (not `RVC`). The relevant inference code is `voice_changer/RVC/RVCr2.py`, not `RVC.py`. If debugging inference issues, patch `RVCr2.py`.

### Performance for gaming (VRAM contention)

RVC inference takes ~167ms on the 6700 XT with no other GPU load. When gaming simultaneously, VRAM contention can push this to 250ms+ causing audio glitches. Mitigation:
- Lower **Index Ratio** to 0.0–0.2 in the Web UI (cuts FAISS search cost; biggest win for large index models)
- Use **slot 6 — Zokax E-Girl** (48kHz, 190MB index) — the best gaming model: no resampy leak, lighter index than E-Girl
- Only slots 0 and 6 are 48kHz — all others (Sansin, Marcus, Daresiel, etc.) are 32kHz/40kHz and spawn a resampy worker that leaks RAM up to 16GB over a session
- `f0Detector = rmvpe_onnx` is faster than `rmvpe` on ROCm if inference is tight

### Running w-okada alongside CS2 (12GB VRAM, 128GB RAM)

**RAM:** Use only 48kHz models (Zokax E-Girl slot 6, E-Girl slot 0). 32kHz/40kHz models (Sansin, Marcus, Daresiel, Female, Amitaro, rvc_okiba) spawn a `resampy` multiprocessing worker that leaks memory — seen accumulating to 16GB over a session, which starves CS2 and causes crashes.

**VRAM:** CS2 uses 4–6GB, w-okada RVC uses 2–3GB — fits in 12GB but tight. Correct startup order:
```bash
w-okada --stop          # ensure clean slate
# launch CS2, wait for main menu
w-okada                 # start after CS2 has claimed its VRAM
# Web UI: select Zokax E-Girl (slot 6), Index Ratio 0.0–0.2, click Start
```
Starting w-okada before CS2 risks CS2 OOMing on launch. Starting after lets CS2 claim what it needs first and w-okada uses the remainder.

**GameMode** already unloads Ollama via `keep_alive=0` before CS2 (`gamemoderun %command%`). w-okada is not managed by GameMode — stop it manually if CS2 is stuttering or crashing.

### Microphone bleed / gibberish from others' voices

The Yeti X picks up audio bleeding from headphones. w-okada converts everything above the silence threshold — including other people's voices leaking through headphones. This produces distorted/robotic playback in the monitoring loopback. Fix: raise `S. Threshold` in the Web UI (try `0.001`), lower headphone volume, or use closed-back headphones.

## Voice gotchas

- `moss-tts-nano-fixed`, `chatterbox-tts-rocm` are **local Docker images** (not flake outputs). Fish is the `fish-audio-suite` flake input (github:kzndotsh/fish-audio-suite): `services.fish-audio-suite-proxy` plus the `fish-voice` CLI, both gated on `ai.voice.fish.enable`. The old Docker proxy and standalone voice agent are in local `archive/`
- Fish proxy: Open WebUI → OpenAI API → Fish native API (fish-audio-suite proxy, systemd service)
- `fish-voice` (duplex mic → LLM → Fish) reads only process env, `--env-file`, or `./.env`. `ai.env` has just `FISH_API_KEY`; the full voice config (`FISH_VOICE_ID`, LLM keys, tuning) is the suite repo's `.env`, so run `fish-voice --env-file <that file>`. Suite changes reach the desktop via `nix flake update fish-audio-suite`
- Chatterbox fights Ollama for GPU (~6–7 GB)

## Open WebUI gotchas

- `ENABLE_PERSISTENT_CONFIG=False` — env wins over Admin UI
- `ENABLE_IMAGE_PROMPT_GENERATION=False` — thinking models break JSON prompt parser
- `COMFYUI_WORKFLOW_NODES`: `type` + `node_ids` + `key` (not `field` + `node_id`)
- open-terminal key: `~/.secrets/open-terminal.env` (`OPEN_TERMINAL_API_KEY`)

## OpenCode gotchas

- Config: tmpfiles symlink `~/.config/opencode/opencode.jsonc` — Kiro `apiKey` is `{file:~/.secrets/kiro-proxy-api-key}` (written by `kiro-gateway` from `PROXY_API_KEY` in `ai.env`). Do not use `{env:PROXY_API_KEY}` — login session does not source `ai.env`. Only `claude-sonnet-4-6` is defined (1M context / 8192 output, `http://127.0.0.1:9000/v1`); add models in `opencode.nix`. No `ai.*` flag — always on via `modules/ai/default.nix`.
- After first `ai.env` key setup or key rotation: `sudo systemctl restart kiro-gateway` (recreates the key file), then retry OpenCode.

## Kiro Crew gotchas

- Enable: `ai.kirocrew.enable` in `hosts/desktop/configuration.nix` (on)
- Package: pinned wheel in `packages/kirocrew` (not nixpkgs, not `curl | sh`)
- Unit: **user** `kirocrew.service` — `systemctl --user start kirocrew`. Do not run `kirocrew service install` (writes `/etc/systemd` outside Nix)
- URL: http://127.0.0.1:5476 after the user unit is up. Loopback only
- Agent: wrapper sets `KIROCREW_KIRO_BIN` to nixpkgs `kiro-cli-unwrapped` (not the FHS `bwrap` wrapper — that cannot nest inside Crew's mount namespace). Login is the existing Builder ID under `~/.kiro`
- PATH: the user unit adds `/run/wrappers` and `/run/current-system/sw`, so the gateway sees `environment.systemPackages` (`git`, `gh`, …). It does not see `~/.local/bin`
- State: `~/.kiro/crew`. First start downloads the ~610 MB embedding model into `~/.kiro/crew/models/`
- This is not `kiro-gateway` (`:9000`, OpenCode / Anthropic proxy)

## kiro-gateway gotchas

- Binds `127.0.0.1:9000`; official API key env is `PROXY_API_KEY` in `~/.secrets/ai.env`
- Syncs `~/.secrets/kiro-proxy-api-key` (mode `600`) for OpenCode on each service start
- `kiro-gateway` is a **system** unit; named tunnel `cloudflared-kiro` → `kiro.kzn.sh` is a **user** unit (creds from `nix run .#vps-tunnels-sync`)
- Patches: `packages/kiro-gateway/patch-cursor.py`

## RisuAI gotchas

- Enable: `ai.risuai.enable` in `hosts/desktop/configuration.nix`
- Unit: **`docker-risuai`** (oci-containers). Data: `/var/lib/risuai` → `/app/save`
- URL: http://127.0.0.1:6001 after `systemctl start docker-risuai`
- Port is published as `127.0.0.1:${port}:6001` (loopback only, like AIRI); the desktop firewall allows all ports, so keep the prefix
- Ollama: UI → Ollama (local) / `ollama-hosted`, URL `http://127.0.0.1:11434`, model from `ollama list`
- Alternate OpenAI-compatible: custom/reverse_proxy → `http://127.0.0.1:11434/v1/...` + placeholder key
- TTS later: RisuAI built-in TTS and/or `ai.voice` OpenAI-compatible backends — not wired in Nix yet
- Image: `risuai:local` via `packages/risuai/build.sh` (not GHCR `latest`, which always shows the Legal documents popup)

## AIRI gotchas

- Enable: `ai.airi.enable` in `hosts/desktop/configuration.nix`
- Unit: **`docker-airi`** (oci-containers). Image: `airi:local` via `packages/airi/build.sh` (static nginx; pinned `v0.11.3`; GHCR `latest` needs auth)
- URL: http://127.0.0.1:6100 after `systemctl start docker-airi`
- Providers are **in-browser** (localStorage), not container env: OpenRouter / Ollama `http://127.0.0.1:11434/v1` / Fish via `http://127.0.0.1:8849/v1` (start `fish-audio-suite-proxy`)
- Desktop Tamagotchi (preferred for voice/overlay): extracted `.deb` + `packages/airi/fhs.nix` (see `packages/airi/AGENTS.md`); `nix run github:moeru-ai/airi` fails
- Docker web is secondary for browser access only
- Browser: Chromium-based with WebGPU preferred for Live2D/VRM stage

## See also

- [`modules/hardware/`](../hardware/) — AMDGPU, ROCm, LACT
- [`modules/gaming/AGENTS.md`](../gaming/AGENTS.md) — GameMode, CS2 launch options
- [`packages/kiro-gateway/`](../../packages/kiro-gateway/)
