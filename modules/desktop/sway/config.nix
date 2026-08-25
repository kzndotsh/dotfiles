# /etc/sway/config — vars, look, outputs. Fragments imported below.
#
# Replaces NixOS mkOptionDefault (stock sway package /etc/sway/config).
# man 5 include: the same file is loaded only once. Do not glob config.d/*
# (nixos.conf would run twice). Include nixos.conf first (sway-session.target).
#
# Sample: https://github.com/swaywm/sway/blob/master/config.in
# https://man.archlinux.org/man/sway.5
# https://man.archlinux.org/man/sway-output.5
# https://wiki.archlinux.org/title/Sway
{ pkgs, self, ... }:
let
  wallpaper = self + /assets/wallpaper.jpg;
  wallpaperPath = "/etc/sway/wallpaper.jpg";
in
{
  imports = [
    ./keybinds.nix
    ./windows.nix
    ./autostart.nix
  ];

  environment = {
    etc."sway/wallpaper.jpg".source = wallpaper;
    systemPackages = with pkgs; [
      autotiling-rs
      bemoji
      cliphist
      glib.bin # gsettings
      grim
      imv
      mpv
      networkmanagerapplet
      playerctl
      polkit_gnome
      satty
      slurp
      swaynotificationcenter
      swayr
      udiskie
      waybar
      wl-clip-persist
      wl-color-picker
      wl-clipboard
      wlr-randr
      wtype
      xrandr # XWayland --primary (autostart.nix)
    ];
    etc."sway/config".text = ''
      set $mod Mod1
      set $term ghostty
      set $menu fuzzel
      set $lock swaylock

      include /etc/sway/config.d/nixos.conf

      # Hide title *text* (pango markup + tiny font). Titlebar still appears in
      # stacking/tabbed (man 5: title bar always shows in those layouts).
      font pango: monospace 0.001
      titlebar_border_thickness 1
      titlebar_padding 1

      gaps inner 1
      gaps outer 1
      smart_gaps on
      # default_border only affects *new* tiled windows. for_window [app_id] is
      # Wayland-only — XWayland uses class, not app_id (man 5 CRITERIA).
      default_border pixel 1
      default_floating_border pixel 1
      for_window [app_id=".*"] border pixel 1
      # --i3: hide titlebar on tabbed/stacked with one child; smart_no_gaps =
      # smart_borders no_gaps + hide_edge_borders none (man 5).
      hide_edge_borders --i3 smart_no_gaps
      # $mod+left drag, $mod+right resize. Also works on tiled (config.in).
      floating_modifier $mod normal
      workspace_auto_back_and_forth no

      # ─── Output (RX 6700 XT, 4K@144 scaled 2×) ───
      # Integer scale (man 5 / Arch HiDPI): XWayland is scaled and blurs.
      # scale_filter nearest = sharp upscale of lo-DPI buffers.
      # adaptive_sync off: VRR can flicker (sway-output(5)).
      # Tearing: output allow_tearing + window allow_tearing + max_render_time off
      # (Arch wiki Tearing; man 5 sway-output). Only while fullscreen.
      output "DP-3" {
          mode 3840x2160@144.001Hz
          pos 0 0
          scale 2.0
          scale_filter nearest
          adaptive_sync off
          subpixel rgb
          max_render_time off
          allow_tearing yes
          background ${wallpaperPath} fill
      }
      output "HDMI-A-1" disable
      output * background ${wallpaperPath} fill
      seat * xcursor_theme catppuccin-mocha-blue-cursors 24

      input * {
          repeat_delay 200
          repeat_rate 40
      }

      client.focused          #7aa2f7 #1a1b26 #c0caf5 #73daca #7aa2f7
      client.focused_inactive #292e42 #1a1b26 #545c7e #292e42 #292e42
      client.unfocused        #15161e #1a1b26 #a9b1d6 #414868 #15161e
      # urgent: XWayland only. Native Wayland has no urgency hint (man 5).
      client.urgent           #db4b4b #1a1b26 #f7768e #ff9e64 #db4b4b
      client.placeholder      #15161e #1a1b26 #c0caf5 #15161e #15161e
      # client.background is ignored (i3 compat). Kept for the palette dump.
      client.background       #1a1b26

      bar {
          swaybar_command ${pkgs.waybar}/bin/waybar
      }

      include /etc/sway/config.d/10-keybinds.conf
      include /etc/sway/config.d/20-windows.conf
      include /etc/sway/config.d/30-autostart.conf
    '';
  };

  system.userActivationScripts = {
    sway-config-link.text = ''
      mkdir -p $HOME/.config/sway
      ln -sfn /etc/sway/config $HOME/.config/sway/config
    '';
  };
}
