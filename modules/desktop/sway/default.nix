# Sway session: wrapper, greetd, portals.
#
# NixOS `programs.sway` has no extraConfig — compositor DSL is /etc/sway/config
# (config.nix + config.d). This file is the session only.
#
# https://wiki.nixos.org/wiki/Sway
# https://github.com/swaywm/sway/wiki
# https://github.com/swaywm/sway/wiki/Running-programs-natively-under-wayland
# nixpkgs: nixos/modules/programs/wayland/sway.nix
{ config, lib, pkgs, ... }:
let
  # WebRTC (Meet / Zoom / Vesktop) can hold both of xdpw's default 2 PipeWire
  # buffers → freeze on last frame.
  # https://github.com/emersion/xdg-desktop-portal-wlr/issues/395
  # Raise-pool PR #396 was rejected (workaround, not a root fix). nixpkgs 0.8.1
  # still has XDPW_PWR_BUFFERS 2. Patch until a retry/scheduling fix lands.
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
    # Default extraPackages: brightnessctl foot grim pulseaudio swayidle swaylock wmenu.
    # Grim lives in config.nix; lock is effects; no laptop backlight / stock terminal.
    extraPackages = with pkgs; [
      pulseaudio # pactl only — daemon is PipeWire (`services.pipewire.pulse`)
      swayidle
      swaylock-effects
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # Blank Java windows without this (Arch wiki Java applications).
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XDG_CURRENT_DESKTOP=sway
      # AMD/RADV fullscreen artifacts under direct scanout.
      # https://github.com/swaywm/sway/issues/8498
      export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1
    '';
  };

  programs.dconf.enable = true; # GTK4; wayland-session.nix also mkDefault

  # Do not auto-login. If this user is missing (uid/rename / old generation),
  # greetd fails with "account does not exist" and you never see ReGreet.
  # Re-enable after the desktop user is stable:
  # services.greetd.settings.initial_session = {
  #   command = "${config.programs.sway.package}/bin/sway";
  #   user = config.my.username;
  # };

  # wlr + gtk portals also come from wayland-session.nix; restated so screencast
  # settings and Inhibit=none stay obvious. Patched xdpw is ExecStart only —
  # extraPortals keeps stock xdpw for .portal metadata.
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
      # gtk portal Inhibit always "succeeds" and blocks Sway idle-inhibit.
      # https://github.com/emersion/xdg-desktop-portal-wlr/blob/master/contrib/wlroots-portals.conf
      "org.freedesktop.impl.portal.Inhibit" = "none";
    };
  };

  # Patched xdpw; WARN so "out of buffers" shows on freeze.
  # Do not set PipeWire `link.max-buffers` — default is already 16.
  systemd.user.services.xdg-desktop-portal-wlr.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${xdpw}/libexec/xdg-desktop-portal-wlr --config=${xdpwConfig} --loglevel=WARN"
  ];
}
