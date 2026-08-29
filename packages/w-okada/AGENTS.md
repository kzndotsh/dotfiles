# AGENTS.md — packages/w-okada

> Scope: `packages/w-okada` — inherits [`AGENTS.md`](../AGENTS.md) unless noted.

Shell helpers for [w-okada/voice-changer](https://github.com/w-okada/voice-changer) — not a Nix-wrapped Python app (ROCm PyTorch stays in user venv).

## Commands

| Script | Role |
|--------|------|
| `w-okada-setup` | Clone repo + venv + ROCm torch + server deps → `~/.local/share/w-okada` |
| `w-okada-models` | Download starter RVC models → `server/model_dir/` (default: 48 kHz slot 0) |
| `w-okada-audio` | Seed server mode + processing defaults → `stored_setting.json` (CHUNK, EXTRA, F0, …) |
| `w-okada` | Singleton start (`systemctl --user start w-okada`) → http://127.0.0.1:18888/ |
| `w-okada --stop` | Stop unit + leftover `MMVCServerSIO` |
| `w-okada-mic` | Legacy pactl cleanup + verify declarative nodes exist |

## Consumer

- `modules/ai/w-okada.nix` — systemPackages, user unit, PipeWire virtual graph

## Upstream docs

- `tutorials/tutorial_anaconda_amd_rocm.md` — AMD Linux / ROCm
- `README_dev_en.md` — server dev (`server/MMVCServerSIO.py`)
- Issue #313 — Linux virtual mic (`pactl` + `pw-link`)

## Web UI (pitch / INDEX)

- TUNE (pitch): **+10..+14** (start +12)
- Index: **0.50–0.65** speech · **0.70+** stronger character lock
- F0: **rmvpe** (ROCm torch) · GAIN in/out: **1.0** · Protect: **0.33–0.50**
- RVC v2 `.pth` + `.index`
- Disable Discord Krisp / noise suppression / echo cancellation

## Optimizations (community)

| Goal | CHUNK | EXTRA | Notes |
|------|-------|-------|-------|
| Low latency | 112 | 8192–16384 | only if `res` stays under `buf` |
| Gaming + VC | **128** | **32768** | default (RX 6700 XT); unload Ollama; stereo patch required |
| Max quality | 128 | 32768–131072 | voice-only; extra is CPU |
| Stutter | +16 CHUNK | drop EXTRA to 16384 | or F0 `rmvpe_onnx`; raise until `res` < `buf` |

- **Server Device** not Client (latency); Sup1/Sup2 strip natural detail — use sparingly
- Clean mic > filters; noise gate default **-110** (don't set -41 unless loud room)
- PipeWire PortAudio `pipewire` device reports **128 channels** — `w-okada` patches `ServerDevice.py` to cap at stereo (stutter if skipped).
- Full cheat sheet: this file + comments in `default.nix`

Sources: [Lenylvt HF guide](https://huggingface.co/blog/Lenylvt/w-okada), issues #1525 #1387 #1503.

## Audio routing (Linux / PipeWire)

**Client mode** in the Web UI uses browser audio — input/output/monitor stay **none** on Linux. Use **server** mode.

| Role | Default pattern | Your hardware |
|------|-----------------|---------------|
| input | `pipewire\|default` | mic via PipeWire default source (never Yeti hw) |
| output | `pipewire` + `PULSE_SINK=VoiceChanger-Output` | set by `w-okada` launcher |
| monitor | **disabled** (`-1`) | hear self via declarative pulse loopback → FiiO |

Virtual graph is **declarative** in `modules/ai/w-okada.nix` (`virtualMic.enable`):
- null sinks (`context.objects`)
- WirePlumber Lua: output monitor → virtual mic
- `pulse.cmd` loopback: output monitor → `@DEFAULT_SINK@`

```bash
w-okada-audio --list          # PortAudio indices + names
w-okada-audio                 # write stored_setting.json (server mode)
VC_AUDIO_FORCE=1 w-okada-audio  # overwrite existing device picks
```

`w-okada` runs audio defaults automatically. Nix options: `ai.wOkada.audio.*` + `ai.wOkada.defaults.*`

### Processing defaults (CHUNK, EXTRA, F0, …)

Nix: `ai.wOkada.defaults.readChunkSize` (default **128**).  
`silenceFront` must be **off** — upstream defaults on; `w-okada` applies via API on start.

```nix
ai.wOkada.defaults = {
  readChunkSize = 128;
  extraConvertSize = 32768;
  f0Detector = "rmvpe";
  indexRatio = 0.55;
};
```

Overwrite stale UI values once: `VC_AUDIO_FORCE=1 w-okada-audio`  
Or `defaults.force = true` to re-apply every start.

Restart w-okada after seeding; refresh Web UI → AUDIO → **server** (not client).

## Gotchas

- First run: `w-okada-setup` (needs network; ~minutes)
- `PIP_USER=0` in setup — global pip `user=true` breaks venv installs
- Pin `setuptools<81` — 81+ drops `pkg_resources`; librosa import fails
- `fairseq` from [One-sixth/fairseq](https://github.com/One-sixth/fairseq) — PyPI fairseq breaks on Python 3.11; required for RVC HuBERT embedder (picking a model without it → UI `modelSlots` null crash)
- `pyworld --no-build-isolation` — DIO pitch extractor; also omitted from upstream `requirements.txt`
- `onnxruntime-gpu` skipped — CPU `onnxruntime` on AMD
- Unload Ollama before realtime GPU inference (12 GB VRAM)
- gfx1030 env matches ComfyUI/chatterbox (`HSA_OVERRIDE_GFX_VERSION=10.3.0`, `HSA_ENABLE_SDMA=0`)
- Override torch index: `W_OKADA_TORCH_INDEX=https://download.pytorch.org/whl/rocm6.2`
- Re-run `w-okada-setup` after Nix changes to refresh venv deps
- `w-okada` is a **singleton**: user unit `w-okada.service` + flock. Second `w-okada` is a no-op. Stop with `w-okada --stop`.
- CHUNK dropdown is **client worklet** (default **192**), not `serverReadChunkSize`. Leave it; picking **8192** (list bottom) crashes the audio callback. Stop hangs: HIP ignores SIGTERM — unit SIGKILLs after 10s (after `nh os switch`).

## Starter models (`w-okada-models`)

Default install is **48 kHz slot 0**. 32 kHz / 40 kHz models resample every chunk and sound choppy at server 48 kHz.

| Slot | SR | Notes | TUNE start |
|------|----|-------|------------|
| 0 | 48 kHz | default | +12 |
| 1 | 32 kHz | extra resample | +11 |
| 2 | 32 kHz | extra resample | +12 |
| 3 | 40 kHz | JP — credit [amitaro.net](https://amitaro.net/) if streaming | +12 |
| 4 | 40 kHz | extra resample | +12 |

```bash
w-okada-models                         # 48 kHz slot 0
W_OKADA_MODELS=all w-okada-models
w-okada-models --register-only         # rewrite params.json INDEX after inspect
```

Each slot: `params.json` + `.pth`. Legacy `starter/` dirs migrate automatically.

## Verify

```bash
w-okada-setup
w-okada-models
w-okada
```

## Related

- [`modules/ai/w-okada.nix`](../../modules/ai/w-okada.nix)
- [`modules/ai/AGENTS.md`](../../modules/ai/AGENTS.md)
