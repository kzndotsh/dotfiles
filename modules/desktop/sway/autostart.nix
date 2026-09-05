# /etc/sway/config.d/30-autostart.conf
# exec runs once per session; exec_always runs on every reload (gsettings, env, xrdb).
{ pkgs, self, ... }:
let
  wlVideoIdleInhibit = self.packages.${pkgs.stdenv.hostPlatform.system}.wl-video-idle-inhibit;
in
{
  environment.etc."sway/config.d/30-autostart.conf".text = ''
    exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
    # Must match modules/desktop/theme.nix dconf — TokyoNight-SE icons, not Papirus.
    exec_always gsettings set org.gnome.desktop.interface gtk-theme 'Tokyonight-Dark'
    exec_always gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    exec_always gsettings set org.gnome.desktop.interface icon-theme 'TokyoNight-SE'
    exec_always gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-mocha-blue-cursors'
    exec_always gsettings set org.gnome.desktop.interface cursor-size 24
    exec_always gsettings set org.gnome.desktop.interface font-name 'Inter Nerd Font 11'

    # autotiling-rs must be exec, not exec_always — two copies fight each other.
    exec autotiling-rs
    exec nm-applet --indicator
    exec blueman-applet
    exec --no-startup-id swayrd
    exec --no-startup-id udiskie --tray

    exec wl-clip-persist --clipboard regular --all-mime-type-regex '.*'
    exec wl-paste --type text --watch cliphist store
    exec wl-paste --type image --watch cliphist store
    # Bridge image clipboard to X11 for XWayland apps (xclip is in modules/packages).
    exec wl-paste --type image --watch xclip -selection clipboard -t image/png -i

    exec eval $(gnome-keyring-daemon --start --components=secrets)
    exec_always systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK I3SOCK XCURSOR_SIZE XCURSOR_THEME GNOME_KEYRING_CONTROL PATH XDG_DATA_DIRS XDG_RUNTIME_DIR XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME XDG_BIN_HOME CARGO_HOME RUSTUP_HOME
    exec_always dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK I3SOCK XCURSOR_SIZE XCURSOR_THEME GNOME_KEYRING_CONTROL PATH XDG_DATA_DIRS XDG_RUNTIME_DIR XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME XDG_BIN_HOME CARGO_HOME RUSTUP_HOME
    # Wine Xft settings from modules/wine (/etc/X11/Xresources).
    exec_always xrdb -load /etc/X11/Xresources
    exec systemctl --user start gvfs-udisks2-volume-monitor.service
    # XWayland click offset when no primary output is set. Needs output pos 0 0;
    # hotplug creates a new XWAYLANDn and drops primary.
    exec_always sh -c 'OUT=$(xrandr 2>/dev/null | grep -m1 XWAYLAND | awk "{print \$1}"); [ -n "$OUT" ] && xrandr --output "$OUT" --primary'

    # Hold idle-inhibit while any /dev/video* is open (Zoom/Meet/Discord camera).
    exec ${wlVideoIdleInhibit}/bin/wl-video-idle-inhibit

    # -w waits for each command. swaylock must use -f/--daemonize or idle DPMS never runs
    # (swayidle blocks until unlock). inhibit_idle rules in 20-windows.conf skip games/DAWs.
    exec swayidle -w \
      timeout 600 '$lock -f' \
      timeout 605 'swaymsg "output * power off"' \
      resume 'swaymsg "output * power on"' \
      before-sleep '$lock -f'
  '';
}
