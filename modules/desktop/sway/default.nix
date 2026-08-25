# Sway session: wrapper, greetd integration, and desktop portals.
#
# NixOS programs.sway has no extraConfig — compositor config lives in /etc/sway/config
# (config.nix plus config.d fragments). This file handles the session layer only.
{ config, lib, pkgs, ... }:
let
  # WebRTC apps (Meet, Zoom, Vesktop) can exhaust xdpw's default two PipeWire buffers and freeze
  # on the last frame (emersion/xdg-desktop-portal-wlr#395). nixpkgs 0.8.1 still ships the default
  # of 2; bump to 4 until upstream lands a proper fix.
  xdpw = pkgs.xdg-desktop-portal-wlr.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace include/pipewire_screencast.h \
        --replace-fail '#define XDPW_PWR_BUFFERS 2' '#define XDPW_PWR_BUFFERS 4' \
        --replace-fail '#define XDPW_PWR_BUFFERS_MIN 2' '#define XDPW_PWR_BUFFERS_MIN 4'
    '';
  });

  screencastSettings = {
    chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
    chooser_type = "simple";
    max_fps = 30;
  };

  xdpwConfig = (pkgs.formats.ini { }).generate "xdg-desktop-portal-wlr.ini" {
    screencast = screencastSettings;
  };
in
{
  imports = [
    ./config.nix
    ./waybar.nix
    ./swaylock.nix
    ./swaync.nix
    ./swayr.nix
  ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;
    # Trim the default extraPackages: grim is in config.nix, lock uses swaylock-effects,
    # and this desktop has no laptop backlight or stock foot/wmenu terminal.
    extraPackages = with pkgs; [
      pulseaudio # pactl only — the daemon is PipeWire (services.pipewire.pulse)
      swayidle
      swaylock-effects
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Without this, Java AWT windows (RuneLite, etc.) render blank under XWayland.
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XDG_CURRENT_DESKTOP=sway
      # Avoid AMD/RADV fullscreen artifacts when direct scanout is enabled (sway#8498).
      export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1
    '';
  };

  programs.dconf.enable = true; # GTK4; wayland-session.nix also sets mkDefault

  # Auto-login is intentionally off. If this user is missing (uid rename, old generation),
  # greetd fails with "account does not exist" and ReGreet never appears.
  # Re-enable after the desktop user is stable:
  # services.greetd.settings.initial_session = {
  #   command = "${config.programs.sway.package}/bin/sway";
  #   user = config.my.username;
  # };

  # wlr and gtk portals also come from wayland-session.nix; restated here so screencast
  # settings and Inhibit=none stay obvious. The patched xdpw binary is ExecStart only —
  # extraPortals keeps stock xdpw around for .portal metadata files.
  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings.screencast = screencastSettings;
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    xdgOpenUsePortal = true;
    config.sway = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      "org.freedesktop.impl.portal.Screenshot" = "wlr";
      # The gtk portal's Inhibit always "succeeds" and blocks Sway's idle-inhibit.
      "org.freedesktop.impl.portal.Inhibit" = "none";
    };
  };

  # Run the patched xdpw with WARN logging so "out of buffers" shows up when screencast freezes.
  # Do not set PipeWire link.max-buffers — the default of 16 is already fine.
  systemd.user.services.xdg-desktop-portal-wlr.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${xdpw}/libexec/xdg-desktop-portal-wlr --config=${xdpwConfig} --loglevel=WARN"
  ];
}
