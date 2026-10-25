# Wireless PCVR for Quest 2 via WiVRn (OpenXR streaming, Monado-based).
#
# Headset: install the WiVRn client (Meta Store or WiVRn-APK), same LAN as the desktop.
# Steam games: Proton 9+ with an OpenVR→OpenXR layer (xrizer, bundled by WiVRn >= 0.23).
#   If a game cannot see the WiVRn socket, add to its launch options:
#     PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/wivrn/comp_ipc %command%
# Encoder: upstream defaults (vulkan + h265 on RADV). Quest 2 has no AV1 decode, and the
#   RX 6700 XT has no AV1 encode. If latency is bad, try vaapi via `gaming.vr.encoder`.
{ config, lib, pkgs, ... }:
let
  cfg = config.gaming.vr;
in
{
  options.gaming.vr = {
    enable = lib.mkEnableOption "wireless PCVR for Quest via WiVRn";

    encoder = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "vulkan" "vaapi" "x264" ]);
      default = null;
      description = "Force one encoder for all streams (null keeps WiVRn's automatic selection)";
    };
  };

  config = lib.mkIf (config.gaming.enable && cfg.enable) {
    # Desktop overlay (Nautilus, Firefox, any window) inside VR. On Sway it captures via
    # wlr-screencopy. Start it by hand after the headset connects — upstream says
    # WiVRn/SteamVR autostart breaks screens.
    # android-tools: adb for Quest battery/status (`adb shell dumpsys battery`) and the wired
    # WiVRn mode (`adb reverse tcp:9757 tcp:9757`). Needs developer mode on the headset.
    environment.systemPackages = with pkgs; [
      wayvr
      android-tools
    ];

    # nixpkgs' wivrn module still sets the obsolete avahi.publish.* options; null them and use settings.
    services.avahi = {
      publish = {
        enable = lib.mkForce null;
        userServices = lib.mkForce null;
      };
      settings.publish = {
        disable-publishing = false;
        disable-user-service-publishing = false;
        publish-addresses = true;
      };
    };

    services.wivrn = {
      enable = true;
      # avahi (mDNS 5353) is enabled by the module; the desktop firewall already allows
      # all ports, so openFirewall is redundant but keeps 9757 open if that ever tightens.
      openFirewall = true;
      # Start on demand from the headset instead of at boot.
      autoStart = false;
      # CAP_SYS_NICE wrapper so the compositor can get a high-priority GPU queue on AMD
      # (async reprojection / less stutter). Try off first if the wrapper misbehaves.
      highPriority = true;
      # Lets Steam's pressure-vessel discover the WiVRn OpenXR runtime (re-login to apply).
      steam.importOXRRuntimes = true;
      # LVRA NixOS page: a 5 ms minimum compositor time helps headset-view stutter.
      monadoEnvironment.U_PACING_COMP_MIN_TIME_MS = "5";

      config = lib.mkIf (cfg.encoder != null) {
        enable = true;
        json.encoder = [
          {
            inherit (cfg) encoder;
            codec = "h265";
          }
        ];
      };
    };
  };
}
