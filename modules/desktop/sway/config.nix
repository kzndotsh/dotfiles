# Main /etc/sway/config — variables, appearance, and outputs. Keybinds and rules live in config.d/.
#
# Replaces NixOS mkOptionDefault (the stock sway package config). Per man 5 include, each file
# loads only once — do not glob config.d/* or nixos.conf would run twice. Include nixos.conf
# first because it sets up sway-session.target.
{ pkgs, self, ... }:
let
  wallpaper = self + /assets/wallpaper.png;
  wallpaperPath = "/etc/sway/wallpaper.png";
in
{
  imports = [
    ./keybinds.nix
    ./windows.nix
    ./autostart.nix
  ];

  environment = {
    etc."sway/wallpaper.png".source = wallpaper;
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

      # Shrink title text to nearly invisible (pango markup + tiny font). Titlebars still show
      # in stacking/tabbed layouts where man 5 says they always appear.
      font pango: monospace 0.001
      titlebar_border_thickness 1
      titlebar_padding 1

      gaps inner 1
      gaps outer 1
      smart_gaps on
      # default_border only affects new tiled windows. for_window [app_id] is Wayland-only —
      # XWayland apps match on class, not app_id (man 5 CRITERIA).
      default_border pixel 1
      default_floating_border pixel 1
      for_window [app_id=".*"] border pixel 1
      # --i3 hides the titlebar on tabbed/stacked with one child; smart_no_gaps combines
      # smart_borders no_gaps with hide_edge_borders none.
      hide_edge_borders --i3 smart_no_gaps
      # Mod+left drag, Mod+right resize — also works on tiled windows (config.in default).
      floating_modifier $mod normal
      workspace_auto_back_and_forth no

      # 4K panel at 2× scale keeps XWayland apps readable with integer scaling.
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
      # urgent styling only applies to XWayland — native Wayland has no urgency hint (man 5).
      client.urgent           #db4b4b #1a1b26 #f7768e #ff9e64 #db4b4b
      client.placeholder      #15161e #1a1b26 #c0caf5 #15161e #15161e
      # client.background is ignored (i3 compat) but kept for the palette reference.
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
