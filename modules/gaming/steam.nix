# Steam and Proton on Sway/Wayland.
#
# Per-game launch options (Steam → Properties → Launch Options):
#   gamemoderun %command%                 # CS2: required (unloads Ollama, DPM=high)
#   gamemoderun mangohud %command%
#   PROTON_ENABLE_WAYLAND=1 %command%     # proton-ge / forks only, not Valve Proton
#   PROTON_USE_NTSYNC=1 %command%         # if ntsync module loaded (kernel.nix)
#   PROTON_LOG=1 %command%                # ~/steam-<APPID>.log
#   LD_BIND_NOW=1 %command%               # less first-call latency
#   gamescope -W 2560 -H 1440 -r 144 -f -e -- %command%
#   gamescope -W 2560 -H 1440 -r 144 -f -e --mangoapp -- %command%
#
# Troubleshooting:
#   1. Prefix reset: delete SteamLibrary/steamapps/compatdata/<APPID>/pfx
#   2. Logs: PROTON_LOG=1 → grep err: in ~/steam-*.log
#   3. NTFS libraries: symlink compatdata to ext4/btrfs
#
# Northstar (TF2): northstar-proton has no steamcompattool — use STEAM_EXTRA_COMPAT_TOOLS_PATHS.
{ config, lib, pkgs, ... }:
let
  cfg = config.gaming;
in
{
  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        # PrivateTmp hides /tmp from the FHS env and breaks some overlays/shaders.
        privateTmp = false;
        extraProfile = ''
          unset TZ
          export XCURSOR_THEME=catppuccin-mocha-blue-cursors
          export XCURSOR_SIZE=24
        '';
      };
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      # X11 Steam Input → uinput on Wayland (extest shim).
      extest.enable = true;
      protontricks.enable = true;

      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];

      extraPackages = with pkgs; [
        gamemode
        mangohud
        gamescope
        protontricks
        protonup-qt
        catppuccin-cursors.mochaBlue
      ];
    };

    # HTTP/2 on Linux Steam can stall downloads. Valve community steam_dev.cfg workaround:
    #   @nClientDownloadEnableHTTP2PlatformLinux 0
    systemd.user.services.steam-download-fix = lib.mkIf cfg.steam.fixDownloadSpeed {
      description = "Steam download speed tweaks";
      wantedBy = [ "default.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p "$HOME/.local/share/Steam"
        cat > "$HOME/.local/share/Steam/steam_dev.cfg" <<'EOF'
        @nClientDownloadEnableHTTP2PlatformLinux 0
        @fDownloadRateImprovementToAddAnotherConnection 1.0
        EOF
      '';
    };
  };
}
