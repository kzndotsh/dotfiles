# FL Studio (Windows) under Wine — dedicated prefix `~/.wine-flstudio`.
#
# Image-Line does not ship Linux and does not support Wine:
#   https://support.image-line.com/action/knowledgebase?ans=140
#   https://forum.image-line.com/viewtopic.php?t=198535
# Community: https://forum.image-line.com/viewtopic.php?t=259129
# WineHQ AppDB: https://appdb.winehq.org/objectManager.php?sClass=application&iId=2317
#
# Audio: WineASIO → JACK → PipeWire JACK compat (`modules/audio` + `music` jack.enable).
#   https://github.com/wineasio/wineasio
#   Register per prefix with `wine regsvr32 wineasio.dll` (nixpkgs has no wineasio-register).
#   Skip ASIO4ALL in the installer — it does not work under Wine (Image-Line KB above).
#   In FL: Options → Audio → Device → WineASIO. Turn off "Mix in buffer switch"
#   if you get xruns (ASIO callback must return within one period):
#   https://github.com/M0n7y5/pipeasio
#   PIPEWIRE_LATENCY hints this client; PIPEWIRE_QUANTUM would force the whole graph:
#   https://gitlab.freedesktop.org/pipewire/pipewire/-/commit/0bc3d1444a98d7e868563a03bf555f28f14e7f2d
#
# Sync: kernel ntsync (≥6.14) is on via `modules/wine` + `gaming/kernel.nix`.
#   Do not enable esync together with fsync/ntsync.
#   https://github.com/begin-theadventure/fl-studio-integrator-linux
#
# Windows VSTs load inside this prefix (no yabridge). Unlock via Image-Line account
# in FL, not a .reg file.
{ config, lib, pkgs, ... }:
let
  cfg = config.music;
  prefix = "$HOME/.wine-flstudio";

  flMime = pkgs.writeTextFile {
    name = "fl-studio-mime";
    destination = "/share/mime/packages/fl-studio.xml";
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
        <mime-type type="application/x-fl-studio-project">
          <comment>FL Studio Project</comment>
          <glob pattern="*.flp"/>
        </mime-type>
      </mime-info>
    '';
  };

  flDesktop = pkgs.makeDesktopItem {
    name = "fl-studio";
    desktopName = "FL Studio";
    exec = "fl-studio %F";
    # https://specifications.freedesktop.org/menu-spec/latest/category-registry.html
    categories = [
      "AudioVideo"
      "Audio"
    ];
    mimeTypes = [ "application/x-fl-studio-project" ];
    startupWMClass = "fl64.exe";
  };

  flStudioSetup = pkgs.writeShellApplication {
    name = "fl-studio-setup";
    runtimeInputs = [
      pkgs.fontconfig
      pkgs.gnugrep
      pkgs.coreutils
      pkgs.winetricks
    ];
    text = ''
      export WINEPREFIX="${prefix}"
      export WINEARCH=win64
      export WINE="''${WINE_BIN:-wine}"
      export WINE64="''${WINE_BIN:-wine}"

      echo "=== FL Studio prefix setup ==="
      echo "Creating 64-bit Wine prefix at $WINEPREFIX ..."
      wineboot -u

      echo "Linking system fonts into C:\\windows\\Fonts ..."
      FONTDIR="$WINEPREFIX/drive_c/windows/Fonts"
      mkdir -p "$FONTDIR"
      while IFS= read -r f; do
        ln -sf "$f" "$FONTDIR/"
      done < <(fc-list -f "%{file}\n" | grep -E '\.(ttf|otf)$' || true)

      # FL looks up arial.ttf by filename for hint-bar / piano-roll labels.
      ARIAL="$(fc-list -f '%{file}\n' | grep -i 'LiberationSans-Regular' | grep '\.ttf$' | head -1 || true)"
      if [ -n "$ARIAL" ]; then
        cp "$ARIAL" "$FONTDIR/arial.ttf"
      fi

      echo "Windows 10 + font smoothing + no crash dialogs ..."
      winetricks -q win10 fontsmooth=rgb csmt=on nocrashdialog mimeassoc=off isolate_home
      echo "corefonts / tahoma / gdiplus / msxml6 / vcrun2022 / dxvk ..."
      winetricks -q corefonts tahoma gdiplus msxml6 vcrun2022 dxvk

      echo "Registering WineASIO in this prefix ..."
      wine regsvr32 wineasio.dll || echo "WineASIO registration failed — check pkgs.wineasio is on PATH"

      # Xft DPI is 96 in modules/wine; Sway scale 2.0 does HiDPI. Don't set 192 here.
      echo "LogPixels=96, ClearType, Sway-friendly X11 driver ..."
      wine reg add "HKCU\\Control Panel\\Desktop" /v LogPixels /t REG_DWORD /d 96 /f
      wine reg add "HKCU\\Control Panel\\Desktop" /v FontSmoothing /t REG_SZ /d 2 /f
      wine reg add "HKCU\\Control Panel\\Desktop" /v FontSmoothingType /t REG_DWORD /d 2 /f
      wine reg add "HKCU\\Control Panel\\Desktop" /v FontSmoothingOrientation /t REG_DWORD /d 1 /f
      wine reg add "HKCU\\Software\\Wine\\X11 Driver" /v GrabFullscreen /t REG_SZ /d N /f
      wine reg add "HKCU\\Software\\Wine\\Direct3D" /v csmt /t REG_SZ /d enabled /f

      echo
      echo "=== Prefix ready ==="
      echo "  1. WINEPREFIX=${prefix} wine ~/Downloads/flstudio_win_64.exe"
      echo "     Skip ASIO4ALL, 32-bit bridge, FL Cloud Plugins (WebView2 hangs)."
      echo "  2. Unlock from inside FL (Image-Line account) — not a .reg file."
      echo "  3. fl-studio"
      echo "  4. Options → Audio → WineASIO; disable Mix in buffer switch if xrunning."
    '';
  };

  flStudio = pkgs.writeShellApplication {
    name = "fl-studio";
    runtimeInputs = [
      pkgs.findutils
      pkgs.coreutils
      pkgs.gamemode
    ];
    text = ''
      export WINEPREFIX="${prefix}"
      export WINEARCH=win64
      # Client hint only — does not FORCE_QUANTUM on the desktop graph.
      export PIPEWIRE_LATENCY="256/48000"
      export WINEESYNC=0
      export WINEFSYNC=1
      export WINEDLLOVERRIDES="winemenubuilder.exe=d"

      if [ -n "''${FL_STUDIO_REPL:-}" ]; then
        exec bash
      fi

      exe="$(find "$WINEPREFIX/drive_c/Program Files/Image-Line" -maxdepth 2 -name FL64.exe 2>/dev/null | sort | tail -1 || true)"
      if [ -z "$exe" ]; then
        echo "FL64.exe not found under $WINEPREFIX. Run fl-studio-setup, then the installer." >&2
        exit 1
      fi

      trap 'wineserver -k' EXIT
      gamemoderun wine "$exe" "$@"
    '';
  };
in
{
  options.music.daw.flstudio.enable =
    lib.mkEnableOption "FL Studio via Wine (wineasio, dedicated prefix, manual installer)";

  config = lib.mkIf (cfg.enable && cfg.daw.flstudio.enable) {
    # ─── Wine stack (wine-tkg, winetricks, Xft) ────────────────────────────
    wine.enable = lib.mkDefault true;

    # ─── Launchers + ASIO ─────────────────────────────────────────────────
    environment.systemPackages = [
      pkgs.wineasio
      flStudioSetup
      flStudio
      flDesktop
      flMime
    ];

    # ─── .flp → fl-studio ─────────────────────────────────────────────────
    # https://specifications.freedesktop.org/shared-mime-info-spec/latest/
    # https://specifications.freedesktop.org/mime-apps-spec/latest/
    xdg.mime.defaultApplications."application/x-fl-studio-project" = "fl-studio.desktop";
  };
}
