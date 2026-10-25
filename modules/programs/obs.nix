# OBS Studio with plugins (wrapOBS) and a v4l2loopback virtual camera.
{ config, pkgs, ... }:
let
  # Websocket URL (obsws://localhost:4455/<password>) stays out of the store.
  obsReplaySave = pkgs.writeShellApplication {
    name = "obs-replay-save";
    runtimeInputs = [ pkgs.obs-cmd pkgs.libnotify ];
    text = ''
      OBS_WEBSOCKET_URL="$(cat "$HOME/.secrets/obs-websocket.url")"
      export OBS_WEBSOCKET_URL
      if obs-cmd replay save; then
        notify-send -a OBS "Replay saved"
      else
        notify-send -a OBS -u critical "Replay save failed"
      fi
    '';
  };
in
{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-vkcapture
      obs-vaapi
      wlrobs
    ];
  };

  # Not enableVirtualCamera: it hardcodes video_nr=1, which the webcam already owns.
  boot = {
    kernelModules = [ "v4l2loopback" ];
    # 0.15.4's `make install` runs depmod; its modules.* indexes collide with the kernel's in buildEnv.
    extraModulePackages = [
      (config.boot.kernelPackages.v4l2loopback.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          rm -f $out/lib/modules/*/modules.*
        '';
      }))
    ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
    '';
  };

  environment.systemPackages = [
    pkgs.obs-cmd
    obsReplaySave
  ];
}
