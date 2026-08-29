# w-okada helpers — ROCm venv in ~/.local/share/w-okada (not a full Nix wrap).
# Upstream: tutorials/tutorial_anaconda_amd_rocm.md, README_dev_en.md, issue #313 (virtual mic).
# Tuning cheat sheet: packages/w-okada/AGENTS.md
#
# Web UI: TUNE +10..+14 (start +12), INDEX 0.55–0.65, F0 rmvpe, GAIN 1.0, Protect 0.33–0.50
# Latency (RX 6700 XT): Server Device mode; CHUNK 128, EXTRA 32768; buf > res in UI; F0 rmvpe
# Routing: input=real mic, output=Voice Changer Output, Discord/OBS=Voice Changer Mic; disable Krisp/AGC
{
  pkgs,
  lib,
  writeShellApplication,
  audioDefaults ? {
    enableServerAudio = 1;
    inputPattern = "pipewire|default";
    outputPattern = "pipewire";
    # -1 = disable VC monitor; hear yourself via declarative pulse loopback
    monitorDeviceId = -1;
  },
  processingDefaults ? {
    readChunkSize = 128;
    extraConvertSize = 32768;
    crossFadeOverlapSize = 4096;
    sampleRate = 48000;
    f0Detector = "rmvpe";
    indexRatio = 0.55;
    pitchSemitones = 12;
    silenceFront = 0;
    silentThreshold = 0.00001;
    protect = 0.5;
  },
  defaultsForce ? false,
}:
let
  python = pkgs.python311;
  pip = pkgs.python311Packages.pip;
  dataDirDefault = ''"$HOME/.local/share/w-okada"'';

  rocmEnv = ''
    export HSA_OVERRIDE_GFX_VERSION="''${HSA_OVERRIDE_GFX_VERSION:-10.3.0}"
    export HSA_ENABLE_SDMA="''${HSA_ENABLE_SDMA:-0}"
    export HSA_NO_SCRATCH_RECLAIM="''${HSA_NO_SCRATCH_RECLAIM:-1}"
    export HIP_LAUNCH_BLOCKING="''${HIP_LAUNCH_BLOCKING:-0}"
    export TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL="''${TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL:-1}"
    export TORCH_CUDNN_ENABLED="''${TORCH_CUDNN_ENABLED:-0}"
    export PYTORCH_HIP_ALLOC_CONF="''${PYTORCH_HIP_ALLOC_CONF:-garbage_collection_threshold:0.7,max_split_size_mb:4096}"
  '';

  resolveDirs = ''
    DATA_DIR="''${W_OKADA_DATA_DIR:-${dataDirDefault}}"
    REPO_DIR="''${W_OKADA_REPO_DIR:-$DATA_DIR/src}"
    VENV_DIR="''${W_OKADA_VENV_DIR:-$DATA_DIR/.venv}"
    SERVER_DIR="''${W_OKADA_SERVER_DIR:-$REPO_DIR/server}"
  '';

  requireSetup = ''
    ${resolveDirs}

    if [[ ! -x "$VENV_DIR/bin/python" || ! -f "$SERVER_DIR/MMVCServerSIO.py" ]]; then
      echo "w-okada is not set up. Run: w-okada-setup" >&2
      exit 1
    fi
  '';

  activateVenv = ''
    # shellcheck disable=SC1091
    source "$VENV_DIR/bin/activate"
    ${vcLibraryEnv}
    ${rocmEnv}
  '';

  # w-okada slots: model_dir/<0..N>/params.json + .pth/.index (not subfolders — UI ignores them).
  # Default install is 48 kHz only (matches server SR). 32k/40k slots resample every chunk → chop.
  starterModels = lib.imap0 (slot: m: m // { inherit slot; }) [
    {
      id = "pendmg-48k";
      label = "pendmg 48 kHz English (w-okada recommended)";
      tune = 12;
      sampleRate = 48000;
      zip = "https://huggingface.co/pendmg/Models/resolve/main/egirl.zip";
    }
    {
      id = "sansin";
      label = "Sansin — 32 kHz";
      tune = 11;
      sampleRate = 32000;
      zip = "https://huggingface.co/lynn43/model/resolve/main/san480epoch.zip";
    }
    {
      id = "dmr-32k";
      label = "DMR 32 kHz";
      tune = 12;
      sampleRate = 32000;
      zip = "https://huggingface.co/Razer112/Public_Models/resolve/main/Female.zip";
    }
    {
      id = "amitaro";
      label = "Amitaro — 40 kHz JP (credit amitaro.net if you stream)";
      tune = 12;
      sampleRate = 40000;
      pth = "https://huggingface.co/wok000/vcclient_model/resolve/main/rvc_v2_alpha/amitaro/amitaro_v2_40k_e100.pth";
      index = "https://huggingface.co/wok000/vcclient_model/resolve/main/rvc_v2_alpha/amitaro/added_IVF3139_Flat_nprobe_1_v2.index.bin";
    }
    {
      id = "okiba-k3";
      label = "rvc_okiba K3 — 40 kHz";
      tune = 12;
      sampleRate = 40000;
      pth = "https://huggingface.co/ttttdiva/rvc_okiba/resolve/main/models/K3/K3_e300.pth";
      index = "https://huggingface.co/ttttdiva/rvc_okiba/resolve/main/models/K3/K3.index";
    }
  ];

  defaultModelIds = lib.concatMapStringsSep "," (m: m.id) (
    builtins.filter (m: m.sampleRate == 48000) starterModels
  );

  mkModelDirCheck = ''
    ${resolveDirs}
    MODEL_ROOT="''${W_OKADA_MODEL_DIR:-$REPO_DIR/server/model_dir}"
    mkdir -p "$MODEL_ROOT"
  '';

  starterModelInstallScript = lib.concatMapStringsSep "\n\n" (m:
    if m ? zip then
      "install_zip \"${toString m.slot}\" \"${m.id}\" \"${m.zip}\" \"${m.label}\" \"${toString m.tune}\""
    else
      "install_files \"${toString m.slot}\" \"${m.id}\" \"${m.label}\" \"${toString m.tune}\" \"${m.pth}\" \"${m.index}\""
  ) starterModels;

  # PyTorch ROCm wheel in user venv needs host libs Nix does not put on PATH by default.
  vcRuntimeLibs = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    (lib.getLib zstd)
    portaudio
  ];

  vcLibraryEnv = ''
    export LD_LIBRARY_PATH="${lib.makeLibraryPath vcRuntimeLibs}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  '';

  # PipeWire PortAudio device reports 128ch; upstream opens maxInputChannels → stutter/cutoffs.
  # Also patch output queue drain — upstream drops every backlog frame → audible gaps.
  patchServerDevicePy = pkgs.writeText "w-okada-patch-server-device.py" ''
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()
changed = []

if "def cap_portaudio_channels" not in text:
    helper = """
def cap_portaudio_channels(channels: int) -> int:
    # PipeWire PortAudio reports 128ch; opening all of them overloads inference and drops audio.
    return 2 if channels > 2 else channels


"""
    needle = "class ServerDevice:"
    if needle not in text:
        print("ServerDevice.py layout changed — stereo patch failed", file=sys.stderr)
        raise SystemExit(1)
    text = text.replace(needle, helper + needle, 1)
    replacements = [
        (
            "self.runNoMonitorSeparate(block_frame, serverInputAudioDevice.maxInputChannels, serverOutputAudioDevice.maxOutputChannels",
            "self.runNoMonitorSeparate(block_frame, cap_portaudio_channels(serverInputAudioDevice.maxInputChannels), cap_portaudio_channels(serverOutputAudioDevice.maxOutputChannels)",
        ),
        (
            "self.runWithMonitorStandard(block_frame, serverInputAudioDevice.maxInputChannels, serverOutputAudioDevice.maxOutputChannels, serverMonitorAudioDevice.maxOutputChannels",
            "self.runWithMonitorStandard(block_frame, cap_portaudio_channels(serverInputAudioDevice.maxInputChannels), cap_portaudio_channels(serverOutputAudioDevice.maxOutputChannels), cap_portaudio_channels(serverMonitorAudioDevice.maxOutputChannels)",
        ),
        (
            "self.runWithMonitorAllSeparate(block_frame, serverInputAudioDevice.maxInputChannels, serverOutputAudioDevice.maxOutputChannels, serverMonitorAudioDevice.maxOutputChannels",
            "self.runWithMonitorAllSeparate(block_frame, cap_portaudio_channels(serverInputAudioDevice.maxInputChannels), cap_portaudio_channels(serverOutputAudioDevice.maxOutputChannels), cap_portaudio_channels(serverMonitorAudioDevice.maxOutputChannels)",
        ),
    ]
    for old, new in replacements:
        if old not in text:
            print(f"missing stereo patch site: {old[:72]}", file=sys.stderr)
            raise SystemExit(1)
        text = text.replace(old, new, 1)
    changed.append("stereo cap")

queue_marker = "# vc-nix: queue-depth-fix"
if queue_marker not in text:
  queue_replacements = [
      (
          """            out_wav = self.outQueue.get()
            while self.outQueue.qsize() > 0:
                self.outQueue.get()""",
          f"""            {queue_marker}
            while self.outQueue.qsize() > 2:
                self.outQueue.get()
            out_wav = self.outQueue.get()""",
      ),
      (
          """            mon_wav = self.monQueue.get()
            while self.monQueue.qsize() > 0:
                self.monQueue.get()""",
          f"""            {queue_marker}
            while self.monQueue.qsize() > 2:
                self.monQueue.get()
            mon_wav = self.monQueue.get()""",
      ),
  ]
  for old, new in queue_replacements:
      if old not in text:
          print(f"missing queue patch site: {old[:72]}", file=sys.stderr)
          raise SystemExit(1)
      text = text.replace(old, new, 1)
  changed.append("queue depth")

if changed:
    path.write_text(text)
    print("patched ServerDevice.py (" + ", ".join(changed) + ")")
'';

  patchServerDevice = ''
    SERVER_DEVICE="$SERVER_DIR/voice_changer/Local/ServerDevice.py"
    if [[ -f "$SERVER_DEVICE" ]]; then
      python ${patchServerDevicePy} "$SERVER_DEVICE"
      rm -f "$SERVER_DIR/voice_changer/Local/__pycache__/ServerDevice."*.pyc 2>/dev/null || true
    fi
  '';

  # PipeWire virtual sinks are not separate PortAudio endpoints — use the pipewire device.
  inherit audioDefaults processingDefaults;

  processingDefaultsJson = builtins.toJSON {
    serverReadChunkSize = processingDefaults.readChunkSize;
    extraConvertSize = processingDefaults.extraConvertSize;
    crossFadeOverlapSize = processingDefaults.crossFadeOverlapSize;
    serverAudioSampleRate = processingDefaults.sampleRate;
    serverInputAudioSampleRate = processingDefaults.sampleRate;
    serverOutputAudioSampleRate = processingDefaults.sampleRate;
    serverMonitorAudioSampleRate = processingDefaults.sampleRate;
    f0Detector = processingDefaults.f0Detector;
    indexRatio = processingDefaults.indexRatio;
    tran = processingDefaults.pitchSemitones;
    silenceFront = processingDefaults.silenceFront;
    silentThreshold = processingDefaults.silentThreshold;
    protect = processingDefaults.protect;
  };

  applyProcessingDefaultsPy = pkgs.writeText "w-okada-apply-processing.py" ''
import json
import os
import sys
import time
import urllib.parse
import urllib.request

PORT = int(os.environ.get("W_OKADA_PORT", "18888"))
DEFAULTS = json.loads("""${processingDefaultsJson}""")
API_DEFAULTS = {k: v for k, v in DEFAULTS.items() if k not in (
    "serverInputAudioSampleRate", "serverOutputAudioSampleRate", "serverMonitorAudioSampleRate",
)}
API_DEFAULTS["serverMonitorDeviceId"] = int(os.environ.get("VC_MONITOR_DEVICE_ID", "${toString audioDefaults.monitorDeviceId}"))


def post(key, val):
    data = urllib.parse.urlencode({"key": key, "val": val}).encode()
    req = urllib.request.Request(
        f"http://127.0.0.1:{PORT}/update_settings",
        data=data,
        method="POST",
    )
    urllib.request.urlopen(req, timeout=3)


def main():
    for _ in range(120):
        try:
            urllib.request.urlopen(f"http://127.0.0.1:{PORT}/info", timeout=1)
            break
        except Exception:
            time.sleep(0.5)
    else:
        print("w-okada API not ready", file=sys.stderr)
        return 1

    for key, val in API_DEFAULTS.items():
        try:
            post(key, val)
        except Exception as exc:
            print(f"warn: {key}={val}: {exc}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
'';

  applyAudioDefaultsPy = pkgs.writeText "w-okada-apply-audio.py" ''
import json
import os
import re
import sys
import time

import sounddevice as sd

STORED = os.environ.get("VC_STORED_SETTING", "stored_setting.json")
FORCE = os.environ.get("VC_AUDIO_FORCE", "0") == "1"
LIST_ONLY = "--list" in sys.argv

INPUT_RE = re.compile(os.environ.get("VC_INPUT_PATTERN", "${audioDefaults.inputPattern}"), re.I)
OUTPUT_RE = re.compile(os.environ.get("VC_OUTPUT_PATTERN", "${audioDefaults.outputPattern}"), re.I)
MONITOR_DEVICE_ID = int(os.environ.get("VC_MONITOR_DEVICE_ID", "${toString audioDefaults.monitorDeviceId}"))
PROCESSING_DEFAULTS = json.loads("""${processingDefaultsJson}""")
# Upstream only loads modelSlotIndex/gpu from stored_setting on boot — RVC keys need API apply.
API_DEFAULTS = {k: v for k, v in PROCESSING_DEFAULTS.items() if k not in (
    "serverInputAudioSampleRate", "serverOutputAudioSampleRate", "serverMonitorAudioSampleRate",
)}
ALWAYS_APPLY = {
    "silenceFront", "indexRatio", "tran", "protect", "f0Detector",
    "extraConvertSize", "serverReadChunkSize", "serverMonitorDeviceId",
    "serverInputDeviceId", "serverOutputDeviceId",
}


def pick(devices, pattern):
    # Honor pipewire|default|Yeti priority — PortAudio index order would pick Yeti hw output first.
    for part in pattern.pattern.split("|"):
        part = part.strip()
        if not part:
            continue
        sub = re.compile(part, pattern.flags)
        for d in devices:
            if sub.search(d["name"]):
                return d["index"], d["name"]
    return None, None


def pick_input(devices, pattern, timeout=15.0, interval=0.5):
    # Capture via PortAudio pipewire — not Yeti hw:3,0 (direct ALSA fights PipeWire → xruns/cutoffs).
    deadline = time.time() + timeout
    while time.time() < deadline:
        for d in devices:
            name = str(d.get("name", ""))
            if name.lower() == "pipewire" and "(hw:" not in name:
                return d["index"], d["name"]
        for i, d in enumerate(sd.query_devices()):
            name = d["name"]
            if name.lower() == "pipewire" and d["max_input_channels"] > 0:
                return i, name
        time.sleep(interval)
        devices = [d for d in sd.query_devices() if d["max_input_channels"] > 0]
    filtered = [d for d in devices if "(hw:" not in d.get("name", "")]
    in_id, in_name = pick(filtered, pattern)
    if in_id is not None and "(hw:" in in_name:
        return None, None
    return in_id, in_name


def should_apply(stored, key, val):
    if key in ALWAYS_APPLY:
        return True
    if FORCE:
        return True
    if key not in stored:
        return True
    if stored.get(key) in (-1, None, ""):
        return True
    return False


def main():
    all_devs = sd.query_devices()
    inputs = [d for d in all_devs if d["max_input_channels"] > 0]
    outputs = [d for d in all_devs if d["max_output_channels"] > 0]

    if LIST_ONLY:
        print("PortAudio devices (use server mode in Web UI, not client):")
        print("inputs:")
        for d in inputs:
            print(f"  {d['index']:3d}  {d['name']}")
        print("outputs:")
        for d in outputs:
            print(f"  {d['index']:3d}  {d['name']}")
        print("processing defaults:", PROCESSING_DEFAULTS)
        return 0

    in_id, in_name = pick_input(inputs, INPUT_RE)
    out_id, out_name = pick(outputs, OUTPUT_RE)
    mon_id = MONITOR_DEVICE_ID
    mon_name = "disabled (PipeWire loopback)" if mon_id == -1 else str(mon_id)

    missing = []
    if in_id is None:
        missing.append("input")
    if out_id is None:
        missing.append("output")
    if missing:
        print("Could not match PortAudio device(s): " + ", ".join(missing), file=sys.stderr)
        print("Run: w-okada-audio --list", file=sys.stderr)
        print("Override patterns: VC_INPUT_PATTERN VC_OUTPUT_PATTERN", file=sys.stderr)
        return 1

    stored = {}
    if os.path.exists(STORED):
        with open(STORED, encoding="utf-8") as f:
            stored = json.load(f)

    # UI bug can write a timestamp as modelSlotIndex — reset to slot 0.
    slot = stored.get("modelSlotIndex")
    if isinstance(slot, int) and slot not in range(0, 16):
        stored["modelSlotIndex"] = 0

    updates = {
        "enableServerAudio": ${toString audioDefaults.enableServerAudio},
        "serverInputDeviceId": in_id,
        "serverOutputDeviceId": out_id,
        "serverMonitorDeviceId": mon_id,
        **PROCESSING_DEFAULTS,
    }

    changed = []
    for key, val in updates.items():
        if should_apply(stored, key, val):
            if stored.get(key) != val:
                changed.append(key)
            stored[key] = val

    with open(STORED, "w", encoding="utf-8") as f:
        json.dump(stored, f, indent=2)
        f.write("\n")

    print("Defaults → stored_setting.json (server mode + processing)")
    print(f"  input   [{in_id}] {in_name}")
    print(f"  output  [{out_id}] {out_name}")
    print(f"  monitor [{mon_id}] {mon_name}")
    print(f"  chunk   {PROCESSING_DEFAULTS['serverReadChunkSize']}  extra {PROCESSING_DEFAULTS['extraConvertSize']}  f0 {PROCESSING_DEFAULTS['f0Detector']}")
    if changed:
        print("  updated:", ", ".join(changed))
    else:
        print("  (already set — use VC_AUDIO_FORCE=1 to overwrite)")
    print("Restart w-okada, then hard-refresh the Web UI.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
'';
in {
  w-okada-setup = writeShellApplication {
    name = "w-okada-setup";
    runtimeInputs = with pkgs; [
      git
      python
      pip
      curl
      wget
      gcc
      gnumake
      cmake
      pkg-config
      portaudio
      ffmpeg
      libsndfile
      openssl
    ];
    text = ''
      set -euo pipefail
      ${resolveDirs}
      TORCH_INDEX="''${W_OKADA_TORCH_INDEX:-https://download.pytorch.org/whl/rocm6.2}"

      mkdir -p "$DATA_DIR"

      if [[ ! -d "$REPO_DIR/.git" ]]; then
        git clone --depth 1 https://github.com/w-okada/voice-changer.git "$REPO_DIR"
      else
        echo "Updating upstream clone..."
        git -C "$REPO_DIR" pull --ff-only
      fi

      ${patchServerDevice}

      if [[ ! -d "$VENV_DIR" ]]; then
        ${python}/bin/python -m venv "$VENV_DIR"
      fi

      # shellcheck disable=SC1091
      source "$VENV_DIR/bin/activate"
      export PIP_USER=0
      ${rocmEnv}

      pip install --upgrade 'pip<26' wheel 'setuptools<81'

      echo "Installing PyTorch (ROCm) from $TORCH_INDEX ..."
      pip install torch torchaudio --index-url "$TORCH_INDEX"

      echo "Installing server deps (skip pinned torch / CUDA onnx) ..."
      grep -Ev '^(torch|torchaudio|onnxruntime-gpu)==|^#' "$SERVER_DIR/requirements.txt" \
        > "$DATA_DIR/requirements-rocm.txt"
      pip install -r "$DATA_DIR/requirements-rocm.txt"
      pip install onnxruntime

      # RVC extras — upstream requirements.txt omits these; Colab/Kaggle install them manually.
      echo "Installing RVC extras (fairseq HuBERT embedder, pyworld pitch) ..."
      # PyPI fairseq 0.12.2 breaks on Python 3.11 dataclasses — patched fork (RVC/Applio community).
      pip install 'git+https://github.com/One-sixth/fairseq.git'
      pip install pyworld --no-build-isolation

      python -c "from fairseq import checkpoint_utils; import pyworld; print('RVC deps OK')"

      mkdir -p "$REPO_DIR/model_dir"

      echo ""
      echo "Setup complete."
      echo "  w-okada-models  # download starter RVC models"
      echo "  w-okada         # start server → http://127.0.0.1:18888/"
    '';
  };

  # Installs into numbered slots + writes params.json (w-okada only reads model_dir/<slot>/).
  w-okada-models = writeShellApplication {
    name = "w-okada-models";
    runtimeInputs = with pkgs; [
      curl
      unzip
      coreutils
      python
    ] ++ vcRuntimeLibs;
    text = ''
      set -euo pipefail
      ${mkModelDirCheck}
      ${requireSetup}
      CACHE="$DATA_DIR/model-cache"
      mkdir -p "$CACHE"

      download() {
        local url="$1"
        local dest="$2"
        if [[ -s "$dest" ]]; then
          echo "  skip (exists): $(basename "$dest")"
          return 0
        fi
        echo "  fetch: $url"
        curl -fL --retry 3 --continue-at - "$url" -o "$dest.part"
        mv "$dest.part" "$dest"
      }

      migrate_legacy_starter() {
        local legacy="$MODEL_ROOT/starter"
        [[ -d "$legacy" ]] || return 0
        echo "Migrating legacy starter/ layout → numbered slots..."
        ${lib.concatStringsSep "\n" (map (m: ''
          if [[ -d "$legacy/${m.id}" && ! -d "$MODEL_ROOT/${toString m.slot}" ]]; then
            mkdir -p "$MODEL_ROOT/${toString m.slot}"
            cp -a "$legacy/${m.id}/." "$MODEL_ROOT/${toString m.slot}/"
          fi
        '') starterModels)}
      }

      should_install() {
        local id="$1"
        local wanted="''${W_OKADA_MODELS:-${defaultModelIds}}"
        if [[ "$wanted" == "all" ]]; then
          return 0
        fi
        [[ ",$wanted," == *",$id,"* ]]
      }

      install_zip() {
        local slot="$1" id="$2" url="$3" label="$4" tune="$5"
        local dir="$MODEL_ROOT/$slot"
        local zip="$CACHE/$id.zip"
        if ! should_install "$id"; then
          return 0
        fi
        echo "[$slot/$id] $label"
        download "$url" "$zip"
        rm -rf "$dir"
        mkdir -p "$dir"
        unzip -oq "$zip" -d "$dir"
        find "$dir" -name '*.pth' -o -name '*.index' | head -5
        echo "  → slot $slot (try TUNE +$tune, INDEX 0.55–0.65)"
      }

      install_files() {
        local slot="$1" id="$2" label="$3" tune="$4" pth="$5" index="$6"
        local dir="$MODEL_ROOT/$slot"
        local pth_name index_name
        pth_name=$(basename "$pth")
        index_name=$(basename "$index")
        if ! should_install "$id"; then
          return 0
        fi
        echo "[$slot/$id] $label"
        mkdir -p "$dir"
        download "$pth" "$dir/$pth_name"
        if [[ "''${W_OKADA_SKIP_INDEX:-}" != 1 ]]; then
          download "$index" "$dir/$index_name"
        else
          echo "  skip index (W_OKADA_SKIP_INDEX=1)"
        fi
        echo "  → slot $slot (try TUNE +$tune, INDEX 0.55–0.65)"
      }

      register_slots() {
        echo ""
        echo "Registering slots (params.json)..."
        ${activateVenv}
        cd "$SERVER_DIR"
        export MODEL_ROOT
        python - <<'PY'
      import glob
      import os

      from data.ModelSlot import RVCModelSlot, saveSlotInfo
      from voice_changer.RVC.RVCModelSlotGenerator import RVCModelSlotGenerator

      model_dir = os.environ["MODEL_ROOT"]
      slots = [
      ${lib.concatStringsSep "\n" (map (m: "    (${toString m.slot}, \"${m.id}\", \"${m.label}\", ${toString m.tune}),") starterModels)}
      ]

      for slot, _id, label, tune in slots:
          slot_dir = os.path.join(model_dir, str(slot))
          pth_files = sorted(glob.glob(os.path.join(slot_dir, "*.pth")))
          if not pth_files:
              print(f"  skip slot {slot}: no .pth in {slot_dir}")
              continue
          pth = pth_files[0]
          index_files = sorted(glob.glob(os.path.join(slot_dir, "*.index*")))
          slot_info = RVCModelSlot()
          slot_info.modelFile = os.path.basename(pth)
          if index_files:
              slot_info.indexFile = os.path.basename(index_files[0])
          slot_info.name = label.split(" — ")[0]
          slot_info.description = label
          slot_info.sampleId = _id
          slot_info.defaultTune = tune
          slot_info = RVCModelSlotGenerator._setInfoByPytorch(pth, slot_info)
          # _setInfoByPytorch resets retrieval defaults — set INDEX after inspect.
          slot_info.defaultIndexRatio = 0.6
          slot_info.defaultProtect = 0.5
          saveSlotInfo(model_dir, slot, slot_info)
          print(f"  slot {slot}: {slot_info.name} ({slot_info.modelFile})")
      PY
      }

      if [[ "''${1:-}" == "--list" ]]; then
        cat <<'LIST'
      Starter models (w-okada-models):
        0  48 kHz  default install
        1  32 kHz  extra resample — W_OKADA_MODELS=all
        2  32 kHz  extra resample — W_OKADA_MODELS=all
        3  40 kHz  JP — W_OKADA_MODELS=all
        4  40 kHz  extra resample — W_OKADA_MODELS=all
      Default: 48 kHz slot 0. All: W_OKADA_MODELS=all w-okada-models
      Skip large .index files: W_OKADA_SKIP_INDEX=1 w-okada-models
      Re-register only: w-okada-models --register-only
      LIST
        exit 0
      fi

      migrate_legacy_starter

      if [[ "''${1:-}" == "--register-only" ]]; then
        register_slots
        echo ""
        echo "Done. Restart w-okada and refresh http://127.0.0.1:18888/"
        exit 0
      fi

      echo "Downloading starter models → $MODEL_ROOT/<slot>/"
      echo "(re-run is safe — skips files already in cache)"
      echo ""

      ${starterModelInstallScript}

      register_slots

      echo ""
      echo "Done. Models under: $MODEL_ROOT/"
      echo "Use slot 0 (48 kHz). Restart w-okada → http://127.0.0.1:18888/"
    '';
  };

  w-okada-audio = writeShellApplication {
    name = "w-okada-audio";
    runtimeInputs = [ python ] ++ vcRuntimeLibs;
    text = ''
      set -euo pipefail
      ${requireSetup}
      ${activateVenv}
      cd "$SERVER_DIR"
      export VC_STORED_SETTING="$SERVER_DIR/stored_setting.json"
      export VC_AUDIO_FORCE="''${VC_AUDIO_FORCE:-${if defaultsForce then "1" else "0"}}"
      exec python ${applyAudioDefaultsPy} "''${1:-}"
    '';
  };

  w-okada = writeShellApplication {
    name = "w-okada";
    runtimeInputs = [
      python
      pkgs.pulseaudio
      pkgs.util-linux
      pkgs.systemd
      pkgs.iproute2
      pkgs.gcc
    ] ++ vcRuntimeLibs;
    text = ''
      set -euo pipefail
      ${requireSetup}

      PORT="''${W_OKADA_PORT:-18888}"
      UNIT="w-okada.service"
      LOCK="''${XDG_RUNTIME_DIR:-/tmp}/w-okada.lock"

      stop_server_python() {
        # Match the real argv only — `pkill -f MMVCServerSIO.py` also kills this script.
        pkill -x -f "python MMVCServerSIO.py -p $PORT" 2>/dev/null || true
      }

      stop_all() {
        systemctl --user stop "$UNIT" 2>/dev/null || true
        stop_server_python
        sleep 0.5
      }

      if [[ "''${1:-}" == "--stop" ]]; then
        stop_all
        echo "Voice changer stopped."
        exit 0
      fi

      # CLI: one systemd unit. Do not exec Python here or leftovers stack with systemd-run.
      if [[ "''${W_OKADA_INNER:-}" != 1 ]]; then
        if systemctl --user is-active --quiet "$UNIT" \
          || [[ "$(systemctl --user is-active "$UNIT" || true)" == "activating" ]]; then
          echo "Voice changer already running → http://127.0.0.1:$PORT/"
          echo "Stop: w-okada --stop"
          exit 0
        fi

        if ss -Hltn "sport = :$PORT" | grep -q .; then
          echo "Clearing leftover process on :$PORT ..." >&2
          stop_server_python
          sleep 1
        fi

        if ss -Hltn "sport = :$PORT" | grep -q .; then
          echo "Port $PORT still in use. w-okada --stop, then retry." >&2
          exit 1
        fi

        systemctl --user start "$UNIT"
        echo "Voice changer → http://127.0.0.1:$PORT/"
        echo "Logs: journalctl --user -u w-okada -f"
        echo "Stop: w-okada --stop"
        exit 0
      fi

      ${activateVenv}
      cd "$SERVER_DIR"

      exec 9>"$LOCK"
      if ! flock -n 9; then
        echo "Voice changer lock held ($LOCK) — already running." >&2
        echo "Stop: w-okada --stop" >&2
        exit 1
      fi

      ${patchServerDevice}

      export PULSE_SINK="''${PULSE_SINK:-VoiceChanger-Output}"
      if [[ -z "''${PULSE_SOURCE:-}" ]] && command -v pactl >/dev/null 2>&1; then
        PULSE_SOURCE="$(pactl get-default-source 2>/dev/null || true)"
        export PULSE_SOURCE
      fi

      if [[ "''${W_OKADA_SKIP_AUDIO_DEFAULTS:-}" != 1 ]]; then
        export VC_STORED_SETTING="$SERVER_DIR/stored_setting.json"
        export VC_AUDIO_FORCE="''${VC_AUDIO_FORCE:-1}"
        export VC_MONITOR_DEVICE_ID="${toString audioDefaults.monitorDeviceId}"
        python ${applyAudioDefaultsPy} || echo "warn: w-okada-audio failed (run w-okada-audio manually)" >&2
      fi

      (
        export W_OKADA_PORT="$PORT"
        export VC_MONITOR_DEVICE_ID="${toString audioDefaults.monitorDeviceId}"
        python ${applyProcessingDefaultsPy} || true
      ) &

      echo "Voice changer → http://127.0.0.1:$PORT/"
      echo "Audio output → $PULSE_SINK (Discord mic: Voice Changer Mic)"
      exec env PYTHONUNBUFFERED=1 "PULSE_PROP_application.name=w-okada" python MMVCServerSIO.py -p "$PORT"
    '';
  };

  # Legacy cleanup for pre-declarative pactl null-sinks / duplicate loopbacks.
  # Routing is declarative in modules/ai/w-okada.nix (virtualMic).
  w-okada-mic = writeShellApplication {
    name = "w-okada-mic";
    runtimeInputs = with pkgs; [
      pulseaudio
      gawk
    ];
    text = ''
      set -euo pipefail

      if ! pactl info >/dev/null 2>&1; then
        echo "PipeWire/PulseAudio not reachable." >&2
        exit 1
      fi

      echo "w-okada routing is declarative (modules/ai/w-okada.nix)."
      echo "Cleaning legacy pactl modules from older setups..."

      while read -r mid _rest; do
        pactl unload-module "$mid" 2>/dev/null || true
      done < <(pactl list short modules | awk '/module-null-sink/ && /VoiceChanger/ {print $1}')

      if pactl list short sinks | awk '{print $2}' | grep -qx "VoiceChanger-Output"; then
        echo "  VoiceChanger-Output: OK"
      else
        echo "  VoiceChanger-Output: missing — nh os switch, then restart PipeWire" >&2
        exit 1
      fi

      if pactl list short sources | awk '{print $2}' | grep -qx "VoiceChanger-Mic"; then
        echo "  VoiceChanger-Mic: OK"
      else
        echo "  VoiceChanger-Mic: missing" >&2
        exit 1
      fi

      echo "Start w-okada; Discord/OBS mic = Voice Changer Mic"
    '';
  };
}
