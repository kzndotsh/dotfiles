# Prism Launcher for Java Minecraft — the official Mojang launcher breaks on 1.19+ under NixOS.
#
# Default play path is `minecraft-fo` (desktop entry: Minecraft): Fabric + Fabulously
# Optimized 14.0.0-beta.6 / MC 26.2. First run opens Prism to confirm the mrpack import
# and Microsoft login. Later runs patch instance.cfg (GameMode, MangoHud, 2–6G heap) then
# launch with `prismlauncher -l`.
#
# To bump the pack: grab the new .mrpack URL and hash from Modrinth project 1KVo5zza.
# No stable FO for 26.2 yet — prefer a later 14.x stable when one ships.
# Skip OptiFine, Indium, and Starlight — FO already bundles Sodium and Lithium.
# Optional server extras (SVC, Emotecraft, PatPat, JourneyMap) belong in Prism, not here.
#
# User must be in the gamemode group (hosts/desktop/user.nix).
{ config, lib, pkgs, ... }:
let
  cfg = config.gaming;

  prism = pkgs.prismlauncher.override {
    gamemodeSupport = true;
    controllerSupport = true;
    textToSpeechSupport = true;
    additionalPrograms = with pkgs; [
      ffmpeg
      mangohud
    ];
  };

  # FO 14.0.0-beta.6 for Minecraft 26.2 (Modrinth version 8ikTAvpG, 2026-08-17).
  foMrpack = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/1KVo5zza/versions/8ikTAvpG/Fabulously.Optimized-v14.0.0-beta.6.mrpack";
    hash = "sha256-EW0osoTwNZ1kRWo7Hq4vHKpHyn0nfdMuumMggAh+xaI=";
  };

  wrapperCmd = "${lib.getExe pkgs.mangohud} ${lib.getExe' pkgs.gamemode "gamemoderun"}";

  minecraftFo = pkgs.writeShellApplication {
    name = "minecraft-fo";
    runtimeInputs = [
      prism
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.gnused
    ];
    text = ''
      set -euo pipefail
      data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
      inst_root="$data_home/PrismLauncher/instances"
      inst=""

      if [[ -d "$inst_root" ]]; then
        for d in "$inst_root"/*/; do
          [[ -f "$d/instance.cfg" ]] || continue
          base="$(basename "$d")"
          if grep -qiE '8ikTAvpG|14\.0\.0-beta\.6' "$d/instance.cfg"; then
            inst="$d"
          elif [[ -f "$d/mmc-pack.json" ]] && grep -q '"26.2"' "$d/mmc-pack.json" && {
            grep -qi 'fabulously' "$d/instance.cfg" || [[ "$base" == Fabulously* ]]
          }; then
            inst="$d"
          fi
        done
      fi

      if [[ -z "$inst" ]]; then
        echo "Importing Fabulously Optimized 14.0.0-beta.6 (MC 26.2) — confirm in the GUI, then sign in with Microsoft."
        echo "Run minecraft-fo again after the instance exists."
        exec prismlauncher -I ${lib.escapeShellArg foMrpack} "$@"
      fi

      cfg="$inst/instance.cfg"
      set_kv() {
        local key="$1" val="$2"
        if grep -q "^''${key}=" "$cfg"; then
          sed -i "s|^''${key}=.*|''${key}=''${val}|" "$cfg"
        else
          printf '%s=%s\n' "$key" "$val" >> "$cfg"
        fi
      }
      set_kv OverrideCommands true
      set_kv WrapperCommand ${lib.escapeShellArg wrapperCmd}
      set_kv OverrideMemory true
      set_kv MinMemAlloc 2048
      set_kv MaxMemAlloc 6144

      exec prismlauncher -l "$(basename "$inst")" "$@"
    '';
  };

  minecraftDesktop = pkgs.makeDesktopItem {
    name = "minecraft-fo";
    desktopName = "Minecraft";
    comment = "Fabulously Optimized (Prism / Fabric)";
    exec = "minecraft-fo";
    icon = "prismlauncher";
    categories = [ "Game" ];
    startupNotify = true;
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.minecraft.prismLauncher.enable) {
    environment.systemPackages = [
      prism
      minecraftFo
      minecraftDesktop
    ];
  };
}
